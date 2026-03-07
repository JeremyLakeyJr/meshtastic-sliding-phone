// ============================================================================
// Meshtastic Sliding Phone – Full Assembly View
// ============================================================================
// Combines all components into an exploded or assembled view for
// visualisation of the shortways magnetic-detent slider mechanism.
//
// The keyboard tray slides in the −X direction (shortways, along the 74 mm
// short axis) along two parallel rail runners captured inside matching
// channels on the bottom shell underside.  Neodymium disc magnets snap the
// tray into the closed (travel = 0) and open (travel = keyboard_travel)
// positions.  Holding the phone in landscape (120 mm wide, 74 mm tall) the
// keyboard slides downward — exactly like a Nokia N900.
//
// Not intended for printing — use individual part files.
//
// Usage:
//   openscad assembly.scad
//   Toggle 'exploded' to see parts separated or assembled.
//   Adjust 'slide_position' (0 = closed → 1 = fully open) to animate.
// ============================================================================

include <parameters.scad>
use <utilities.scad>
use <top_shell.scad>
use <bottom_shell.scad>
use <keyboard_tray.scad>
use <battery_cover.scad>
use <antenna_mount.scad>

// --- Assembly mode ---
exploded       = true;             // false = assembled view
explode_gap    = exploded ? 22 : 0;

// --- Slide position (0 = closed, 1 = fully open) ---
slide_position = exploded ? 0.65 : 0;
slide_offset   = slide_position * keyboard_travel;   // tray moves in −X

// --- Colours for visualisation ---
color_top     = [0.18, 0.18, 0.18, 0.88];   // near-black body
color_bottom  = [0.25, 0.25, 0.28, 0.92];   // dark grey body
color_tray    = [0.15, 0.30, 0.48, 0.92];   // blue keyboard tray
color_battery = [0.60, 0.14, 0.14, 0.90];   // red battery cover
color_antenna = [0.70, 0.70, 0.18, 0.90];   // gold antenna

// ── Stack from bottom to top in assembled Z ──────────────────────────────
// Z = 0                 : bottom of keyboard tray
// Z = tray_z            : tray top face / bot-shell bottom face interface
// Z = tray_z+bot_shell_z: bot-shell top / top-shell bottom interface
// Z = phone_thickness   : top of display face
// ─────────────────────────────────────────────────────────────────────────

// --- Keyboard tray (slides in −X; at Z = 0) ---
color(color_tray)
    translate([-slide_offset, 0, -explode_gap * 0.5])
        keyboard_tray();

// --- Bottom shell (stationary; at Z = tray_z) ---
color(color_bottom)
    translate([0, 0, tray_z])
        bottom_shell();

// --- Top shell (stationary; at Z = tray_z + bot_shell_z) ---
color(color_top)
    translate([0, 0, tray_z + bot_shell_z + explode_gap])
        top_shell();

// --- Battery cover (snaps onto bottom-shell battery opening) ---
color(color_battery)
    translate([0,
               phone_length/2 - wall - lipo_length/2 - 5,
               tray_z - explode_gap * 0.5])
        rotate([180, 0, 0])
            battery_cover();

// --- Antenna mount (top-right edge of bottom shell) ---
color(color_antenna)
    translate([phone_width/2 - 12,
               phone_length/2 + explode_gap * 0.3,
               tray_z + bot_shell_z/2 + 2])
        rotate([90, 0, 0])
            antenna_mount();

if (exploded) {
    translate([0, 0, phone_thickness + 3 * explode_gap + 8])
        linear_extrude(height = 0.5)
            text("Meshtastic Sliding Phone", size = 6, halign = "center");
    translate([0, 0, phone_thickness + 3 * explode_gap + 2])
        linear_extrude(height = 0.5)
            text("Shortways slider (−X) · Heltec V4 · magnetic detents · parallel rail guides",
                 size = 3.2, halign = "center");
}
