// ============================================================================
// Meshtastic Sliding Phone – Main Body  (backward-compatible alias)
// ============================================================================
// This file is a backward-compatible alias for top_shell.scad.
// The canonical file for the unified top enclosure is top_shell.scad.
//
// STRUCTURE
// ─────────
//   • Full exterior shell (95 × 120 × 19 mm, rounded corners)
//   • Display / OLED viewport cutout with countersink on the top face
//   • Electronics cavity accessible from the bottom (open rail face)
//   • Dedicated battery recess inside the cavity (battery cover integrated)
//   • Two rectangular slider rails on the interior side walls (additive)
//     (rail_width = 3 mm, rail_height = 3 mm, clearance = 0.35 mm – per spec)
//     Rails protrude inward at Y = ±(phone_length/2 − wall_thickness);
//     the solid bottom floor is not modified
//   • Magnet pockets: 10.3 mm bore × 4.2 mm deep, 0.5 mm retention lip
//     for 10 mm × 4 mm neodymium disc magnets
//   • PCB mounting posts (Heltec V4) positioned below the viewport
//   • Internal reinforcement ribs on large flat surfaces (reduce flex)
//   • USB-C, SMA, microphone, and speaker holes on appropriate edges
//
// ASSEMBLY ORDER
// ──────────────
//   1. Install Heltec V4 PCB onto mounting posts (M2 screws)
//   2. Press 10 mm × 4 mm magnets into pockets (check polarity)
//   3. Insert LiPo battery into recess
//   4. Slide keyboard_tray onto top-shell rails from the +X end
//   5. Snap tray closed; clip CardKB (88×54 mm) into tray pocket
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

    // Stop block X position (body X of stop block +X face)
    stop_block_pos_x = -(slider_travel - tab_stop_margin - phone_width/2);

    union() {
        difference() {
            union() {
                // ── Outer shell ─────────────────────────────────────────────────
                rounded_box(phone_width, phone_length, body_z, corner_radius);

                // ── PCB mounting posts ───────────────────────────────────────────
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
            // Height = body_z − 2×wall_thickness preserves BOTH the solid bottom
            // floor (Z = 0…wall_thickness) AND the display-face top plate
            // (Z = body_z−wall_thickness…body_z) so the viewport cutout works.
            translate([0, 0, wall_thickness])
                rounded_box(phone_width  - 2 * wall_thickness,
                            phone_length - 2 * wall_thickness,
                            body_z - 2 * wall_thickness,
                            max(corner_radius - wall_thickness, 0.5));

            // ── Battery recess (MakerFocus 3000 mAh, 71 × 51 × 9 mm) ─────────────
            translate([0,
                       phone_length/2 - wall_thickness - battery_pocket_y/2 - 5,
                       wall_thickness])
                cube([battery_pocket_x, battery_pocket_y, battery_pocket_z + 1],
                     center = true);

            // (Rail channels removed: rails are now additive features on side walls,
            //  added below in the outer union() – floor remains solid per spec)

            // ── Magnet pockets – CLOSED-position detent ─────────────────────────
            // Body pocket at X = detent_x_offset + magnet_offset = +38 mm.
            // The +6 mm offset creates an attractive X-component that pulls the
            // tray into the closed stop.
            for (side = [-1, 1]) {
                translate([detent_x_offset + magnet_offset, side * magnet_y, -0.1])
                    magnet_pocket();
            }

            // ── Magnet pockets – OPEN-position detent ───────────────────────────
            // Body pocket at X = detent_x_offset − slider_travel − magnet_offset
            //                   = 32 − 65 − 6 = −39 mm.
            for (side = [-1, 1]) {
                translate([detent_x_offset - slider_travel - magnet_offset,
                           side * magnet_y,
                           -0.1])
                    magnet_pocket();
            }

            // ── OLED viewport cutout (top face, Z = body_z) ──────────────────────
            translate([0,
                       phone_length/2 - display_offset_y - display_h/2,
                       body_z - wall_thickness - 0.1])
                rounded_box(display_w, display_h, wall_thickness + 0.2, 1);

            // ── Viewport countersink ─────────────────────────────────────────────
            translate([0,
                       phone_length/2 - display_offset_y - display_h/2,
                       body_z - wall_thickness - display_depth])
                rounded_box(display_w + 2, display_h + 2, display_depth + 0.2, 1.5);

            // ── Speaker grille (top face, near +Y edge) ───────────────────────────
            translate([0, phone_length/2 - 8, body_z - wall_thickness - 0.1])
                linear_extrude(height = wall_thickness + 0.2)
                    grille_pattern(6, 2, 3, 1.5, 1.2, 0.5);

            // ── Front camera / sensor pinhole ─────────────────────────────────────
            translate([display_w/2 + 6,
                       phone_length/2 - display_offset_y - 5,
                       body_z - wall_thickness - 0.1])
                cylinder(h = wall_thickness + 0.2, d = 2.5);

            // ── Notification LED slot ─────────────────────────────────────────────
            translate([0, phone_length/2 - 5, body_z - wall_thickness - 0.1])
                rounded_box(6, 2, wall_thickness + 0.2, 0.8);

            // ── Power button (right side, +X wall) ────────────────────────────────
            translate([phone_width/2 - 0.1,
                       phone_length/2 - 30,
                       body_z * 0.65])
                rotate([0, 90, 0])
                    rounded_box(8, 4, wall_thickness + 0.2, 1);

            // ── Volume rocker (right side, +X wall) ───────────────────────────────
            translate([phone_width/2 - 0.1,
                       phone_length/2 - 50,
                       body_z * 0.65])
                rotate([0, 90, 0])
                    rounded_box(14, 4, wall_thickness + 0.2, 1);

            // ── USB-C port (−Y / bottom edge) ─────────────────────────────────────
            translate([0,
                       -phone_length/2 - 0.1,
                       bot_shell_z/2 + 1])
                rotate([90, 0, 0])
                    rounded_box(usbc_width, usbc_height, wall_thickness + 0.4, 1);

            // ── SMA antenna connector hole (+Y / top edge) ────────────────────────
            translate([phone_width/2 - 12,
                       phone_length/2 - 0.1,
                       bot_shell_z/2 + 2])
                rotate([90, 0, 0])
                    cylinder(h = wall_thickness + 0.4, d = sma_diameter);

            // ── Microphone hole (−Y / bottom edge) ───────────────────────────────
            translate([-12,
                       -phone_length/2 - 0.1,
                       bot_shell_z/2 - 1])
                rotate([90, 0, 0])
                    cylinder(h = wall_thickness + 0.4, d = mic_diameter);

            // ── Bottom speaker grille (−Y / bottom edge) ──────────────────────────
            translate([12,
                       -phone_length/2 - 0.1,
                       bot_shell_z/2])
                rotate([90, 0, 0])
                    linear_extrude(height = wall_thickness + 0.2)
                        grille_pattern(3, 2, 3, 1.5, 1.2, 0.5);

            // ── Ventilation slots (±Y long edges) ─────────────────────────────────
            for (side = [-1, 1]) {
                translate([0,
                           side * (phone_length/2 - 0.1),
                           body_z * 0.5])
                    rotate([90, 0, 0])
                        linear_extrude(height = wall_thickness + 0.2)
                            grille_pattern(1, 3, 2, 6, 2, 0.8);
            }

            // ── PCB screw holes (M2 pass-through in mounting posts) ───────────────
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

        // ── Slider guide rails (protrude BELOW the bottom face) ──────────────────
        // Rails at Z = −rail_height … 0 hang below the exterior bottom face.
        // In world coords (top_shell at world Z = tray_z = 8 mm):
        //   Rail world Z = tray_z − rail_height … tray_z = 5.0 … 8.0 mm
        //   Tray groove world Z = 4.65 … 8.0 mm → rail captured, 0.35 mm clearance ✓
        wall_inner_y_mb        = phone_length / 2 - wall_thickness;
        slider_rail_inner_y_mb = wall_inner_y_mb - rail_width;
        slider_rail_x_start_mb = phone_width / 2 - rail_length;
        for (flip = [false, true]) {
            mirror([0, flip ? 1 : 0, 0])
                translate([slider_rail_x_start_mb,
                           slider_rail_inner_y_mb,
                           -rail_height])
                    cube([rail_length, rail_width, rail_height]);
        }
    }
}

// --- Render ---
main_body();
