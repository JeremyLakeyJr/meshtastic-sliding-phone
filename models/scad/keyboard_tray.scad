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
// Dual captured dovetail rails with anti-tilt system
//   Two trapezoidal runners protrude from the tray top face (+Z).
//   Runners run along the X axis at Y = ±rail_y = ±40 mm.
//     Base (tray face):  rail_top_width  = 1.2 mm  (narrow, attachment end)
//     Cap  (free end):   rail_base_width = 4.0 mm  (wide, captured in groove)
//     Height:            rail_height     = 3.0 mm
//   The ±40 mm rail spacing (rail_spacing = 80 mm) prevents rotational tilt.
//   Passive typing angle ≈ atan(channel_standoff/30) ≈ 3° at full extension.
//
// Wire routing groove alongside +Y rail
//   6 mm wide × 2 mm deep channel outside the +Y rail for the CardKB flex
//   cable; a matching groove in the top shell prevents cable pinching.
//
// Magnetic detents (neodymium disc magnets, 10 mm dia × 4 mm thick, N35)
//   Two press-fit pockets on the tray top face at ±magnet_y = ±20 mm,
//   X = +detent_x_offset = +32 mm (tray local).
//   Bore = 10.3 mm, retention lip = 0.5 mm (entrance 9.3 mm).
//   Closed (travel = 0):    tray magnets at body X = +32 mm → CLOSED pockets ✓
//   Open   (travel = 65 mm): tray magnets at body X = 32−65 = −33 mm → OPEN ✓
//
// Stop cutouts at runner −X tip
//   A 2.5 mm (stop_cutout) deep notch at the −X end of each runner allows the
//   runner tip to clear the body's stop blocks during initial assembly.
//   Cutout: stop_cutout × groove_opening_w (1.9 mm) × (stop_block_height + 0.5 mm)
//
// CardKB pocket (M5Stack CardKB v1.1, 88 × 54 × 7 mm)
//   Recessed pocket at the −X (extension) end:
//   Pocket: 89 × 55 mm (X × Y, with 0.5 mm per-side clearance)
//   Depth: keyboard_pocket_depth = 8 mm  ✓  (> cardkb_thickness 7 mm)
//   Retention ledges on ±Y sides hold the CardKB in the pocket.
//
// ─────────────────────────────────────────────────────────────────────────
// Assembly
//   1. Insert from the +X end: align the two dovetail runners with the
//      top-shell grooves and slide −X until the closed-position snap is felt.
//      The entry chamfer (1 mm) guides the runner caps into the grooves.
//   2. Press-fit magnets (check pole orientation — opposing pairs attract).
//   3. Clip CardKB module into the tray pocket.
//
// Print orientation : TOP FACE DOWN (runners print upward from tray face;
//                     no supports needed — dovetail walls at ~65° from horizontal)
// Print settings    : 0.2 mm layer height, 30 % infill, brim recommended
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module keyboard_tray() {
    tray_w = phone_width;   // Tray X span matches top-shell body width (95 mm)

    // CardKB pocket dimensions (with clearance)
    pocket_x = cardkb_h + 2 * keyboard_clearance;   // 55 mm in X (slide direction)
    pocket_y = cardkb_w + 2 * keyboard_clearance;   // 89 mm in Y (long axis)

    // Groove opening width (for stop cutout sizing to match stop block)
    groove_opening_w = rail_top_width + 2 * rail_clearance;  // 1.9 mm

    difference() {
        union() {
            // --- Main tray body ---
            rounded_box(phone_width, phone_length, tray_z, corner_radius);

            // --- Dual dovetail runners (top face, Z = tray_z) ----------------
            // Trapezoidal runners at Y = ±rail_y = ±40 mm, spanning the full
            // tray width in X.  The ±40 mm separation prevents rotational tilt
            // about the X axis.  Runner is centred on each rail_y position.
            for (side = [-1, 1]) {
                translate([-tray_w / 2,
                           side * rail_y,
                           tray_z])
                    rail_runner(tray_w);
            }
        }

        // --- Interior cavity --------------------------------------------------
        // Tray is open-bottom (Z = wall_thickness upward), with
        // keyboard_height_clearance (10 mm min) internal vertical space.
        translate([0, 0, wall_thickness])
            rounded_box(phone_width  - 2 * wall_thickness,
                        phone_length - 2 * wall_thickness,
                        tray_z,
                        max(corner_radius - wall_thickness, 0.5));

        // --- CardKB module pocket (at the −X extension end) ------------------
        // CardKB: 88 mm (Y) × 54 mm (X) × 7 mm (Z).
        // Pocket centred at X = −tray_w/2 + wall + pocket_x/2,
        // Y = 0 (phone centreline), Z = wall_thickness (floor of pocket).
        // Depth = keyboard_pocket_depth = 8 mm > cardkb_thickness = 7 mm ✓
        translate([-tray_w / 2 + wall_thickness + pocket_x / 2,
                   0,
                   wall_thickness])
            rounded_box(pocket_x, pocket_y, keyboard_pocket_depth, 2);

        // --- I²C / ribbon-cable relief slot (−X edge of tray) ---------------
        // Allows the CardKB cable to exit through the tray's −X end face.
        translate([-tray_w / 2 - 0.1,
                   0,
                   wall_thickness + cardkb_thickness / 2])
            rotate([0, 90, 0])
                rounded_box(cardkb_thickness + 1, 10, wall_thickness + 0.4, 1);

        // --- Wire routing groove alongside +Y rail ---------------------------
        // Matches the groove in the top shell; 6 mm wide × 2 mm deep.
        // Provides a protected channel for the keyboard flex cable.
        translate([-tray_w / 2,
                   rail_y + rail_base_width / 2 + rail_clearance + 0.5,
                   tray_z - wire_tunnel_height])
            cube([tray_w, wire_tunnel_width, wire_tunnel_height + 0.1]);

        // --- Magnet pockets on tray top face (openings at Z = tray_z) --------
        // Pockets at ±magnet_y, X = +detent_x_offset (+32 mm tray-local).
        // Opening is flush with the tray top face; Z offset = tray_z − magnet_depth.
        for (side = [-1, 1]) {
            translate([detent_x_offset,
                       side * magnet_y,
                       tray_z - magnet_depth])
                magnet_pocket();
        }

        // --- Stop cutouts at runner −X tips ----------------------------------
        // Notch at the leading (−X) end of each runner, spanning the groove
        // opening width (1.9 mm) so the runner tip clears the stop block
        // (also 1.9 mm wide) during initial assembly from the +X entry end.
        // Cutout dimensions: stop_cutout (X) × groove_opening_w (Y) × (stop_block_height + 0.5) (Z)
        cutout_z_clearance = 0.5;
        for (side = [-1, 1]) {
            translate([-tray_w / 2,
                       side * rail_y - groove_opening_w / 2,
                       tray_z])
                cube([stop_cutout, groove_opening_w,
                      stop_block_height + cutout_z_clearance]);
        }
    }

    // --- CardKB retention ledges (snap lips to hold module in pocket) --------
    // Ledges on the ±Y sides of the pocket prevent the CardKB from falling out.
    for (side = [-1, 1]) {
        translate([-tray_w / 2 + wall_thickness + pocket_x / 2,
                   side * (pocket_y / 2 + 1),
                   wall_thickness + cardkb_thickness])
            cube([pocket_x - 2, 2, 1.5], center = true);
    }
}

// --- Render ---
keyboard_tray();
