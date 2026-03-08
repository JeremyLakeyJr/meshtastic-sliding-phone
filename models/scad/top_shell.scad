// ============================================================================
// Meshtastic Sliding Phone – Top Shell  (unified 2-piece enclosure)
// ============================================================================
// The single printed top enclosure (replaces the former 3-piece
// top_shell + bottom_shell + battery_cover stack).
//
// STRUCTURE
// ─────────
//   • Full exterior shell (95 × 120 × 19 mm, rounded corners)
//   • Uniform exterior wall thickness (wall_thickness = 2.2 mm)
//   • Solid bottom panel (no cut-throughs)
//   • Internal cavity with rounded interior corners for print reliability
//   • PCB mounting platform + 4 standoffs with blind screw holes
//   • Evenly spaced internal support ribs tied to enclosure walls
//   • Slider guide rails on interior side walls (Y = ±wall_inner_y)
//       additive rectangular rails: rail_width × rail_height = 3 × 3 mm
//       protrude inward from wall face; sit above the bottom floor surface
//       one rail per interior side wall; length = rail_length = 70 mm
//       positioned at the +X (insertion) end of the tray travel range
//
// SLIDER RAIL PLACEMENT
// ─────────────────────
//   Interior wall face : Y = ±(phone_length/2 − wall_thickness) = ±57.8 mm
//   Rail protrudes inward by rail_width = 3 mm  →  rail spans ±54.8…57.8 mm
//   Rail height (Z)    : rail_height = 3 mm, sitting above the floor surface
//   Rail length (X)    : rail_length = 70 mm at the +X insertion end
//   Rail length ≥ 70 % of tray width (95 mm)  →  73.7 % ✓
//   Bottom floor (Z = 0 … wall_thickness) : solid, unmodified ✓
//   Does NOT intersect PCB pocket (Y ≈ −1…45 mm) or battery pocket ✓
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
    assert(standoff_floor_thickness < standoff_height,
           "Blind standoff floor thickness must be less than standoff height");

    // Reinforcement rib dimensions (from parameters)
    rib_t  = rib_width;                             // 2.0 mm
    rib_h  = body_z - wall_thickness;               // floor-to-ceiling span inside cavity
    rib_iw = phone_width  - 2 * wall_thickness;     // interior width  (X)
    rib_il = phone_length - 2 * wall_thickness;     // interior length (Y)
    standoff_hole_depth = standoff_height - standoff_floor_thickness;

    // Slider rail geometry (per spec)
    // Interior wall face at Y = ±wall_inner_y; rail protrudes inward by rail_width.
    wall_inner_y        = phone_length / 2 - wall_thickness;  // 57.8 mm
    slider_rail_inner_y = wall_inner_y - rail_width;          // 54.8 mm (inner edge)
    // Rails span the +X insertion end, same X range as tray grooves.
    slider_rail_x_start = phone_width / 2 - rail_length;      // −22.5 mm

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
                    if (standoff_hole_depth > 0)
                        translate([0, 0, standoff_floor_thickness])
                            cylinder(h = standoff_hole_depth + geom_epsilon, d = screw_hole_d);
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

        // ── Slider guide rails (additive, on interior side walls) ─────────────
        // Rectangular rails on the interior face of the outer long walls
        // (Y = ±wall_inner_y = ±57.8 mm).  Rails protrude inward by rail_width
        // (3 mm) and rise above the floor surface (Z = wall_thickness) by
        // rail_height (3 mm).  The solid bottom floor (Z = 0 … wall_thickness)
        // is not cut or modified.
        //
        // One rail per interior side wall (per spec):
        //   +Y rail : Y = slider_rail_inner_y … wall_inner_y = 54.8 … 57.8 mm
        //   −Y rail : Y = −wall_inner_y … −slider_rail_inner_y
        //
        // Rail length = rail_length = 70 mm ≥ 70 % of tray width (95 mm) ✓
        // X range: slider_rail_x_start … phone_width/2 = −22.5 … +47.5 mm
        //
        // The matching tray grooves capture these rails; see keyboard_tray.scad.
        for (flip = [false, true]) {
            mirror([0, flip ? 1 : 0, 0])
                translate([slider_rail_x_start,
                           slider_rail_inner_y,
                           wall_thickness])
                    cube([rail_length, rail_width, rail_height]);
        }
    }
}

// --- Render ---
top_shell();
