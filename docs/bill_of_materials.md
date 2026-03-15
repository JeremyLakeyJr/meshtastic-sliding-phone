# Bill of Materials — Meshtastic Sliding Phone

## Electronics

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 1 | Heltec WiFi LoRa 32 V4 | ESP32-S3 + SX1262 LoRa + built-in 0.96" OLED, 7 capacitive touch pins | Main controller board (51.7 × 25.4 mm, ≈52 × 26 mm) |
| 1 | M5Stack CardKB v1.1 | I²C QWERTY keyboard, 88×54×7 mm, 3.3 V/5 V | Connects to Heltec V4 via I²C (SDA/SCL) |
| 1 | LiPo Battery | 3.7 V, MakerFocus 3000 mAh flat pouch ~71×51×9 mm | JST PH 2.0 or JST 1.25 mm 2-pin connector |
| 1 | LoRa Antenna | SMA, 868 MHz or 915 MHz (region-dependent) | Stubby or flexible whip style |
| 1 | GPS Antenna | IPX/U.FL ceramic patch | Optional — Heltec V4 has no on-board GPS |

## Sliding Mechanism — Neodymium Disc Magnets

Six magnets total; install with poles oriented so opposing pairs **attract**.
Verify orientation before pressing in: wrong polarity will repel instead of snap.

| Qty | Component | Specification | Location |
|-----|-----------|--------------|----------|
| 4 | Neodymium disc magnet | **10 mm dia × 4 mm thick, N35 grade** | Top shell — 2 × closed-snap pockets (body X=+38 mm), 2 × open-snap pockets (body X=−39 mm) |
| 2 | Neodymium disc magnet | **10 mm dia × 4 mm thick, N35 grade** | Keyboard tray — 2 × detent pockets (tray X=+32 mm) |

> **Magnet pocket spec**: Each pocket bore is 10.3 mm diameter × 3.6 mm deep with a 0.6 mm retention lip
> (entrance narrows to 9.1 mm). Press the 10 mm magnet past the lip — the FDM wall deflects slightly
> and springs back, locking the magnet in place. The magnet sits 0.4 mm proud of the face for better
> magnetic contact with the opposing pocket.
>
> **Detent offset**: Top-shell pockets are displaced ±6 mm in the slide direction (X) relative to the
> tray pockets. This offset creates an X-component attraction force that actively pulls the tray into
> each snap position rather than just providing a Z-axis normal force.

## Mechanical

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 8 | M2×8 mm screws | Pan head, Phillips or hex socket | PCB mounting + shell join |
| 8 | M2 hex nuts | Standard | Or use heat-set inserts |
| 4 | M2 heat-set inserts | 3.5 mm OD × 4 mm length | Optional — replaces nuts |
| 1 | Silicone grease | Small tube, PTFE-based | Apply to rail runners for smooth sliding |

## 3D Printed Parts

| Qty | Part | File | Material | Infill | Supports |
|-----|------|------|----------|--------|----------|
| 1 | Top Shell | `top_shell.scad` | PETG / ASA | 20–25% | No |
| 1 | Keyboard Tray | `keyboard_tray.scad` | PETG / ASA | 30% | No — print top face DOWN |
| 1 | Antenna Mount | `antenna_mount.scad` | PETG / ASA | 40% | No |

> `bottom_shell.scad` is an alias for `keyboard_tray.scad` — they produce the same part.
> `main_body.scad` is a backward-compatible alias for `top_shell.scad`.

### Print orientation notes
- **Top shell**: display face down — button recesses and viewport print cleanly without support.
- **Keyboard tray**: top face (rail grooves) down — rectangular groove walls print as clean vertical layers; zero support needed.

## Assembly sequence

1. Press-fit magnets into the top-shell pockets (4 magnets; check polarity — closed-snap pair at X=+38 mm must attract tray magnets when tray is in closed position).
2. Press-fit magnets into the keyboard-tray pockets (2 magnets; opposing pole faces upward toward top shell).
3. Apply a thin coat of PTFE grease to the rectangular guide rails on the top shell.
4. Slide the keyboard tray in from the **+X (right) end** of the top shell.
   Hold the phone landscape (120 mm wide, 95 mm tall) — the keyboard slides
   downward to expose the CardKB, Nokia N900-style.
5. Snap the tray closed — the magnetic click should be clearly perceptible.
6. Assemble electronics: mount Heltec V4 PCB (51.7 × 25.4 mm) onto the 4 standoffs with M2 screws,
   route I²C cable from CardKB through the wire-routing groove and side access slot.
7. Insert the MakerFocus LiPo battery (71×51×9 mm) into the battery pocket; the retention clips snap over the edges.
8. Attach antenna mount to the top edge of the top shell with M2 screws and thread the SMA connector through.

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
- **M5Stack CardKB v1.1**: [M5Stack Official Store](https://shop.m5stack.com/products/cardkb-mini-keyboard-programmable-unit-v1-1-mega328p)
- **MakerFocus 3000 mAh LiPo**: Search for "MakerFocus 3000mAh 3.7V lipo 71×51mm" on Amazon
- **10 mm × 4 mm N35 magnets**: Amazon / AliExpress — search "10mm x 4mm neodymium disc magnets N35"
- **M2 hardware**: Amazon, McMaster-Carr, local hardware store
- **PETG filament**: Prusament, eSun, Hatchbox or equivalent
