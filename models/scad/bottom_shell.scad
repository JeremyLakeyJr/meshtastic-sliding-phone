// ============================================================================
// Meshtastic Sliding Phone – Bottom Shell (Battery / Ports Face)
// ============================================================================
// Lower half of the phone body.  Snap-fits under the top shell.
// Houses the LiPo battery, USB-C charging port, SMA antenna connector,
// and microphone.
//
// The exterior bottom face (Z = 0 in this module) contains:
//   • Two parallel rectangular rail CHANNELS that accept the keyboard-tray
//     runners.  The channels are 1 mm deeper than the runners (rail_channel_h
//     vs rail_h), creating a 1 mm air-gap standoff that reduces friction.
//   • Four neodymium-magnet pockets – two for the CLOSED-position snap and
//     two for the OPEN-position snap.  Each pocket is 0.5 mm deeper than the
//     magnet, so opposing magnets are always separated by ≥ 2 mm.
//
// Print orientation : battery face DOWN (flat bottom for a stable print).
// Print settings    : 0.2 mm layer height, 25 % infill
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module bottom_shell() {
    difference() {
        union() {
            // --- Main body ---
            rounded_box(phone_width, phone_length, bot_shell_z, corner_radius);

            // --- Corner screw posts (join to top shell) ---
            for (pos = [
                [ phone_width/2 - 8,  phone_length/2 - 8],
                [-phone_width/2 + 8,  phone_length/2 - 8],
                [ phone_width/2 - 8, -phone_length/2 + 8],
                [-phone_width/2 + 8, -phone_length/2 + 8]
            ]) {
                translate([pos[0], pos[1], bot_shell_z])
                    screw_post(screw_post_h, screw_post_d, screw_hole_d);
            }
        }

        // --- Interior cavity (battery + wiring) ---
        translate([0, 0, wall])
            rounded_box(phone_width - 2*wall,
                        phone_length - 2*wall,
                        bot_shell_z,
                        max(corner_radius - wall, 0.5));

        // --- LiPo battery pocket ---
        translate([0,
                   phone_length/2 - wall - lipo_length/2 - 5,
                   wall])
            cube([lipo_width + 1, lipo_length + 1, lipo_thickness + 1], center = true);

        // --- Battery door opening (exterior bottom face) ---
        translate([0,
                   phone_length/2 - wall - lipo_length/2 - 5,
                   -0.1])
            rounded_box(lipo_width + 6, lipo_length + 6, wall + 0.2, 2);

        // --- Rail channels (cut from exterior bottom face Z=0 upward) ---
        // Two channels accept the keyboard-tray runners.  Centred at ±rail_x.
        // Extended 1 mm past each end so the channels are fully open for
        // sliding-in during assembly.
        for (side = [-1, 1]) {
            translate([side * rail_x - rail_channel_w / 2,
                       -phone_length / 2 - 1,
                       0])
                rail_channel_void(phone_length);
        }

        // --- Magnet pockets – CLOSED-position detent ---
        // When the keyboard tray is at travel = 0, the tray's magnets (at
        // tray-local Y = +detent_y_offset) align with these pockets.
        for (side = [-1, 1]) {
            translate([side * magnet_x, detent_y_offset, -0.1])
                magnet_pocket();
        }

        // --- Magnet pockets – OPEN-position detent ---
        // When the tray is at full travel (keyboard_travel = 42 mm), the
        // tray's magnets align with these pockets.
        // Y = detent_y_offset − keyboard_travel = 35 − 42 = −7 mm
        for (side = [-1, 1]) {
            translate([side * magnet_x,
                       detent_y_offset - keyboard_travel,
                       -0.1])
                magnet_pocket();
        }

        // --- USB-C port (−Y / bottom edge) ---
        translate([0,
                   -phone_length/2 - 0.1,
                   bot_shell_z/2 + 1])
            rotate([90, 0, 0])
                rounded_box(usbc_width, usbc_height, wall + 0.4, 1);

        // --- SMA antenna connector hole (+Y / top edge) ---
        translate([phone_width/2 - 12,
                   phone_length/2 - 0.1,
                   bot_shell_z/2 + 2])
            rotate([90, 0, 0])
                cylinder(h = wall + 0.4, d = sma_diameter);

        // --- Microphone hole (−Y / bottom edge) ---
        translate([-12,
                   -phone_length/2 - 0.1,
                   bot_shell_z/2 - 1])
            rotate([90, 0, 0])
                cylinder(h = wall + 0.4, d = mic_diameter);

        // --- Bottom speaker grille (−Y / bottom edge) ---
        translate([12,
                   -phone_length/2 - 0.1,
                   bot_shell_z/2])
            rotate([90, 0, 0])
                linear_extrude(height = wall + 0.2)
                    grille_pattern(3, 2, 3, 1.5, 1.2, 0.5);

        // --- Ventilation slots (left and right sides) ---
        for (side = [-1, 1]) {
            translate([side * (phone_width/2 - 0.1),
                       phone_length/2 - pcb_length/2 - 10,
                       bot_shell_z/2])
                rotate([0, 90, 0])
                    linear_extrude(height = wall + 0.2)
                        grille_pattern(1, 4, 2, 8, 2, 0.8);
        }

        // --- Corner screw holes (pass-through, for M2 screws joining shells) ---
        for (pos = [
            [ phone_width/2 - 8,  phone_length/2 - 8],
            [-phone_width/2 + 8,  phone_length/2 - 8],
            [ phone_width/2 - 8, -phone_length/2 + 8],
            [-phone_width/2 + 8, -phone_length/2 + 8]
        ]) {
            translate([pos[0], pos[1], -0.1])
                cylinder(h = bot_shell_z + 0.2, d = screw_hole_d);
        }
    }
}

// --- Render ---
bottom_shell();
