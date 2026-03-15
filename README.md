# Meshtastic Sliding Phone

A 3D-printable sliding phone enclosure for **Meshtastic** mesh networking devices. This design houses a **Heltec WiFi LoRa 32 V4** board and a **M5Stack CardKB** I²C keyboard in a compact, pocket-friendly Nokia N900-style landscape slider. The keyboard tray slides along two rectangular guide rails on the interior side walls of the top shell, snapping into open and closed positions via offset neodymium magnet detents.

```
    ┌─────────────────────┐
    │  ╔═════════╗        │  ← Speaker grille
    │  ║ 0.96"   ║        │
    │  ║  OLED   ║        │  ← OLED viewport
    │  ╚═════════╝        │
    │     [PWR]  [VOL]    │  ← Side buttons
    ├─────────────────────┤  ← Rectangular rail guides (interior side walls)
    │  ┌─┐┌─┐┌─┐┌─┐┌─┐  │
    │  │Q││W││E││R││T│..  │  ← CardKB (revealed when slid open)
    │  └─┘└─┘└─┘└─┘└─┘  │
    │  ┌─┐┌─┐┌─┐┌─┐┌─┐  │
    │  │A││S││D││F││G│..  │
    │  └─┘└─┘└─┘└─┘└─┘  │
    │  [USB-C]    [ANT]   │  ← Ports
    └─────────────────────┘
```

## Features

- **Rectangular-rail slider** — two 3×3 mm rectangular guide rails on the interior side walls of the top shell constrain the keyboard tray; passive ~3° typing tilt at full extension
- **Offset magnetic detents** — 6× 10 mm × 4 mm neodymium disc magnets (4 in top shell, 2 in tray) snap audibly into closed and open positions via 6 mm lateral offset
- **0.96" OLED viewport** aligned with the Heltec V4's built-in 128×64 display
- **CardKB pocket** — snap-in slot for the M5Stack CardKB I²C keyboard module (88×54×7 mm)
- **LiPo battery** compartment (MakerFocus 3000 mAh or similar flat pouch cell, ~71×51×9 mm) integrated in the top shell
- **SMA antenna mount** with strain relief for LoRa whip antenna
- **USB-C port** access for charging and firmware flashing
- **Speaker grille & microphone** holes
- **Ventilation slots** for thermal management
- **M2 screw posts** for secure PCB mounting
- **Fully parametric** — all dimensions easily adjustable

## Improved CAD Generation Prompt

Use this prompt when generating enclosure concepts with AI CAD tools:

> Create a fully parametric, 3D-printable electronics enclosure optimized for FDM printing. Model separate printable parts (main shell, sliding tray, and mounting features), expose key dimensions as editable parameters (PCB size, battery size, wall thickness, clearances, and travel), and enforce print-safe geometry (minimum 2 mm walls, filleted/chamfered transitions, no unsupported overhangs beyond ~45°, and practical assembly tolerances). Include internal standoffs, cable-routing channels, ventilation, fastener or snap-fit options, and clear support for iterative dimension tuning without rewriting core geometry.

## Project Structure

```
meshtastic-sliding-phone/
├── models/
│   ├── scad/                    # OpenSCAD parametric source files
│   │   ├── parameters.scad      # Shared dimensions & tolerances
│   │   ├── utilities.scad       # Reusable shape modules (rails, magnets, etc.)
│   │   ├── top_shell.scad       # Unified top enclosure: OLED viewport, PCB bay, battery, rails
│   │   ├── keyboard_tray.scad   # Sliding keyboard tray: CardKB pocket, rail grooves, magnets
│   │   ├── bottom_shell.scad    # Alias for keyboard_tray.scad (2-piece naming)
│   │   ├── main_body.scad       # Backward-compatible alias for top_shell.scad
│   │   ├── antenna_mount.scad   # SMA connector mount with strain relief
│   │   └── assembly.scad        # Full exploded/assembled preview (not for printing)
│   └── stl/                     # Pre-generated printable meshes
│       ├── top_shell.stl
│       ├── keyboard_tray.stl
│       └── antenna_mount.stl
├── scripts/
│   └── generate_stl.py          # Python STL generator (no OpenSCAD needed; approximate)
├── docs/
│   └── bill_of_materials.md     # Parts list & sourcing guide
└── README.md
```

## Hardware Compatibility

| Component | Specification |
|-----------|--------------|
| **Main board** | Heltec WiFi LoRa 32 V4 (ESP32-S3 + SX1262 LoRa + 0.96" OLED) |
| **Display** | Built-in 0.96" OLED 128×64 (on Heltec V4 PCB) |
| **Keyboard** | M5Stack CardKB v1.1 (I²C, 88×54×7 mm, 46-key QWERTY) |
| **Battery** | MakerFocus 3.7 V LiPo 3000 mAh (~71×51×9 mm nominal) |
| **Antenna** | SMA LoRa antenna (868/915 MHz) |
| **Fasteners** | M2×8mm screws + M2 nuts |

## Dimensions

| Part | Width (X) | Length (Y) | Height (Z) |
|------|-----------|------------|------------|
| Top Shell | 95 mm | 120 mm | 19 mm |
| Keyboard Tray (Bottom Shell) | 95 mm | 120 mm | 8 mm |
| Antenna Mount | 16 mm | 12 mm | 10 mm |
| **Assembled (closed)** | **95 mm** | **120 mm** | **27 mm** |

Slider travel: **65 mm** (exposes full 54 mm CardKB short axis + margin)

## Getting Started

### Option 1: Use Pre-generated STL Files

The `models/stl/` directory contains ready-to-print STL files. Import them into your slicer (PrusaSlicer, Cura, etc.) and print.

### Option 2: Customize with OpenSCAD

1. Install [OpenSCAD](https://openscad.org/downloads.html)
2. Open any `.scad` file from `models/scad/`
3. Edit `parameters.scad` to adjust dimensions for your hardware
4. Render and export as STL

```bash
# Render individual parts from command line
openscad -o top_shell.stl models/scad/top_shell.scad
openscad -o keyboard_tray.stl models/scad/keyboard_tray.scad
openscad -o antenna_mount.stl models/scad/antenna_mount.scad
```

### Option 3: Generate STL with Python

No OpenSCAD required — uses `numpy-stl` for mesh generation:

```bash
pip install numpy-stl numpy
python3 scripts/generate_stl.py              # Generate all parts
python3 scripts/generate_stl.py --part top_shell  # Generate one part
```

## Print Settings

| Setting | Recommendation |
|---------|---------------|
| **Layer Height** | 0.2mm (0.12mm for OLED viewport frame) |
| **Infill** | 20–25% top shell, 30% keyboard tray |
| **Material** | PETG or ASA recommended (PLA acceptable) |
| **Supports** | Not required — all overhangs ≤ 45°; rectangular groove walls need no support |
| **Orientation** | Top shell: display face down; keyboard tray: top face (grooves) down |
| **Walls** | 3 perimeters minimum |

## Assembly Instructions

1. **Print all parts** using recommended settings above
2. **Press-fit magnets** — press 6× 10 mm × 4 mm neodymium disc magnets into their pockets (check polarity: opposing pairs must attract). Top shell has 4 pockets (2 for closed snap at X=+38 mm, 2 for open snap at X=−39 mm); keyboard tray has 2 pockets at X=+32 mm.
3. **Seat the CardKB** — press the M5Stack CardKB module into the pocket in the keyboard tray; the retention ledges click it in place
4. **Mount the Heltec V4** — secure with M2×8mm screws through the 4 mounting posts inside the top shell; align the OLED with the viewport window
5. **Wire the CardKB** — run the CardKB I²C cable through the side access slot and connect to the Heltec V4 (SDA → GPIO 21, SCL → GPIO 22); use the wire routing groove alongside the rail
6. **Install the antenna mount** — attach to the top edge of the top shell with M2 screws, thread the SMA connector through
7. **Insert the LiPo battery** — place the flat LiPo cell in the battery compartment inside the top shell and snap the retention clips
8. **Assemble the slide** — align the keyboard tray's rail grooves with the top shell's rectangular rails at the **+X (right) end** and slide the tray in; it will snap into the closed position via the magnet detents
9. **Flash Meshtastic firmware** — connect via USB-C and use [flasher.meshtastic.org](https://flasher.meshtastic.org); select **Heltec WiFi LoRa 32 V4** as the target device

## Customization

All dimensions are parametric. Edit `models/scad/parameters.scad` to adjust:

- `phone_length`, `phone_width` — overall body footprint
- `wall_thickness` / `wall` — shell wall thickness (increase for durability)
- `clearance` — general sliding-fit tolerance (tune for your printer)
- `slider_travel` / `keyboard_travel` — how far the keyboard tray slides out (default 65 mm)
- `rail_width`, `rail_height` — rectangular guide rail cross-section (3×3 mm default)
- `rail_clearance` — per-side clearance between rail and tray groove (0.35 mm default)
- `rail_length` — guide rail length along X (70 mm default, ≥70% of tray width)
- `channel_standoff` — extra groove depth for passive typing tilt (2 mm → ~3° tilt)
- `magnet_offset` — lateral offset between body and tray magnet pockets for snap-in detent (6 mm)
- `corner_radius` — roundness of edges
- `cardkb_w`, `cardkb_h`, `cardkb_thickness` — CardKB module pocket dimensions
- PCB, battery, display viewport dimensions — match your specific hardware

## Contributing

Contributions welcome! Please:
- Test-print modified designs before submitting
- Update `parameters.scad` comments for new dimensions
- Include photos of printed parts if possible

## License

This project is open source. See individual files for details.

## Acknowledgments

- [Meshtastic](https://meshtastic.org/) — open-source mesh networking
- [Heltec Automation](https://heltec.org/) — WiFi LoRa 32 V4 hardware
- [M5Stack](https://m5stack.com/) — CardKB keyboard module
- OpenSCAD and numpy-stl communities
