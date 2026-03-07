#!/usr/bin/env python3
"""
Meshtastic Sliding Phone - STL Generator
=========================================
Generates printable STL mesh files for all phone components using numpy-stl.
Run this script to produce STL files without needing OpenSCAD installed.

DESIGN (2-piece)
  main_body     – unified enclosure (display, PCB, battery, rails, ports)
  keyboard_tray – sliding keyboard carriage (CardKB, T-runners, magnets)

Mechanism: shortways (X-axis) magnetic-detent slider with captured-lip T-slot rails.
  • Two parallel T-shaped rail runners on the keyboard-tray top face run along
    the X axis (the 74 mm short side) and slide inside matching T-slot channels
    in the main-body underside, positioned at Y = ±RAIL_Y (±40 mm).
  • Each runner has a narrow stem and a wider lip cap at the top.  The matching
    T-slot channel captures the lip vertically so the tray cannot tilt away from
    the phone body mid-slide.  Dual-rail geometry eliminates rotational tilt.
  • Holding the phone landscape (120 mm wide × 74 mm tall), the keyboard
    slides downward — exactly like a Nokia N900.
  • Neodymium 5 mm × 2 mm disc magnets press-fitted (with retention lips) in
    both faces snap the tray into closed and open positions.
  • A shallow snap ramp in the last 5 mm of travel creates the "self-finish"
    snap-open feel; the magnet detent reinforces the final click.
  • Over-travel stop tabs on the runners contact stop walls at the body −X face,
    preventing the tray from sliding out during normal operation.

Usage:
    python3 generate_stl.py                     # Generate all parts
    python3 generate_stl.py --part main_body    # Single part

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
PHONE_WIDTH      =  74.0

WALL_THICKNESS   =   2.2
WALL             =   WALL_THICKNESS
CLEARANCE        =   0.3
CORNER_R         =   4.0

# Component heights
TOP_SHELL_Z  =  10.0   # used in body_z
BOT_SHELL_Z  =   9.0   # used in body_z and port Z positions
BODY_Z       =  TOP_SHELL_Z + BOT_SHELL_Z  # 19 mm – unified main body
TRAY_Z       =   8.0   # keyboard tray
PHONE_THICKNESS = BODY_Z + TRAY_Z   # 27 mm

# Display (Heltec V4 OLED 0.96″; viewport sized for optional touch overlay)
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

# CardKB keyboard module
CARDKB_LENGTH    =  59.0
CARDKB_WIDTH     =  28.0
CARDKB_THICKNESS =   7.0

# Slider travel (shortways, −X direction)
SLIDER_TRAVEL    =  35.0
KEYBOARD_TRAVEL  =  SLIDER_TRAVEL   # alias

# --- Rail system (T-slot captured-lip; runners run along X axis at Y = ±RAIL_Y) ---
RAIL_W          =  4.0
RAIL_H          =  2.5
RAIL_Y          = 40.0
RAIL_LIP_H      =  1.0
RAIL_LIP_W      =  1.5
RAIL_CLEARANCE  =  0.35
RAIL_ENTRY_CHAMFER = 0.6
RAIL_CHAMFER    = RAIL_ENTRY_CHAMFER
RAIL_CHANNEL_W  = RAIL_W + 2 * RAIL_CLEARANCE   # 4.7 mm
RAIL_CHANNEL_H  = RAIL_H + 1.0                  # 3.5 mm
RAIL_HEIGHT     = RAIL_CHANNEL_H

# Snap-ramp near the open-position end
SNAP_RAMP_X     =  5.0
SNAP_RAMP_Z     =  0.4

# --- Neodymium magnet detents (5 mm × 2 mm disc, N35) ---
MAGNET_DIAMETER  =  5.0
MAGNET_HEIGHT    =  2.0
MAGNET_PRESS_FIT =  0.1
MAGNET_OFFSET    =  0.2
MAGNET_POCKET_D  = MAGNET_DIAMETER - MAGNET_PRESS_FIT   # 4.9 mm
MAGNET_POCKET_H  = MAGNET_HEIGHT + 0.5                  # 2.5 mm
MAGNET_Y         = 20.0
DETENT_X_OFFSET  = 28.0

# --- End-stop tab dimensions ---
TAB_W_EXTRA     =  2.0
TAB_DEPTH       =  3.0
TAB_HEIGHT_EXT  =  1.5
TAB_STOP_MARGIN =  2.0

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

def generate_main_body():
    """Unified 2-piece enclosure: display face, PCB bay, battery cavity, T-slot rails.

    Replaces the former top_shell + bottom_shell + battery_cover assembly.
    The keyboard tray slides underneath along two captured-lip T-slot channels.
    """
    parts = []
    w, l, d = PHONE_WIDTH, PHONE_LENGTH, BODY_Z

    # Outer box (simplified – interior cavity approximated via wall boxes)
    parts.append(_box_triangles(0, 0, 0, w, l, d))

    # Top plate
    parts.append(_box_triangles(0, 0, d - WALL_THICKNESS, w, l, WALL_THICKNESS))

    # Side walls (four perimeter walls, wall_thickness thick, body_z tall)
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

    # Floor (wall_thickness at Z=0 — provides material for T-slot channels)
    parts.append(_box_triangles(0, 0, 0, w, l, WALL_THICKNESS))

    # T-slot rail channel representations (X-axis slots on underside at Y = ±RAIL_Y)
    # Shown as the full T-slot void width (lip + stem) as a visual approximation.
    t_slot_w = RAIL_CHANNEL_W + 2 * RAIL_LIP_W   # 7.7 mm total void width
    for side in [-1, 1]:
        cy = side * RAIL_Y
        parts.append(_box_triangles(0, cy, 0, w, t_slot_w, RAIL_CHANNEL_H))

    # Magnet pocket representations on bottom face (press-fit bore, 5 mm × 2 mm)
    for side in [-1, 1]:
        my = side * MAGNET_Y
        # Closed-position pocket
        parts.append(_cylinder_triangles(DETENT_X_OFFSET, my, 0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 12))
        # Open-position pocket (body X = DETENT_X_OFFSET - SLIDER_TRAVEL)
        parts.append(_cylinder_triangles(DETENT_X_OFFSET - SLIDER_TRAVEL, my, 0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 12))

    # PCB mounting posts (4 cylinders, Heltec V4 under OLED viewport)
    dy = l / 2 - DISPLAY_OFFSET_Y - PCB_LENGTH / 2
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            px = sx * (PCB_WIDTH / 2 - 2)
            py = dy + sy * (PCB_LENGTH / 2 - 3)
            parts.append(_cylinder_triangles(px, py, WALL_THICKNESS,
                                             SCREW_POST_D / 2, SCREW_POST_H, 16))

    # Reinforcement ribs (longitudinal + two lateral, approximated as boxes)
    rib_t  = WALL_THICKNESS / 2
    rib_h  = d - WALL_THICKNESS
    rib_iw = w - 2 * WALL_THICKNESS
    rib_il = l - 2 * WALL_THICKNESS
    # Longitudinal rib (along Y)
    parts.append(_box_triangles(0, 0, WALL_THICKNESS, rib_t, rib_il, rib_h))
    # Lateral ribs (along X at 1/3 and 2/3 of interior Y)
    for frac in [1/3, 2/3]:
        ry = -l/2 + WALL_THICKNESS + frac * rib_il
        parts.append(_box_triangles(0, ry, WALL_THICKNESS, rib_iw, rib_t, rib_h))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_keyboard_tray():
    """Sliding keyboard tray: CardKB pocket, dual T-rail runners, press-fit magnet pockets."""
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

    # Dual anti-tilt T-shaped rail runners on top face at Y = ±RAIL_Y.
    # The ±40 mm separation constrains rotational tilt (anti-tilt system).
    for side in [-1, 1]:
        cy = side * RAIL_Y
        stem_h = RAIL_H - RAIL_LIP_H
        lip_w  = RAIL_W + 2 * RAIL_LIP_W
        # Stem
        parts.append(_box_triangles(0, cy, d, w, RAIL_W, stem_h))
        # Lip cap (wider, at the top of the runner)
        parts.append(_box_triangles(0, cy, d + stem_h, w, lip_w, RAIL_LIP_H))

    # End-stop tabs (open-position stops on −X end of runners)
    # Tab contact occurs at travel = SLIDER_TRAVEL − TAB_STOP_MARGIN.
    tab_lead_x = -w / 2 + SLIDER_TRAVEL - TAB_STOP_MARGIN
    tab_cx     = tab_lead_x + TAB_DEPTH / 2
    for side in [-1, 1]:
        cy = side * RAIL_Y
        parts.append(_box_triangles(tab_cx, cy, d,
                                    TAB_DEPTH,
                                    RAIL_CHANNEL_W + TAB_W_EXTRA,
                                    RAIL_H + TAB_HEIGHT_EXT))

    # CardKB pocket representation (raised walls around pocket area)
    # CardKB long axis (59 mm) along Y; short axis (28 mm) along X
    ckb_cx = -w / 2 + WALL_THICKNESS + CARDKB_WIDTH / 2
    ckb_w  = CARDKB_WIDTH  + 2 * CLEARANCE
    ckb_l  = CARDKB_LENGTH + 2 * CLEARANCE
    parts.append(_box_triangles(ckb_cx, -(ckb_l / 2 + WALL_THICKNESS / 2),
                                WALL_THICKNESS, ckb_w, WALL_THICKNESS,
                                CARDKB_THICKNESS))
    parts.append(_box_triangles(ckb_cx,  (ckb_l / 2 + WALL_THICKNESS / 2),
                                WALL_THICKNESS, ckb_w, WALL_THICKNESS,
                                CARDKB_THICKNESS))

    # Magnet pockets on top face (press-fit, 5 mm × 2 mm, at X = +DETENT_X_OFFSET)
    for side in [-1, 1]:
        my = side * MAGNET_Y
        parts.append(_cylinder_triangles(DETENT_X_OFFSET, my,
                                         d - MAGNET_POCKET_H,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 12))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


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
    "main_body":      generate_main_body,
    "keyboard_tray":  generate_keyboard_tray,
    "antenna_mount":  generate_antenna_mount,
}


def main():
    parser = argparse.ArgumentParser(
        description="Generate Meshtastic Sliding Phone STL files (2-piece design)")
    parser.add_argument("--part", choices=list(GENERATORS.keys()),
                        help="Generate a single part (default: all)")
    parser.add_argument("--output-dir", default=OUTPUT_DIR,
                        help="Output directory for STL files")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    parts = [args.part] if args.part else list(GENERATORS.keys())

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
