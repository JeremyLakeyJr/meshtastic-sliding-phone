// ============================================================================
// Meshtastic Sliding Phone – Top Shell (Display / PCB Face)
// ============================================================================
// Upper half of the phone body.  Snap-fits onto the bottom shell.
// Houses the Heltec WiFi LoRa 32 V4 PCB below the OLED viewport, the
// speaker grille, front camera pinhole, notification LED slot, and side
// buttons (power + volume rocker).
//
// Print orientation : display face DOWN – viewport and button recesses print
//                     without supports.
// Print settings    : 0.2 mm layer height, 20 % infill
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module top_shell() {
    difference() {
        union() {
            // --- Main body ---
            rounded_box(phone_width, phone_length, top_shell_z, corner_radius);

            // --- PCB mounting posts (Heltec V4, positioned below viewport) ---
            for (pos = [
                [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - 3],
                [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - 3],
                [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - pcb_length + 3],
                [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - pcb_length + 3]
            ]) {
                translate([pos[0], pos[1], wall])
                    screw_post(screw_post_h, screw_post_d, screw_hole_d);
            }
        }

        // --- Interior cavity ---
        translate([0, 0, wall])
            rounded_box(phone_width - 2*wall,
                        phone_length - 2*wall,
                        top_shell_z,
                        max(corner_radius - wall, 0.5));

        // --- OLED viewport cutout ---
        translate([0,
                   phone_length/2 - display_offset_y - display_h/2,
                   -0.1])
            rounded_box(display_w, display_h, wall + 0.2, 1);

        // --- Viewport countersink (protects display glass) ---
        translate([0,
                   phone_length/2 - display_offset_y - display_h/2,
                   wall - display_depth])
            rounded_box(display_w + 2, display_h + 2, display_depth + 0.2, 1.5);

        // --- Speaker grille (top edge, centred) ---
        translate([0, phone_length/2 - 8, -0.1])
            linear_extrude(height = wall + 0.2)
                grille_pattern(6, 2, 3, 1.5, 1.2, 0.5);

        // --- Front camera / sensor pinhole ---
        translate([display_w/2 + 6,
                   phone_length/2 - display_offset_y - 5,
                   -0.1])
            cylinder(h = wall + 0.2, d = 2.5);

        // --- Notification LED slot ---
        translate([0, phone_length/2 - 5, -0.1])
            rounded_box(6, 2, wall + 0.2, 0.8);

        // --- Power button (right side) ---
        translate([phone_width/2 - 0.1,
                   phone_length/2 - 30,
                   top_shell_z/2])
            rotate([0, 90, 0])
                rounded_box(8, 4, wall + 0.2, 1);

        // --- Volume rocker (right side) ---
        translate([phone_width/2 - 0.1,
                   phone_length/2 - 50,
                   top_shell_z/2])
            rotate([0, 90, 0])
                rounded_box(14, 4, wall + 0.2, 1);

        // --- PCB mounting screw holes ---
        for (pos = [
            [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - 3],
            [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - 3],
            [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - pcb_length + 3],
            [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - pcb_length + 3]
        ]) {
            translate([pos[0], pos[1], wall])
                cylinder(h = top_shell_z, d = screw_hole_d);
        }

        // --- Corner screw holes (joins top shell to bottom shell) ---
        for (pos = [
            [ phone_width/2 - 8,  phone_length/2 - 8],
            [-phone_width/2 + 8,  phone_length/2 - 8],
            [ phone_width/2 - 8, -phone_length/2 + 8],
            [-phone_width/2 + 8, -phone_length/2 + 8]
        ]) {
            translate([pos[0], pos[1], -0.1])
                cylinder(h = top_shell_z + 0.2, d = screw_hole_d);
        }
    }
}

// --- Render ---
top_shell();
