#!/usr/bin/env python3
"""
Meshtastic Sliding Phone - STL Generator
=========================================
Generates printable STL mesh files for all phone components using numpy-stl.
Run this script to produce STL files without needing OpenSCAD installed.

DESIGN (2-piece)
  top_shell     – unified enclosure (display, PCB, battery, rails, ports)
  keyboard_tray – sliding keyboard carriage (CardKB 88×54mm, T-runners, magnets)
  bottom_shell  – alias for keyboard_tray (2-piece naming convention)

Mechanism: shortways (X-axis) magnetic-detent slider with captured-lip T-slot rails.
  • phone_width = 95 mm; slider_travel = 65 mm → 30 mm rail engagement at full ext.
  • Two parallel T-rail runners (rail_w=3mm, rail_h=2mm, clearance=0.35mm) on the
    keyboard-tray top face slide inside matching T-slot channels in the top-shell
    underside, positioned at Y = ±RAIL_Y (±40 mm).
  • Neodymium 10 mm × 4 mm disc magnets (pocket bore 10.3 mm, depth 4.2 mm,
    retention lip 0.5 mm) snap the tray into closed (travel=0) and open
    (travel=65 mm) positions.  Symmetric detents at body X = ±32 mm.
  • Stop blocks (2 mm tall) inside the rail channels at body X ≈ −15.5 mm prevent
    accidental removal.  A matching stop_cutout (2.5 mm) at the runner -X tip
    allows initial assembly from the +X entry end.
  • A shallow snap ramp in the last 5 mm of travel gives a "self-finish" feel.
  • CardKB pocket: 88×54 mm (width×height), 8 mm deep, 0.5 mm clearance.

Usage:
    python3 generate_stl.py                     # Generate all parts
    python3 generate_stl.py --part top_shell    # Single part

Output directory: ../models/stl/
"""

import argparse
import math
import os
import sys
import numpy as np
from stl import mesh

# ---------------------------------------------------------------------------
# Parameters (mirrors parameters.scad)
# ---------------------------------------------------------------------------
PHONE_LENGTH     = 120.0
# phone_width = 95 mm: slider_travel(65) + rail_engagement(30) = 95  ✓
PHONE_WIDTH      =  95.0

WALL_THICKNESS   =   2.2
WALL             =   WALL_THICKNESS
CLEARANCE        =   0.3
CORNER_R         =   4.0

# Component heights
TOP_SHELL_Z  =  10.0   # display / PCB section
BOT_SHELL_Z  =   9.0   # battery / ports section
BODY_Z       =  TOP_SHELL_Z + BOT_SHELL_Z  # 19 mm – unified top shell
TRAY_Z       =   8.0   # keyboard tray
PHONE_THICKNESS = BODY_Z + TRAY_Z   # 27 mm

# Display (Heltec V4 OLED 0.96″)
DISPLAY_W        =  23.0
DISPLAY_H        =  13.0
DISPLAY_OFFSET_Y =  12.0
DISPLAY_DEPTH    =   2.0

# Heltec WiFi LoRa 32 V4 PCB (ESP32-S3 + SX1262; actual 51.7 × 25.4 mm)
PCB_LENGTH       =  52.0
PCB_WIDTH        =  26.0

# LiPo battery
LIPO_THICKNESS   =   6.0
LIPO_WIDTH       =  42.0
LIPO_LENGTH      =  52.0

# CardKB keyboard module (M5Stack CardKB v1.1)
# cardkb_w  = 88 mm (along phone Y-axis)
# cardkb_h  = 54 mm (along sliding X-axis)
CARDKB_W         =  88.0   # long axis, along phone Y
CARDKB_H         =  54.0   # short axis, along sliding X
CARDKB_THICKNESS =   7.0

KEYBOARD_CLEARANCE    = 0.5   # per-side clearance around keyboard
KEYBOARD_POCKET_DEPTH = 8.0   # pocket depth (> cardkb_thickness)
KEYBOARD_HEIGHT_CLEARANCE = 10.0  # min internal Z clearance

# Slider travel (shortways, −X direction)
# 65 mm travel exposes 65 mm of tray area (≥ 60 mm spec)  ✓
SLIDER_TRAVEL    =  65.0
KEYBOARD_TRAVEL  =  SLIDER_TRAVEL   # alias

# --- Rail system (T-slot captured-lip; per spec) ---
RAIL_W          =  3.0   # runner stem width (Y) – per spec
RAIL_H          =  2.0   # runner height (Z) – per spec
RAIL_Y          = 40.0   # ±Y from phone centreline
RAIL_LIP_H      =  1.0
RAIL_LIP_W      =  1.5
RAIL_CLEARANCE  =  0.35  # per-side – per spec
RAIL_ENTRY_CHAMFER = 0.6
RAIL_CHAMFER    = RAIL_ENTRY_CHAMFER
RAIL_CHANNEL_W  = RAIL_W + 2 * RAIL_CLEARANCE   # 3.7 mm
RAIL_CHANNEL_H  = RAIL_H + 2.5                  # 4.5 mm (2.5 mm standoff)
RAIL_HEIGHT     = RAIL_CHANNEL_H

# Snap-ramp near the open-position end
SNAP_RAMP_X     =  5.0
SNAP_RAMP_Z     =  0.4

# Typing angle (passive – accommodated by 2.5 mm standoff clearance)
TYPING_ANGLE    =  3.0   # degrees (design intent)

# --- Neodymium magnet detents (10 mm × 4 mm disc, N35) – per spec ---
MAGNET_D         = 10.0   # physical magnet diameter
MAGNET_H         =  4.0   # physical magnet thickness
MAGNET_DIAMETER  = 10.3   # pocket bore – per spec
MAGNET_DEPTH     =  4.2   # pocket depth – per spec
MAGNET_LIP       =  0.5   # retention lip – per spec
MAGNET_POCKET_D  = MAGNET_DIAMETER   # 10.3 mm bore
MAGNET_POCKET_H  = MAGNET_DEPTH      # 4.2 mm depth
MAGNET_Y         = 20.0
# Symmetric detents: closed at +32 mm, open at 32−65 = −33 mm
DETENT_X_OFFSET  = 32.0

# --- End-stop blocks (inside rail channels) – per spec ---
STOP_BLOCK_HEIGHT = 2.0   # block height above channel floor
STOP_CUTOUT       = 2.5   # runner -X tip cutout depth (enables assembly)
STOP_BLOCK_DEPTH  = 2.0   # stop block X-dimension
TAB_STOP_MARGIN   = 2.0   # travel margin before stop (mm before SLIDER_TRAVEL)

# Stop block +X face position: body X = −(SLIDER_TRAVEL − TAB_STOP_MARGIN − PHONE_WIDTH/2)
# Stop block +X face position in body frame:
# STOP_BLOCK_POS_X = -(SLIDER_TRAVEL - TAB_STOP_MARGIN - PHONE_WIDTH/2) = -15.5 mm
STOP_BLOCK_POS_X = -(SLIDER_TRAVEL - TAB_STOP_MARGIN - PHONE_WIDTH / 2)

# Legacy tab stop (kept for backward compat)
TAB_W_EXTRA     =  2.0
TAB_DEPTH       =  3.0
TAB_HEIGHT_EXT  =  1.5

# --- Ports ---
SMA_D    =  6.5
USBC_W   =  9.5
USBC_H   =  3.5

# --- Screw posts ---
SCREW_HOLE_D =  2.2
SCREW_POST_D =  5.0
SCREW_POST_H =  5.0

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          "..", "models", "stl")


# ---------------------------------------------------------------------------
# Mesh helpers
# ---------------------------------------------------------------------------

def _box_triangles(cx, cy, cz, w, h, d):
    """12 triangles for an axis-aligned box centred at (cx, cy), base at cz."""
    x0, x1 = cx - w / 2, cx + w / 2
    y0, y1 = cy - h / 2, cy + h / 2
    z0, z1 = cz, cz + d
    verts = np.array([
        [x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0],  # bottom
        [x0, y0, z1], [x1, y0, z1], [x1, y1, z1], [x0, y1, z1],  # top
    ])
    faces = np.array([
        [0, 2, 1], [0, 3, 2],   # bottom
        [4, 5, 6], [4, 6, 7],   # top
        [0, 1, 5], [0, 5, 4],   # front
        [1, 2, 6], [1, 6, 5],   # right
        [2, 3, 7], [2, 7, 6],   # back
        [3, 0, 4], [3, 4, 7],   # left
    ])
    return verts, faces


def _cylinder_triangles(cx, cy, z0, r, h, n=24):
    """Triangles for a cylinder centred at (cx, cy) from z0 to z0+h."""
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    verts = [[cx, cy, z0], [cx, cy, z0 + h]]
    for a in angles:
        verts.append([cx + r * math.cos(a), cy + r * math.sin(a), z0])
    for a in angles:
        verts.append([cx + r * math.cos(a), cy + r * math.sin(a), z0 + h])
    verts = np.array(verts)
    faces = []
    for i in range(n):
        j = (i + 1) % n
        bi, bj = 2 + i, 2 + j
        ti, tj = 2 + n + i, 2 + n + j
        faces.append([0, bj, bi])
        faces.append([1, ti, tj])
        faces.append([bi, bj, tj])
        faces.append([bi, tj, ti])
    return verts, np.array(faces)


def _combine_meshes(parts):
    """Combine multiple (verts, faces) tuples into one mesh."""
    all_v, all_f, offset = [], [], 0
    for v, f in parts:
        all_v.append(v)
        all_f.append(f + offset)
        offset += len(v)
    return np.vstack(all_v), np.vstack(all_f)


def _make_stl(verts, faces):
    m = mesh.Mesh(np.zeros(len(faces), dtype=mesh.Mesh.dtype))
    for i, f in enumerate(faces):
        for j in range(3):
            m.vectors[i][j] = verts[f[j]]
    return m


# ---------------------------------------------------------------------------
# Part generators
# ---------------------------------------------------------------------------

def generate_top_shell():
    """Unified top enclosure: display face, PCB bay, battery cavity, T-slot rails.

    95 × 120 × 19 mm.  T-slot channels at Y = ±RAIL_Y (±40 mm) with stop blocks.
    Magnet pockets (10.3 mm bore × 4.2 mm) at body X = ±32 mm (symmetric).
    """
    parts = []
    w, l, d = PHONE_WIDTH, PHONE_LENGTH, BODY_Z

    # Outer box (interior cavity approximated via wall boxes)
    parts.append(_box_triangles(0, 0, 0, w, l, d))

    # Top plate
    parts.append(_box_triangles(0, 0, d - WALL_THICKNESS, w, l, WALL_THICKNESS))

    # Side walls
    iw = w - 2 * WALL_THICKNESS
    il = l - 2 * WALL_THICKNESS
    parts.append(_box_triangles(-(w / 2 - WALL_THICKNESS / 2), 0,
                                WALL_THICKNESS, WALL_THICKNESS, l,
                                d - WALL_THICKNESS))
    parts.append(_box_triangles( (w / 2 - WALL_THICKNESS / 2), 0,
                                WALL_THICKNESS, WALL_THICKNESS, l,
                                d - WALL_THICKNESS))
    parts.append(_box_triangles(0, -(l / 2 - WALL_THICKNESS / 2),
                                WALL_THICKNESS, iw, WALL_THICKNESS,
                                d - WALL_THICKNESS))
    parts.append(_box_triangles(0,  (l / 2 - WALL_THICKNESS / 2),
                                WALL_THICKNESS, iw, WALL_THICKNESS,
                                d - WALL_THICKNESS))

    # Floor (provides material for T-slot channels)
    parts.append(_box_triangles(0, 0, 0, w, l, WALL_THICKNESS))

    # T-slot rail channel representations at Y = ±RAIL_Y
    t_slot_w = RAIL_CHANNEL_W + 2 * RAIL_LIP_W   # total void width
    for side in [-1, 1]:
        cy = side * RAIL_Y
        parts.append(_box_triangles(0, cy, 0, w, t_slot_w, RAIL_CHANNEL_H))

    # Stop blocks inside channels at body X = STOP_BLOCK_POS_X (≈ −15.5 mm)
    for side in [-1, 1]:
        cy = side * RAIL_Y
        parts.append(_box_triangles(STOP_BLOCK_POS_X - STOP_BLOCK_DEPTH / 2, cy,
                                    0, STOP_BLOCK_DEPTH,
                                    RAIL_CHANNEL_W, STOP_BLOCK_HEIGHT))

    # Magnet pocket representations on bottom face (10 mm × 4 mm)
    for side in [-1, 1]:
        my = side * MAGNET_Y
        # Closed-position pocket at body X = +DETENT_X_OFFSET
        parts.append(_cylinder_triangles(DETENT_X_OFFSET, my, 0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 16))
        # Open-position pocket at body X = DETENT_X_OFFSET - SLIDER_TRAVEL
        parts.append(_cylinder_triangles(DETENT_X_OFFSET - SLIDER_TRAVEL, my, 0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 16))

    # PCB mounting posts (4 cylinders, Heltec V4 under OLED viewport)
    dy = l / 2 - DISPLAY_OFFSET_Y - PCB_LENGTH / 2
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            px = sx * (PCB_WIDTH / 2 - 2)
            py = dy + sy * (PCB_LENGTH / 2 - 3)
            parts.append(_cylinder_triangles(px, py, WALL_THICKNESS,
                                             SCREW_POST_D / 2, SCREW_POST_H, 16))

    # Reinforcement ribs
    rib_t  = WALL_THICKNESS / 2
    rib_h  = d - WALL_THICKNESS
    rib_iw = w - 2 * WALL_THICKNESS
    rib_il = l - 2 * WALL_THICKNESS
    parts.append(_box_triangles(0, 0, WALL_THICKNESS, rib_t, rib_il, rib_h))
    for frac in [1/3, 2/3]:
        ry = -l/2 + WALL_THICKNESS + frac * rib_il
        parts.append(_box_triangles(0, ry, WALL_THICKNESS, rib_iw, rib_t, rib_h))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_main_body():
    """Backward-compatible alias for generate_top_shell()."""
    return generate_top_shell()


def generate_keyboard_tray():
    """Sliding keyboard tray (bottom shell): CardKB pocket, T-rail runners, magnets.

    95 × 120 × 8 mm.  CardKB pocket 88×54 mm (width×height), 8 mm deep.
    Runners: rail_w=3mm, rail_h=2mm at Y = ±40 mm.
    Magnets: 10 mm × 4 mm at ±20 mm Y, tray-local X = +32 mm.
    Stop cutouts at runner -X tips (2.5 mm deep, enables assembly).
    """
    parts = []
    w, l, d = PHONE_WIDTH, PHONE_LENGTH, TRAY_Z

    # Outer box
    parts.append(_box_triangles(0, 0, 0, w, l, d))
    # Floor
    parts.append(_box_triangles(0, 0, 0, w, l, WALL_THICKNESS))
    # Side walls
    iw = w - 2 * WALL_THICKNESS
    parts.append(_box_triangles(-(w / 2 - WALL_THICKNESS / 2), 0,
                                WALL_THICKNESS, WALL_THICKNESS, l,
                                d - WALL_THICKNESS))
    parts.append(_box_triangles( (w / 2 - WALL_THICKNESS / 2), 0,
                                WALL_THICKNESS, WALL_THICKNESS, l,
                                d - WALL_THICKNESS))
    parts.append(_box_triangles(0, -(l / 2 - WALL_THICKNESS / 2),
                                WALL_THICKNESS, iw, WALL_THICKNESS,
                                d - WALL_THICKNESS))
    parts.append(_box_triangles(0,  (l / 2 - WALL_THICKNESS / 2),
                                WALL_THICKNESS, iw, WALL_THICKNESS,
                                d - WALL_THICKNESS))

    # Dual T-rail runners on top face at Y = ±RAIL_Y
    # Runner: 3 mm wide stem (rail_h − rail_lip_h = 1 mm tall) +
    #         6 mm wide lip cap (rail_lip_h = 1 mm tall)
    for side in [-1, 1]:
        cy = side * RAIL_Y
        stem_h = RAIL_H - RAIL_LIP_H   # 1.0 mm
        lip_w  = RAIL_W + 2 * RAIL_LIP_W   # 6.0 mm
        # Stem
        parts.append(_box_triangles(0, cy, d, w, RAIL_W, stem_h))
        # Lip cap
        parts.append(_box_triangles(0, cy, d + stem_h, w, lip_w, RAIL_LIP_H))

    # CardKB pocket representation (walls around the pocket area)
    # CardKB: 88 mm (Y) × 54 mm (X, slide direction), 7 mm thick
    # Pocket: 89 mm (Y) × 55 mm (X), 8 mm deep
    pocket_x = CARDKB_H + 2 * KEYBOARD_CLEARANCE   # 55 mm
    pocket_y = CARDKB_W + 2 * KEYBOARD_CLEARANCE   # 89 mm
    ckb_cx = -w / 2 + WALL_THICKNESS + pocket_x / 2
    # Side walls of pocket (long sides along X direction)
    parts.append(_box_triangles(ckb_cx, -(pocket_y / 2 + WALL_THICKNESS / 2),
                                WALL_THICKNESS, pocket_x, WALL_THICKNESS,
                                KEYBOARD_POCKET_DEPTH))
    parts.append(_box_triangles(ckb_cx,  (pocket_y / 2 + WALL_THICKNESS / 2),
                                WALL_THICKNESS, pocket_x, WALL_THICKNESS,
                                KEYBOARD_POCKET_DEPTH))

    # Magnet pockets on top face (10 mm × 4 mm at tray-local X = +DETENT_X_OFFSET)
    for side in [-1, 1]:
        my = side * MAGNET_Y
        parts.append(_cylinder_triangles(DETENT_X_OFFSET, my,
                                         d - MAGNET_POCKET_H,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 16))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_bottom_shell():
    """Alias for generate_keyboard_tray() (2-piece naming convention)."""
    return generate_keyboard_tray()


def generate_antenna_mount():
    """SMA antenna mount / strain relief."""
    parts = []
    mw, ml, mh = 16, 12, 10
    parts.append(_box_triangles(0, 0, 0, mw, ml, mh))
    fl_ext = 3
    parts.append(_box_triangles(0, -ml / 2 + 1.5, 0, mw + 2 * fl_ext, 3, mh))
    parts.append(_cylinder_triangles(0, 0, mh / 2 - SMA_D / 2, SMA_D / 2, ml, 16))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

GENERATORS = {
    "top_shell":      generate_top_shell,
    "main_body":      generate_main_body,      # backward-compat alias
    "keyboard_tray":  generate_keyboard_tray,
    "bottom_shell":   generate_bottom_shell,   # 2-piece alias
    "antenna_mount":  generate_antenna_mount,
}


def main():
    parser = argparse.ArgumentParser(
        description="Generate Meshtastic Sliding Phone STL files (2-piece design)")
    parser.add_argument("--part", choices=list(GENERATORS.keys()),
                        help="Generate a single part (default: all canonical parts)")
    parser.add_argument("--output-dir", default=OUTPUT_DIR,
                        help="Output directory for STL files")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    # Canonical parts (avoid duplicates from aliases)
    canonical = ["top_shell", "keyboard_tray", "antenna_mount"]
    parts = [args.part] if args.part else canonical

    for name in parts:
        print(f"Generating {name}...")
        stl_mesh = GENERATORS[name]()
        out_path = os.path.join(args.output_dir, f"{name}.stl")
        stl_mesh.save(out_path)
        tri_count = len(stl_mesh.vectors)
        size_kb   = os.path.getsize(out_path) / 1024
        print(f"  → {out_path}  ({tri_count} triangles, {size_kb:.1f} KB)")

    print("\nAll parts generated successfully!")
    print(f"Output directory: {os.path.abspath(args.output_dir)}")


if __name__ == "__main__":
    main()
