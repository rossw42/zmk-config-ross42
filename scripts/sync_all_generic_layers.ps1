# PowerShell script to sync all generic layers
# Called by sync_all_generic_layers.bat

$ErrorActionPreference = "Stop"

$KEYMAP_3X5 = "config\generic_3x5.keymap"
$KEYMAP_3X6 = "config\generic_3x6.keymap"
$DTSI_3X5 = "config\generic_3x5_layers.dtsi"
$DTSI_3X6 = "config\generic_3x6_layers.dtsi"

# Function to extract layer bindings
function Extract-Layer {
    param(
        [string]$Content,
        [string]$LayerName
    )
    
    # Match the layer block and extract bindings
    # Use a more robust pattern that handles whitespace better
    if ($Content -match "(?s)${LayerName}\s*\{[^}]*?bindings\s*=\s*<\s*([^>]+?)\s*>") {
        $bindings = $matches[1].Trim()
        # Split into lines, clean up, and add line continuation
        $lines = $bindings -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        
        # Ensure we have at least one line
        if ($lines.Count -eq 0) {
            return ""
        }
        
        # Add backslash continuation to all lines except the last
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($i -lt $lines.Count - 1) {
                $lines[$i] = $lines[$i] + "  \"
            }
        }
        return $lines -join "`n"
    }
    return ""
}

try {
    # ===== Process 3x5 keymap =====
    Write-Host "   Extracting 3x5 layers..." -ForegroundColor Cyan
    
    $content3x5 = Get-Content $KEYMAP_3X5 -Raw
    
    $base3x5 = Extract-Layer $content3x5 "base_layer"
    $num3x5 = Extract-Layer $content3x5 "num_layer"
    $sym3x5 = Extract-Layer $content3x5 "sym_layer"
    $fnc3x5 = Extract-Layer $content3x5 "fnc_layer"
    
    # Build 3x5 .dtsi file
    $output3x5 = @"
/*
 * Generic 3x5 Layer Definitions
 * 
 * This file is auto-generated from generic_3x5.keymap
 * Edit generic_3x5.keymap with keymap-editor, then run: scripts\sync_all_generic_layers.bat
 * 
 * IMPORTANT: Include generic_3x5_behaviors.dtsi BEFORE this file in your board keymap
 * 
 * Example:
 *   #include "generic_3x5_behaviors.dtsi"
 *   #include "generic_3x5_layers.dtsi"
 */

// Base Layer - QWERTY
#define BASE_LAYER \
$base3x5

// Numbers Layer - Numbers, F-keys, Navigation
#define NUM_LAYER \
$num3x5

// Symbols Layer - All symbols and brackets
#define SYM_LAYER \
$sym3x5

// Function Layer - Bluetooth, system controls, media
#define FNC_LAYER \
$fnc3x5
"@
    
    Set-Content -Path $DTSI_3X5 -Value $output3x5 -NoNewline
    Write-Host "   ✅ Created $DTSI_3X5" -ForegroundColor Green
    Write-Host ""
    
    # ===== Process 3x6 keymap =====
    Write-Host "   Extracting 3x6 layers..." -ForegroundColor Cyan
    
    $content3x6 = Get-Content $KEYMAP_3X6 -Raw
    
    $base3x6 = Extract-Layer $content3x6 "base_layer"
    $num3x6 = Extract-Layer $content3x6 "num_layer"
    $sym3x6 = Extract-Layer $content3x6 "sym_layer"
    $fnc3x6 = Extract-Layer $content3x6 "fnc_layer"
    
    # Build 3x6 .dtsi file
    $output3x6 = @"
/*
 * Generic 3x6 Layer Definitions
 * 
 * This file is auto-generated from generic_3x6.keymap
 * Edit generic_3x6.keymap with keymap-editor, then run: scripts\sync_all_generic_layers.bat
 * 
 * Uses the same macro names as 3x5 for consistency
 * 
 * Layout: 3 rows of 6 keys per side + 3 thumb keys per side = 42 keys
 */

// Base Layer - QWERTY with outer columns
#define BASE_LAYER \
$base3x6

// Numbers Layer - Numbers, F-keys, Navigation
#define NUM_LAYER \
$num3x6

// Symbols Layer - All symbols and brackets
#define SYM_LAYER \
$sym3x6

// Function Layer - Bluetooth, system controls, media
#define FNC_LAYER \
$fnc3x6
"@
    
    Set-Content -Path $DTSI_3X6 -Value $output3x6 -NoNewline
    Write-Host "   ✅ Created $DTSI_3X6" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
