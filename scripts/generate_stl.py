#!/usr/bin/env python3
"""
Meshtastic Sliding Phone - STL Generator
=========================================
Generates printable STL mesh files for all phone components using numpy-stl.
Run this script to produce STL files without needing OpenSCAD installed.

DESIGN (2-piece)
  top_shell     – unified enclosure (display, PCB, battery, rails, ports)
  keyboard_tray – sliding keyboard carriage (CardKB 88×54mm, dovetail runners, magnets)
  bottom_shell  – alias for keyboard_tray (2-piece naming convention)

Mechanism: shortways (X-axis) magnetic-detent slider with captured dovetail rails.
  • phone_width = 95 mm; slider_travel = 65 mm.
  • Two parallel dovetail runners (rail_top_width=1.2mm narrow base,
    rail_base_width=4mm wide cap, rail_height=3mm) on the keyboard-tray top face
    slide inside matching dovetail grooves in the top-shell underside,
    positioned at Y = ±RAIL_Y (±40 mm, spacing = 80 mm).
    Runner length = RAIL_LENGTH = 70 mm (at +X insertion end); shorter runner
    reduces cantilever flex at full extension (5 mm engagement at travel=65).
  • Groove: narrow opening 1.9mm → widens to 4.7mm at rail_height depth,
    plus CHANNEL_STANDOFF=2mm straight zone for passive ~3° typing angle.
  • Offset magnet detents (MAGNET_OFFSET = 6 mm):
      Tray pockets at tray-local X = DETENT_X_OFFSET = +32 mm.
      Body closed pocket at body-X = DETENT_X_OFFSET + MAGNET_OFFSET = +38 mm.
      Body open   pocket at body-X = DETENT_X_OFFSET − SLIDER_TRAVEL
                                     − MAGNET_OFFSET = −39 mm.
    The offset creates an X-component of magnetic force that guides the tray
    into position rather than opposing mid-travel motion.
  • Magnet pocket: 10.3 mm bore × 3.6 mm deep, 0.6 mm retention lip.
  • Stop blocks (2 mm tall, groove-opening-width wide) inside the rail grooves
    at body X ≈ −15.5 mm prevent accidental removal.  A matching stop_cutout
    (2.5 mm) at the runner −X tip allows initial assembly from the +X entry end.
  • Battery pocket: 71×51×9 mm (MakerFocus 3000 mAh, integrated in top shell).
  • Battery retention clips: BATTERY_CLIP_HEIGHT = 1.5 mm at pocket ±Y edges.
  • USB-C cutout: 11×4 mm.  Standoffs: 4×M2, height 4 mm, diameter 5 mm.
  • PCB platform: PLATFORM_THICKNESS = 2 mm (structural floor reinforcement).
  • Lightening pockets: POCKET_DEPTH = 1.5 mm on body bottom face.
  • Wire routing groove: 6×2 mm alongside +Y rail for CardKB flex cable.
  • CardKB pocket: 89×55 mm (width×height), 8 mm deep, 0.5 mm clearance.

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

# Battery pocket (MakerFocus 3000 mAh 3.7 V LiPo, ~70×50×8 mm nominal)
BATTERY_POCKET_X =  71.0   # pocket X dimension – per spec
BATTERY_POCKET_Y =  51.0   # pocket Y dimension – per spec
BATTERY_POCKET_Z =   9.0   # pocket depth – per spec

# Legacy LiPo (kept for reference)
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

# --- Dovetail rail system (per spec) ---
RAIL_BASE_WIDTH  =  4.0   # runner cap width (wide, free end) – per spec
RAIL_TOP_WIDTH   =  1.2   # runner base width (narrow, tray-attachment) – per spec
RAIL_HEIGHT      =  3.0   # runner height (Z) – per spec
RAIL_ANGLE       = 45.0   # reference dovetail side angle – per spec
RAIL_SPACING     = 80.0   # centre-to-centre Y spacing between rails – per spec
RAIL_Y           = RAIL_SPACING / 2   # ±40.0 mm

RAIL_CLEARANCE   =  0.35  # per-side clearance – per spec
CLEARANCE_START  =  0.30  # start of travel
CLEARANCE_MID    =  0.35  # mid-travel nominal
CLEARANCE_END    =  0.45  # end of travel (open)

RAIL_ENTRY_CHAMFER = 1.0  # per spec (was 0.6 mm)
RAIL_CHAMFER     = RAIL_ENTRY_CHAMFER

# Rail length: runners and grooves are RAIL_LENGTH mm (< full tray width).
# Shorter runner reduces cantilever flex at full extension.
RAIL_LENGTH      = 70.0   # per spec

CHANNEL_STANDOFF =  2.0   # extra groove depth beyond rail_height (passive tilt)

# Derived groove dimensions
RAIL_CHANNEL_W     = RAIL_TOP_WIDTH  + 2 * RAIL_CLEARANCE   # 1.9 mm – groove opening
RAIL_CHANNEL_INNER = RAIL_BASE_WIDTH + 2 * RAIL_CLEARANCE   # 4.7 mm – groove inner
RAIL_CHANNEL_H     = RAIL_HEIGHT + CHANNEL_STANDOFF          # 5.0 mm – total groove depth

# Pop-up (passive via CHANNEL_STANDOFF)
RAIL_SLOPE_ANGLE    =  3.0   # target typing angle degrees
MAXIMUM_LIFT_HEIGHT =  3.0   # maximum tray lift mm

# Stop / detent bumps
STOP_BUMP_HEIGHT =  1.2   # per spec
DETENT_HEIGHT    =  0.3   # per spec

# Wire routing tunnel
WIRE_TUNNEL_WIDTH  =  6.0   # per spec
WIRE_TUNNEL_HEIGHT =  2.0   # per spec

# --- End-stop blocks (inside rail grooves) – per spec ---
STOP_BLOCK_HEIGHT = 2.0   # block height above groove floor
STOP_CUTOUT       = 2.5   # runner -X tip cutout depth (enables assembly)
STOP_BLOCK_DEPTH  = 2.0   # stop block X-dimension
TAB_STOP_MARGIN   = 2.0   # travel margin before stop (mm before SLIDER_TRAVEL)

# Stop block +X face position in body frame:
# STOP_BLOCK_POS_X = -(SLIDER_TRAVEL - TAB_STOP_MARGIN - PHONE_WIDTH/2) = -15.5 mm
STOP_BLOCK_POS_X = -(SLIDER_TRAVEL - TAB_STOP_MARGIN - PHONE_WIDTH / 2)

# Legacy tab stop (kept for backward compat)
TAB_W_EXTRA     =  2.0
TAB_DEPTH       =  3.0
TAB_HEIGHT_EXT  =  1.5

# --- Ports (per spec) ---
SMA_D    =  6.5
USBC_W   = 11.0   # per spec (was 9.5 mm)
USBC_H   =  4.0   # per spec (was 3.5 mm)

# --- Standoffs / screw posts (per spec) ---
STANDOFF_HEIGHT   =  4.0   # per spec (was 5.0 mm)
STANDOFF_DIAMETER =  5.0   # per spec
SCREW_HOLE_D      =  2.2
SCREW_POST_D      =  STANDOFF_DIAMETER
SCREW_POST_H      =  STANDOFF_HEIGHT   # alias

# --- Antenna keepout ---
ANTENNA_KEEPOUT_RADIUS = 12.0  # per spec

# --- Neodymium magnet detents (10 mm × 4 mm disc, N35) – per spec ---
MAGNET_D         = 10.0   # physical magnet diameter
MAGNET_H         =  4.0   # physical magnet thickness
MAGNET_DIAMETER  = 10.3   # pocket bore – per spec
MAGNET_DEPTH     =  3.6   # pocket depth – per spec (magnet 0.4 mm proud)
MAGNET_LIP       =  0.6   # retention lip – per spec (entrance 9.1 mm)
MAGNET_POCKET_D  = MAGNET_DIAMETER   # 10.3 mm bore
MAGNET_POCKET_H  = MAGNET_DEPTH      # 3.6 mm depth
MAGNET_Y         = 20.0
DETENT_X_OFFSET  = 32.0

# Offset detent configuration (per spec):
#   Body closed pocket at body-X = DETENT_X_OFFSET + MAGNET_OFFSET = +38 mm
#   Body open   pocket at body-X = DETENT_X_OFFSET - SLIDER_TRAVEL
#                                  - MAGNET_OFFSET = -39 mm
#   Tray pockets at tray-local X = DETENT_X_OFFSET = +32 mm (unchanged)
MAGNET_OFFSET    =  6.0   # per spec

# --- Structural ribs (per spec) ---
RIB_WIDTH  = 2.0   # per spec
RIB_HEIGHT = 6.0   # per spec

# --- PCB mounting platform (per spec) ---
PLATFORM_THICKNESS = 2.0   # structural floor reinforcement under Heltec board

# --- Battery retention clips (per spec) ---
BATTERY_CLIP_HEIGHT = 1.5  # clip tab height at battery pocket edges

# --- Lightening pockets (per spec) ---
POCKET_DEPTH = 1.5   # shallow recess depth on body bottom face

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
    """Unified top enclosure: display face, PCB bay, battery pocket, dovetail rail grooves.

    95 × 120 × 19 mm.  Dovetail grooves (RAIL_LENGTH=70 mm) at Y = ±RAIL_Y (±40 mm)
    with stop blocks.  Battery pocket 71×51×9 mm.
    Offset magnet detents: body closed at X=+38 mm, body open at X=−39 mm.
    USB-C 11×4 mm.  Standoffs 4 mm tall, 5 mm dia (M2).
    PCB platform 2 mm thick.  Battery clips 1.5 mm.  Lightening pockets 1.5 mm.
    Wire routing groove 6×2 mm alongside +Y rail.
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

    # Floor (provides material for dovetail grooves and lightening pockets)
    parts.append(_box_triangles(0, 0, 0, w, l, WALL_THICKNESS))

    # Dovetail rail groove representations at Y = ±RAIL_Y
    # Groove length = RAIL_LENGTH = 70 mm, starting at +X end (body-X = +w/2)
    groove_repr_w = RAIL_CHANNEL_INNER  # represent as inner width for visibility
    groove_x_start = w / 2 - RAIL_LENGTH
    groove_cx = groove_x_start + RAIL_LENGTH / 2
    for side in [-1, 1]:
        cy = side * RAIL_Y
        parts.append(_box_triangles(groove_cx, cy, 0, RAIL_LENGTH, groove_repr_w,
                                    RAIL_CHANNEL_H))

    # Stop blocks inside grooves at body X = STOP_BLOCK_POS_X (≈ −15.5 mm)
    for side in [-1, 1]:
        cy = side * RAIL_Y
        parts.append(_box_triangles(STOP_BLOCK_POS_X - STOP_BLOCK_DEPTH / 2, cy,
                                    0, STOP_BLOCK_DEPTH,
                                    RAIL_CHANNEL_W, STOP_BLOCK_HEIGHT))

    # Battery pocket representation (71 × 51 × 9 mm, per spec)
    bat_cy = l / 2 - WALL_THICKNESS - BATTERY_POCKET_Y / 2 - 5
    parts.append(_box_triangles(0, bat_cy, WALL_THICKNESS,
                                BATTERY_POCKET_X, BATTERY_POCKET_Y, BATTERY_POCKET_Z))

    # Battery retention clips at ±Y edges of battery pocket
    for side in [-1, 1]:
        clip_cy = bat_cy + side * BATTERY_POCKET_Y / 2
        parts.append(_box_triangles(0, clip_cy,
                                    WALL_THICKNESS + BATTERY_POCKET_Z - BATTERY_CLIP_HEIGHT,
                                    BATTERY_POCKET_X - 4, 2,
                                    BATTERY_CLIP_HEIGHT * 2))

    # Offset magnet pocket representations on bottom face (10 mm × 4 mm)
    # Body closed pocket at X = DETENT_X_OFFSET + MAGNET_OFFSET = +38 mm
    # Body open   pocket at X = DETENT_X_OFFSET - SLIDER_TRAVEL - MAGNET_OFFSET = -39 mm
    closed_x = DETENT_X_OFFSET + MAGNET_OFFSET
    open_x   = DETENT_X_OFFSET - SLIDER_TRAVEL - MAGNET_OFFSET
    for side in [-1, 1]:
        my = side * MAGNET_Y
        parts.append(_cylinder_triangles(closed_x, my, 0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 16))
        parts.append(_cylinder_triangles(open_x, my, 0,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 16))

    # Lightening pockets on body bottom face (POCKET_DEPTH=1.5 mm between rails)
    for px in [10, -25]:
        for py in [10, -10]:
            parts.append(_box_triangles(px, py, 0, 14, 12, POCKET_DEPTH))

    # PCB mounting platform (PLATFORM_THICKNESS = 2 mm slab on case floor)
    plat_cx = 0
    plat_cy = l / 2 - DISPLAY_OFFSET_Y - PCB_LENGTH / 2
    parts.append(_box_triangles(plat_cx, plat_cy, WALL_THICKNESS,
                                PCB_WIDTH + 4, PCB_LENGTH + 4, PLATFORM_THICKNESS))

    # PCB mounting standoffs (4 posts, Heltec V4, height STANDOFF_HEIGHT=4 mm)
    # Added outside the cavity so they protrude correctly.
    dy = l / 2 - DISPLAY_OFFSET_Y - PCB_LENGTH / 2
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            px = sx * (PCB_WIDTH / 2 - 2)
            py = dy + sy * (PCB_LENGTH / 2 - 3)
            parts.append(_cylinder_triangles(px, py, WALL_THICKNESS,
                                             STANDOFF_DIAMETER / 2,
                                             STANDOFF_HEIGHT, 16))

    # Reinforcement ribs (rib_width=2mm, rib_height=6mm per spec)
    rib_t  = RIB_WIDTH
    rib_h  = RIB_HEIGHT
    rib_iw = w - 2 * WALL_THICKNESS
    rib_il = l - 2 * WALL_THICKNESS
    # Longitudinal rib (along Y, centred in X)
    parts.append(_box_triangles(0, 0, WALL_THICKNESS, rib_t, rib_il, rib_h))
    # Lateral ribs at 1/3 and 2/3 of interior Y span
    for frac in [1/3, 2/3]:
        ry = -l/2 + WALL_THICKNESS + frac * rib_il
        parts.append(_box_triangles(0, ry, WALL_THICKNESS, rib_iw, rib_t, rib_h))

    # Wire routing groove alongside +Y rail (6×2 mm)
    wire_cy = RAIL_Y + RAIL_BASE_WIDTH / 2 + RAIL_CLEARANCE + 0.5 + WIRE_TUNNEL_WIDTH / 2
    parts.append(_box_triangles(0, wire_cy, 0,
                                w, WIRE_TUNNEL_WIDTH, WIRE_TUNNEL_HEIGHT))

    verts, faces = _combine_meshes(parts)
    return _make_stl(verts, faces)


def generate_main_body():
    """Backward-compatible alias for generate_top_shell()."""
    return generate_top_shell()


def generate_keyboard_tray():
    """Sliding keyboard tray (bottom shell): CardKB pocket, dovetail runners, magnets.

    95 × 120 × 8 mm.  CardKB pocket 89×55 mm (width×height), 8 mm deep.
    Dovetail runners: base 1.2 mm, cap 4.0 mm, height 3.0 mm at Y = ±40 mm.
    Runner length = RAIL_LENGTH = 70 mm, positioned at +X (insertion) end.
    Tray magnets: 10 mm × 4 mm at ±20 mm Y, tray-local X = +32 mm
      (offset 6 mm from body pockets for guided detent).
    Stop cutouts at runner -X tips (2.5 mm deep × groove_opening_w wide).
    Wire routing groove: 6×2 mm alongside +Y rail.
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

    # Dual dovetail runners on top face at Y = ±RAIL_Y
    # Runner length = RAIL_LENGTH = 70 mm, at +X end of tray.
    # runner_x_start = w/2 - RAIL_LENGTH (tray-local X)
    runner_x_start = w / 2 - RAIL_LENGTH
    runner_cx = runner_x_start + RAIL_LENGTH / 2   # centre of runner in X
    for side in [-1, 1]:
        cy = side * RAIL_Y
        # Represent runner as a trapezoidal prism: use average width for box approx
        # Base part (narrow, at tray face)
        parts.append(_box_triangles(runner_cx, cy, d,
                                    RAIL_LENGTH, RAIL_TOP_WIDTH, RAIL_HEIGHT / 2))
        # Cap part (wide, at free end)
        parts.append(_box_triangles(runner_cx, cy, d + RAIL_HEIGHT / 2,
                                    RAIL_LENGTH, RAIL_BASE_WIDTH, RAIL_HEIGHT / 2))

    # CardKB pocket representation (walls around the pocket area)
    # Pocket: 55 mm (X) × 89 mm (Y), 8 mm deep
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

    # Magnet pockets on top face (tray-local X = +DETENT_X_OFFSET = +32 mm)
    # These are offset from body pockets by MAGNET_OFFSET = 6 mm.
    for side in [-1, 1]:
        my = side * MAGNET_Y
        parts.append(_cylinder_triangles(DETENT_X_OFFSET, my,
                                         d - MAGNET_POCKET_H,
                                         MAGNET_POCKET_D / 2, MAGNET_POCKET_H, 16))

    # Wire routing groove alongside +Y rail (6×2 mm)
    wire_cy = RAIL_Y + RAIL_BASE_WIDTH / 2 + RAIL_CLEARANCE + 0.5 + WIRE_TUNNEL_WIDTH / 2
    parts.append(_box_triangles(0, wire_cy, d - WIRE_TUNNEL_HEIGHT,
                                w, WIRE_TUNNEL_WIDTH, WIRE_TUNNEL_HEIGHT))

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
        description="Generate Meshtastic Sliding Phone STL files (2-piece dovetail design)")
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
