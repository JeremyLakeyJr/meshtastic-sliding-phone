// ============================================================================
// Meshtastic Sliding Phone - Top Shell
// ============================================================================
// The upper sliding half of the phone containing the display window,
// speaker grille, and front-facing elements.
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

            // --- Slide rails (male dovetail on bottom face, both sides) ---
            for (side = [-1, 1]) {
                translate([side * (top_shell_width/2 - wall - rail_width/2),
                           0,
                           -rail_height])
                    dovetail_rail(rail_width, rail_height, rail_length_top);
            }
        }

        // --- Interior cavity ---
        translate([0, 0, wall])
            rounded_box(top_shell_width - 2*wall,
                        top_shell_length - 2*wall,
                        top_shell_z,
                        max(corner_radius - wall, 0.5));

        // --- Display window cutout (through top face) ---
        translate([0, top_shell_length/2 - display_offset_y - display_h/2, -0.1])
            rounded_box(display_w, display_h, wall + 0.2, 2);

        // --- Display recess (step for glass/module to sit in) ---
        translate([0, top_shell_length/2 - display_offset_y - display_h/2, wall - 0.5])
            rounded_box(display_w + 4, display_h + 4, display_depth + 0.5, 2);

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

        // --- Screw post holes (for securing display bracket) ---
        for (pos = [
            [ display_w/2 + 6, top_shell_length/2 - display_offset_y - 3],
            [-display_w/2 - 6, top_shell_length/2 - display_offset_y - 3],
            [ display_w/2 + 6, top_shell_length/2 - display_offset_y - display_h + 3],
            [-display_w/2 - 6, top_shell_length/2 - display_offset_y - display_h + 3]
        ]) {
            translate([pos[0], pos[1], wall])
                cylinder(h = top_shell_z, d = screw_hole_d);
        }
    }

    // --- Display mounting posts ---
    for (pos = [
        [ display_w/2 + 6, top_shell_length/2 - display_offset_y - 3],
        [-display_w/2 - 6, top_shell_length/2 - display_offset_y - 3],
        [ display_w/2 + 6, top_shell_length/2 - display_offset_y - display_h + 3],
        [-display_w/2 - 6, top_shell_length/2 - display_offset_y - display_h + 3]
    ]) {
        translate([pos[0], pos[1], wall])
            screw_post(display_depth + 1, screw_post_d, screw_hole_d);
    }
}

// --- Render ---
top_shell();
