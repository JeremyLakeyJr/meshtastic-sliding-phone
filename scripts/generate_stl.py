#!/usr/bin/env python3
"""
Meshtastic Sliding Phone - STL Generator
=========================================
Generates printable STL mesh files for all phone components using numpy-stl.
Run this script to produce STL files without needing OpenSCAD installed.

Mechanism: horizontal magnetic-detent slider.
  • Two parallel rectangular rail runners on the keyboard-tray top face
    slide inside matching channels in the bottom-shell underside.
  • Neodymium disc magnets recessed in both faces snap the tray into the
    closed and open positions and provide Z-axis retention during sliding.

Usage:
    python3 generate_stl.py                         # Generate all parts
    python3 generate_stl.py --part keyboard_tray    # Single part

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
PHONE_THICKNESS  =  27.0   # top_shell_z + bot_shell_z + tray_z

WALL             =   2.0
CLEARANCE        =   0.3
CORNER_R         =   4.0

# Display (Heltec V4 OLED 0.96″)
DISPLAY_W        =  21.0
DISPLAY_H        =  11.0
DISPLAY_OFFSET_Y =  12.0
DISPLAY_DEPTH    =   2.0

# Heltec WiFi LoRa 32 V4 PCB
PCB_LENGTH       =  55.0
PCB_WIDTH        =  27.0

# LiPo battery (slim pouch, ~50×40×5 mm nominal)
LIPO_THICKNESS   =   6.0
LIPO_WIDTH       =  42.0
LIPO_LENGTH      =  52.0

# CardKB keyboard module
CARDKB_LENGTH    =  59.0
CARDKB_WIDTH     =  28.0
CARDKB_THICKNESS =   7.0

KEYBOARD_TRAVEL  =  42.0

# --- Shell heights ---
TOP_Z  =  10.0   # top shell
BOT_Z  =   9.0   # bottom shell
TRAY_Z =   8.0   # keyboard tray

# --- Rail system ---
RAIL_W          =  4.0
RAIL_H          =  2.5
RAIL_X          = 32.0
RAIL_CHANNEL_W  = RAIL_W + 2 * CLEARANCE          # 4.6 mm
RAIL_CHANNEL_H  = RAIL_H + 1.0                    # 3.5 mm

# --- Neodymium magnet detents ---
MAGNET_D        =  5.0
MAGNET_H        =  2.0
MAGNET_POCKET_D =  5.2
MAGNET_POCKET_H =  2.5
MAGNET_X        = 16.0
DETENT_Y_OFFSET = 35.0

# --- End-stop tab dimensions (keyboard tray open-position mechanical stop) ---
# The tab's leading (−Y) face hits the phone body's −Y wall, stopping the
# tray TAB_STOP_MARGIN mm before the theoretical maximum travel so the tray
# doesn't slam against the hard stop.
TAB_W_EXTRA     =  2.0   # mm wider than the channel (1 mm per side) – cannot pass through opening
TAB_DEPTH       =  3.0   # mm Y extent – provides adequate bearing surface
TAB_HEIGHT_EXT  =  1.5   # mm extra height above rail_h – ensures positive engagement
TAB_STOP_MARGIN =  2.0   # mm safety margin before maximum travel

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
    """12 triangles for an axis-aligned box with bottom-left-front at (cx-w/2, cy-h/2, cz)."""
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
    """Top half of the phone body: display face, Heltec V4 PCB, buttons."""
    parts = []
    w, l, d = PHONE_WIDTH, PHONE_LENGTH, TOP_Z

    # Outer box
    parts.append(_box_triangles(0, 0, 0, w, l, d))
    # Floor
    parts.append(_box_triangles(0, 0, 0, w, l, WALL))
    # Side walls
    iw = w - 2 * WALL
    parts.append(_box_triangles(-(w / 2 - WALL / 2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles( (w / 2 - WALL / 2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles(0, -(l / 2 - WALL / 2), WALL, iw, WALL, d - WALL))
    parts.append(_box_triangles(0,  (l / 2 - WALL / 2), WALL, iw, WALL, d - WALL))

    # PCB mounting posts (4 cylinders, Heltec V4 under OLED viewport)
    dy = l / 2 - DISPLAY_OFFSET_Y - PCB_LENGTH / 2
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            px = sx * (PCB_WIDTH / 2 - 2)
            py = dy + sy * (PCB_LENGTH / 2 - 3)
            parts.append(_cylinder_triangles(px, py, WALL, SCREW_POST_D / 2, SCREW_POST_H, 16))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_bottom_shell():
    """Bottom half of the phone body: battery, ports, rail channels, magnet pockets."""
    parts = []
    w, l, d = PHONE_WIDTH, PHONE_LENGTH, BOT_Z

    # Outer box
    parts.append(_box_triangles(0, 0, 0, w, l, d))
    # Floor (solid bottom wall — rail channels are cut in it, simplified here)
    parts.append(_box_triangles(0, 0, 0, w, l, WALL))
    # Side walls
    iw = w - 2 * WALL
    parts.append(_box_triangles(-(w / 2 - WALL / 2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles( (w / 2 - WALL / 2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles(0, -(l / 2 - WALL / 2), WALL, iw, WALL, d - WALL))
    parts.append(_box_triangles(0,  (l / 2 - WALL / 2), WALL, iw, WALL, d - WALL))

    # Rail channel representations (rectangular slots on underside, simplified)
    for side in [-1, 1]:
        cx = side * RAIL_X
        parts.append(_box_triangles(cx, 0, 0, RAIL_CHANNEL_W, l, RAIL_CHANNEL_H))

    # Magnet pocket representations (cylinders on underside, simplified)
    for side in [-1, 1]:
        mx = side * MAGNET_X
        # Closed-position pocket
        parts.append(_cylinder_triangles(mx,  DETENT_Y_OFFSET,             0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 12))
        # Open-position pocket
        parts.append(_cylinder_triangles(mx,  DETENT_Y_OFFSET - KEYBOARD_TRAVEL, 0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 12))

    # Corner screw posts (join to top shell)
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            px = sx * (w / 2 - 8)
            py = sy * (l / 2 - 8)
            parts.append(_cylinder_triangles(px, py, d, SCREW_POST_D / 2, SCREW_POST_H, 16))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_keyboard_tray():
    """Sliding keyboard tray: CardKB pocket, rail runners, magnet pockets."""
    parts = []
    w, l, d = PHONE_WIDTH, PHONE_LENGTH, TRAY_Z

    # Outer box
    parts.append(_box_triangles(0, 0, 0, w, l, d))
    # Floor
    parts.append(_box_triangles(0, 0, 0, w, l, WALL))
    # Side walls
    iw = w - 2 * WALL
    parts.append(_box_triangles(-(w / 2 - WALL / 2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles( (w / 2 - WALL / 2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles(0, -(l / 2 - WALL / 2), WALL, iw, WALL, d - WALL))
    parts.append(_box_triangles(0,  (l / 2 - WALL / 2), WALL, iw, WALL, d - WALL))

    # Rail runners (two rectangular bars on top face)
    for side in [-1, 1]:
        cx = side * RAIL_X
        parts.append(_box_triangles(cx, 0, d, RAIL_W, l, RAIL_H))

    # End-stop tabs (open-position stops)
    # The tab's leading (−Y) face contacts the phone body −Y wall at
    # travel = KEYBOARD_TRAVEL − TAB_STOP_MARGIN (40 mm), providing a
    # 2 mm safety margin so the tray decelerates before the hard stop.
    # _box_triangles is centred on (cx, cy), so tab centre is offset by
    # TAB_DEPTH / 2 from the leading face position.
    tab_lead_y = -l / 2 + KEYBOARD_TRAVEL - TAB_STOP_MARGIN
    tab_cy     = tab_lead_y + TAB_DEPTH / 2
    for side in [-1, 1]:
        cx = side * RAIL_X
        parts.append(_box_triangles(cx, tab_cy, d,
                                    RAIL_CHANNEL_W + TAB_W_EXTRA,
                                    TAB_DEPTH,
                                    RAIL_H + TAB_HEIGHT_EXT))

    # CardKB pocket representation (raised walls around pocket area)
    ckb_cy = -l / 2 + WALL + CARDKB_WIDTH / 2
    ckb_w  = CARDKB_LENGTH + 2 * CLEARANCE
    ckb_l  = CARDKB_WIDTH  + 2 * CLEARANCE
    parts.append(_box_triangles(-(ckb_w / 2 + WALL / 2), ckb_cy, WALL,
                                WALL, ckb_l, CARDKB_THICKNESS))
    parts.append(_box_triangles( (ckb_w / 2 + WALL / 2), ckb_cy, WALL,
                                WALL, ckb_l, CARDKB_THICKNESS))

    # Magnet pockets on top face (cylinders, simplified representation)
    for side in [-1, 1]:
        mx = side * MAGNET_X
        parts.append(_cylinder_triangles(mx, DETENT_Y_OFFSET,
                                         d - MAGNET_POCKET_H,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 12))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_battery_cover():
    """Snap-fit LiPo battery door."""
    parts = []
    cw = LIPO_WIDTH + 8
    cl = LIPO_LENGTH + 8
    ch = 1.5

    # Main plate
    parts.append(_box_triangles(0, 0, 0, cw, cl, ch))
    # Perimeter lip
    lw, ll, lh, lt = cw - 1, cl - 1, 1.5, WALL
    parts.append(_box_triangles(-(lw / 2 - lt / 2), 0, ch, lt, ll, lh))
    parts.append(_box_triangles( (lw / 2 - lt / 2), 0, ch, lt, ll, lh))
    parts.append(_box_triangles(0, -(ll / 2 - lt / 2), ch, lw - 2 * lt, lt, lh))
    parts.append(_box_triangles(0,  (ll / 2 - lt / 2), ch, lw - 2 * lt, lt, lh))
    # Snap tabs
    tw, tl, th = 3, 6, 2
    for end in [-1, 1]:
        ty = end * (cl / 2 - tl / 2 - 1)
        parts.append(_box_triangles(0, ty, ch, tw, tl, th))
        parts.append(_box_triangles(0, ty + end * tl / 2, ch + th - 0.3, tw, 1, 0.6))

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
    "top_shell":      generate_top_shell,
    "bottom_shell":   generate_bottom_shell,
    "keyboard_tray":  generate_keyboard_tray,
    "battery_cover":  generate_battery_cover,
    "antenna_mount":  generate_antenna_mount,
}


def main():
    parser = argparse.ArgumentParser(
        description="Generate Meshtastic Sliding Phone STL files")
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
