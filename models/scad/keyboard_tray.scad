// ============================================================================
// Meshtastic Sliding Phone – Keyboard Tray  (sliding component)
// ============================================================================
// The horizontally sliding keyboard carriage.  Sits beneath the phone body
// and slides in the −Y direction by keyboard_travel (42 mm) to expose the
// M5Stack CardKB module.
//
// KEY FEATURES
// ─────────────────────────────────────────────────────────────────────────
// Parallel side rails
//   Two rectangular runners protrude from the tray top face (+Z).  They
//   slide inside matching channels cut into the bottom-shell underside,
//   keeping the motion straight and preventing lateral (X-axis) wobble.
//   Runner dimensions: rail_w × rail_h = 4.0 × 2.5 mm.
//   The channels are 1 mm deeper (rail_channel_h = 3.5 mm) so the runners
//   float freely in Z — friction is only on the narrow runner side-faces.
//
// Magnetic detents (neodymium disc magnets, 5 mm dia × 2 mm thick, N42)
//   Two recessed pockets on the tray top face, centred at ±magnet_x = ±16 mm,
//   at tray-local Y = +detent_y_offset = +35 mm.
//   Magnets sit 0.5 mm below the tray surface (pocket depth = 2.5 mm).
//   Combined with the 1 mm rail standoff and the 0.5 mm recess in the
//   bottom shell, the guaranteed air gap between opposing faces is 2.0 mm —
//   magnets CAN NEVER touch.
//
//   Alignment logic (body frame: phone body centred at origin):
//     Closed (travel = 0 mm): tray magnets at abs Y = 0 + 35 = +35 mm
//                             → aligns with body's CLOSED-snap pockets. ✓
//     Open   (travel = 42 mm): tray magnets at abs Y = −42 + 35 = −7 mm
//                             → aligns with body's OPEN-snap pockets.  ✓
//
// End-stop tabs
//   A pair of small tabs on the runners prevent over-travel in the open
//   direction.  At full travel the tabs press against the phone body's −Y
//   face, providing a clean mechanical stop.  Tab Y-position in tray coords:
//     tray_Y = −tray_l/2 + keyboard_travel = −60 + 42 = −18 mm
//
// CardKB pocket
//   Recessed pocket at the −Y (extension) end of the tray sized for the
//   M5Stack CardKB (59 × 28 × 7 mm).  Retention ledges on the long sides
//   prevent the module from falling out during slide.
//
// ─────────────────────────────────────────────────────────────────────────
// Assembly
//   1. Insert the tray from the −Y end of the phone body: align the two
//      runners with the two channels and slide inward until the rear walls
//      of the channels act as a closed-position stop.
//   2. Press-fit magnets into the pockets (check pole orientation: opposing
//      pairs must attract, not repel).  A drop of CA glue is optional.
//   3. Slide closed — the magnetic snap should be clearly perceptible.
//
// Print orientation : TOP FACE DOWN (runners print upward; no supports needed)
// Print settings    : 0.2 mm layer height, 30 % infill, brim recommended
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module keyboard_tray() {
    tray_l = phone_length;   // Tray Y length matches phone body

    difference() {
        union() {
            // --- Main tray body ---
            rounded_box(phone_width, tray_l, tray_z, corner_radius);

            // --- Rail runners (protrude upward from tray top face at Z = tray_z) ---
            // Centred at X = ±rail_x, running the full tray length in Y.
            for (side = [-1, 1]) {
                translate([side * rail_x - rail_w / 2,
                           -tray_l / 2,
                           tray_z])
                    rail_runner(tray_l);
            }

            // --- Open-position end-stop tabs ---
            // The tab is (rail_channel_w + tab_w_extra) wide so it cannot pass
            // through the channel opening, acting as a hard mechanical stop.
            // The tab's leading (−Y) face contacts the phone body −Y wall when
            // travel = keyboard_travel − tab_stop_margin (40 mm), giving a
            // 2 mm safety margin so the tray decelerates before the hard stop.
            //   tab_w_extra  = 2 mm (1 mm protruding each side of channel)
            //   tab_depth    = 3 mm (adequate bearing / contact surface in Y)
            //   tab_z_ext    = 1.5 mm (taller than runner to ensure engagement)
            //   tab_stop_margin = 2 mm (contact happens 2 mm before max travel)
            tab_w_extra      = 2;
            tab_depth        = 3;
            tab_z_ext        = 1.5;
            tab_stop_margin  = 2;
            for (side = [-1, 1]) {
                translate([side * rail_x - (rail_channel_w + tab_w_extra) / 2,
                           -tray_l / 2 + keyboard_travel - tab_stop_margin - tab_depth,
                           tray_z])
                    cube([rail_channel_w + tab_w_extra, tab_depth, rail_h + tab_z_ext]);
            }
        }

        // --- Interior cavity ---
        translate([0, 0, wall])
            rounded_box(phone_width - 2 * wall,
                        tray_l - 2 * wall,
                        tray_z,
                        max(corner_radius - wall, 0.5));

        // --- CardKB module pocket (at the −Y extension end) ---
        // Positioned so the module is hidden when closed and fully exposed
        // when the tray has been slid out by keyboard_travel (42 mm).
        translate([0,
                   -tray_l / 2 + wall + cardkb_width / 2,
                   wall])
            rounded_box(cardkb_length + 2 * clearance,
                        cardkb_width  + 2 * clearance,
                        cardkb_thickness + 1,
                        2);

        // --- I²C / ribbon-cable relief slot (front/−Y edge of tray) ---
        translate([0,
                   -tray_l / 2 - 0.1,
                   wall + cardkb_thickness / 2])
            rotate([90, 0, 0])
                rounded_box(10, cardkb_thickness + 1, wall + 0.4, 1);

        // --- Magnet pockets on tray top face (openings at Z = tray_z) ---
        // Pockets are centred at ±magnet_x, Y = +detent_y_offset (+35 mm).
        // translate Z = tray_z − magnet_pocket_h puts the pocket opening
        // flush with the tray top face; the +0.1 in magnet_pocket() ensures
        // the boolean cut breaks through the face cleanly.
        for (side = [-1, 1]) {
            translate([side * magnet_x,
                       detent_y_offset,
                       tray_z - magnet_pocket_h])
                magnet_pocket();
        }
    }

    // --- CardKB retention ledges (snap lips to hold module in pocket) ---
    for (side = [-1, 1]) {
        translate([side * (cardkb_length / 2 + clearance + 1),
                   -tray_l / 2 + wall + cardkb_width / 2,
                   wall + cardkb_thickness])
            cube([2, cardkb_width - 2, 1.5], center = true);
    }
}

// --- Render ---
keyboard_tray();
