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
// Dual captured-lip (T-slot) rails with anti-tilt system
//   Two T-shaped runners protrude from the tray top face (+Z).  Runners run
//   along the X axis at Y = ±rail_y = ±40 mm.
//     Stem: rail_w × (rail_h − rail_lip_h) = 3.0 × 1.0 mm
//     Lip:  (rail_w + 2×rail_lip_w) × rail_lip_h = 6.0 × 1.0 mm
//   The 2.5 mm T-slot standoff (rail_channel_h − rail_h) allows the tray to
//   adopt a slight (~3°) passive typing angle when fully extended.
//
// Magnetic detents (neodymium disc magnets, 10 mm dia × 4 mm thick, N35)
//   Two press-fit pockets on the tray top face at ±magnet_y = ±20 mm,
//   X = +detent_x_offset = +32 mm (tray local).
//   Bore = magnet_diameter = 10.3 mm (0.15 mm/side clearance).
//   Retention lip: 9.3 mm entrance (magnet snaps past lip on insertion).
//   Alignment (body frame):
//     Closed (travel = 0):    tray magnets at body X = +32 mm → CLOSED pockets ✓
//     Open   (travel = 65 mm): tray magnets at body X = 32−65 = −33 mm → OPEN ✓
//
// Stop cutouts at runner -X tip
//   A 2.5 mm (stop_cutout) deep × 2 mm (stop_block_height) tall notch at
//   the -X end of each runner allows the runner tip to pass the body's stop
//   blocks (at body X ≈ −15.5 mm) during initial assembly.  After assembly
//   the solid runner body contacts the stop blocks at full travel, preventing
//   accidental removal.
//
// CardKB pocket (M5Stack CardKB v1.1, 88 × 54 × 7 mm)
//   Recessed pocket at the −X (extension) end sized for the CardKB:
//   88 mm long axis along Y, 54 mm short axis along X (slide direction).
//   Pocket: (cardkb_w + 2×keyboard_clearance) × (cardkb_h + 2×keyboard_clearance)
//           = 89 × 55 mm in X–Y, depth = keyboard_pocket_depth = 8 mm.
//   Internal Z clearance = keyboard_height_clearance = 10 mm so the keyboard
//   never collides with the shell when the slider is closed.
//   Retention ledges on the ±Y sides snap the CardKB into the pocket.
//
// Auto-snap ramp
//   The top-shell rail channels have a shallow snap ramp near the −X end
//   (last snap_ramp_x = 5 mm of travel) for the classic "snap open" feel.
//
// ─────────────────────────────────────────────────────────────────────────
// Assembly
//   1. Insert from the +X end: align the two T-runners with the T-slot
//      channels and slide −X until the closed-position magnetic snap is felt.
//      The entry chamfer guides the runner lips in automatically.
//   2. Press-fit magnets (check pole orientation — opposing pairs attract).
//   3. Clip CardKB module into the tray pocket.
//
// Print orientation : TOP FACE DOWN (runners print upward; no supports needed)
// Print settings    : 0.2 mm layer height, 30 % infill, brim recommended
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module keyboard_tray() {
    tray_w = phone_width;   // Tray X span matches top-shell body width (95 mm)

    // Stop block position in body frame: stop_bx = −15.5 mm (same as top_shell).
    // In TRAY-LOCAL frame at CLOSED position (travel = 0), the stop block
    // sits at the same X coordinate.  The stop_cutout notch is placed at the
    // runner −X TIP (tray-local X = −tray_w/2 = −47.5 mm).
    // Cutout width in X = stop_cutout = 2.5 mm (> stop_block_depth = 2 mm).

    // CardKB pocket dimensions (with clearance)
    pocket_x = cardkb_h + 2 * keyboard_clearance;   // 55 mm in X (slide direction)
    pocket_y = cardkb_w + 2 * keyboard_clearance;   // 89 mm in Y (long axis)

    difference() {
        union() {
            // --- Main tray body ---
            rounded_box(phone_width, phone_length, tray_z, corner_radius);

            // --- Dual captured-lip T-rail runners (top face, Z = tray_z) ------
            // T-shaped runners at Y = ±rail_y = ±40 mm, spanning the full
            // tray width in X.  The ±40 mm separation prevents rotational tilt
            // about the X axis.
            for (side = [-1, 1]) {
                translate([-tray_w / 2,
                           side * rail_y - rail_w / 2,
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
        // Notch at the leading (−X) end of each runner: stop_cutout deep × rail_w
        // wide × (stop_block_height + cutout_z_clearance) tall.
        // cutout_z_clearance: extra 0.5 mm so the cutout clears the stop block top
        // with a small vertical gap, ensuring smooth assembly and no rattle.
        cutout_z_clearance = 0.5;
        for (side = [-1, 1]) {
            translate([-tray_w / 2,
                       side * rail_y - rail_w / 2,
                       tray_z])
                cube([stop_cutout, rail_w, stop_block_height + cutout_z_clearance]);
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
