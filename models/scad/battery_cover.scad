// ============================================================================
// Meshtastic Sliding Phone – Battery Cover
// ============================================================================
// Snap-fit battery door that covers the LiPo cell compartment on the
// bottom shell.  Features a latch mechanism for tool-free battery swaps.
// Dimensions are derived from lipo_width and lipo_length in parameters.scad.
//
// Print settings: 0.2 mm layer height, 100 % infill for snap strength
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module battery_cover() {
    cover_w = lipo_width + 8;
    cover_l = lipo_length + 8;
    cover_h = 1.5;  // Thin cover plate

    // Snap tab dimensions
    tab_w     = 3;
    tab_l     = 6;
    tab_h     = 2;
    tab_hook  = 0.6;

    difference() {
        union() {
            // --- Cover plate ---
            rounded_box(cover_w, cover_l, cover_h, 2);

            // --- Perimeter lip (fits into battery door opening) ---
            translate([0, 0, cover_h])
                difference() {
                    rounded_box(cover_w - 1, cover_l - 1, 1.5, 1.5);
                    translate([0, 0, -0.1])
                        rounded_box(cover_w - 1 - 2*wall, cover_l - 1 - 2*wall, 2, 0.8);
                }

            // --- Snap tabs (both short edges) ---
            for (end = [-1, 1]) {
                translate([0, end * (cover_l/2 - tab_l/2 - 1), cover_h]) {
                    // Tab arm
                    cube([tab_w, tab_l, tab_h], center = true);
                    // Hook
                    translate([0, end * tab_l/2, tab_h/2 - tab_hook/2])
                        cube([tab_w, 1, tab_hook], center = true);
                }
            }
        }

        // --- Finger grip recess (center of cover for easy removal) ---
        translate([0, 0, cover_h - 0.5])
            cylinder(h = 1, d = 10);

        // --- Ventilation holes for battery ---
        for (i = [-2 : 2]) {
            translate([0, i * 10, -0.1])
                cylinder(h = cover_h + 0.2, d = 2);
        }

        // --- Label recess (for battery polarity marking) ---
        translate([cover_w/2 - 5, -cover_l/2 + 6, cover_h - 0.3])
            rounded_box(6, 8, 0.5, 1);
    }
}

// --- Render ---
battery_cover();
