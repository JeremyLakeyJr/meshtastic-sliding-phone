# Bill of Materials — Meshtastic Sliding Phone

## Electronics

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 1 | Heltec WiFi LoRa 32 V4 | ESP32-S3 + SX1262 LoRa + built-in 0.96" OLED, 7 capacitive touch pins | Main controller board (51.7 × 25.4 mm, ≈52 × 26 mm) |
| 1 | M5Stack CardKB | I²C QWERTY keyboard, 58.2×27.6 mm, 3.3 V/5 V | Connects to Heltec V4 via I²C |
| 1 | LiPo Battery | 3.7 V, slim pouch ~50×40×5 mm, ≥ 800 mAh | JST PH 2.0 or JST 1.25 mm 2-pin connector |
| 1 | LoRa Antenna | SMA, 868 MHz or 915 MHz (region-dependent) | Stubby or flexible whip style |
| 1 | GPS Antenna | IPX/U.FL ceramic patch | Optional — Heltec V4 has no on-board GPS |

## Sliding Mechanism — Neodymium Disc Magnets

Eight magnets total; install with poles oriented so opposing pairs **attract**.
Verify orientation before gluing: wrong polarity will repel instead of snap.

| Qty | Component | Specification | Location |
|-----|-----------|--------------|----------|
| 4 | Neodymium disc magnet | **5 mm dia × 2 mm thick, N42 grade** | Bottom shell — 2 × closed snap, 2 × open snap |
| 4 | Neodymium disc magnet | **5 mm dia × 2 mm thick, N42 grade** | Keyboard tray — 2 × detent pockets |

> **Magnetic gap guarantee**: Each pocket is 2.5 mm deep for a 2 mm magnet (0.5 mm recess per face).
> Combined with the 1 mm rail standoff the guaranteed air gap between opposing faces is **2.0 mm** —
> the magnets will **never** physically touch. The magnetic force at 2 mm gap produces a
> noticeable snap (~1 N) that clearly marks the open and closed positions.

## Mechanical

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 8 | M2×8 mm screws | Pan head, Phillips or hex socket | PCB mounting + shell join |
| 8 | M2 hex nuts | Standard | Or use heat-set inserts |
| 4 | M2 heat-set inserts | 3.5 mm OD × 4 mm length | Optional — replaces nuts |
| 1 | Silicone grease | Small tube, PTFE-based | Apply to rail runners for smooth sliding |

## 3D Printed Parts

| Qty | Part | Material | Infill | Supports |
|-----|------|----------|--------|----------|
| 1 | Top Shell (`top_shell.scad`) | PETG / ASA | 20 % | No |
| 1 | Bottom Shell (`bottom_shell.scad`) | PETG / ASA | 25 % | No |
| 1 | Keyboard Tray (`keyboard_tray.scad`) | PETG / ASA | 30 % | No — print top face DOWN |
| 1 | Battery Cover (`battery_cover.scad`) | PETG / ASA | 100 % | No |
| 1 | Antenna Mount (`antenna_mount.scad`) | PETG / ASA | 40 % | No |

### Print orientation notes
- **Top shell**: display face down — button recesses and viewport need no support.
- **Bottom shell**: battery face down — flat bottom for a stable first layer.
- **Keyboard tray**: top face (rail runners) down — runners print as vertical columns, zero support needed.

## Assembly sequence

1. Press-fit magnets into the bottom-shell pockets (check polarity!).
2. Press-fit magnets into the keyboard-tray pockets (opposing pole faces up).
3. Apply a thin coat of PTFE grease to the rail runners.
4. Slide the keyboard tray in from the **−X (left) end** of the bottom shell.
   Hold the phone landscape (120 mm wide, 74 mm tall) — the keyboard slides
   downward to expose the CardKB, just like a Nokia N900.
5. Snap the tray closed — the magnetic click should be clearly perceptible.
6. Assemble electronics: mount Heltec V4 PCB (51.7 × 25.4 mm) with M2 screws,
   route I²C cable from CardKB.  The V4's 7 touch pins can be connected to an
   optional capacitive touch overlay panel placed over the OLED viewport.
7. Close and screw the top shell onto the bottom shell (four corner M2 screws).

## Optional Add-ons

| Component | Purpose |
|-----------|---------|
| Wrist strap loop | Attach lanyard/strap for field use |
| Belt clip adapter | Clip to belt or MOLLE webbing |
| Capacitive touch overlay | 23 × 13 mm panel over OLED viewport; wire to V4 touch pins |
| Screen protector film | Cut to 23×13 mm for OLED/touch viewport |
| Rubber bumpers (4×) | Stick-on feet for table use |
| USB-C cable (short) | Charging / firmware flash |
| External GPS module | Add GPS capability (Heltec V4 has no on-board GPS) |

## Sourcing

- **Heltec WiFi LoRa 32 V4**: [Heltec Official Store](https://heltec.org/project/wifi-lora-32-v4/)
- **M5Stack CardKB**: [M5Stack Official Store](https://shop.m5stack.com/products/cardkb-mini-keyboard-programmable-unit-v1-1-mega328p)
- **Slim LiPo battery**: Search for "3.7V slim flat lipo 40×50mm" on your local electronics supplier
- **5 mm × 2 mm N42 magnets**: Amazon / AliExpress — search "5mm x 2mm neodymium disc magnets"
- **M2 hardware**: Amazon, McMaster-Carr, local hardware store
- **PETG filament**: Prusament, eSun, Hatchbox or equivalent
