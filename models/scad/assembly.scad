// ============================================================================
// Meshtastic Sliding Phone - Full Assembly View
// ============================================================================
// Combines all components into an exploded or assembled view for
// visualization. Demonstrates the Sony Xperia-style arc sliding mechanism
// where the top shell tilts upward when opened.
//
// Not intended for printing — use individual part files.
//
// Usage:
//   openscad assembly.scad
//   Toggle 'exploded' variable to see parts separated or assembled.
//   Adjust 'slide_position' (0..1) to animate the slide open/close.
// ============================================================================

include <parameters.scad>
use <utilities.scad>
use <top_shell.scad>
use <bottom_shell.scad>
use <battery_cover.scad>
use <antenna_mount.scad>

// --- Assembly mode ---
exploded = true;  // Set to false for assembled view
explode_gap = exploded ? 25 : 0;

// --- Slide position (0 = closed, 1 = fully open with tilt) ---
slide_position = exploded ? 0.8 : 0;

// --- Colors for visualization ---
color_top     = [0.2, 0.2, 0.2, 0.85];  // Dark grey
color_bottom  = [0.25, 0.25, 0.28, 0.9]; // Slightly lighter
color_battery = [0.6, 0.15, 0.15, 0.9];  // Red accent
color_antenna = [0.7, 0.7, 0.2, 0.9];    // Gold

total_bot_length = bot_shell_length;

// --- Derived slide transforms ---
// The top shell follows an arc path: as it slides back it tilts upward.
// The rotation pivot is at the rear edge of the top shell.
current_tilt   = slide_position * tilt_angle;
slide_offset_y = slide_position * keyboard_travel;

// --- Bottom shell ---
color(color_bottom)
    translate([0, 0, 0])
        bottom_shell();

// --- Top shell (Sony Xperia-style arc slide — tilts as it opens) ---
color(color_top)
    translate([0,
               keyboard_travel/2 - slide_offset_y/2 + explode_gap * 0.5,
               bot_shell_z + explode_gap])
        // Pivot around the rear bottom edge of the top shell
        translate([0, -top_shell_length/2, 0])
            rotate([current_tilt, 0, 0])
                translate([0, top_shell_length/2, 0])
                    top_shell();

// --- Battery cover (snaps onto back of bottom shell) ---
color(color_battery)
    translate([0,
               -total_bot_length/2 + wall + lipo_length/2 + 5,
               -explode_gap])
        rotate([180, 0, 0])
            battery_cover();

// --- Antenna mount (top-right edge of bottom shell) ---
color(color_antenna)
    translate([bot_shell_width/2 - 12,
               total_bot_length/2 + explode_gap * 0.3,
               bot_shell_z/2 + 2])
        rotate([90, 0, 0])
            antenna_mount();

// --- Info text (shown in preview only) ---
if (exploded) {
    translate([0, 0, phone_thickness + 3 * explode_gap + 5])
        linear_extrude(height = 0.5)
            text("Meshtastic Sliding Phone", size = 6, halign = "center");
    translate([0, 0, phone_thickness + 3 * explode_gap])
        linear_extrude(height = 0.5)
            text("Sony Xperia-style arc slider", size = 4, halign = "center");
}
