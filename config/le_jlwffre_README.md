# le jlwffre ZMK Config

ZMK firmware config for the [le jlwffre](https://www.jlw-kb.com/products/le-jlwffre) — a BLE drop-in hotswap PCB for the Le Chiffre 34-key keyboard by JLW Keyboards.

## Hardware

- nRF52840 SoC (onboard controller, no separate MCU board needed)
- 34 keys (3x10 + 4 thumb keys)
- Optional EC11 rotary encoder
- HAC-006 (Nintendo Switch Joycon) battery connector
- USB-C for charging and firmware flashing

## Flashing Firmware

Double-tap the reset button to enter bootloader. A USB drive will appear — drag and drop the `.uf2` file onto it.

## Layers

### Layer 0 — Base (QWERTY)

```
Q  W  E  R  T    Y  U  I  O  P
A  S  D  F  G    H  J  K  L  '
Z  X  C  V  B    N  M  ,  .  /
      LCTL  RET    SPC  FN
```

`FN` = hold right thumb for layer 1 (Numbers)

### Layer 1 — Numbers

```
1  2  3  4  5    6  7  8  9  0
!  @  #  $  %    ^  &  *  (  )
-  -  -  -  -    -  -  -  -  -
      ---  ---    ---  ---
```

### Layer 2 — Functions

Access: (how you reach layer 2 — update this if you add a hold)

```
F1  F2  F3  F4  F5      F6      F7      F8      F9   F10
-   -   -   -   -       BT0     BT1     BT2     -    BTCLR
-   -   -   -   SOFF    -       -       -       -    -
        ---     ---             ---     ---
```

`SOFF` = soft off (puts keyboard to sleep)
`BT0/1/2` = select Bluetooth profile
`BTCLR` = clear current Bluetooth pairing

## Combos

| Combo | Keys (positions) | Action |
|-------|-----------------|--------|
| Backspace | P + O (8+9) | Backspace |
| Escape | Q + W (0+1) | Escape |
| Tab | A + S (10+11) | Tab |
| Ctrl+Z | Z + X (20+21) | Undo |
| Ctrl+X | Z + C (21+22) | Cut |
| Ctrl+C | C + V (22+23) | Copy |
| Ctrl+V | V + B (23+24) | Paste |
| Ctrl+A | A + Z (10+21) | Select All |
| Soft Off | Q + P (0+9) on layer 2 | Sleep |

## Power / Sleep

| Feature | Value |
|---------|-------|
| Idle timeout | 1 minute |
| Deep sleep timeout | 15 minutes |
| Hardware soft off | Hold AND-gate combo ~5 seconds (see board DTS) |
| Wake from soft off | Press the hardware wakeup key or reset button |

## Bluetooth

Up to 3 profiles supported (`BT0`, `BT1`, `BT2`). Switch profiles from the Functions layer.

To clear a pairing: switch to the profile you want to clear, then press `BTCLR`.

## Pairing Issues

If the keyboard isn't connecting, flash `settings_reset` firmware first:
1. Add `- board: le_jlwffre` with `shield: settings_reset` to `build.yaml` temporarily
2. Flash to the keyboard
3. Re-flash your normal firmware
4. Re-pair on your device

## Files

| File | Purpose |
|------|---------|
| `config/le_jlwffre.keymap` | Keymap and combos |
| `config/le_jlwffre.conf` | Kconfig options (sleep, BT, etc.) |
| `config/le_jlwffre.json` | Layout metadata for keymap-editor |
| `config/west.yml` | West manifest (includes JLW board module) |
| `build.yaml` | GitHub Actions build targets |

## Keymap Editor

This config supports [nickcoutsos/keymap-editor](https://github.com/nickcoutsos/keymap-editor).
The `config/le_jlwffre.json` file provides the physical layout metadata.
