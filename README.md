# Meshtastic Sliding Phone

A 3D-printable sliding phone enclosure for **Meshtastic** mesh networking devices. Inspired by classic slider phones (Nokia N95, Samsung SGH-D900), this design houses a **Heltec WiFi LoRa 32 V4** board and a **M5Stack CardKB** I²C keyboard in a compact, pocket-friendly form factor with a slide-out keyboard.

```
    ┌─────────────────────┐
    │  ╔═════════╗        │  ← Speaker grille
    │  ║ 0.96"   ║        │
    │  ║  OLED   ║        │  ← OLED viewport (built into Heltec V4)
    │  ╚═════════╝        │
    │     [PWR]  [VOL]    │  ← Side buttons
    ├─────────────────────┤  ← Slide mechanism
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

- **Sliding mechanism** with dovetail rails for smooth, snap-free action
- **0.96" OLED viewport** aligned with the Heltec V4's built-in 128×64 display
- **CardKB pocket** — snap-in slot for the M5Stack CardKB I²C keyboard module
- **LiPo battery** compartment (503450 or similar flat pouch cell) with snap-fit cover
- **SMA antenna mount** with strain relief for LoRa whip antenna
- **USB-C port** access for charging and firmware flashing
- **Speaker grille & microphone** holes
- **Ventilation slots** for thermal management
- **M2 screw posts** for secure PCB mounting
- **Fully parametric** — all dimensions easily adjustable

## Project Structure

```
meshtastic-sliding-phone/
├── models/
│   ├── scad/                    # OpenSCAD parametric source files
│   │   ├── parameters.scad      # Shared dimensions & tolerances
│   │   ├── utilities.scad       # Reusable shape modules
│   │   ├── top_shell.scad       # Upper sliding body + OLED viewport
│   │   ├── bottom_shell.scad    # Lower body + CardKB pocket + PCB bay
│   │   ├── battery_cover.scad   # Snap-fit LiPo battery door
│   │   ├── antenna_mount.scad   # SMA connector mount
│   │   └── assembly.scad        # Full exploded/assembled view
│   └── stl/                     # Pre-generated printable meshes
│       ├── top_shell.stl
│       ├── bottom_shell.stl
│       ├── battery_cover.stl
│       └── antenna_mount.stl
├── scripts/
│   └── generate_stl.py          # Python STL generator (no OpenSCAD needed)
├── docs/
│   └── bill_of_materials.md     # Parts list & sourcing guide
└── README.md
```

## Hardware Compatibility

| Component | Specification |
|-----------|--------------|
| **Main board** | Heltec WiFi LoRa 32 V4 (ESP32-S3 + SX1262 LoRa + 0.96" OLED) |
| **Display** | Built-in 0.96" OLED 128×64 (on Heltec V4 PCB) |
| **Keyboard** | M5Stack CardKB (I²C, 58.2×27.6mm, 46-key QWERTY) |
| **Battery** | 3.7 V LiPo 503450 (~1200 mAh, 5×34×50 mm nominal) |
| **Antenna** | SMA LoRa antenna (868/915 MHz) |
| **Fasteners** | M2×8mm screws + M2 nuts |

## Dimensions

| Part | Width | Length | Height |
|------|-------|--------|--------|
| Top Shell | 74mm | 120mm | 7.5mm |
| Bottom Shell | 74mm | 155mm | 7.5mm |
| Battery Cover | 43mm | 59mm | 4mm |
| Antenna Mount | 22mm | 12mm | 10mm |
| **Assembled (closed)** | **74mm** | **120mm** | **15mm** |

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
openscad -o bottom_shell.stl models/scad/bottom_shell.scad
openscad -o battery_cover.stl models/scad/battery_cover.scad
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
| **Infill** | 20–25% (100% for battery cover snap tabs) |
| **Material** | PETG or ASA recommended (PLA acceptable) |
| **Supports** | Required for rail channels |
| **Orientation** | Print shells face-down for best surface finish |
| **Walls** | 3 perimeters minimum |

## Assembly Instructions

1. **Print all parts** using recommended settings above
2. **Seat the CardKB** — press the M5Stack CardKB module into the pocket in the bottom shell keyboard well; the retention ledges click it in place
3. **Mount the Heltec V4** — secure with M2×8mm screws through the 4 mounting posts in the bottom shell; align the OLED with the viewport window in the top shell
4. **Wire the CardKB** — run the CardKB Grove/I²C cable through the side access slot and connect to the Heltec V4 (SDA → GPIO 21, SCL → GPIO 22)
5. **Install the antenna mount** — attach to the top edge of the bottom shell with M2 screws, thread the SMA connector through
6. **Insert the LiPo battery** — place the flat LiPo cell in the battery compartment and snap the battery cover shut
7. **Assemble the slide** — align the top shell's dovetail rails with the bottom shell's channels and slide together from the keyboard end
8. **Flash Meshtastic firmware** — connect via USB-C and use [flasher.meshtastic.org](https://flasher.meshtastic.org); select **Heltec WiFi LoRa 32 V4** as the target device

## Customization

All dimensions are parametric. Edit `models/scad/parameters.scad` to adjust:

- `phone_length`, `phone_width`, `phone_thickness` — overall size
- `wall` — shell thickness (increase for durability, decrease for weight)
- `clearance` — sliding fit tolerance (tune for your printer)
- `keyboard_travel` — how far the keyboard slides out
- `corner_radius` — roundness of edges
- `cardkb_length`, `cardkb_width`, `cardkb_thickness` — CardKB module pocket
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