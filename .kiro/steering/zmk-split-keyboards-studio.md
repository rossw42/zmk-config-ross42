---
inclusion: auto
---

# ZMK Split Keyboards with Studio Support

This steering document provides critical guidance for working with ZMK split keyboards, particularly when adding ZMK Studio support.

## Critical Configuration Rules

### Split Keyboard Basics

**Official ZMK Documentation**: https://zmk.dev/docs/features/split-keyboards

1. **Central vs Peripheral Roles**
   - Central (usually left): Handles keymap logic, communicates with host devices
   - Peripheral (usually right): Only communicates with central, never with host
   - Peripherals do NOT advertise as Bluetooth devices

2. **Required Kconfig Settings**
   - `CONFIG_ZMK_SPLIT=y` - Enables split keyboard support
   - `CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y` - Sets central role (left side)
   - `CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n` - Sets peripheral role (right side)
   - `CONFIG_ZMK_SPLIT_BLE=y` - Enables BLE split communication

3. **Kconfig.defconfig Structure**
   ```
   if SHIELD_<KEYBOARD>_LEFT
       config ZMK_KEYBOARD_NAME
           default "<KeyboardName>"
       
       config ZMK_SPLIT_ROLE_CENTRAL
           default y
   endif
   
   if SHIELD_<KEYBOARD>_LEFT || SHIELD_<KEYBOARD>_RIGHT
       config ZMK_SPLIT
           default y
   endif
   ```

### ZMK Studio Support for Split Keyboards

**CRITICAL**: Studio should ONLY be enabled on the central (left) side.

#### Working Configuration Pattern

**Left Side (`<keyboard>_left.conf`):**
```properties
# Split configuration
CONFIG_ZMK_SPLIT=y
CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y
CONFIG_ZMK_SPLIT_BLE=y

# Bluetooth
CONFIG_BT=y
CONFIG_ZMK_BLE=y

# Battery reporting (optional)
CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_FETCHING=y
CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_PROXY=y

# Enable ZMK Studio on central side only
CONFIG_ZMK_STUDIO=y
```

**Right Side (`<keyboard>_right.conf`):**
```properties
# Split configuration
CONFIG_ZMK_SPLIT=y
CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
CONFIG_ZMK_SPLIT_BLE=y

# Bluetooth
CONFIG_BT=y
CONFIG_ZMK_BLE=y

# Battery reporting (optional)
CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_FETCHING=y
CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_PROXY=y

# DO NOT enable Studio on peripheral
```

**build.yaml:**
```yaml
- board: nice_nano/nrf52840
  shield: <keyboard>_left
  snippet: studio-rpc-usb-uart  # Studio RPC via USB
- board: nice_nano/nrf52840
  shield: <keyboard>_right
  # No snippet on right side
```

### Common Mistakes to Avoid

1. **DO NOT** enable `CONFIG_ZMK_STUDIO=y` on the peripheral (right) side
2. **DO NOT** use deprecated config names like `CONFIG_ZMK_SPLIT_BLE_ROLE_CENTRAL`
3. **DO NOT** add Studio snippet to the right side in build.yaml
4. **DO NOT** create a shared `.conf` file with Studio enabled for both sides

### Troubleshooting Split Connection Issues

#### Symptoms
- Right half doesn't connect to left
- Keyboard not discoverable via Bluetooth
- Split worked before but broke after config changes

#### Solution: Settings Reset Procedure

1. **Add settings_reset to build.yaml:**
   ```yaml
   - board: nice_nano/nrf52840
     shield: settings_reset
   ```

2. **Flash procedure:**
   - Flash `settings_reset` to LEFT half
   - Flash `settings_reset` to RIGHT half
   - Flash `<keyboard>_left` firmware to LEFT half
   - Flash `<keyboard>_right` firmware to RIGHT half

3. **Power cycle:**
   - Turn off both halves
   - Turn on LEFT half first, wait 10 seconds
   - Turn on RIGHT half
   - Wait 30 seconds for pairing

4. **Re-pair with computer:**
   - Remove/forget keyboard from Bluetooth settings
   - Pair fresh

### Studio Usage with Split Keyboards

**Connection Method:**
- Connect LEFT half via USB cable
- ZMK Studio communicates over USB
- Split BLE continues to work between halves
- Keyboard can still advertise to computer via Bluetooth

**Wireless Operation:**
- Unplug USB cable
- Keyboard automatically switches to Bluetooth output
- Both halves communicate via BLE split
- Computer connects to left half via Bluetooth

### File Structure for Split Keyboards

Required files:
```
boards/shields/<keyboard>/
├── Kconfig.defconfig          # Split role configuration
├── Kconfig.shield             # Shield definitions
├── <keyboard>.dtsi            # Shared devicetree
├── <keyboard>.zmk.yml         # Metadata (include "studio" feature)
├── <keyboard>_left.overlay    # Left side pins
├── <keyboard>_right.overlay   # Right side pins
├── <keyboard>_left.conf       # Left side config (Studio enabled)
└── <keyboard>_right.conf      # Right side config (Studio disabled)
```

### Verification Checklist

Before committing split keyboard changes:

- [ ] `CONFIG_ZMK_SPLIT_ROLE_CENTRAL` is used (not deprecated names)
- [ ] Studio only enabled on left side conf
- [ ] Studio snippet only on left side in build.yaml
- [ ] Right side has NO Studio configuration
- [ ] Kconfig.defconfig properly sets central role for left
- [ ] Both sides have BLE enabled
- [ ] Settings reset build available for troubleshooting

### Reference Implementation

See `boards/shields/hillside48/` for a working example of split keyboard with Studio support.

### Additional Resources

- ZMK Split Keyboards: https://zmk.dev/docs/features/split-keyboards
- ZMK Split Config: https://zmk.dev/docs/config/split
- ZMK Studio: https://zmk.dev/docs/features/studio
- Connection Issues: https://zmk.dev/docs/troubleshooting/connection-issues
