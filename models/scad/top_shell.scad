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
//   • Three structured internal zones separated by reinforcement ribs:
//       1. Heltec board mounting area (PCB platform + 4 standoffs)
//       2. Battery pocket (71 × 51 × 9 mm, MakerFocus 3000 mAh)
//       3. Slider clearance cavity (keyboard tray path, ≥ 14 mm stack)
//   • Two dovetail rail GROOVES on the bottom face for the keyboard tray
//     – Groove length: rail_length = 70 mm (< tray width, reduces flex)
//     – Groove: narrow opening (1.9 mm), tapered to 4.7 mm at rail_height,
//       then channel_standoff straight zone → passive ~3° typing angle
//   • Stop blocks inside the rail grooves prevent accidental tray removal
//   • Offset magnet detents (magnet_offset = 6 mm) — body pockets are
//     displaced ±6 mm from the tray pockets in the sliding direction so the
//     magnetic force GUIDES the tray into closed/open position rather than
//     opposing mid-travel motion
//       Closed: body-X = detent_x_offset + magnet_offset = +38 mm
//       Open  : body-X = detent_x_offset − slider_travel − magnet_offset = −39 mm
//     (10 mm × 4 mm neodymium disc magnets, 10.3 mm bore × 3.6 mm deep,
//      0.6 mm retention lip — prevents magnets ejecting on impact)
//   • PCB mounting platform (platform_thickness = 2 mm) reinforces floor
//   • PCB mounting standoffs (Heltec V3/V4, 4 posts, M2 screws)
//   • Internal reinforcement ribs (rib_width=2 mm, rib_height=6 mm)
//     between PCB area, battery pocket, and slider cavity
//   • Battery retention clips (battery_clip_height=1.5 mm) at pocket edges
//   • Lightening pockets (pocket_depth=1.5 mm) on body bottom face between
//     rails reduce material without affecting structural integrity
//   • Wire routing channel (2 × 6 mm) from battery to Heltec JST connector
//   • Wire routing groove alongside +Y rail for keyboard flex cable
//   • USB-C, SMA antenna, microphone, and speaker holes on edges
//
// VERTICAL CLEARANCE STACK (minimum 14 mm total)
// ───────────────────────────────────────────────
//   keyboard_thickness = 7 mm
//   tray_floor         = wall_thickness ≈ 2.2 mm  (≥ 2 mm spec ✓)
//   rail_height        = 3 mm
//   case_floor         = wall_thickness ≈ 2.2 mm  (≥ 2 mm spec ✓)
//   Total ≈ 14.4 mm ≥ 14 mm spec ✓
//
// STOP BLOCK ASSEMBLY
// ───────────────────
//   Stop blocks (2 mm tall, 2 mm deep) sit at the groove entrance face (Z = 0)
//   at body X ≈ −15.5 mm.  The runner −X tip has a stop_cutout notch (2.5 mm)
//   that allows the runner tip to clear the stop block during initial assembly.
//   After assembly the solid runner body prevents over-travel on opening.
//
// PASSIVE TYPING ANGLE
// ─────────────────────
//   channel_standoff = 2 mm of extra groove depth beyond rail_height = 3 mm.
//   At full extension (5 mm rail engagement, 65 mm keyboard arm):
//     passive tilt ≈ atan(2/5) ≈ 21.8° (gravity-loaded) — user ergonomic.
//
// PRINT ORIENTATION
//   Display face DOWN — viewport and button recesses print without supports.
//   Dovetail grooves face UP during print; groove walls at ~65° from horizontal
//   are well within FDM limits (< 45° overhang from horizontal).
//   Minimum wall 2.2 mm; entry chamfer guides tray insertion.
//
// Print settings: 0.2 mm layer height, 25 % infill, 3 perimeters
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module top_shell() {
    // Reinforcement rib dimensions (from parameters)
    rib_t  = rib_width;                             // 2.0 mm
    rib_h  = body_z - wall_thickness;               // floor-to-ceiling span inside cavity
    rib_iw = phone_width  - 2 * wall_thickness;     // interior width  (X)
    rib_il = phone_length - 2 * wall_thickness;     // interior length (Y)

    // Stop block +X-face position in body frame:
    //   stop_block_pos_x = -(slider_travel - tab_stop_margin - phone_width/2) = -15.5 mm
    stop_block_pos_x = -(slider_travel - tab_stop_margin - phone_width / 2);

    // Groove opening width (for stop block sizing)
    groove_opening_w = rail_top_width + 2 * rail_clearance;  // 1.9 mm

    // Battery pocket centre Y position
    bat_cy = phone_length/2 - wall_thickness - battery_pocket_y/2 - 5;

    // PCB platform and standoff XY positions (Heltec V3/V4 mounting corners)
    standoff_positions = [
        [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - 3],
        [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - 3],
        [ pcb_width/2 - 2,  phone_length/2 - display_offset_y - pcb_length + 3],
        [-pcb_width/2 + 2,  phone_length/2 - display_offset_y - pcb_length + 3]
    ];

    union() {
        // ── Main shell (outer box minus all cavities / cutouts) ───────────────
        difference() {
            // ── Outer shell ─────────────────────────────────────────────────
            rounded_box(phone_width, phone_length, body_z, corner_radius);

            // ── Interior cavity ──────────────────────────────────────────────
            translate([0, 0, wall_thickness])
                rounded_box(phone_width  - 2 * wall_thickness,
                            phone_length - 2 * wall_thickness,
                            body_z,
                            max(corner_radius - wall_thickness, 0.5));

            // ── Battery pocket (MakerFocus 3000 mAh, 71 × 51 × 9 mm) ───────
            // Centred in X; positioned at +Y end clear of the antenna keepout.
            // Wire routing channel (2 × 6 mm) runs toward the PCB JST connector.
            translate([0, bat_cy, wall_thickness])
                cube([battery_pocket_x, battery_pocket_y, battery_pocket_z],
                     center = true);

            // Wire channel from battery pocket to PCB JST connector
            translate([pcb_width/2,
                       phone_length/2 - wall_thickness
                           - battery_pocket_y - 5 - wire_channel_h/2,
                       wall_thickness])
                cube([wire_channel_w, wire_channel_h, body_z], center = true);

            // ── Dovetail rail grooves (bottom face, Z = 0 upward) ───────────
            // Two grooves of length rail_length = 70 mm, starting from the
            // +X insertion end.  Entry chamfer at +X end.
            for (side = [-1, 1]) {
                translate([phone_width/2 - rail_length - 1,
                           side * rail_y,
                           0])
                    rail_channel_void(rail_length);
            }

            // ── Wire routing groove alongside +Y rail ────────────────────────
            // 6 mm wide × 2 mm deep groove outside the +Y rail for keyboard
            // flex cable routing; prevents cable pinching during slider motion.
            translate([-phone_width/2,
                       rail_y + rail_base_width/2 + rail_clearance + 0.5,
                       -0.1])
                cube([phone_width,
                      wire_tunnel_width,
                      wire_tunnel_height + 0.1]);

            // ── Magnet pockets – CLOSED-position detent (body bottom, Z = 0) ─
            // Body pockets offset +magnet_offset from tray pocket position.
            // At closed (travel=0): tray magnet at body-X=+32, body pocket at
            // detent_x_offset+magnet_offset=+38 → attraction pulls tray closed.
            for (side = [-1, 1]) {
                translate([detent_x_offset + magnet_offset,
                           side * magnet_y,
                           -0.1])
                    magnet_pocket();
            }

            // ── Magnet pockets – OPEN-position detent (body bottom, Z = 0) ───
            // Body pockets offset -magnet_offset from tray open position.
            // At open (travel=65): tray magnet at body-X=-33, body pocket at
            // detent_x_offset-slider_travel-magnet_offset=-39 → attraction
            // pulls tray open.
            for (side = [-1, 1]) {
                translate([detent_x_offset - slider_travel - magnet_offset,
                           side * magnet_y,
                           -0.1])
                    magnet_pocket();
            }

            // ── Lightening pockets (body bottom face, between rails) ─────────
            // Four shallow pockets (pocket_depth=1.5 mm) in the slider-path
            // zone between the rail grooves.  Placed away from magnet pockets,
            // stop blocks, and wire groove to maintain structural integrity.
            for (px = [10, -25]) {
                for (py = [10, -10]) {
                    translate([px, py, -0.1])
                        cube([14, 12, pocket_depth + 0.1], center = true);
                }
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
            // Opening: 11 mm wide × 4 mm tall (per spec)
            translate([0,
                       -phone_length/2 - 0.1,
                       bot_shell_z/2 + 1])
                rotate([90, 0, 0])
                    rounded_box(usbc_width, usbc_height, wall_thickness + 0.4, 1);

            // ── SMA antenna connector hole (+Y / top edge) ────────────────────
            // Antenna keepout_radius = 12 mm reserved around this connector.
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

            // ── PCB screw holes (M2 pass-through in floor) ───────────────────
            for (pos = standoff_positions) {
                translate([pos[0], pos[1], 0])
                    cylinder(h = wall_thickness + 0.2, d = screw_hole_d);
            }
        }

        // ── PCB mounting platform ─────────────────────────────────────────────
        // Solid slab on top of the case floor in the Heltec board area.
        // Reinforces the mounting zone; standoffs protrude through and above it.
        translate([-pcb_width/2 - 2,
                   phone_length/2 - display_offset_y - pcb_length - 2,
                   wall_thickness])
            cube([pcb_width + 4, pcb_length + 4, platform_thickness]);

        // ── PCB mounting standoffs (Heltec V3/V4, 4 posts) ───────────────────
        // Added AFTER the main difference() so they are not removed by the
        // interior cavity subtraction.  Posts start at the case floor
        // (wall_thickness) and protrude standoff_height = 4 mm into the cavity.
        for (pos = standoff_positions) {
            translate([pos[0], pos[1], wall_thickness])
                screw_post(standoff_height, standoff_diameter, screw_hole_d);
        }

        // ── Internal reinforcement ribs ───────────────────────────────────────
        // Added AFTER the main difference() so they are not removed by the
        // interior cavity subtraction.
        // Longitudinal rib (along Y, centred in X) — full interior Y span
        translate([-rib_t/2,
                   -(phone_length/2 - wall_thickness),
                   wall_thickness])
            cube([rib_t, rib_il, rib_h]);

        // Lateral ribs at 1/3 and 2/3 of interior Y span
        // Separates: PCB mounting area / battery pocket / slider clearance cavity
        for (frac = [1/3, 2/3]) {
            translate([-rib_iw/2,
                       -phone_length/2 + wall_thickness
                           + frac * rib_il - rib_t/2,
                       wall_thickness])
                cube([rib_iw, rib_t, rib_h]);
        }

        // ── Battery retention clips ────────────────────────────────────────────
        // Thin ledges at the ±Y edges of the battery pocket that snap over
        // the battery face, preventing ejection on impact.
        for (side = [-1, 1]) {
            translate([0,
                       bat_cy + side * battery_pocket_y/2,
                       wall_thickness + battery_pocket_z - battery_clip_height])
                cube([battery_pocket_x - 4, 2, battery_clip_height * 2],
                     center = true);
        }

        // ── Stop blocks inside rail grooves ──────────────────────────────────
        // Added AFTER the main difference() so they protrude into the groove void.
        // Dimensions: stop_block_depth (X) × groove_opening_w (Y) × stop_block_height (Z).
        // Positioned at body X = stop_block_pos_x − stop_block_depth to stop_block_pos_x.
        // The runner −X tip stop_cutout (2.5 mm) clears these blocks during assembly;
        // after assembly, the solid runner body hits them at full travel.
        for (side = [-1, 1]) {
            translate([stop_block_pos_x - stop_block_depth,
                       side * rail_y - groove_opening_w / 2,
                       0])
                cube([stop_block_depth, groove_opening_w, stop_block_height]);
        }
    }
}

// --- Render ---
top_shell();
