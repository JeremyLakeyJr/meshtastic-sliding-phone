// ============================================================================
// Meshtastic Sliding Phone – Full Assembly View
// ============================================================================
// Combines the two printed components into an exploded or assembled view for
// visualisation of the shortways magnetic-detent slider mechanism.
//
// PARTS
//   main_body     – unified enclosure (display, PCB, battery, rails, ports)
//   keyboard_tray – sliding component (CardKB, T-runners, magnets)
//
// The keyboard tray slides in the −X direction (shortways, along the 74 mm
// short axis) along two parallel T-slot captured-lip rail channels on the
// main-body underside.  Neodymium 5 mm × 2 mm disc magnets snap the tray
// into the closed (travel = 0) and open (travel = slider_travel = 35 mm)
// positions.  Holding the phone in landscape (120 mm wide, 74 mm tall) the
// keyboard slides downward — exactly like a Nokia N900.
//
// Not intended for printing — use main_body.scad and keyboard_tray.scad.
//
// Usage:
//   openscad assembly.scad
//   Toggle 'exploded' to see parts separated or assembled.
//   Adjust 'slide_position' (0 = closed → 1 = fully open) to animate.
// ============================================================================

include <parameters.scad>
use <utilities.scad>
use <main_body.scad>
use <keyboard_tray.scad>
use <antenna_mount.scad>

// --- Assembly mode ---
exploded       = true;              // false = assembled view
explode_gap    = exploded ? 22 : 0;

// --- Slide position (0 = closed, 1 = fully open) ---
slide_position = exploded ? 0.65 : 0;
slide_offset   = slide_position * slider_travel;   // tray moves in −X

// --- Colours for visualisation ---
color_body    = [0.18, 0.18, 0.18, 0.88];   // near-black main body
color_tray    = [0.15, 0.30, 0.48, 0.92];   // blue keyboard tray
color_antenna = [0.70, 0.70, 0.18, 0.90];   // gold antenna

// ── Stack from bottom to top in assembled Z ──────────────────────────────
// Z = 0                 : bottom of keyboard tray
// Z = tray_z            : tray top face / main-body bottom face interface
// Z = tray_z + body_z   : top of main body (display face)
// ─────────────────────────────────────────────────────────────────────────

// --- Keyboard tray (slides in −X; at Z = 0) ---
color(color_tray)
    translate([-slide_offset, 0, -explode_gap * 0.5])
        keyboard_tray();

// --- Main body (stationary; at Z = tray_z) ---
color(color_body)
    translate([0, 0, tray_z + explode_gap])
        main_body();

// --- Antenna mount (top-right edge of main body) ---
color(color_antenna)
    translate([phone_width/2 - 12,
               phone_length/2 + explode_gap * 0.3,
               tray_z + bot_shell_z/2 + 2 + explode_gap])
        rotate([90, 0, 0])
            antenna_mount();

if (exploded) {
    translate([0, 0, phone_thickness + 2 * explode_gap + 8])
        linear_extrude(height = 0.5)
            text("Meshtastic Sliding Phone", size = 6, halign = "center");
    translate([0, 0, phone_thickness + 2 * explode_gap + 2])
        linear_extrude(height = 0.5)
            text("2-piece design · main_body + keyboard_tray · 5 mm magnetic detents · snap-open ramp",
                 size = 3.2, halign = "center");
}
