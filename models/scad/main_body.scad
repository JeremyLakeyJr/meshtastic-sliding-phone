// ============================================================================
// Meshtastic Sliding Phone – Main Body  (unified 2-piece enclosure)
// ============================================================================
// The single printed enclosure that replaces the former 3-piece
// top_shell + bottom_shell + battery_cover stack.
//
// STRUCTURE
// ─────────
//   • Full exterior shell (74 × 120 × 19 mm, rounded corners)
//   • Display / OLED viewport cutout with countersink on the top face
//   • Electronics cavity accessible from the bottom (open rail face)
//   • Dedicated battery recess inside the cavity
//   • Two T-slot rail CHANNELS on the bottom face for the keyboard tray
//   • Rail-boss ribs at Y = ±rail_y provide solid material for channels
//   • Magnet pockets for closed-position and open-position snap detents
//   • PCB mounting posts (Heltec V4) positioned below the viewport
//   • Antenna-mount reinforcement boss around the SMA hole
//   • Internal reinforcement ribs on large flat surfaces (reduce flex)
//   • USB-C, SMA, microphone, and speaker holes on appropriate edges
//
// ASSEMBLY ORDER
// ──────────────
//   1. Install Heltec V4 PCB onto mounting posts (M2 screws)
//   2. Press magnets into pockets (check polarity: opposing pairs attract)
//   3. Insert LiPo battery into recess
//   4. Slide keyboard_tray into rail channels from the +X end
//   5. Snap tray closed; clip CardKB module into tray pocket
//
// PRINT ORIENTATION
//   Display face DOWN — viewport and button recesses print without supports.
//   Minimum wall 2.2 mm; no overhang > 50°; chamfered rail entry.
//
// Print settings: 0.2 mm layer height, 25 % infill, 3 perimeters
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module main_body() {
    // Reinforcement rib thickness and interior span
    rib_t  = wall_thickness / 2;                    // 1.1 mm
    rib_h  = body_z - wall_thickness;               // floor-to-ceiling span inside cavity
    rib_iw = phone_width  - 2 * wall_thickness;     // interior width  (X)
    rib_il = phone_length - 2 * wall_thickness;     // interior length (Y)

    difference() {
        union() {
            // ── Outer shell ─────────────────────────────────────────────────
            rounded_box(phone_width, phone_length, body_z, corner_radius);

            // ── PCB mounting posts ───────────────────────────────────────────
            // Four M2 screw posts on the interior floor, positioned for the
            // Heltec V4 PCB (51.7 × 25.4 mm) below the display viewport.
            for (pos = [
                [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - 3],
                [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - 3],
                [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - pcb_length + 3],
                [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - pcb_length + 3]
            ]) {
                translate([pos[0], pos[1], wall_thickness])
                    screw_post(screw_post_h, screw_post_d, screw_hole_d);
            }

            // ── Internal reinforcement ribs ──────────────────────────────────
            // Thin cross-ribs on the interior reduce flex on large flat panels.
            // One longitudinal rib (along Y, centred in X) and two lateral ribs
            // (along X, at 1/3 and 2/3 of the interior Y span).

            // Longitudinal rib
            translate([-rib_t/2,
                       -(phone_length/2 - wall_thickness),
                       wall_thickness])
                cube([rib_t, rib_il, rib_h]);

            // Lateral ribs at 1/3 and 2/3 interior Y
            for (frac = [1/3, 2/3]) {
                translate([-rib_iw/2,
                           -phone_length/2 + wall_thickness
                               + frac * rib_il - rib_t/2,
                           wall_thickness])
                    cube([rib_iw, rib_t, rib_h]);
            }
        }

        // ── Interior cavity ──────────────────────────────────────────────────
        // Carve out the body interior, leaving wall_thickness on all sides
        // and the top plate.  The bottom (Z = 0 … wall_thickness) is left
        // solid so the rail channels have material to cut into.
        translate([0, 0, wall_thickness])
            rounded_box(phone_width  - 2 * wall_thickness,
                        phone_length - 2 * wall_thickness,
                        body_z,
                        max(corner_radius - wall_thickness, 0.5));

        // ── Battery recess ───────────────────────────────────────────────────
        // Sunken pocket inside the cavity for the LiPo pouch cell.
        // Positioned toward the +Y end, 5 mm from the inner wall.
        // +1 mm clearance on each LiPo dimension provides assembly tolerance.
        translate([0,
                   phone_length/2 - wall_thickness - lipo_length/2 - 5,
                   wall_thickness])
            cube([lipo_width + 1, lipo_length + 1, lipo_thickness + 1],
                 center = true);

        // ── T-slot rail channels (bottom face, Z = 0 upward) ────────────────
        // Two T-slot channels at Y = ±rail_y accept the keyboard-tray runners.
        // Channels run the full X width; lip void extends 1 mm past each X end.
        // Stem void is inset 1 mm from −X (natural stop wall for tray tabs).
        // Snap-ramp near the −X end assists "self-finishing" open action.
        for (side = [-1, 1]) {
            translate([-phone_width/2 - 1,
                       side * rail_y - rail_channel_w/2,
                       0])
                rail_channel_void(phone_width);
        }

        // ── Magnet pockets – CLOSED-position detent (bottom face, Z = 0) ─────
        // At travel = 0, tray magnets at tray-local X = +detent_x_offset
        // align with these pockets.
        for (side = [-1, 1]) {
            translate([detent_x_offset, side * magnet_y, -0.1])
                magnet_pocket();
        }

        // ── Magnet pockets – OPEN-position detent (bottom face, Z = 0) ───────
        // At full travel (slider_travel = 35 mm):
        //   X = detent_x_offset − slider_travel = 28 − 35 = −7 mm
        for (side = [-1, 1]) {
            translate([detent_x_offset - slider_travel,
                       side * magnet_y,
                       -0.1])
                magnet_pocket();
        }

        // ── OLED viewport cutout (top face, Z = body_z) ──────────────────────
        translate([0,
                   phone_length/2 - display_offset_y - display_h/2,
                   body_z - wall_thickness - 0.1])
            rounded_box(display_w, display_h, wall_thickness + 0.2, 1);

        // ── Viewport countersink (protects display / touch glass) ────────────
        translate([0,
                   phone_length/2 - display_offset_y - display_h/2,
                   body_z - wall_thickness - display_depth])
            rounded_box(display_w + 2, display_h + 2, display_depth + 0.2, 1.5);

        // ── Speaker grille (top face, near +Y edge) ───────────────────────────
        translate([0, phone_length/2 - 8, body_z - wall_thickness - 0.1])
            linear_extrude(height = wall_thickness + 0.2)
                grille_pattern(6, 2, 3, 1.5, 1.2, 0.5);

        // ── Front camera / sensor pinhole (top face) ─────────────────────────
        translate([display_w/2 + 6,
                   phone_length/2 - display_offset_y - 5,
                   body_z - wall_thickness - 0.1])
            cylinder(h = wall_thickness + 0.2, d = 2.5);

        // ── Notification LED slot (top face) ─────────────────────────────────
        translate([0, phone_length/2 - 5, body_z - wall_thickness - 0.1])
            rounded_box(6, 2, wall_thickness + 0.2, 0.8);

        // ── Power button (right side, +X wall) ───────────────────────────────
        translate([phone_width/2 - 0.1,
                   phone_length/2 - 30,
                   body_z * 0.65])
            rotate([0, 90, 0])
                rounded_box(8, 4, wall_thickness + 0.2, 1);

        // ── Volume rocker (right side, +X wall) ──────────────────────────────
        translate([phone_width/2 - 0.1,
                   phone_length/2 - 50,
                   body_z * 0.65])
            rotate([0, 90, 0])
                rounded_box(14, 4, wall_thickness + 0.2, 1);

        // ── USB-C port (−Y / bottom edge) ────────────────────────────────────
        translate([0,
                   -phone_length/2 - 0.1,
                   bot_shell_z/2 + 1])
            rotate([90, 0, 0])
                rounded_box(usbc_width, usbc_height, wall_thickness + 0.4, 1);

        // ── SMA antenna connector hole (+Y / top edge) ───────────────────────
        // Extra material around the hole acts as the reinforcement boss.
        translate([phone_width/2 - 12,
                   phone_length/2 - 0.1,
                   bot_shell_z/2 + 2])
            rotate([90, 0, 0])
                cylinder(h = wall_thickness + 0.4, d = sma_diameter);

        // ── Microphone hole (−Y / bottom edge) ──────────────────────────────
        translate([-12,
                   -phone_length/2 - 0.1,
                   bot_shell_z/2 - 1])
            rotate([90, 0, 0])
                cylinder(h = wall_thickness + 0.4, d = mic_diameter);

        // ── Bottom speaker grille (−Y / bottom edge) ─────────────────────────
        translate([12,
                   -phone_length/2 - 0.1,
                   bot_shell_z/2])
            rotate([90, 0, 0])
                linear_extrude(height = wall_thickness + 0.2)
                    grille_pattern(3, 2, 3, 1.5, 1.2, 0.5);

        // ── Ventilation slots (±Y long edges) ────────────────────────────────
        for (side = [-1, 1]) {
            translate([0,
                       side * (phone_length/2 - 0.1),
                       body_z * 0.5])
                rotate([90, 0, 0])
                    linear_extrude(height = wall_thickness + 0.2)
                        grille_pattern(1, 3, 2, 6, 2, 0.8);
        }

        // ── PCB screw holes (M2 pass-through in mounting posts) ──────────────
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
}

// --- Render ---
main_body();
