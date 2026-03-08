// ============================================================================
// Meshtastic Sliding Phone – Top Shell  (unified 2-piece enclosure)
// ============================================================================
// The single printed top enclosure (replaces the former 3-piece
// top_shell + bottom_shell + battery_cover stack).
//
// STRUCTURE
// ─────────
//   • Full exterior shell (95 × 120 × 19 mm, rounded corners)
//   • Fully enclosed rectangular shell (95 × 120 × 19 mm) with rounded corners
//   • Uniform exterior wall thickness (wall_thickness = 2.2 mm)
//   • Solid bottom panel (no cut-throughs)
//   • Internal cavity with rounded interior corners for print reliability
//   • PCB mounting platform + 4 standoffs with blind screw holes
//   • Evenly spaced internal support ribs tied to enclosure walls
//   • Wall-attached component side rails for module support
//
// VERTICAL CLEARANCE STACK (minimum 14 mm total)
// ───────────────────────────────────────────────
//   keyboard_thickness = 7 mm
//   tray_floor         = wall_thickness ≈ 2.2 mm  (≥ 2 mm spec ✓)
//   rail_height        = 3 mm
//   case_floor         = wall_thickness ≈ 2.2 mm  (≥ 2 mm spec ✓)
//   Total ≈ 14.4 mm ≥ 14 mm spec ✓
//
// PRINT ORIENTATION
//   Base DOWN for watertight first layers and strong blind standoffs.
//   Minimum wall 2.2 mm.
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
    standoff_hole_depth = max(standoff_height - standoff_floor_thickness, standoff_floor_thickness);
    side_rail_w = wall_thickness;
    side_rail_l = side_rail_length;
    side_rail_h = side_rail_height;

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
        }

        // ── PCB mounting platform ─────────────────────────────────────────────
        // Solid slab on top of the case floor in the Heltec board area.
        // Reinforces the mounting zone; standoffs protrude through and above it.
        translate([-pcb_width/2 - 2,
                   phone_length/2 - display_offset_y - pcb_length - 2,
                   wall_thickness])
            cube([pcb_width + 4, pcb_length + 4, platform_thickness]);

        // ── PCB mounting standoffs (Heltec V3/V4, 4 posts) ───────────────────
        // Blind holes leave a solid standoff floor and never cut through the
        // enclosure's exterior bottom panel.
        for (pos = standoff_positions) {
            translate([pos[0], pos[1], wall_thickness])
                difference() {
                    cylinder(h = standoff_height, d = standoff_diameter);
                    translate([0, 0, standoff_height - standoff_hole_depth])
                        cylinder(h = standoff_hole_depth + 0.1, d = screw_hole_d);
                }
        }

        // ── Internal reinforcement ribs ───────────────────────────────────────
        // Added AFTER the main difference() so they are not removed by the
        // interior cavity subtraction.
        // Lateral ribs at 1/3 and 2/3 of interior Y span.
        for (frac = [1/3, 2/3]) {
            translate([-rib_iw/2,
                       -phone_length/2 + wall_thickness
                           + frac * rib_il - rib_t/2,
                       wall_thickness])
                cube([rib_iw, rib_t, rib_h]);
        }

        // ── Component side rails (module support, wall-attached) ──────────────
        // Rails are short center segments to avoid overlapping reinforcement ribs.
        for (side = [-1, 1]) {
            translate([side * (rib_iw/2 - side_rail_w/2),
                       -side_rail_l/2,
                       wall_thickness])
                cube([side_rail_w, side_rail_l, side_rail_h]);
        }
    }
}

// --- Render ---
top_shell();
