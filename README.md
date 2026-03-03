# Meshtastic Sliding Phone

A 3D-printable sliding phone enclosure for **Meshtastic** mesh networking devices. Inspired by classic slider phones (Nokia N95, Samsung SGH-D900), this design houses a LILYGO T-Beam V1.2 board with LoRa radio, GPS, battery, and display in a compact, pocket-friendly form factor with a slide-out keyboard.

```
    ┌─────────────────────┐
    │  ╔═══════════════╗  │  ← Speaker grille
    │  ║               ║  │
    │  ║    2.8" IPS    ║  │  ← Display window
    │  ║    Display     ║  │
    │  ║               ║  │
    │  ╚═══════════════╝  │
    │     [PWR]  [VOL]    │  ← Side buttons
    ├─────────────────────┤  ← Slide mechanism
    │  ┌─┐┌─┐┌─┐┌─┐┌─┐  │
    │  │Q││W││E││R││T│..  │  ← Keyboard (revealed)
    │  └─┘└─┘└─┘└─┘└─┘  │
    │  ┌─┐┌─┐┌─┐┌─┐┌─┐  │
    │  │A││S││D││F││G│..  │
    │  └─┘└─┘└─┘└─┘└─┘  │
    │  [USB-C]    [ANT]   │  ← Ports
    └─────────────────────┘
```

## Features

- **Sliding mechanism** with dovetail rails for smooth, snap-free action
- **2.8" IPS LCD** display window (320×240, fits standard T-Deck displays)
- **4×10 keyboard grid** with tactile switch mounting posts
- **18650 battery** compartment with snap-fit removable cover
- **SMA antenna mount** with strain relief for LoRa whip antenna
- **USB-C port** access for charging and firmware flashing
- **Speaker grille & microphone** holes
- **Ventilation slots** for thermal management
- **M2 screw posts** for secure PCB and display mounting
- **Fully parametric** — all dimensions easily adjustable

## Project Structure

```
meshtastic-sliding-phone/
├── models/
│   ├── scad/                    # OpenSCAD parametric source files
│   │   ├── parameters.scad      # Shared dimensions & tolerances
│   │   ├── utilities.scad       # Reusable shape modules
│   │   ├── top_shell.scad       # Upper sliding body + display
│   │   ├── bottom_shell.scad    # Lower body + keyboard + PCB bay
│   │   ├── battery_cover.scad   # Snap-fit battery door
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
| **Main board** | LILYGO T-Beam V1.2 (ESP32 + LoRa + GPS) |
| **Display** | 2.8" IPS LCD 320×240 (SPI interface) |
| **Battery** | 18650 Li-Ion cell (unprotected, flat-top) |
| **Antenna** | SMA LoRa antenna (868/915 MHz) |
| **Keyboard** | 4×10 tactile switch matrix (6×6mm switches) |
| **Fasteners** | M2×8mm screws + M2 nuts |

## Dimensions

| Part | Width | Length | Height |
|------|-------|--------|--------|
| Top Shell | 68mm | 140mm | 9mm |
| Bottom Shell | 68mm | 192mm | 13mm |
| Battery Cover | 27mm | 74mm | 4mm |
| Antenna Mount | 22mm | 12mm | 10mm |
| **Assembled (closed)** | **68mm** | **140mm** | **18mm** |

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
| **Layer Height** | 0.2mm (0.12mm for display frame) |
| **Infill** | 20–25% (100% for battery cover snap tabs) |
| **Material** | PETG or ASL recommended (PLA acceptable) |
| **Supports** | Required for display recess and rail channels |
| **Orientation** | Print shells face-down for best surface finish |
| **Walls** | 3 perimeters minimum |

## Assembly Instructions

1. **Print all parts** using recommended settings above
2. **Install keyboard switches** — press 6×6mm tactile switches onto the mounting posts in the bottom shell keyboard well
3. **Mount the T-Beam PCB** — secure with M2×8mm screws through the 4 mounting posts in the bottom shell
4. **Connect the display** — route the ribbon cable and seat the LCD module in the top shell display recess, secure with M2 screws
5. **Install the antenna mount** — attach to the top edge of the bottom shell with M2 screws, thread the SMA connector through
6. **Insert the battery** — place an 18650 cell in the battery compartment and snap the battery cover shut
7. **Assemble the slide** — align the top shell's dovetail rails with the bottom shell's channels and slide together from the keyboard end
8. **Flash Meshtastic firmware** — connect via USB-C and use [flasher.meshtastic.org](https://flasher.meshtastic.org)

## Customization

All dimensions are parametric. Edit `models/scad/parameters.scad` to adjust:

- `phone_length`, `phone_width`, `phone_thickness` — overall size
- `wall` — shell thickness (increase for durability, decrease for weight)
- `clearance` — sliding fit tolerance (tune for your printer)
- `keyboard_travel` — how far the keyboard slides out
- `corner_radius` — roundness of edges
- Display, PCB, battery dimensions — match your specific hardware

## Contributing

Contributions welcome! Please:
- Test-print modified designs before submitting
- Update `parameters.scad` comments for new dimensions
- Include photos of printed parts if possible

## License

This project is open source. See individual files for details.

## Acknowledgments

- [Meshtastic](https://meshtastic.org/) — open-source mesh networking
- [LILYGO](https://www.lilygo.cc/) — T-Beam and T-Deck hardware
- OpenSCAD and numpy-stl communities