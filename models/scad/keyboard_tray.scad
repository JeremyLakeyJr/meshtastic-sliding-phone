// ============================================================================
// Meshtastic Sliding Phone – Keyboard Tray  (sliding component)
// ============================================================================
// The horizontally sliding keyboard carriage.  Sits beneath the phone body
// and slides in the −X direction (shortways, along the 74 mm short axis) by
// keyboard_travel (42 mm) to expose the M5Stack CardKB module.  Holding the
// phone in landscape (120 mm wide × 74 mm tall) the keyboard slides downward,
// exactly like a Nokia N900.
//
// KEY FEATURES
// ─────────────────────────────────────────────────────────────────────────
// Parallel top/bottom rails
//   Two rectangular runners protrude from the tray top face (+Z).  They
//   slide inside matching channels cut into the bottom-shell underside,
//   keeping the motion straight and preventing front/back (Y-axis) wobble.
//   Runners run along the X axis; positioned at Y = ±rail_y = ±40 mm.
//   Runner dimensions: rail_w × rail_h = 4.0 × 2.5 mm.
//   The channels are 1 mm deeper (rail_channel_h = 3.5 mm) so the runners
//   float freely in Z — friction is only on the narrow runner side-faces.
//
// Magnetic detents (neodymium disc magnets, 5 mm dia × 2 mm thick, N42)
//   Two recessed pockets on the tray top face, centred at ±magnet_y = ±20 mm,
//   at tray-local X = +detent_x_offset = +28 mm.
//   Magnets sit 0.5 mm below the tray surface (pocket depth = 2.5 mm).
//   Combined with the 1 mm rail standoff and the 0.5 mm recess in the
//   bottom shell, the guaranteed air gap between opposing faces is 2.0 mm —
//   magnets CAN NEVER touch.
//
//   Alignment logic (body frame: phone body centred at origin):
//     Closed (travel = 0 mm): tray magnets at abs X = 0 + 28 = +28 mm
//                             → aligns with body's CLOSED-snap pockets. ✓
//     Open   (travel = 42 mm): tray magnets at abs X = −42 + 28 = −14 mm
//                             → aligns with body's OPEN-snap pockets.  ✓
//
// End-stop tabs
//   A pair of small tabs on the runners prevent over-travel in the open
//   direction.  At full travel the tabs press against the phone body's −X
//   face, providing a clean mechanical stop.  Tab X-position in tray coords:
//     tray_X = −phone_width/2 + keyboard_travel − tab_stop_margin
//            = −37 + 42 − 2 = +3 mm
//
// CardKB pocket
//   Recessed pocket at the −X (extension) end of the tray sized for the
//   M5Stack CardKB (59 × 28 × 7 mm).  The long axis (59 mm) runs along Y;
//   the short axis (28 mm) runs along X (the slide direction).
//   Retention ledges on the long (Y-axis) sides prevent the module from
//   falling out during slide.
//
// ─────────────────────────────────────────────────────────────────────────
// Assembly
//   1. Insert the tray from the −X end of the phone body: align the two
//      runners with the two channels and slide inward until the magnetic
//      detent snaps closed.
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
    tray_w = phone_width;   // Tray X span matches phone body width (74 mm)

    difference() {
        union() {
            // --- Main tray body ---
            rounded_box(phone_width, phone_length, tray_z, corner_radius);

            // --- Rail runners (protrude upward from tray top face at Z = tray_z) ---
            // Positioned at Y = ±rail_y, running the full tray width in X.
            for (side = [-1, 1]) {
                translate([-tray_w / 2,
                           side * rail_y - rail_w / 2,
                           tray_z])
                    rail_runner(tray_w);
            }

            // --- Open-position end-stop tabs ---
            // The tab is (rail_channel_w + tab_w_extra) wide in Y so it cannot
            // pass through the channel opening, acting as a hard mechanical stop.
            // The tab's leading (−X) face contacts the phone body −X wall when
            // travel = keyboard_travel − tab_stop_margin (40 mm), giving a
            // 2 mm safety margin so the tray decelerates before the hard stop.
            //   tab_w_extra  = 2 mm (1 mm protruding each Y side of channel)
            //   tab_depth    = 3 mm (adequate bearing / contact surface in X)
            //   tab_z_ext    = 1.5 mm (taller than runner to ensure engagement)
            //   tab_stop_margin = 2 mm (contact happens 2 mm before max travel)
            tab_w_extra      = 2;
            tab_depth        = 3;
            tab_z_ext        = 1.5;
            tab_stop_margin  = 2;
            tab_lead_x = -tray_w / 2 + keyboard_travel - tab_stop_margin;
            for (side = [-1, 1]) {
                translate([tab_lead_x,
                           side * rail_y - (rail_channel_w + tab_w_extra) / 2,
                           tray_z])
                    cube([tab_depth, rail_channel_w + tab_w_extra, rail_h + tab_z_ext]);
            }
        }

        // --- Interior cavity ---
        translate([0, 0, wall])
            rounded_box(phone_width - 2 * wall,
                        phone_length - 2 * wall,
                        tray_z,
                        max(corner_radius - wall, 0.5));

        // --- CardKB module pocket (at the −X extension end) ---
        // The CardKB long axis (59 mm) runs along Y; short axis (28 mm) along X.
        // Positioned so the module is hidden when closed and fully exposed
        // when the tray has been slid out by keyboard_travel (42 mm).
        translate([-tray_w / 2 + wall + cardkb_width / 2,
                   0,
                   wall])
            rounded_box(cardkb_width  + 2 * clearance,
                        cardkb_length + 2 * clearance,
                        cardkb_thickness + 1,
                        2);

        // --- I²C / ribbon-cable relief slot (front/−X edge of tray) ---
        translate([-tray_w / 2 - 0.1,
                   0,
                   wall + cardkb_thickness / 2])
            rotate([0, 90, 0])
                rounded_box(cardkb_thickness + 1, 10, wall + 0.4, 1);

        // --- Magnet pockets on tray top face (openings at Z = tray_z) ---
        // Pockets are centred at ±magnet_y, X = +detent_x_offset (+28 mm).
        // translate Z = tray_z − magnet_pocket_h puts the pocket opening
        // flush with the tray top face; the +0.1 in magnet_pocket() ensures
        // the boolean cut breaks through the face cleanly.
        for (side = [-1, 1]) {
            translate([detent_x_offset,
                       side * magnet_y,
                       tray_z - magnet_pocket_h])
                magnet_pocket();
        }
    }

    // --- CardKB retention ledges (snap lips to hold module in pocket) ---
    // Ledges on the +Y and −Y sides of the pocket (short ends of the CardKB).
    for (side = [-1, 1]) {
        translate([-tray_w / 2 + wall + cardkb_width / 2,
                   side * (cardkb_length / 2 + clearance + 1),
                   wall + cardkb_thickness])
            cube([cardkb_width - 2, 2, 1.5], center = true);
    }
}

// --- Render ---
keyboard_tray();
