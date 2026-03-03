// ============================================================================
// Meshtastic Sliding Phone - Bottom Shell
// ============================================================================
// The lower half of the phone housing the T-Beam PCB, battery compartment,
// keyboard well, and the female slide rail channels.
//
// Print settings: 0.2mm layer height, 25% infill, supports for rail channels
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module bottom_shell() {
    total_length = bot_shell_length;

    difference() {
        union() {
            // --- Main body (extended for keyboard area) ---
            rounded_box(bot_shell_width, total_length, bot_shell_z, corner_radius);

            // --- Raised rail guides along both sides ---
            for (side = [-1, 1]) {
                translate([side * (bot_shell_width/2 - wall/2),
                           0,
                           bot_shell_z])
                    rounded_box(wall, total_length, rail_height + wall, corner_radius/2);
            }
        }

        // --- Interior cavity ---
        translate([0, 0, wall])
            rounded_box(bot_shell_width - 2*wall,
                        total_length - 2*wall,
                        bot_shell_z,
                        max(corner_radius - wall, 0.5));

        // --- Slide rail channels (female dovetail, both sides) ---
        for (side = [-1, 1]) {
            translate([side * (bot_shell_width/2 - wall - rail_width/2),
                       0,
                       bot_shell_z])
                dovetail_channel(rail_width, rail_height, total_length - 10, clearance);
        }

        // --- T-Beam PCB pocket (recessed mounting area) ---
        translate([0,
                   total_length/2 - 10 - pcb_length/2,
                   wall])
            cube([pcb_width + 1, pcb_length + 1, pcb_thickness + 0.5], center = true);

        // --- Battery compartment (18650 cell, bottom section) ---
        translate([0,
                   -total_length/2 + wall + battery_length/2 + 5,
                   wall + battery_diameter/2 + pcb_thickness])
            rotate([0, 0, 0])
                cube([battery_diameter + 1,
                      battery_length + 1,
                      battery_diameter + 1], center = true);

        // --- Battery door opening (bottom face) ---
        translate([0,
                   -total_length/2 + wall + battery_length/2 + 5,
                   -0.1])
            rounded_box(battery_diameter + 6, battery_length + 6, wall + 0.2, 2);

        // --- Keyboard well (the area exposed when top slides up) ---
        translate([0,
                   -total_length/2 + keyboard_travel/2 + wall + 3,
                   bot_shell_z - 2])
            rounded_box(bot_shell_width - 2*wall - 2*rail_width - 4,
                        keyboard_travel - 6,
                        3,
                        2);

        // --- USB-C port cutout (bottom edge) ---
        translate([0,
                   -total_length/2 - 0.1,
                   bot_shell_z/2 + 1])
            rotate([90, 0, 0])
                rounded_box(usbc_width, usbc_height, wall + 0.4, 1);

        // --- SMA antenna connector hole (top edge) ---
        translate([bot_shell_width/2 - 12,
                   total_length/2 - 0.1,
                   bot_shell_z/2 + 2])
            rotate([90, 0, 0])
                cylinder(h = wall + 0.4, d = sma_diameter);

        // --- Microphone hole (bottom edge) ---
        translate([-12,
                   -total_length/2 - 0.1,
                   bot_shell_z/2 - 1])
            rotate([90, 0, 0])
                cylinder(h = wall + 0.4, d = mic_diameter);

        // --- Bottom speaker grille ---
        translate([12,
                   -total_length/2 - 0.1,
                   bot_shell_z/2])
            rotate([90, 0, 0])
                linear_extrude(height = wall + 0.2)
                    grille_pattern(3, 2, 3, 1.5, 1.2, 0.5);

        // --- Ventilation slots (sides) ---
        for (side = [-1, 1]) {
            translate([side * (bot_shell_width/2 - 0.1),
                       total_length/2 - pcb_length/2 - 10,
                       bot_shell_z/2])
                rotate([0, 90, 0])
                    linear_extrude(height = wall + 0.2)
                        grille_pattern(1, 4, 2, 8, 2, 0.8);
        }

        // --- PCB mounting screw holes ---
        for (pos = [
            [ pcb_width/2 - 2,  total_length/2 - 14],
            [-pcb_width/2 + 2,  total_length/2 - 14],
            [ pcb_width/2 - 2,  total_length/2 - 14 - pcb_length + 4],
            [-pcb_width/2 + 2,  total_length/2 - 14 - pcb_length + 4]
        ]) {
            translate([pos[0], pos[1], -0.1])
                cylinder(h = wall + 1, d = screw_hole_d);
        }
    }

    // --- PCB mounting posts ---
    for (pos = [
        [ pcb_width/2 - 2,  total_length/2 - 14],
        [-pcb_width/2 + 2,  total_length/2 - 14],
        [ pcb_width/2 - 2,  total_length/2 - 14 - pcb_length + 4],
        [-pcb_width/2 + 2,  total_length/2 - 14 - pcb_length + 4]
    ]) {
        translate([pos[0], pos[1], wall])
            screw_post(screw_post_h, screw_post_d, screw_hole_d);
    }

    // --- Keyboard key posts (tactile switch mounting grid) ---
    kb_area_x = bot_shell_width - 2*wall - 2*rail_width - 8;
    kb_area_y = keyboard_travel - 10;
    key_pitch = (key_size + key_spacing);

    for (c = [0 : keyboard_cols - 1]) {
        for (r = [0 : keyboard_rows - 1]) {
            kx = -kb_area_x/2 + 4 + c * (kb_area_x - 8) / (keyboard_cols - 1);
            ky = -total_length/2 + wall + 8 + r * (kb_area_y - 4) / (keyboard_rows - 1);
            translate([kx, ky, wall])
                cylinder(h = 2, d = 1.5);
        }
    }

    // --- Slide end-stops (prevents top from sliding off) ---
    for (side = [-1, 1]) {
        translate([side * (bot_shell_width/2 - wall - rail_width/2),
                   total_length/2 - 3,
                   bot_shell_z])
            cube([rail_width + 2, 3, rail_height + wall], center = true);
    }
}

// --- Render ---
bottom_shell();
