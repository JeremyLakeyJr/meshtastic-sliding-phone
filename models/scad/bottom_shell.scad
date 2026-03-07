// ============================================================================
// Meshtastic Sliding Phone - Bottom Shell
// ============================================================================
// The lower half of the phone housing the Heltec V4 PCB, LiPo battery
// compartment, CardKB keyboard pocket, and the curved arc guide channels
// for the Sony Xperia-style sliding mechanism.
//
// The arc channels allow the top shell to slide and tilt upward when
// opened, providing a comfortable viewing angle for the OLED display.
//
// Print settings: 0.2mm layer height, 25% infill, supports for arc channels
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module bottom_shell() {
    total_length = bot_shell_length;

    // Compute the arc chord length from the tilt angle and arc radius
    arc_chord = 2 * arc_radius * sin(tilt_angle / 2);

    difference() {
        union() {
            // --- Main body (extended for keyboard area) ---
            rounded_box(bot_shell_width, total_length, bot_shell_z, corner_radius);

            // --- Side walls that house the arc guide channels ---
            // Slightly raised inner walls on both sides provide material for
            // the curved guide channels to be cut into.
            for (side = [-1, 1]) {
                translate([side * (bot_shell_width/2 - wall/2),
                           0,
                           bot_shell_z])
                    rounded_box(wall, total_length, guide_pin_h + wall, corner_radius/2);
            }
        }

        // --- Interior cavity ---
        translate([0, 0, wall])
            rounded_box(bot_shell_width - 2*wall,
                        total_length - 2*wall,
                        bot_shell_z,
                        max(corner_radius - wall, 0.5));

        // --- Arc guide channels (Sony Xperia-style curved slots, both sides) ---
        // Each side has a curved slot cut into the inner face of the side wall.
        // The arc sweeps through tilt_angle degrees so the top shell tilts when
        // slid open.  Guide pins from the top shell ride in these channels.
        for (side = [-1, 1]) {
            // Front guide channel (near top of phone)
            translate([side * (bot_shell_width/2 - wall - 0.1),
                       total_length/2 - 15,
                       bot_shell_z - guide_slot_depth])
                rotate([0, side * 90, 0])
                    arc_guide_channel(arc_radius, tilt_angle, guide_slot_width, guide_slot_depth + 0.2);

            // Rear guide channel (near bottom of phone)
            translate([side * (bot_shell_width/2 - wall - 0.1),
                       -total_length/2 + 15 + keyboard_travel,
                       bot_shell_z - guide_slot_depth])
                rotate([0, side * 90, 0])
                    arc_guide_channel(arc_radius, tilt_angle, guide_slot_width, guide_slot_depth + 0.2);
        }

        // --- Detent notches (snap positions at open and closed) ---
        // Small recesses at each end of the arc channel provide tactile snap.
        for (side = [-1, 1]) {
            for (pin_y = [total_length/2 - 15, -total_length/2 + 15 + keyboard_travel]) {
                // Closed-position detent (bottom of arc)
                translate([side * (bot_shell_width/2 - wall + detent_depth/2),
                           pin_y,
                           bot_shell_z])
                    cube([detent_depth, detent_width, guide_pin_h + wall + 0.2], center = true);

                // Open-position detent (top of arc, offset along the arc chord)
                translate([side * (bot_shell_width/2 - wall + detent_depth/2),
                           pin_y - keyboard_travel + 5,
                           bot_shell_z])
                    cube([detent_depth, detent_width, guide_pin_h + wall + 0.2], center = true);
            }
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

    // --- Arc channel end-stops (prevents top shell from sliding off) ---
    // Small walls at each end of the arc guide channels block the guide
    // pins from leaving the track.
    for (side = [-1, 1]) {
        // Front end-stop
        translate([side * (bot_shell_width/2 - wall - guide_pin_d/2 - 1),
                   total_length/2 - 12,
                   bot_shell_z])
            cube([guide_slot_width + 2, 2, guide_pin_h + wall], center = true);

        // Rear end-stop
        translate([side * (bot_shell_width/2 - wall - guide_pin_d/2 - 1),
                   -total_length/2 + 12 + keyboard_travel,
                   bot_shell_z])
            cube([guide_slot_width + 2, 2, guide_pin_h + wall], center = true);
    }
}

// --- Render ---
bottom_shell();
