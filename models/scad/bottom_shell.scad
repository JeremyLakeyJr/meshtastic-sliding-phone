// ============================================================================
// Meshtastic Sliding Phone - Bottom Shell
// ============================================================================
// The lower half of the phone housing the Heltec V4 PCB, LiPo battery
// compartment, CardKB keyboard pocket, and the female slide rail channels.
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

        // --- Heltec V4 PCB pocket (recessed mounting area) ---
        translate([0,
                   total_length/2 - 10 - pcb_length/2,
                   wall])
            cube([pcb_width + 1, pcb_length + 1, pcb_thickness + 0.5], center = true);

        // --- LiPo battery compartment (flat pouch cell) ---
        translate([0,
                   -total_length/2 + wall + lipo_length/2 + 5,
                   wall])
            cube([lipo_width + 1,
                  lipo_length + 1,
                  lipo_thickness + 1], center = true);

        // --- Battery door opening (bottom face) ---
        translate([0,
                   -total_length/2 + wall + lipo_length/2 + 5,
                   -0.1])
            rounded_box(lipo_width + 6, lipo_length + 6, wall + 0.2, 2);

        // --- CardKB module pocket (revealed when top shell slides open) ---
        translate([0,
                   -total_length/2 + wall + cardkb_width/2 + 3,
                   wall])
            rounded_box(cardkb_length + 2*clearance,
                        cardkb_width  + 2*clearance,
                        cardkb_thickness + 1,
                        2);

        // --- I2C cable access slot (bottom edge of keyboard pocket) ---
        translate([0,
                   -total_length/2 - 0.1,
                   wall + cardkb_thickness/2])
            rotate([90, 0, 0])
                rounded_box(8, cardkb_thickness, wall + 0.4, 1);

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

    // --- CardKB retention ledges (keeps module from sliding forward) ---
    for (side = [-1, 1]) {
        translate([side * (cardkb_length/2 + clearance + 1),
                   -total_length/2 + wall + cardkb_width/2 + 3,
                   wall + cardkb_thickness + 1])
            cube([2, cardkb_width, 1.5], center = true);
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
