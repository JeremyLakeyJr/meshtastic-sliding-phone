# Bill of Materials — Meshtastic Sliding Phone

## Electronics

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 1 | Heltec WiFi LoRa 32 V4 | ESP32-S3 + SX1262 LoRa + built-in 0.96" OLED | Main controller board (~55×27mm) |
| 1 | M5Stack CardKB | I²C QWERTY keyboard, 58.2×27.6mm, 3.3 V/5 V | Connects to Heltec V4 via I²C (Grove or direct wires) |
| 1 | LiPo Battery | 3.7 V, 503450, ~1200 mAh (5×34×50 mm) | Flat pouch cell; JST 1.25 mm 2-pin connector |
| 1 | LoRa Antenna | SMA, 868 MHz or 915 MHz (region-dependent) | Stubby or flexible whip style |
| 1 | GPS Antenna | IPX/U.FL ceramic patch | Optional — Heltec V4 does not have on-board GPS |

## Mechanical

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 8 | M2×8mm Screws | Pan head, Phillips or hex | PCB mounting |
| 8 | M2 Nuts | Standard hex | Or use heat-set inserts |
| 4 | M2 Heat-Set Inserts | M2, 3.5mm OD × 4mm length | Optional, replaces nuts |
| 1 | Silicone Grease | Small tube, PTFE-based | For smooth slide rails |

## 3D Printed Parts

| Qty | Part | Material | Infill | Supports |
|-----|------|----------|--------|----------|
| 1 | Top Shell | PETG/ASA | 20% | Yes (rail channels) |
| 1 | Bottom Shell | PETG/ASA | 25% | Yes (rail channels) |
| 1 | Battery Cover | PETG/ASA | 100% | No |
| 1 | Antenna Mount | PETG/ASA | 40% | No |

## Optional Add-ons

| Component | Purpose |
|-----------|---------|
| Wrist strap loop | Attach lanyard/strap for field use |
| Belt clip adapter | Clip to belt or MOLLE webbing |
| Screen protector film | Cut to 23×13 mm for OLED viewport |
| Rubber bumpers (4×) | Stick-on feet for table use |
| USB-C cable (short) | For charging / firmware flash |
| External GPS module | Add GPS capability (Heltec V4 has no on-board GPS) |

## Sourcing

- **Heltec WiFi LoRa 32 V4**: [Heltec Official Store](https://heltec.org/project/wifi-lora-32-v4/), [Amazon](https://www.amazon.com/s?k=heltec+wifi+lora+32+v4)
- **M5Stack CardKB**: [M5Stack Official Store](https://shop.m5stack.com/products/cardkb-mini-keyboard-programmable-unit-v1-1-mega328p), [Amazon](https://www.amazon.com/s?k=m5stack+cardkb)
- **LiPo 503450**: Any electronics supplier (Adafruit, Mouser, Amazon) — ensure JST 1.25 mm connector
- **M2 Hardware**: Amazon, McMaster-Carr, local hardware store
- **PETG Filament**: Any reputable brand (Prusament, eSun, Hatchbox)
