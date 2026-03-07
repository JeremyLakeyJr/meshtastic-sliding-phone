// ============================================================================
// Meshtastic Sliding Phone - Top Shell
// ============================================================================
// The upper sliding half of the phone. Uses Sony Xperia-style arc guide pins
// on the underside that ride inside curved channels in the bottom shell.
// When slid open the top shell tilts upward for a comfortable viewing angle.
//
// Contains a viewport window aligned with the Heltec V4's built-in 0.96"
// OLED display, speaker grille, and front-facing elements.
//
// Print settings: 0.2mm layer height, 20% infill, supports for display recess
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module top_shell() {
    difference() {
        union() {
            // --- Main body ---
            rounded_box(top_shell_width, top_shell_length, top_shell_z, corner_radius);

            // --- Arc guide pins (Sony Xperia-style, on underside, both sides) ---
            // Two pins per side ride inside the curved arc channels in the
            // bottom shell.  Pins are placed near the front and rear edges.
            for (side = [-1, 1]) {
                for (pin_y_off = [-1, 1]) {
                    translate([side * (top_shell_width/2 - wall - guide_pin_d/2 - 1),
                               pin_y_off * (top_shell_length/2 - 15),
                               -guide_pin_h])
                        guide_pin(guide_pin_d, guide_pin_h);
                }
            }
        }

        // --- Interior cavity ---
        translate([0, 0, wall])
            rounded_box(top_shell_width - 2*wall,
                        top_shell_length - 2*wall,
                        top_shell_z,
                        max(corner_radius - wall, 0.5));

        // --- OLED viewport cutout (through top face, aligns with Heltec V4 OLED) ---
        translate([0, top_shell_length/2 - display_offset_y - display_h/2, -0.1])
            rounded_box(display_w, display_h, wall + 0.2, 1);

        // --- Viewport recess (slight countersink to protect display glass) ---
        translate([0, top_shell_length/2 - display_offset_y - display_h/2, wall - display_depth])
            rounded_box(display_w + 2, display_h + 2, display_depth + 0.2, 1);

        // --- Speaker grille (top edge, centered) ---
        translate([0, top_shell_length/2 - 8, -0.1])
            linear_extrude(height = wall + 0.2)
                grille_pattern(6, 2, 3, 1.5, 1.2, 0.5);

        // --- Front camera / sensor pinhole ---
        translate([display_w/2 + 6,
                   top_shell_length/2 - display_offset_y - 5,
                   -0.1])
            cylinder(h = wall + 0.2, d = 2.5);

        // --- Notification LED slot ---
        translate([0, top_shell_length/2 - 5, -0.1])
            rounded_box(6, 2, wall + 0.2, 0.8);

        // --- Side button cutouts (power, volume) ---
        // Power button (right side)
        translate([top_shell_width/2 - 0.1,
                   top_shell_length/2 - 30,
                   top_shell_z/2])
            rotate([0, 90, 0])
                rounded_box(8, 4, wall + 0.2, 1);

        // Volume rocker (right side)
        translate([top_shell_width/2 - 0.1,
                   top_shell_length/2 - 50,
                   top_shell_z/2])
            rotate([0, 90, 0])
                rounded_box(14, 4, wall + 0.2, 1);

        // --- Screw post holes (PCB mounting — aligns Heltec V4 under viewport) ---
        for (pos = [
            [ pcb_width/2 - 2, top_shell_length/2 - display_offset_y - 3],
            [-pcb_width/2 + 2, top_shell_length/2 - display_offset_y - 3],
            [ pcb_width/2 - 2, top_shell_length/2 - display_offset_y - pcb_length + 3],
            [-pcb_width/2 + 2, top_shell_length/2 - display_offset_y - pcb_length + 3]
        ]) {
            translate([pos[0], pos[1], wall])
                cylinder(h = top_shell_z, d = screw_hole_d);
        }
    }

    // --- PCB mounting posts (secure Heltec V4 beneath viewport) ---
    for (pos = [
        [ pcb_width/2 - 2, top_shell_length/2 - display_offset_y - 3],
        [-pcb_width/2 + 2, top_shell_length/2 - display_offset_y - 3],
        [ pcb_width/2 - 2, top_shell_length/2 - display_offset_y - pcb_length + 3],
        [-pcb_width/2 + 2, top_shell_length/2 - display_offset_y - pcb_length + 3]
    ]) {
        translate([pos[0], pos[1], wall])
            screw_post(screw_post_h, screw_post_d, screw_hole_d);
    }
}

// --- Render ---
top_shell();
