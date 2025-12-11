# Requirements Document

## Introduction

This document specifies the requirements for adding ZMK Studio support to the HyperGolic keyboard. The HyperGolic is a 34-key split keyboard (3x5 layout with 2 thumb keys per side) that currently uses the Cradios shield configuration. ZMK Studio enables runtime keymap editing without reflashing firmware, providing a more user-friendly configuration experience.

The HyperGolic keyboard uses wired UART communication between halves and connects to the host via USB. This feature will create a dedicated shield with proper physical layout definitions required for ZMK Studio compatibility.

## Glossary

- **ZMK Studio**: A runtime configuration tool that allows users to modify keymaps without reflashing firmware
- **Shield**: A ZMK configuration that defines the hardware interface for a keyboard, including GPIO pin mappings and matrix transforms
- **Physical Layout**: A devicetree entity that describes the physical key positions, required for ZMK Studio support
- **Matrix Transform**: Defines how physical key positions map to logical keymap positions
- **kscan**: Keyboard scan driver that detects key presses
- **UART**: Universal Asynchronous Receiver-Transmitter, used for wired communication between split keyboard halves
- **Central/Peripheral**: In split keyboards, the central half connects to the host and runs the keymap; the peripheral half sends key events to the central
- **nice!nano**: A Pro Micro-compatible nRF52840 development board commonly used in custom keyboards
- **studio_unlock**: A ZMK behavior that unlocks the keyboard for ZMK Studio editing

## Requirements

### Requirement 1

**User Story:** As a keyboard user, I want to create a new HyperGolic shield with ZMK Studio support, so that I can edit my keymap at runtime without reflashing firmware.

#### Acceptance Criteria

1. WHEN the HyperGolic shield is built with ZMK Studio enabled THEN the Shield SHALL include a physical layout definition with the keys property describing all 34 key positions
2. WHEN the shield files are created THEN the Shield SHALL include a zmk.yml metadata file with the studio feature flag enabled
3. WHEN the shield is configured THEN the Shield SHALL reference the physical layout in the chosen node instead of a matrix transform
4. WHEN the physical layout is defined THEN the Shield SHALL specify accurate x, y coordinates for each key in centi-keyunit format matching the 3x5+2 split layout

### Requirement 2

**User Story:** As a keyboard user, I want the HyperGolic shield to maintain wired split communication, so that I can use my keyboard reliably without Bluetooth.

#### Acceptance Criteria

1. WHEN the shield is configured for the left half THEN the Shield SHALL enable UART communication with appropriate TX/RX pin configuration
2. WHEN the shield is configured for the right half THEN the Shield SHALL enable UART communication with swapped TX/RX pins for proper half-to-half communication
3. WHEN the shield configuration files are created THEN the Shield SHALL disable Bluetooth and enable wired split mode via configuration options
4. WHEN the left half is designated as central THEN the Shield SHALL set ZMK_SPLIT_ROLE_CENTRAL appropriately for each half

### Requirement 3

**User Story:** As a keyboard user, I want the HyperGolic shield to use the correct GPIO pin mappings, so that all keys register correctly.

#### Acceptance Criteria

1. WHEN the kscan driver is configured THEN the Shield SHALL use direct GPIO scanning with the same pin mappings as the existing hypergarlic shield
2. WHEN the matrix transform is defined THEN the Shield SHALL map the 34 keys (17 per half) with correct column offsets for the right half
3. WHEN key positions are defined THEN the Shield SHALL maintain the same logical key ordering as the existing cradio keymap for compatibility

### Requirement 4

**User Story:** As a keyboard user, I want to build the HyperGolic firmware through GitHub Actions, so that I can easily obtain updated firmware files.

#### Acceptance Criteria

1. WHEN the build.yaml is updated THEN the Build Configuration SHALL include entries for hypergolic_left with the studio-rpc-usb-uart snippet and ZMK_STUDIO cmake argument
2. WHEN the build.yaml is updated THEN the Build Configuration SHALL include an entry for hypergolic_right without Studio configuration (peripheral does not need Studio)
3. WHEN the build completes THEN the Build System SHALL produce UF2 firmware files for both halves

### Requirement 5

**User Story:** As a keyboard user, I want the default keymap to include a studio_unlock binding, so that I can enable ZMK Studio editing mode.

#### Acceptance Criteria

1. WHEN the keymap is created THEN the Keymap SHALL include a combo or key binding for the studio_unlock behavior
2. WHEN the keymap is created THEN the Keymap SHALL include display-name properties for each layer for better ZMK Studio visibility
3. WHEN the keymap is created THEN the Keymap SHALL be compatible with the existing cradio keymap structure to ease migration
