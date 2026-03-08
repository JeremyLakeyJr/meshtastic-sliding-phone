// ============================================================================
// Meshtastic Sliding Phone – Top Shell  (unified 2-piece enclosure)
// ============================================================================
// The single printed top enclosure.
//
// STRUCTURE
// ─────────
//   • Full exterior shell (95 × 120 × 19 mm, rounded corners)
//   • Uniform exterior wall thickness (wall_thickness = 2.2 mm)
//   • Solid bottom floor panel (Z = 0 … wall_thickness)
//   • Solid display-face top plate (Z = body_z − wall_thickness … body_z)
//   • Interior cavity (Z = wall_thickness … body_z − wall_thickness)
//   • OLED viewport cutout + countersink through the top-face display plate
//   • PCB mounting platform + 4 standoffs with blind screw holes
//   • Evenly spaced internal support ribs tied to enclosure walls
//   • Slider guide rails that protrude BELOW the bottom face (Z = −rail_height … 0)
//       → rails engage the keyboard-tray grooves (world Z = tray_z − rail_height … tray_z)
//       → rail Y = ±54.8 … ±57.8 mm (3 mm wide, inward from interior side walls)
//       → rail X = phone_width/2 − rail_length … phone_width/2 = −22.5 … +47.5 mm
//   • Battery pocket in interior floor (MakerFocus 3000 mAh LiPo)
//   • Offset magnet pockets on bottom face:
//       Closed-snap body pocket at X = detent_x_offset + magnet_offset = +38 mm
//       Open-snap  body pocket at X = detent_x_offset − slider_travel
//                                     − magnet_offset              = −39 mm
//   • USB-C, SMA, microphone, speaker, power-button, volume-rocker cutouts
//
// SLIDER RAIL FIX (vs. prior versions)
// ──────────────────────────────────────
//   Rails now protrude BELOW the bottom face (Z = −rail_height … 0) instead
//   of sitting inside the cavity (Z = wall_thickness … wall_thickness+rail_height).
//   In world coordinates (top_shell at world Z = tray_z = 8 mm):
//     Rails   : world Z = tray_z − rail_height … tray_z = 5.0 … 8.0 mm
//     Grooves : world Z = tray_z − groove_depth … tray_z = 4.65 … 8.0 mm
//     0.35 mm clearance at groove floor = rail_clearance  ✓
//
// PRINT ORIENTATION
//   Display face DOWN — viewport and countersink print without supports.
//   Minimum wall 2.2 mm.
//
// Print settings: 0.2 mm layer height, 25 % infill, 3 perimeters
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module top_shell() {
    assert(standoff_floor_thickness < standoff_height,
           "Blind standoff floor thickness must be less than standoff height");

    // Reinforcement rib dimensions
    rib_t  = rib_width;                              // 2.0 mm
    rib_h  = body_z - 2 * wall_thickness;            // span between floor and top plate
    rib_iw = phone_width  - 2 * wall_thickness;      // interior width  (X)
    rib_il = phone_length - 2 * wall_thickness;      // interior length (Y)
    standoff_hole_depth = standoff_height - standoff_floor_thickness;

    // Slider rail geometry
    // Interior wall face: Y = ±wall_inner_y = ±57.8 mm.
    // Rail protrudes inward by rail_width = 3 mm → inner edge at ±54.8 mm.
    // Rail runs along X from slider_rail_x_start to +phone_width/2.
    wall_inner_y        = phone_length / 2 - wall_thickness;  // 57.8 mm
    slider_rail_inner_y = wall_inner_y - rail_width;           // 54.8 mm
    slider_rail_x_start = phone_width  / 2 - rail_length;     // −22.5 mm

    // PCB standoff XY positions (Heltec V3/V4 mounting corners)
    standoff_positions = [
        [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - 3],
        [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - 3],
        [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - pcb_length + 3],
        [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - pcb_length + 3]
    ];

    // Battery pocket centre Y (near +Y end, 5 mm clearance from inner wall)
    bat_cy = phone_length/2 - wall_thickness - battery_pocket_y/2 - 5;

    union() {
        // ── Main shell (outer box minus all cavities / cutouts) ───────────────
        difference() {
            // ── Outer shell ──────────────────────────────────────────────────
            rounded_box(phone_width, phone_length, body_z, corner_radius);

            // ── Interior cavity ───────────────────────────────────────────────
            // Height = body_z − 2×wall_thickness preserves BOTH:
            //   • solid bottom floor (Z = 0 … wall_thickness)
            //   • solid display-face top plate (Z = body_z−wall_thickness … body_z)
            translate([0, 0, wall_thickness])
                rounded_box(phone_width  - 2 * wall_thickness,
                            phone_length - 2 * wall_thickness,
                            body_z - 2 * wall_thickness,
                            max(corner_radius - wall_thickness, 0.5));

            // ── Battery pocket (MakerFocus 3000 mAh, 71 × 51 × 9 mm) ─────────
            translate([0, bat_cy, wall_thickness])
                cube([battery_pocket_x, battery_pocket_y, battery_pocket_z + 1],
                     center = true);

            // ── Magnet pockets – CLOSED-position detent ───────────────────────
            // Body pocket at X = detent_x_offset + magnet_offset = +38 mm.
            // The +6 mm offset creates an attractive X-component that pulls the
            // tray into the closed stop position.
            for (side = [-1, 1]) {
                translate([detent_x_offset + magnet_offset,
                           side * magnet_y,
                           -0.1])
                    magnet_pocket();
            }

            // ── Magnet pockets – OPEN-position detent ─────────────────────────
            // Body pocket at X = detent_x_offset − slider_travel − magnet_offset
            //                   = 32 − 65 − 6 = −39 mm.
            for (side = [-1, 1]) {
                translate([detent_x_offset - slider_travel - magnet_offset,
                           side * magnet_y,
                           -0.1])
                    magnet_pocket();
            }

            // ── OLED viewport cutout (top face, Z = body_z) ───────────────────
            translate([0,
                       phone_length/2 - display_offset_y - display_h/2,
                       body_z - wall_thickness - 0.1])
                rounded_box(display_w, display_h, wall_thickness + 0.2, 1);

            // ── Viewport countersink ──────────────────────────────────────────
            translate([0,
                       phone_length/2 - display_offset_y - display_h/2,
                       body_z - wall_thickness - display_depth])
                rounded_box(display_w + 2, display_h + 2, display_depth + 0.2, 1.5);

            // ── Speaker grille (top face, near +Y edge) ───────────────────────
            translate([0, phone_length/2 - 8, body_z - wall_thickness - 0.1])
                linear_extrude(height = wall_thickness + 0.2)
                    grille_pattern(6, 2, 3, 1.5, 1.2, 0.5);

            // ── Front sensor / camera pinhole ─────────────────────────────────
            translate([display_w/2 + 6,
                       phone_length/2 - display_offset_y - 5,
                       body_z - wall_thickness - 0.1])
                cylinder(h = wall_thickness + 0.2, d = 2.5);

            // ── Notification LED slot ─────────────────────────────────────────
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

            // ── SMA antenna connector (+Y / top edge) ─────────────────────────
            translate([phone_width/2 - 12,
                       phone_length/2 - 0.1,
                       bot_shell_z/2 + 2])
                rotate([90, 0, 0])
                    cylinder(h = wall_thickness + 0.4, d = sma_diameter);

            // ── Microphone hole (−Y / bottom edge) ────────────────────────────
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
        }

        // ── PCB mounting platform ─────────────────────────────────────────────
        // Solid slab on the case floor reinforcing the Heltec board area.
        // Standoffs protrude through and above it.
        translate([-pcb_width/2 - 2,
                   phone_length/2 - display_offset_y - pcb_length - 2,
                   wall_thickness])
            cube([pcb_width + 4, pcb_length + 4, platform_thickness]);

        // ── PCB mounting standoffs (Heltec V3/V4, 4 blind posts) ─────────────
        for (pos = standoff_positions) {
            translate([pos[0], pos[1], wall_thickness])
                difference() {
                    cylinder(h = standoff_height, d = standoff_diameter);
                    if (standoff_hole_depth > 0)
                        translate([0, 0, standoff_floor_thickness])
                            cylinder(h = standoff_hole_depth + geom_epsilon,
                                     d = screw_hole_d);
                }
        }

        // ── Internal reinforcement ribs ───────────────────────────────────────
        // Lateral ribs at 1/3 and 2/3 of interior Y span.
        for (frac = [1/3, 2/3]) {
            translate([-rib_iw/2,
                       -phone_length/2 + wall_thickness
                           + frac * rib_il - rib_t/2,
                       wall_thickness])
                cube([rib_iw, rib_t, rib_h]);
        }

        // ── Slider guide rails (protrude BELOW the bottom face) ───────────────
        // Rails at Z = −rail_height … 0 hang below the exterior bottom face.
        // In world coords (top_shell at world Z = tray_z = 8 mm):
        //   Rail world Z = tray_z − rail_height … tray_z = 5.0 … 8.0 mm
        //   Tray groove world Z = 4.65 … 8.0 mm  → rail captured, 0.35 mm clearance ✓
        //
        // Y = ±slider_rail_inner_y … ±wall_inner_y = ±54.8 … ±57.8 mm (3 mm inward)
        // X = slider_rail_x_start … +phone_width/2 = −22.5 … +47.5 mm (70 mm)
        for (flip = [false, true]) {
            mirror([0, flip ? 1 : 0, 0])
                translate([slider_rail_x_start,
                           slider_rail_inner_y,
                           -rail_height])
                    cube([rail_length, rail_width, rail_height]);
        }
    }
}

// --- Render ---
top_shell();
