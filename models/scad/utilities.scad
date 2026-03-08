// ============================================================================
// Meshtastic Sliding Phone – Utility Modules
// ============================================================================
// Reusable shapes and helpers shared by all phone components.
// ============================================================================

include <parameters.scad>

// --- 2-D rounded rectangle (profile for linear_extrude) ---
module rounded_rect(w, h, r) {
    offset(r = r)
        square([w - 2*r, h - 2*r], center = true);
}

// --- 3-D rounded box ---
module rounded_box(w, h, d, r) {
    linear_extrude(height = d)
        rounded_rect(w, h, r);
}

// --- Hollow rounded shell ---
module rounded_shell(w, h, d, r, t) {
    difference() {
        rounded_box(w, h, d, r);
        translate([0, 0, t])
            rounded_box(w - 2*t, h - 2*t, d, max(r - t, 0.5));
    }
}

// --- Screw post (solid cylinder with through hole) ---
module screw_post(h, od, id) {
    difference() {
        cylinder(h = h, d = od);
        translate([0, 0, -0.1])
            cylinder(h = h + 0.2, d = id);
    }
}

// --- Speaker / vent grille pattern ---
module grille_pattern(cols, rows, slot_w, slot_h, spacing, slot_r) {
    total_w = cols * (slot_w + spacing) - spacing;
    total_h = rows * (slot_h + spacing) - spacing;
    translate([-total_w/2, -total_h/2, 0])
        for (c = [0 : cols-1])
            for (r = [0 : rows-1])
                translate([c * (slot_w + spacing) + slot_w/2,
                           r * (slot_h + spacing) + slot_h/2, 0])
                    rounded_rect(slot_w, slot_h, slot_r);
}

// ============================================================================
// Shortways (X-axis) slider – captured-lip (T-slot) rail modules
// ============================================================================
// The keyboard tray has two parallel T-shaped runners on its top face.  Each
// runner has a narrow rectangular stem and a wider lip cap at the top.  The
// runners slide inside matching T-slot channels in the top-shell underside,
// which constrains front/back (Y-axis) drift AND prevents vertical (Z-axis)
// lift so the tray cannot separate from the body mid-slide.
//
// Rail geometry (cross-section, Y–Z plane):
//
//   ┌─────────────────┐  ← lip cap  (rail_w + 2×rail_lip_w wide, rail_lip_h tall)
//   └───┐       ┌─────┘
//       │ stem  │           (rail_w wide, rail_h − rail_lip_h tall)
//       └───────┘
//
//   Parameters (per spec):
//     rail_width   = 3 mm   (rail_w)
//     rail_height  = 2 mm   (rail_h)
//     clearance    = 0.35 mm (rail_clearance per side)
//
// Channel T-slot (wider at the base where the lip sits, narrower above):
//
//   ┌─────┐                ┌─────┐  ← shell body (solid)
//   │     └────────────────┘     │  ← stem void (rail_channel_w = 3.7 mm wide)
//   └─────────────────────────────┘  ← lip void
//
// Standoff = rail_channel_h − rail_h = 4.5 − 2.0 = 2.5 mm
// (generous clearance accommodates the slight passive typing angle at
//  full extension; see typing_angle in parameters.scad)
//
// Entry chamfer (+X end): flares the lip void for smooth runner insertion.
// Snap ramp     (−X end): a shallow floor crest in the last snap_ramp_x mm
//                         makes the tray self-finish into the open position.
// ============================================================================

// A single T-shaped runner – placed on the tray top face, protruding up.
//   length = X-axis extent of the runner
module rail_runner(length) {
    // Stem (lower portion – rail_w wide, rail_h − rail_lip_h tall)
    cube([length, rail_w, rail_h - rail_lip_h]);
    // Lip cap (wider, at the top of the stem)
    translate([0, -rail_lip_w, rail_h - rail_lip_h])
        cube([length, rail_w + 2 * rail_lip_w, rail_lip_h]);
}

// The T-slot void subtracted from the top-shell underside to form one channel.
//   length = X-axis extent (pass phone_width)
//
// Lip void  : extends 1 mm past both X ends for clean open edges.
// Stem void : full X extent (lip-void-length), enabling the runner to slide
//             freely along the entire channel.
// Entry chamfer: flares the lip void at the +X end for smooth insertion.
// Snap ramp    : a small floor crest in the last snap_ramp_x mm of travel
//               makes the tray "snap" into the fully-open position.
module rail_channel_void(length) {
    ch = rail_entry_chamfer;

    // Lip void (Z = 0 … rail_lip_h) – wide, open at both ends
    translate([0, -rail_lip_w, 0])
        cube([length + 2, rail_channel_w + 2 * rail_lip_w, rail_lip_h]);

    // Stem void (Z = rail_lip_h … rail_channel_h)
    // Split into snap-ramp section (near −X) and plain section.
    ramp_start_x = 1 + snap_ramp_x;  // X = 6 mm from void origin
    translate([ramp_start_x, 0, rail_lip_h])
        cube([length + 2 - ramp_start_x, rail_channel_w,
              rail_channel_h - rail_lip_h]);

    // Snap-ramp section: gentle floor crest for the "snap" feel at open end
    hull() {
        // Near −X end: reduced void height (crest of ramp)
        translate([1, 0, rail_lip_h])
            cube([0.01, rail_channel_w, rail_channel_h - rail_lip_h - snap_ramp_z]);
        // At ramp_start_x: full void height
        translate([ramp_start_x, 0, rail_lip_h])
            cube([0.01, rail_channel_w, rail_channel_h - rail_lip_h]);
    }

    // Entry chamfer on the lip void at the +X insertion end
    hull() {
        translate([length + 2 - ch, -rail_lip_w, 0])
            cube([0.01, rail_channel_w + 2 * rail_lip_w, rail_lip_h]);
        translate([length + 2, -rail_lip_w - ch, 0])
            cube([0.01, rail_channel_w + 2 * (rail_lip_w + ch), rail_lip_h + ch]);
    }
}

// ============================================================================
// Magnet-pocket module  (10 mm × 4 mm neodymium disc)
// ============================================================================
// Cylindrical pocket for one 10 mm × 4 mm neodymium disc magnet.
//
// Bore = magnet_diameter = 10.3 mm (0.15 mm per-side clearance from 10 mm
// physical magnet; FDM tolerance allows easy insertion).
//
// Retention lip: the pocket entrance (top 0.5 mm = magnet_lip deep) is
// narrowed to (magnet_diameter − 2 × magnet_lip) = 9.3 mm.  The 10 mm magnet
// is pressed past this lip — the FDM wall deflects slightly and springs back,
// locking the magnet in place.
//
// Pocket depth = magnet_depth = 4.2 mm, leaving the magnet 0.2 mm recessed.
// Air gap between opposing faces (body + tray) = 2 × 0.2 mm + 2.5 mm standoff
//                                              = 2.9 mm  ✓  magnets never touch.
// ============================================================================
module magnet_pocket() {
    retention_lip_d = magnet_diameter - 2 * magnet_lip;  // 9.3 mm – snap-fit entrance
    lip_depth       = magnet_lip;                         // 0.5 mm retention zone

    // Retention lip zone (narrow entrance)
    cylinder(h = lip_depth + 0.1, d = retention_lip_d);

    // Main pocket bore (full diameter)
    translate([0, 0, lip_depth])
        cylinder(h = magnet_depth - lip_depth + 0.1, d = magnet_diameter);
}
