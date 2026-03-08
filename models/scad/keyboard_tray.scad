// ============================================================================
// Meshtastic Sliding Phone – Keyboard Tray  (sliding component)
// ============================================================================
// The horizontally sliding keyboard carriage.  Sits beneath the main body
// and slides in the −X direction (shortways, along the 74 mm short axis) by
// slider_travel (35 mm) to expose the M5Stack CardKB module.  Holding the
// phone in landscape (120 mm wide × 74 mm tall) the keyboard slides downward,
// exactly like a Nokia N900.
//
// KEY FEATURES
// ─────────────────────────────────────────────────────────────────────────
// Dual captured-lip (T-slot) rails with anti-tilt system
//   Two T-shaped runners protrude from the tray top face (+Z).  Each runner
//   has a narrow stem and a wider lip cap at the top, matching the T-slot
//   channels in the main-body underside.  The dual-rail geometry constrains:
//     • vertical movement  (Z-axis) via the captured lip
//     • horizontal movement (Y-axis) via the stem width
//     • rotational tilt    (about X) via the ±40 mm rail separation
//   Runners run along the X axis; positioned at Y = ±rail_y = ±40 mm.
//   Stem: rail_w × (rail_h − rail_lip_h) = 4.0 × 1.5 mm.
//   Lip:  (rail_w + 2×rail_lip_w) × rail_lip_h = 7.0 × 1.0 mm.
//   The channels are 1 mm deeper (rail_channel_h = 3.5 mm) so the runners
//   float freely in Z — friction is only on the runner side-faces.
//
// Magnetic detents (neodymium disc magnets, 5 mm dia × 2 mm thick, N35)
//   Two press-fit pockets on the tray top face, centred at ±magnet_y = ±20 mm,
//   at tray-local X = +detent_x_offset = +28 mm.
//   Pocket bore = magnet_diameter − magnet_press_fit (4.9 mm) press-fit.
//   A retention lip (magnet_offset mm narrower, 0.5 mm deep) prevents magnets
//   from backing out.  Magnets sit 0.5 mm below the tray surface.
//   Combined with the 1 mm rail standoff and 0.5 mm recess in the main body,
//   guaranteed air gap between opposing faces is 2.0 mm — magnets NEVER touch.
//
//   Alignment (body frame):
//     Closed (travel = 0):    tray magnets at body X = 0 + 28 = +28 mm  → CLOSED pockets ✓
//     Open   (travel = 35 mm): tray magnets at body X = −35 + 28 = −7 mm → OPEN pockets  ✓
//
// Auto-snap ramp
//   The main-body rail channels have a shallow snap ramp near the −X end
//   (last snap_ramp_x = 5 mm of travel).  As the tray approaches the fully-
//   open position, the runner rides over the crest and drops in, assisted by
//   the magnet.  This produces the classic slider-phone "snap open" feel.
//
// End-stop tabs
//   A pair of tabs on the runners prevent over-travel in the open direction.
//   The tabs are (rail_channel_w + tab_w_extra) wide in Y so they contact the
//   body's stop walls at the −X face when travel ≥ slider_travel − tab_stop_margin
//   = 35 − 2 = 33 mm.
//   Tab X-position in tray coords:
//     tray_X = −phone_width/2 + slider_travel − tab_stop_margin
//            = −37 + 35 − 2 = −4 mm
//
// CardKB pocket
//   Recessed pocket at the −X (extension) end sized for the M5Stack CardKB
//   (59 × 28 × 7 mm).  Retention ledges on the long (Y-axis) sides prevent
//   the module from falling out during sliding.
//
// ─────────────────────────────────────────────────────────────────────────
// Assembly
//   1. Insert the tray from the +X end of the main body: align the two
//      T-runners with the T-slot channels and slide inward (−X direction)
//      until the magnetic closed-position snap is felt.  The entry chamfer
//      guides the runner lips into the channels automatically.
//   2. Press-fit magnets into the pockets (check pole orientation: opposing
//      pairs must attract, not repel).  Press firmly until the magnet clicks
//      past the retention lip.
//   3. Slide open — the tray will self-finish into the open position during
//      the last 5 mm of travel via the snap ramp + magnet detent.
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

            // --- Dual anti-tilt rail runners (top face, Z = tray_z) ----------
            // Two T-shaped runners at Y = ±rail_y = ±40 mm, running the full
            // tray width in X.  The ±40 mm separation prevents rotational tilt
            // about the X-axis (anti-tilt system).
            for (side = [-1, 1]) {
                translate([-tray_w / 2,
                           side * rail_y - rail_w / 2,
                           tray_z])
                    rail_runner(tray_w);
            }

            // --- Open-position end-stop tabs ---------------------------------
            // Tabs are (rail_channel_w + tab_w_extra) wide in Y so they cannot
            // pass through the T-slot stem void, acting as a hard stop.
            // tab_lead_x = tray X position where the tab leading (−X) face
            //              contacts the body stop wall at max travel.
            //   tab_lead_x = −phone_width/2 + slider_travel − tab_stop_margin
            tab_lead_x = -tray_w / 2 + slider_travel - tab_stop_margin;
            for (side = [-1, 1]) {
                translate([tab_lead_x,
                           side * rail_y - (rail_channel_w + tab_w_extra) / 2,
                           tray_z])
                    cube([tab_depth,
                          rail_channel_w + tab_w_extra,
                          rail_h + tab_z_extra]);
            }
        }

        // --- Interior cavity -------------------------------------------------
        translate([0, 0, wall_thickness])
            rounded_box(phone_width  - 2 * wall_thickness,
                        phone_length - 2 * wall_thickness,
                        tray_z,
                        max(corner_radius - wall_thickness, 0.5));

        // --- CardKB module pocket (at the −X extension end) ------------------
        // The CardKB long axis (59 mm) runs along Y; short axis (28 mm) along X.
        // Positioned so the module is hidden when closed and fully exposed
        // when the tray has been slid out by slider_travel (35 mm).
        translate([-tray_w / 2 + wall_thickness + cardkb_width / 2,
                   0,
                   wall_thickness])
            rounded_box(cardkb_width  + 2 * clearance,
                        cardkb_length + 2 * clearance,
                        cardkb_thickness + 1,
                        2);

        // --- I²C / ribbon-cable relief slot (−X edge of tray) ---------------
        translate([-tray_w / 2 - 0.1,
                   0,
                   wall_thickness + cardkb_thickness / 2])
            rotate([0, 90, 0])
                rounded_box(cardkb_thickness + 1, 10, wall_thickness + 0.4, 1);

        // --- Magnet pockets on tray top face (openings at Z = tray_z) --------
        // Pockets at ±magnet_y, X = +detent_x_offset (+28 mm).
        // translate Z = tray_z − magnet_pocket_h puts the pocket opening
        // flush with the tray top face.
        for (side = [-1, 1]) {
            translate([detent_x_offset,
                       side * magnet_y,
                       tray_z - magnet_pocket_h])
                magnet_pocket();
        }
    }

    // --- CardKB retention ledges (snap lips to hold module in pocket) --------
    // Ledges on the +Y and −Y sides of the pocket (short ends of the CardKB).
    for (side = [-1, 1]) {
        translate([-tray_w / 2 + wall_thickness + cardkb_width / 2,
                   side * (cardkb_length / 2 + clearance + 1),
                   wall_thickness + cardkb_thickness])
            cube([cardkb_width - 2, 2, 1.5], center = true);
    }
}

// --- Render ---
keyboard_tray();
