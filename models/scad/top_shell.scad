// ============================================================================
// Meshtastic Sliding Phone – Top Shell  (unified 2-piece enclosure)
// ============================================================================
// The single printed top enclosure (replaces the former 3-piece
// top_shell + bottom_shell + battery_cover stack).
//
// STRUCTURE
// ─────────
//   • Full exterior shell (95 × 120 × 19 mm, rounded corners)
//   • Display / OLED viewport cutout with countersink on the top face
//   • Electronics cavity accessible from the bottom (open rail face)
//   • Dedicated battery recess inside the cavity (battery cover integrated)
//   • Two T-slot rail CHANNELS on the bottom face for the keyboard tray
//   • Rail-boss ribs at Y = ±rail_y provide solid material for channels
//   • Stop blocks inside the rail channels (prevent accidental tray removal)
//   • Magnet pockets for closed-position and open-position snap detents
//     (10 mm × 4 mm neodymium disc magnets, 10.3 mm bore × 4.2 mm deep)
//   • PCB mounting posts (Heltec V4) positioned below the viewport
//   • Internal reinforcement ribs on large flat surfaces (reduce flex)
//   • USB-C, SMA, microphone, and speaker holes on appropriate edges
//
// STOP BLOCK ASSEMBLY
// ───────────────────
//   Stop blocks are 2 mm tall protrusions on the channel floor at
//   body X ≈ −15.5 mm from centre.  The runner -X tip has a matching
//   stop_cutout (2.5 mm deep notch) enabling assembly from the +X end:
//   1. Align runner with channel entry at +X body face.
//   2. Slide tray in −X direction.  Runner -X tip cutout clears the
//      stop block at ~63 mm insertion depth.
//   3. Continue sliding to closed position — done.
//   When tray is opened, the solid runner trailing-face hits the stop
//   block at travel = slider_travel − 2 = 63 mm, preventing over-travel.
//
// TYPING ANGLE
// ─────────────
//   A passive 3° typing angle (see typing_angle in parameters.scad) is
//   produced when the keyboard is fully extended: the 2.5 mm T-slot
//   standoff allows the tray to rest at a natural incline.  No angled
//   rails are needed — standard straight T-slot channels suffice.
//
// PRINT ORIENTATION
//   Display face DOWN — viewport and button recesses print without supports.
//   Minimum wall 2.2 mm; no overhang > 50°; chamfered rail entry.
//
// Print settings: 0.2 mm layer height, 25 % infill, 3 perimeters
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module top_shell() {
    // Reinforcement rib thickness and interior span
    rib_t  = wall_thickness / 2;                    // 1.1 mm
    rib_h  = body_z - wall_thickness;               // floor-to-ceiling span inside cavity
    rib_iw = phone_width  - 2 * wall_thickness;     // interior width  (X)
    rib_il = phone_length - 2 * wall_thickness;     // interior length (Y)

    // Stop block +X-face position in body frame.
    // stop_block_pos_x = -(slider_travel - tab_stop_margin - phone_width/2) = -15.5 mm
    stop_block_pos_x = -(slider_travel - tab_stop_margin - phone_width/2);

    union() {
        difference() {
            union() {
                // ── Outer shell ─────────────────────────────────────────────
                rounded_box(phone_width, phone_length, body_z, corner_radius);

                // ── PCB mounting posts ───────────────────────────────────────
                // Four M2 screw posts for Heltec V4 PCB (52 × 26 mm).
                for (pos = [
                    [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - 3],
                    [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - 3],
                    [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - pcb_length + 3],
                    [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - pcb_length + 3]
                ]) {
                    translate([pos[0], pos[1], wall_thickness])
                        screw_post(screw_post_h, screw_post_d, screw_hole_d);
                }

                // ── Internal reinforcement ribs ──────────────────────────────
                // Longitudinal rib (along Y, centred in X)
                translate([-rib_t/2,
                           -(phone_length/2 - wall_thickness),
                           wall_thickness])
                    cube([rib_t, rib_il, rib_h]);

                // Lateral ribs at 1/3 and 2/3 of interior Y span
                for (frac = [1/3, 2/3]) {
                    translate([-rib_iw/2,
                               -phone_length/2 + wall_thickness
                                   + frac * rib_il - rib_t/2,
                               wall_thickness])
                        cube([rib_iw, rib_t, rib_h]);
                }
            }

            // ── Interior cavity ──────────────────────────────────────────────
            translate([0, 0, wall_thickness])
                rounded_box(phone_width  - 2 * wall_thickness,
                            phone_length - 2 * wall_thickness,
                            body_z,
                            max(corner_radius - wall_thickness, 0.5));

            // ── Battery recess (integrated battery cover) ────────────────────
            // Sunken pocket for the LiPo pouch cell at +Y end, 5 mm from wall.
            translate([0,
                       phone_length/2 - wall_thickness - lipo_length/2 - 5,
                       wall_thickness])
                cube([lipo_width + 1, lipo_length + 1, lipo_thickness + 1],
                     center = true);

            // ── T-slot rail channels (bottom face, Z = 0 upward) ─────────────
            // Two T-slot channels at Y = ±rail_y accept keyboard-tray runners.
            // Channels span the full phone_width; lip void extends 1 mm past each
            // X end; entry chamfer at +X; snap ramp near −X end.
            for (side = [-1, 1]) {
                translate([-phone_width/2 - 1,
                           side * rail_y - rail_channel_w/2,
                           0])
                    rail_channel_void(phone_width);
            }

            // ── Magnet pockets – CLOSED-position detent (body bottom, Z = 0) ─
            // Tray magnets at tray-local X = +detent_x_offset align here
            // when travel = 0 (closed).
            for (side = [-1, 1]) {
                translate([detent_x_offset, side * magnet_y, -0.1])
                    magnet_pocket();
            }

            // ── Magnet pockets – OPEN-position detent (body bottom, Z = 0) ───
            // At full travel (slider_travel = 65 mm):
            //   body X = detent_x_offset − slider_travel = 32 − 65 = −33 mm
            for (side = [-1, 1]) {
                translate([detent_x_offset - slider_travel,
                           side * magnet_y,
                           -0.1])
                    magnet_pocket();
            }

            // ── OLED viewport cutout (top face, Z = body_z) ──────────────────
            translate([0,
                       phone_length/2 - display_offset_y - display_h/2,
                       body_z - wall_thickness - 0.1])
                rounded_box(display_w, display_h, wall_thickness + 0.2, 1);

            // ── Viewport countersink ─────────────────────────────────────────
            translate([0,
                       phone_length/2 - display_offset_y - display_h/2,
                       body_z - wall_thickness - display_depth])
                rounded_box(display_w + 2, display_h + 2, display_depth + 0.2, 1.5);

            // ── Speaker grille (top face, near +Y edge) ───────────────────────
            translate([0, phone_length/2 - 8, body_z - wall_thickness - 0.1])
                linear_extrude(height = wall_thickness + 0.2)
                    grille_pattern(6, 2, 3, 1.5, 1.2, 0.5);

            // ── Front camera / sensor pinhole (top face) ──────────────────────
            translate([display_w/2 + 6,
                       phone_length/2 - display_offset_y - 5,
                       body_z - wall_thickness - 0.1])
                cylinder(h = wall_thickness + 0.2, d = 2.5);

            // ── Notification LED slot (top face) ──────────────────────────────
            translate([0, phone_length/2 - 5, body_z - wall_thickness - 0.1])
                rounded_box(6, 2, wall_thickness + 0.2, 0.8);

            // ── Power button (right side, +X wall) ────────────────────────────
            translate([phone_width/2 - 0.1,
                       phone_length/2 - 30,
                       body_z * 0.65])
                rotate([0, 90, 0])
                    rounded_box(8, 4, wall_thickness + 0.2, 1);

            // ── Volume rocker (right side, +X wall) ───────────────────────────
            translate([phone_width/2 - 0.1,
                       phone_length/2 - 50,
                       body_z * 0.65])
                rotate([0, 90, 0])
                    rounded_box(14, 4, wall_thickness + 0.2, 1);

            // ── USB-C port (−Y / bottom edge) ─────────────────────────────────
            translate([0,
                       -phone_length/2 - 0.1,
                       bot_shell_z/2 + 1])
                rotate([90, 0, 0])
                    rounded_box(usbc_width, usbc_height, wall_thickness + 0.4, 1);

            // ── SMA antenna connector hole (+Y / top edge) ────────────────────
            translate([phone_width/2 - 12,
                       phone_length/2 - 0.1,
                       bot_shell_z/2 + 2])
                rotate([90, 0, 0])
                    cylinder(h = wall_thickness + 0.4, d = sma_diameter);

            // ── Microphone hole (−Y / bottom edge) ───────────────────────────
            translate([-12,
                       -phone_length/2 - 0.1,
                       bot_shell_z/2 - 1])
                rotate([90, 0, 0])
                    cylinder(h = wall_thickness + 0.4, d = mic_diameter);

            // ── Bottom speaker grille (−Y / bottom edge) ──────────────────────
            translate([12,
                       -phone_length/2 - 0.1,
                       bot_shell_z/2])
                rotate([90, 0, 0])
                    linear_extrude(height = wall_thickness + 0.2)
                        grille_pattern(3, 2, 3, 1.5, 1.2, 0.5);

            // ── Ventilation slots (±Y long edges) ─────────────────────────────
            for (side = [-1, 1]) {
                translate([0,
                           side * (phone_length/2 - 0.1),
                           body_z * 0.5])
                    rotate([90, 0, 0])
                        linear_extrude(height = wall_thickness + 0.2)
                            grille_pattern(1, 3, 2, 6, 2, 0.8);
            }

            // ── PCB screw holes (M2 pass-through in mounting posts) ───────────
            for (pos = [
                [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - 3],
                [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - 3],
                [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - pcb_length + 3],
                [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - pcb_length + 3]
            ]) {
                translate([pos[0], pos[1], wall_thickness])
                    cylinder(h = body_z, d = screw_hole_d);
            }
        }

        // ── Stop blocks inside rail channels ─────────────────────────────────
        // Added AFTER the main difference() so they protrude into the channel void.
        // Height = stop_block_height (2 mm), depth = stop_block_depth (2 mm),
        // width = rail_channel_w (spans full stem void width).
        // The runner -X tip has a stop_cutout (2.5 mm) that clears these blocks
        // during assembly; after assembly they prevent over-travel on opening.
        for (side = [-1, 1]) {
            translate([stop_block_pos_x - stop_block_depth,
                       side * rail_y - rail_channel_w/2,
                       0])
                cube([stop_block_depth, rail_channel_w, stop_block_height]);
        }
    }
}

// --- Render ---
top_shell();
