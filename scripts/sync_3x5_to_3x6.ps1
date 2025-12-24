# PowerShell script to sync 3x5 to 3x6 keymap
# Called by sync_3x5_to_3x6.bat

$ErrorActionPreference = "Stop"

$KEYMAP_3X5 = "config\generic_3x5.keymap"
$KEYMAP_3X6 = "config\generic_3x6.keymap"

# Function to extract layer bindings
function Extract-Layer {
    param(
        [string]$Content,
        [string]$LayerName
    )
    
    # Match the layer block and extract bindings
    # Use non-greedy matching and explicit whitespace handling
    if ($Content -match "(?s)${LayerName}\s*\{[^}]*?bindings\s*=\s*<\s*([^>]+?)\s*>") {
        $bindings = $matches[1].Trim()
        # Split into lines and clean up
        $lines = $bindings -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        return $lines
    }
    return @()
}

# Function to convert 3x5 layer to 3x6 format
function Convert-To3x6 {
    param(
        [array]$Rows,
        [string]$LeftOuter1,
        [string]$LeftOuter2,
        [string]$LeftOuter3,
        [string]$RightOuter1,
        [string]$RightOuter2,
        [string]$RightOuter3,
        [string]$LeftThumb,
        [string]$RightThumb
    )
    
    if ($Rows.Count -lt 4) {
        throw "Invalid layer format: expected 4 rows, got $($Rows.Count)"
    }
    
    $result = @()
    $result += "$LeftOuter1  $($Rows[0])  $RightOuter1"
    $result += "$LeftOuter2  $($Rows[1])  $RightOuter2"
    $result += "$LeftOuter3  $($Rows[2])  $RightOuter3"
    $result += "                                       $LeftThumb  $($Rows[3])  $RightThumb"
    
    return $result
}

try {
    # Read the 3x5 keymap
    $content3x5 = Get-Content $KEYMAP_3X5 -Raw
    
    Write-Host "   Extracting base_layer..." -ForegroundColor Cyan
    $base3x5 = Extract-Layer $content3x5 "base_layer"
    
    Write-Host "   Extracting num_layer..." -ForegroundColor Cyan
    $num3x5 = Extract-Layer $content3x5 "num_layer"
    
    Write-Host "   Extracting sym_layer..." -ForegroundColor Cyan
    $sym3x5 = Extract-Layer $content3x5 "sym_layer"
    
    Write-Host "   Extracting fnc_layer..." -ForegroundColor Cyan
    $fnc3x5 = Extract-Layer $content3x5 "fnc_layer"
    
    Write-Host ""
    Write-Host "   Converting to 3x6 format..." -ForegroundColor Cyan
    
    # Convert layers
    $base3x6 = Convert-To3x6 $base3x5 "&kp TAB" "&kp LCTRL" "&kp LSHFT" "&kp BSPC" "&kp SQT" "&kp RSHFT" "&kp TAB" "&kp LGUI"
    $num3x6 = Convert-To3x6 $num3x5 "&kp ESC" "&kp F11" "&kp F12" "&kp DEL" "&kp TAB" "&kp INS" "&trans" "&trans"
    $sym3x6 = Convert-To3x6 $sym3x5 "&kp TILDE" "&kp LSHFT" "&kp LSHFT" "&kp BSPC" "&kp SQT" "&kp RSHFT" "&trans" "&trans"
    $fnc3x6 = Convert-To3x6 $fnc3x5 "&none" "&none" "&bootloader" "&none" "&none" "&none" "&none" "&none"
    
    # Build the new 3x6 keymap
    $output = @"
/*
 * Generic 3x6 Keymap
 * 
 * AUTO-SYNCED from generic_3x5.keymap
 * Core keys are synced automatically - outer columns defined here
 * 
 * Edit generic_3x5.keymap, then run: scripts\sync_3x5_to_3x6.bat
 */

#include <behaviors.dtsi>
#include <dt-bindings/zmk/bt.h>
#include <dt-bindings/zmk/ext_power.h>
#include <dt-bindings/zmk/keys.h>
#include <dt-bindings/zmk/outputs.h>

/ {
    behaviors {
        esc_q: escape_q {
            compatible = "zmk,behavior-hold-tap";
            #binding-cells = <2>;
            flavor = "tap-preferred";
            tapping-term-ms = <200>;
            quick-tap-ms = <150>;
            bindings = <&kp>, <&kp>;
        };
        
        bspc_p: backspace_p {
            compatible = "zmk,behavior-hold-tap";
            #binding-cells = <2>;
            flavor = "tap-preferred";
            tapping-term-ms = <200>;
            quick-tap-ms = <150>;
            bindings = <&kp>, <&kp>;
        };
    };

    combos {
        compatible = "zmk,combos";

        combo_unlock {
            timeout-ms = <50>;
            key-positions = <0 1>;
            bindings = <&studio_unlock>;
            layers = <0>;
        };

        combo_fnc {
            timeout-ms = <200>;
            key-positions = <36 41>;
            bindings = <&mo 3>;
        };
    };

    keymap {
        compatible = "zmk,keymap";

        base_layer {
            display-name = "Base";
            bindings = <
$($base3x6 -join "`n")
            >;
        };

        num_layer {
            display-name = "Numbers";
            bindings = <
$($num3x6 -join "`n")
            >;
        };

        sym_layer {
            display-name = "Symbols";
            bindings = <
$($sym3x6 -join "`n")
            >;
        };

        fnc_layer {
            display-name = "Function";
            bindings = <
$($fnc3x6 -join "`n")
            >;
        };
    };
};
"@
    
    # Write the output
    Set-Content -Path $KEYMAP_3X6 -Value $output -NoNewline
    
    Write-Host "   ✅ Updated $KEYMAP_3X6" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
