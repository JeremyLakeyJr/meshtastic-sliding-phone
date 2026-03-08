// ============================================================================
// Meshtastic Sliding Phone – Full Assembly View
// ============================================================================
// Combines the two printed components into an exploded or assembled view for
// visualisation of the shortways magnetic-detent slider mechanism.
//
// PARTS
//   top_shell     – unified enclosure (display, PCB, battery, rails, ports)
//   keyboard_tray – sliding component (CardKB 88×54 mm, dovetail runners, magnets)
//
// The keyboard tray slides in the −X direction (shortways, along the 95 mm
// short axis) along two parallel captured dovetail rail grooves on the
// top-shell underside.  Neodymium 10 mm × 4 mm disc magnets snap the tray
// into the closed (travel = 0) and open (travel = slider_travel = 65 mm)
// positions.  Holding the phone in landscape (120 mm wide, 95 mm tall) the
// keyboard slides downward — Nokia N900-style.
//
// SLIDER TRAVEL = 65 mm → exposes 65 mm of tray area (≥ 60 mm spec) ✓
// RAIL ENGAGEMENT at full extension = phone_width − slider_travel = 30 mm ✓
// MAGNET POCKETS: 10.3 mm bore × 4.2 mm deep, 0.5 mm retention lip
// STOP BLOCKS: 2 mm tall inside grooves at body X ≈ −15.5 mm
//
// RAIL SYSTEM (dovetail, per spec):
//   Runner: narrow base 1.2 mm (rail_top_width) → wide cap 4 mm (rail_base_width)
//   Groove: opening 1.9 mm → inner 4.7 mm at rail_height, +2 mm standoff zone
//   Passive typing angle ≈ 3° at full extension via channel_standoff
//
// BATTERY POCKET: 71 × 51 × 9 mm (MakerFocus 3000 mAh), integrated in top shell
// USB-C CUTOUT: 11 × 4 mm (per spec); SMA antenna keepout radius 12 mm
// STANDOFFS: 4 × M2, height 4 mm, diameter 5 mm (Heltec V3/V4)
//
// WIRE ROUTING: 6 × 2 mm groove alongside +Y rail for CardKB flex cable
//
// Not intended for printing — use top_shell.scad and keyboard_tray.scad.
//
// Usage:
//   openscad assembly.scad
//   Toggle 'exploded' to see parts separated or assembled.
//   Adjust 'slide_position' (0 = closed → 1 = fully open) to animate.
// ============================================================================

include <parameters.scad>
use <utilities.scad>
use <top_shell.scad>
use <keyboard_tray.scad>
use <antenna_mount.scad>

// --- Assembly mode ---
exploded       = true;              // false = assembled view
explode_gap    = exploded ? 22 : 0;

// --- Slide position (0 = closed, 1 = fully open) ---
slide_position = exploded ? 0.65 : 0;
slide_offset   = slide_position * slider_travel;   // tray moves in −X

// --- Colours for visualisation ---
color_body    = [0.18, 0.18, 0.18, 0.88];   // near-black top shell
color_tray    = [0.15, 0.30, 0.48, 0.92];   // blue keyboard tray
color_antenna = [0.70, 0.70, 0.18, 0.90];   // gold antenna
color_magnet  = [0.75, 0.20, 0.20, 0.95];   // red magnet indicators

// ── Stack from bottom to top in assembled Z ──────────────────────────────
// Z = 0                 : bottom of keyboard tray
// Z = tray_z            : tray top face / top-shell bottom face interface
// Z = tray_z + body_z   : top of top shell (display face)
// ─────────────────────────────────────────────────────────────────────────

// --- Keyboard tray (slides in −X; at Z = 0) ---
color(color_tray)
    translate([-slide_offset, 0, -explode_gap * 0.5])
        keyboard_tray();

// --- Top shell (stationary; at Z = tray_z) ---
color(color_body)
    translate([0, 0, tray_z + explode_gap])
        top_shell();

// --- Antenna mount (top-right edge of top shell) ---
color(color_antenna)
    translate([phone_width/2 - 12,
               phone_length/2 + explode_gap * 0.3,
               tray_z + bot_shell_z/2 + 2 + explode_gap])
        rotate([90, 0, 0])
            antenna_mount();

// --- Magnet position indicators (visual reference only, not printed) ---
if (exploded) {
    // Closed-snap magnets in top shell (body bottom face)
    for (side = [-1, 1]) {
        color(color_magnet)
            translate([detent_x_offset,
                       side * magnet_y,
                       tray_z + explode_gap - magnet_depth])
                cylinder(h = magnet_depth, d = magnet_d);
    }
    // Open-snap magnets in top shell
    for (side = [-1, 1]) {
        color(color_magnet)
            translate([detent_x_offset - slider_travel,
                       side * magnet_y,
                       tray_z + explode_gap - magnet_depth])
                cylinder(h = magnet_depth, d = magnet_d);
    }
    // Tray magnets (on tray top face, moved with tray)
    for (side = [-1, 1]) {
        color(color_magnet)
            translate([detent_x_offset - slide_offset,
                       side * magnet_y,
                       tray_z - magnet_depth - explode_gap * 0.5])
                cylinder(h = magnet_depth, d = magnet_d);
    }
}

if (exploded) {
    translate([0, 0, phone_thickness + 2 * explode_gap + 8])
        linear_extrude(height = 0.5)
            text("Meshtastic Sliding Phone", size = 6, halign = "center");
    translate([0, 0, phone_thickness + 2 * explode_gap + 2])
        linear_extrude(height = 0.5)
            text(str("2-piece · dovetail rail · 10mm×4mm magnets · ",
                     slider_travel, "mm travel · 30mm engagement · 3° typing angle"),
                 size = 3.0, halign = "center");
}
