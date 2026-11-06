# Flash a UF2 to a nice!nano (Adafruit UF2 bootloader) and report timing.
# Usage: .\flash_uf2.ps1 -Uf2 <path> [-TimeoutSec 120]
param(
    [Parameter(Mandatory)][string]$Uf2,
    [int]$TimeoutSec = 120
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path $Uf2)) { throw "Not found: $Uf2" }
$size = (Get-Item $Uf2).Length
Write-Host ("Firmware: {0}  ({1} bytes, {2} UF2 blocks)" -f (Split-Path $Uf2 -Leaf), $size, ($size/512))

Write-Host "Waiting up to $TimeoutSec s for a UF2 bootloader drive (double-tap RESET on the board now)..."
$deadline = (Get-Date).AddSeconds($TimeoutSec)
$vol = $null
while ((Get-Date) -lt $deadline) {
    $vol = Get-Volume -ErrorAction SilentlyContinue | ? { $_.FileSystemLabel -match 'NICENANO|NICE_NANO|UF2|RPI-RP2|XIAO|BOOT' -and $_.DriveLetter }
    if ($vol) { break }
    Start-Sleep -Milliseconds 300
}
if (-not $vol) { throw "No UF2 bootloader drive appeared." }
$drive = "$($vol.DriveLetter):"
Write-Host "Found $drive  label=$($vol.FileSystemLabel)"
$info = Get-Content "$drive\INFO_UF2.TXT" -ErrorAction SilentlyContinue
if ($info) { Write-Host "--- INFO_UF2.TXT ---"; $info | % { Write-Host "  $_" } }

# Single buffered write via the .NET stream, so the whole file is queued to the
# device in one go; the bootloader reboots itself when the last block lands.
$dest = Join-Path $drive (Split-Path $Uf2 -Leaf)
$sw = [Diagnostics.Stopwatch]::StartNew()
try {
    $bytes = [IO.File]::ReadAllBytes($Uf2)
    $fs = [IO.File]::Open($dest, 'Create', 'Write', 'None')
    $fs.Write($bytes, 0, $bytes.Length)
    $fs.Flush($true)
    $fs.Close()
    Write-Host ("Copy returned OK after {0:N2} s" -f $sw.Elapsed.TotalSeconds)
} catch {
    Write-Host ("Copy raised after {0:N2} s: {1}" -f $sw.Elapsed.TotalSeconds, $_.Exception.Message)
    Write-Host "(a drive-vanished error here is normal IF enough time elapsed for the full write)"
}

# Wait for the drive to go away (device rebooting into the new firmware)
$gone = $false
$deadline = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $deadline) {
    if (-not (Test-Path "$drive\")) { $gone = $true; break }
    Start-Sleep -Milliseconds 200
}
Write-Host ("Drive {0} after {1:N2} s total" -f ($(if ($gone) {'gone'} else {'STILL PRESENT (flash probably did not take)'}), $sw.Elapsed.TotalSeconds))
if ($size -gt 100000 -and $sw.Elapsed.TotalSeconds -lt 1.2) {
    Write-Warning "That was too fast for $size bytes - the bootloader most likely rejected the image and rebooted the OLD firmware."
}
