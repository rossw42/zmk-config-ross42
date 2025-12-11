# Implementation Plan

- [x] 1. Create shield directory structure and metadata





  - [x] 1.1 Create the boards/shields/hypergolic/ directory


    - Create empty directory structure for the new shield
    - _Requirements: 1.2_
  - [x] 1.2 Create hypergolic.zmk.yml metadata file


    - Define shield id, name, type, requires, features (keys, studio), and siblings
    - _Requirements: 1.2_
  - [x] 1.3 Create Kconfig.shield file


    - Define SHIELD_HYPERGOLIC_LEFT and SHIELD_HYPERGOLIC_RIGHT config options
    - _Requirements: 1.1_
  - [x] 1.4 Create Kconfig.defconfig file


    - Set ZMK_SPLIT default, keyboard name, and central role for left half
    - _Requirements: 2.4_

- [x] 2. Create physical layout definition for ZMK Studio





  - [x] 2.1 Create hypergolic-layouts.dtsi with keys property


    - Include physical_layouts.dtsi header
    - Define physical_layout0 with compatible, display-name, kscan, and transform references
    - Add keys property with 34 key_physical_attrs entries for 3x5+2 split layout
    - Use centi-keyunit coordinates matching standard Cradio/Ferris layout
    - _Requirements: 1.1, 1.4_

- [x] 3. Create main shield definition





  - [x] 3.1 Create hypergolic.dtsi with kscan and matrix transform


    - Include hypergolic-layouts.dtsi
    - Define chosen node with zmk,kscan and zmk,physical-layout references
    - Define default_transform with 34 RC entries (17 per half)
    - Define kscan0 with direct GPIO scanning
    - Copy GPIO pin mappings from existing hypergarlic shield
    - Configure UART settings
    - _Requirements: 1.3, 3.1, 3.2_

- [x] 4. Create half-specific overlay files





  - [x] 4.1 Create hypergolic_left.overlay


    - Include hypergolic.dtsi
    - Configure pinctrl for UART with TX=0,6 and RX=0,8
    - _Requirements: 2.1_
  - [x] 4.2 Create hypergolic_right.overlay


    - Include hypergolic.dtsi
    - Set col-offset=17 on default_transform
    - Configure pinctrl for UART with TX=0,8 and RX=0,6 (swapped)
    - _Requirements: 2.2, 3.2_

- [x] 5. Create configuration files for wired split





  - [x] 5.1 Create hypergolic_left.conf


    - Enable ZMK_SPLIT and ZMK_SPLIT_ROLE_CENTRAL
    - Disable ZMK_SPLIT_BLE, BT, and ZMK_BLE
    - _Requirements: 2.3, 2.4_
  - [x] 5.2 Create hypergolic_right.conf

    - Enable ZMK_SPLIT, disable ZMK_SPLIT_ROLE_CENTRAL
    - Disable ZMK_SPLIT_BLE, BT, and ZMK_BLE
    - _Requirements: 2.3, 2.4_

- [x] 6. Create default keymap with ZMK Studio support





  - [x] 6.1 Create config/hypergolic.keymap


    - Base on existing cradio.keymap structure
    - Add studio_unlock combo on keys 0+1 (Q+W)
    - Add display-name property to each layer
    - Include Base, Numbers, Symbols, and Function layers
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 7. Update build configuration





  - [x] 7.1 Update build.yaml with hypergolic shield entries


    - Add hypergolic_left entry with nice_nano_v2 board, studio-rpc-usb-uart snippet, and -DCONFIG_ZMK_STUDIO=y cmake arg
    - Add hypergolic_right entry with nice_nano_v2 board (no studio config needed)
    - _Requirements: 4.1, 4.2_

- [x] 8. Final Checkpoint - Verify all files are correct





  - Ensure all files are created with correct content
  - Verify file structure matches design
  - Ask the user if questions arise
