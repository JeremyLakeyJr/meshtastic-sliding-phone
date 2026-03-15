// ============================================================================
// Meshtastic Sliding Phone – Keyboard Tray  (sliding component / bottom shell)
// ============================================================================
// The horizontally sliding keyboard carriage.  Sits beneath the top shell
// and slides in the −X direction (shortways, along the 95 mm short axis) by
// slider_travel (65 mm) to expose the M5Stack CardKB module.  Holding the
// phone in landscape (120 mm wide × 95 mm tall) the keyboard slides downward.
//
// KEY FEATURES
// ─────────────────────────────────────────────────────────────────────────
// Slider rail grooves (capture the additive rails from the top shell)
//   The top shell carries two rectangular rails (rail_width × rail_height =
//   3 × 3 mm) on its interior side walls at Y = ±(phone_length/2 −
//   wall_thickness) = ±57.8 mm, protruding inward by rail_width.
//
//   The tray contains matching grooves that capture these rails:
//     Groove width  = rail_width  + 2 × rail_clearance = 3.7 mm  (Y span)
//     Groove depth  = rail_height + rail_clearance      = 3.35 mm (from top face)
//     Inner face    = wall_inner_y − rail_width − rail_clearance = 54.45 mm
//     Outer face    = wall_inner_y + rail_clearance             = 58.15 mm
//   The groove runs the same X range as the rails (runner_x_start … +47.5 mm).
//   Each groove is formed by:
//     (a) A guide block (additive) that fills the hollow interior near the
//         side wall, providing the groove floor and inner face.
//     (b) A clearance cut into the tray’s outer side wall (rail_clearance mm).
//
// Wire routing groove alongside +Y guide block
//   6 mm wide × 2 mm deep channel for the CardKB flex cable.
//
// Magnetic detents (neodymium disc magnets, 10 mm dia × 4 mm thick, N35)
//   Two press-fit pockets on the tray top face at ±magnet_y = ±20 mm,
//   X = +detent_x_offset = +32 mm (tray local).
//
// CardKB pocket (M5Stack CardKB v1.1, 88 × 54 × 7 mm)
//   Recessed pocket at the −X (extension) end.
//   Pocket: 89 × 55 mm (X × Y), depth = keyboard_pocket_depth = 8 mm.
//   Retention ledges on ±Y sides hold the CardKB in the pocket.
//
// VERTICAL CLEARANCE STACK (minimum 14 mm)
//   keyboard_thickness = 7 mm + tray_floor ≈ 2.2 mm + rail_height = 3 mm
//   + case_floor ≈ 2.2 mm = ~14.4 mm ≥ 14 mm spec ✓
//
// ─────────────────────────────────────────────────────────────────────────
// Assembly
//   1. Insert from the +X end: align the tray grooves with the top-shell
//      rails and slide −X until the closed-position magnet snap is felt.
//   2. Press-fit magnets (check pole orientation — opposing pairs attract).
//   3. Clip CardKB module into the tray pocket.
//
// Print orientation : TOP FACE DOWN (grooves print downward from tray face;
//                     no supports needed for rectangular groove walls)
// Print settings    : 0.2 mm layer height, 30 % infill, brim recommended
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module keyboard_tray() {
    tray_w = phone_width;   // Tray X span matches top-shell body width (95 mm)

    // CardKB pocket dimensions (with clearance)
    pocket_x = cardkb_h + 2 * keyboard_clearance;   // 55 mm in X (slide direction)
    pocket_y = cardkb_w + 2 * keyboard_clearance;   // 89 mm in Y (long axis)

    // Groove X start: positioned at the +X (insertion) end of the tray.
    // Groove spans from (tray_w/2 − rail_length) to +tray_w/2.
    runner_x_start = tray_w/2 - rail_length;   // −22.5 mm (tray-local)

    // Slider rail groove geometry (per spec)
    // The top shell has rails at Y = ±wall_inner_y, protruding inward by rail_width.
    // Tray grooves capture these rails with rail_clearance on each side.
    wall_inner_y       = phone_length / 2 - wall_thickness;         // 57.8 mm
    groove_outer_y     = wall_inner_y + rail_clearance;              // 58.15 mm
    groove_inner_y     = wall_inner_y - rail_width - rail_clearance; // 54.45 mm
    slider_groove_depth = rail_height + rail_clearance;              // 3.35 mm
    slider_groove_width = rail_width  + 2 * rail_clearance;          // 3.70 mm

    union() {
        // ── Main tray body with all standard subtractions ──────────────────────────────
        difference() {
            // ── Main tray body ──────────────────────────────────────────────────────
            rounded_box(phone_width, phone_length, tray_z, corner_radius);

            // ── Interior cavity ─────────────────────────────────────────────────────
            // Open-bottom tray: hollow from wall_thickness up to tray_z.
            translate([0, 0, wall_thickness])
                rounded_box(phone_width  - 2 * wall_thickness,
                            phone_length - 2 * wall_thickness,
                            tray_z,
                            max(corner_radius - wall_thickness, 0.5));

            // ── CardKB module pocket (at the −X extension end) ───────────────────
            translate([-tray_w / 2 + wall_thickness + pocket_x / 2,
                       0,
                       wall_thickness])
                rounded_box(pocket_x, pocket_y, keyboard_pocket_depth, 2);

            // ── I²C / ribbon-cable relief slot (−X edge of tray) ─────────────────
            translate([-tray_w / 2 - 0.1,
                       0,
                       wall_thickness + cardkb_thickness / 2])
                rotate([0, 90, 0])
                    rounded_box(cardkb_thickness + 1, 10, wall_thickness + 0.4, 1);

            // ── Wire routing groove alongside +Y rail ───────────────────────────
            // Just inside the +Y guide block: Y = groove_inner_y − wire_tunnel_width − 0.5 mm gap
            translate([-tray_w / 2,
                       groove_inner_y - wire_tunnel_width - 0.5,
                       tray_z - wire_tunnel_height])
                cube([tray_w, wire_tunnel_width, wire_tunnel_height + 0.1]);

            // ── Magnet pockets on tray top face ──────────────────────────────────
            for (side = [-1, 1]) {
                translate([detent_x_offset,
                           side * magnet_y,
                           tray_z - magnet_depth])
                    magnet_pocket();
            }

            // ── Rail groove outer-wall clearance cut ───────────────────────────────
            // Removes rail_clearance (0.35 mm) from the outer side walls to provide
            // clearance between the groove outer face and the rail outer face.
            // Cut: Y = wall_inner_y … groove_outer_y = 57.8 … 58.15 mm (+Y side)
            //      mirrored for −Y side.
            for (flip = [false, true]) {
                mirror([0, flip ? 1 : 0, 0])
                    translate([runner_x_start - geom_epsilon,
                               wall_inner_y,
                               tray_z - slider_groove_depth - geom_epsilon])
                        cube([rail_length + 2 * geom_epsilon,
                              rail_clearance + geom_epsilon,
                              slider_groove_depth + 2 * geom_epsilon]);
            }
        }

        // ── Rail guide blocks with groove cuts ───────────────────────────────────
        // Each guide block fills the hollow interior adjacent to the outer side
        // wall.  After subtracting the groove interior, the block provides:
        //   • Groove floor  : solid from Z = wall_thickness to tray_z − groove_depth
        //   • Groove channel : hollow from Z = tray_z − groove_depth to tray_z
        //   • Inner face    : block face at Y = groove_inner_y (captures rail
        //                      inner face at Y = wall_inner_y − rail_width with
        //                      rail_clearance = 0.35 mm clearance)
        //
        // Guide block (additive):
        //   Y = groove_inner_y … wall_inner_y = 54.45 … 57.8 mm
        //   Z = wall_thickness … tray_z         = 2.2 … 8 mm
        //   X = runner_x_start … tray_w/2        = −22.5 … +47.5 mm
        //
        // Groove cut (subtracted from block):
        //   Y = groove_inner_y … wall_inner_y  (same as block width)
        //   Z = tray_z − groove_depth … tray_z = 4.65 … 8 mm
        for (flip = [false, true]) {
            mirror([0, flip ? 1 : 0, 0])
                difference() {
                    // Guide block
                    translate([runner_x_start,
                               groove_inner_y,
                               wall_thickness])
                        cube([rail_length,
                              wall_inner_y - groove_inner_y,
                              tray_z - wall_thickness]);

                    // Groove interior (hollow out upper portion for the rail)
                    translate([runner_x_start - geom_epsilon,
                               groove_inner_y - geom_epsilon,
                               tray_z - slider_groove_depth - geom_epsilon])
                        cube([rail_length + 2 * geom_epsilon,
                              wall_inner_y - groove_inner_y + 2 * geom_epsilon,
                              slider_groove_depth + 2 * geom_epsilon]);
                }
        }

        // ── CardKB retention ledges (snap lips to hold module in pocket) ────────
        for (side = [-1, 1]) {
            translate([-tray_w / 2 + wall_thickness + pocket_x / 2,
                       side * (pocket_y / 2 + 1),
                       wall_thickness + cardkb_thickness])
                cube([pocket_x - 2, 2, 1.5], center = true);
        }
    }
}

// --- Render ---
keyboard_tray();
