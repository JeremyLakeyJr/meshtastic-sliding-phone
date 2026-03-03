# Bill of Materials — Meshtastic Sliding Phone

## Electronics

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 1 | LILYGO T-Beam V1.2 | ESP32 + SX1276/SX1262 LoRa + NEO-6M/8M GPS | Main controller board (~100×33mm) |
| 1 | IPS LCD Display | 2.8" 320×240 SPI (ST7789/ILI9341 driver) | Connects to T-Beam SPI header |
| 1 | 18650 Li-Ion Battery | 3.7V, 2600–3500mAh, flat-top, unprotected | Fits battery compartment (65×18mm) |
| 1 | LoRa Antenna | SMA, 868MHz or 915MHz (region-dependent) | Stubby or flexible whip style |
| 40 | Tactile Switches | 6×6×5mm through-hole, 4-pin | Keyboard matrix (4 rows × 10 cols) |
| 1 | GPS Antenna | IPX/U.FL ceramic patch | Usually included with T-Beam |
| 1 | Speaker | 12mm diameter, 8Ω, 0.5W | Optional, for audio alerts |
| 1 | Electret Microphone | 6mm, with breakout/amplifier | Optional, for voice memos |

## Mechanical

| Qty | Component | Specification | Notes |
|-----|-----------|--------------|-------|
| 8 | M2×8mm Screws | Pan head, Phillips or hex | PCB + display mounting |
| 8 | M2 Nuts | Standard hex | Or use heat-set inserts |
| 4 | M2 Heat-Set Inserts | M2, 3.5mm OD × 4mm length | Optional, replaces nuts |
| 1 | Silicone Grease | Small tube, PTFE-based | For smooth slide rails |

## 3D Printed Parts

| Qty | Part | Material | Infill | Supports |
|-----|------|----------|--------|----------|
| 1 | Top Shell | PETG/ASA | 20% | Yes (display recess) |
| 1 | Bottom Shell | PETG/ASA | 25% | Yes (rail channels) |
| 1 | Battery Cover | PETG/ASA | 100% | No |
| 1 | Antenna Mount | PETG/ASA | 40% | No |

## Optional Add-ons

| Component | Purpose |
|-----------|---------|
| Wrist strap loop | Attach lanyard/strap for field use |
| Belt clip adapter | Clip to belt or MOLLE webbing |
| Screen protector film | Cut to 57×43mm for display |
| Rubber bumpers (4×) | Stick-on feet for table use |
| USB-C cable (short) | For charging / firmware flash |

## Sourcing

- **T-Beam V1.2**: [LILYGO Official Store (AliExpress)](https://www.aliexpress.com/store/2090076), [Amazon](https://www.amazon.com/s?k=lilygo+t-beam)
- **Tactile Switches**: Any electronics supplier (Mouser, Digikey, Amazon)
- **18650 Battery**: Samsung 25R, Sony VTC6, or LG HG2 recommended
- **M2 Hardware**: Amazon, McMaster-Carr, local hardware store
- **PETG Filament**: Any reputable brand (Prusament, eSun, Hatchbox)
