#!/usr/bin/env python3
"""
Meshtastic Sliding Phone - STL Generator
=========================================
Generates printable STL mesh files for all phone components using numpy-stl.
Run this script to produce STL files without needing OpenSCAD installed.

Usage:
    python3 generate_stl.py           # Generate all STL files
    python3 generate_stl.py --part top_shell   # Generate a single part

Output directory: ../stl/
"""

import argparse
import os
import sys
import numpy as np
from stl import mesh

# ---------------------------------------------------------------------------
# Parameters (mirrors parameters.scad)
# ---------------------------------------------------------------------------
PHONE_LENGTH = 120.0
PHONE_WIDTH = 74.0
PHONE_THICKNESS = 15.0

WALL = 1.8
CORNER_R = 4.0
CLEARANCE = 0.3

# Heltec V4 built-in 0.96" OLED viewport
DISPLAY_W = 21.0
DISPLAY_H = 11.0
DISPLAY_OFFSET_Y = 15.0
DISPLAY_DEPTH = 2.0

# Heltec WiFi LoRa 32 V4 board
PCB_LENGTH = 55.0
PCB_WIDTH = 27.0

# LiPo battery (503450)
LIPO_THICKNESS = 6.0
LIPO_WIDTH = 35.0
LIPO_LENGTH = 51.0

# CardKB keyboard module (M5Stack CardKB) — nominal + tolerance
CARDKB_LENGTH = 59.0    # 58.2 mm nominal + 0.8 mm tolerance
CARDKB_WIDTH = 28.0     # 27.6 mm nominal + 0.4 mm tolerance
CARDKB_THICKNESS = 8.0  # 7.5 mm nominal + 0.5 mm tolerance

KEYBOARD_TRAVEL = 35.0

RAIL_W = 4.0
RAIL_H = 2.0

SMA_D = 6.5
USBC_W = 9.5
USBC_H = 3.5

TOP_Z = PHONE_THICKNESS / 2
BOT_Z = PHONE_THICKNESS / 2
BOT_LENGTH = PHONE_LENGTH + KEYBOARD_TRAVEL

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "models", "stl")


# ---------------------------------------------------------------------------
# Mesh helpers
# ---------------------------------------------------------------------------

def _box_triangles(cx, cy, cz, w, h, d):
    """Return 12 triangles (vertices array) for an axis-aligned box centered at (cx,cy,cz)."""
    x0, x1 = cx - w / 2, cx + w / 2
    y0, y1 = cy - h / 2, cy + h / 2
    z0, z1 = cz, cz + d

    verts = np.array([
        [x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0],  # bottom
        [x0, y0, z1], [x1, y0, z1], [x1, y1, z1], [x0, y1, z1],  # top
    ])
    # 12 triangles = 6 faces * 2 tris
    faces = np.array([
        [0,2,1], [0,3,2],  # bottom
        [4,5,6], [4,6,7],  # top
        [0,1,5], [0,5,4],  # front
        [1,2,6], [1,6,5],  # right
        [2,3,7], [2,7,6],  # back
        [3,0,4], [3,4,7],  # left
    ])
    return verts, faces


def _cylinder_triangles(cx, cy, z0, r, h, n=24):
    """Return triangles for a cylinder centered at (cx,cy) from z0 to z0+h."""
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    cos_a = np.cos(angles)
    sin_a = np.sin(angles)

    # Bottom center = index 0, Top center = index 1
    # Bottom ring = 2..n+1, Top ring = n+2..2n+1
    verts = [[cx, cy, z0], [cx, cy, z0 + h]]
    for i in range(n):
        verts.append([cx + r * cos_a[i], cy + r * sin_a[i], z0])
    for i in range(n):
        verts.append([cx + r * cos_a[i], cy + r * sin_a[i], z0 + h])
    verts = np.array(verts)

    faces = []
    for i in range(n):
        j = (i + 1) % n
        bi, bj = 2 + i, 2 + j
        ti, tj = 2 + n + i, 2 + n + j
        # Bottom fan
        faces.append([0, bj, bi])
        # Top fan
        faces.append([1, ti, tj])
        # Side quads (2 tris)
        faces.append([bi, bj, tj])
        faces.append([bi, tj, ti])
    return verts, np.array(faces)


def _combine_meshes(parts):
    """Combine multiple (verts, faces) tuples into a single mesh."""
    all_verts = []
    all_faces = []
    offset = 0
    for v, f in parts:
        all_verts.append(v)
        all_faces.append(f + offset)
        offset += len(v)
    all_verts = np.vstack(all_verts)
    all_faces = np.vstack(all_faces)
    return all_verts, all_faces


def _make_stl(verts, faces):
    """Create an stl.mesh.Mesh from vertices and face indices."""
    m = mesh.Mesh(np.zeros(len(faces), dtype=mesh.Mesh.dtype))
    for i, f in enumerate(faces):
        for j in range(3):
            m.vectors[i][j] = verts[f[j]]
    return m


# ---------------------------------------------------------------------------
# Part generators
# ---------------------------------------------------------------------------

def generate_top_shell():
    """Generate the top sliding shell mesh."""
    parts = []
    w, l, d = PHONE_WIDTH, PHONE_LENGTH, TOP_Z

    # Outer box
    parts.append(_box_triangles(0, 0, 0, w, l, d))

    # Inner cavity (slightly smaller, acts as visual representation)
    # For a proper boolean subtract we'd need CSG; here we add the shell
    # walls as separate boxes to create a hollow appearance when printed.
    iw = w - 2 * WALL
    il = l - 2 * WALL

    # Floor
    parts.append(_box_triangles(0, 0, 0, w, l, WALL))

    # Side walls
    parts.append(_box_triangles(-(w/2 - WALL/2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles( (w/2 - WALL/2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles(0, -(l/2 - WALL/2), WALL, iw, WALL, d - WALL))
    parts.append(_box_triangles(0,  (l/2 - WALL/2), WALL, iw, WALL, d - WALL))

    # Slide rails (two dovetail-like rails on bottom)
    rail_d = RAIL_H
    rail_l = l - 20
    for side in [-1, 1]:
        rx = side * (w / 2 - WALL - RAIL_W / 2)
        parts.append(_box_triangles(rx, 0, -rail_d, RAIL_W, rail_l, rail_d))

    # PCB mounting posts (4 cylinders, align Heltec V4 under OLED viewport)
    dy_center = l / 2 - DISPLAY_OFFSET_Y - PCB_LENGTH / 2
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            px = sx * (PCB_WIDTH / 2 - 2)
            py = dy_center + sy * (PCB_LENGTH / 2 - 3)
            parts.append(_cylinder_triangles(px, py, WALL, 2.5, 6, 16))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_bottom_shell():
    """Generate the bottom shell mesh with CardKB pocket and PCB mounts."""
    parts = []
    w = PHONE_WIDTH
    l = BOT_LENGTH
    d = BOT_Z

    # Outer box
    parts.append(_box_triangles(0, 0, 0, w, l, d))

    # Floor
    parts.append(_box_triangles(0, 0, 0, w, l, WALL))

    # Side walls
    iw = w - 2 * WALL
    parts.append(_box_triangles(-(w/2 - WALL/2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles( (w/2 - WALL/2), 0, WALL, WALL, l, d - WALL))
    parts.append(_box_triangles(0, -(l/2 - WALL/2), WALL, iw, WALL, d - WALL))
    parts.append(_box_triangles(0,  (l/2 - WALL/2), WALL, iw, WALL, d - WALL))

    # Rail guides (raised walls for sliding channel)
    guide_h = RAIL_H + WALL
    for side in [-1, 1]:
        gx = side * (w / 2 - WALL / 2)
        parts.append(_box_triangles(gx, 0, d, WALL, l, guide_h))

    # PCB mounting posts (4 cylinders, Heltec V4)
    pcb_cy = l / 2 - 14 - PCB_LENGTH / 2
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            px = sx * (PCB_WIDTH / 2 - 2)
            py = pcb_cy + sy * (PCB_LENGTH / 2 - 2)
            parts.append(_cylinder_triangles(px, py, WALL, 2.5, 6, 16))

    # Slide end-stops
    for side in [-1, 1]:
        sx = side * (w / 2 - WALL - RAIL_W / 2)
        parts.append(_box_triangles(sx, l / 2 - 1.5, d, RAIL_W + 2, 3, guide_h))

    # CardKB pocket (rectangular recess for the keyboard module)
    ckb_cy = -l / 2 + WALL + CARDKB_WIDTH / 2 + 3
    parts.append(_box_triangles(0, ckb_cy, WALL,
                                CARDKB_LENGTH + 2 * CLEARANCE,
                                CARDKB_WIDTH  + 2 * CLEARANCE,
                                CARDKB_THICKNESS + 1))

    # CardKB retention ledges (two small lips to keep module in pocket)
    for side in [-1, 1]:
        lx = side * (CARDKB_LENGTH / 2 + CLEARANCE + 1)
        parts.append(_box_triangles(lx, ckb_cy,
                                    WALL + CARDKB_THICKNESS + 1,
                                    2, CARDKB_WIDTH, 1.5))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_battery_cover():
    """Generate the snap-fit LiPo battery door."""
    parts = []
    cw = LIPO_WIDTH + 8
    cl = LIPO_LENGTH + 8
    ch = 1.5

    # Main plate
    parts.append(_box_triangles(0, 0, 0, cw, cl, ch))

    # Perimeter lip
    lip_w = cw - 1
    lip_l = cl - 1
    lip_h = 1.5
    lip_t = WALL
    parts.append(_box_triangles(-(lip_w/2 - lip_t/2), 0, ch, lip_t, lip_l, lip_h))
    parts.append(_box_triangles( (lip_w/2 - lip_t/2), 0, ch, lip_t, lip_l, lip_h))
    parts.append(_box_triangles(0, -(lip_l/2 - lip_t/2), ch, lip_w - 2*lip_t, lip_t, lip_h))
    parts.append(_box_triangles(0,  (lip_l/2 - lip_t/2), ch, lip_w - 2*lip_t, lip_t, lip_h))

    # Snap tabs
    tab_w, tab_l, tab_h = 3, 6, 2
    for end in [-1, 1]:
        ty = end * (cl / 2 - tab_l / 2 - 1)
        parts.append(_box_triangles(0, ty, ch, tab_w, tab_l, tab_h))
        # Hook
        parts.append(_box_triangles(0, ty + end * tab_l / 2, ch + tab_h - 0.3, tab_w, 1, 0.6))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_antenna_mount():
    """Generate the SMA antenna mount / strain relief."""
    parts = []
    mw, ml, mh = 16, 12, 10

    # Main body
    parts.append(_box_triangles(0, 0, 0, mw, ml, mh))

    # Flange
    fl_ext = 3
    fl_h = 3
    parts.append(_box_triangles(0, -ml/2 + fl_h/2, 0, mw + 2*fl_ext, fl_h, mh))

    # SMA tube (representative cylinder)
    parts.append(_cylinder_triangles(0, 0, mh/2 - SMA_D/2, SMA_D/2, ml, 16))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

GENERATORS = {
    "top_shell":      generate_top_shell,
    "bottom_shell":   generate_bottom_shell,
    "battery_cover":  generate_battery_cover,
    "antenna_mount":  generate_antenna_mount,
}


def main():
    parser = argparse.ArgumentParser(description="Generate Meshtastic Sliding Phone STL files")
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
        size_kb = os.path.getsize(out_path) / 1024
        print(f"  → {out_path}  ({tri_count} triangles, {size_kb:.1f} KB)")

    print("\nAll parts generated successfully!")
    print(f"Output directory: {os.path.abspath(args.output_dir)}")


if __name__ == "__main__":
    main()
