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
// runners slide inside matching T-slot channels in the main-body underside,
// which constrains front/back (Y-axis) drift AND prevents vertical (Z-axis)
// tilt so the tray cannot separate from the body mid-slide.
//
// Rail geometry (cross-section, Y–Z plane):
//
//   ┌───────────────────────┐  ← lip cap  (rail_w + 2×rail_lip_w wide, rail_lip_h tall)
//   └──────┐         ┌──────┘
//          │  stem   │         (rail_w wide, rail_h − rail_lip_h tall)
//          └─────────┘
//
// Channel T-slot (wider at the base where the lip sits, narrower above):
//
//   ┌─────┐                ┌─────┐  ← shell body (solid)
//   │     └────────────────┘     │  ← stem void (rail_channel_w wide)
//   └─────────────────────────────┘  ← lip void  (rail_channel_w + 2×rail_lip_w wide)
//
// The stem void ends FLUSH with the −X face of the main body.  Shell material
// at Y positions outside the stem void acts as natural stop walls.
//
// Entry chamfer  (+X end): flares the lip void for smooth runner insertion.
// Snap ramp      (−X end): a shallow floor crest in the last snap_ramp_x mm
//                          makes the tray self-finish into the open position.
//
// Standoff = rail_channel_h − rail_h = 4.5 − 3.5 = 1.0 mm
// ============================================================================

// A single T-shaped runner – placed on the tray top face, protruding up.
//   length = X-axis extent of the runner
module rail_runner(length) {
    // Stem (lower portion – rail_w wide)
    cube([length, rail_w, rail_h - rail_lip_h]);
    // Lip cap (wider, sits at the top of the runner)
    translate([0, -rail_lip_w, rail_h - rail_lip_h])
        cube([length, rail_w + 2 * rail_lip_w, rail_lip_h]);
}

// The T-slot void subtracted from the main-body underside to form one channel.
//   length = X-axis extent (pass phone_width)
//
// Lip void  : extends 1 mm past both X ends (clean open edges for insertion).
// Stem void : starts 1 mm INSET from the −X end (flush with −X body face),
//             extends 1 mm past the +X end.
//             → body material outside the stem-void Y range acts as the
//               natural stop wall for the keyboard-tray over-travel tabs.
// Entry chamfer: flares the lip void at the +X end for smooth insertion.
// Snap ramp    : a small floor crest in the last snap_ramp_x mm of the stem
//               void makes the tray "snap" into the fully-open position.
module rail_channel_void(length) {
    ch = rail_entry_chamfer;

    // Lip void (Z = 0 … rail_lip_h) – wide, open at both ends
    translate([0, -rail_lip_w, 0])
        cube([length + 2, rail_channel_w + 2 * rail_lip_w, rail_lip_h]);

    // Stem void (Z = rail_lip_h … rail_channel_h) – narrow,
    // starts 1 mm inset so the −X body face remains for stop walls.
    // Total X extent: from X=1 to X=length+2 (same as original plain channel).
    // Split into two sections:
    //   • Snap-ramp section: X=1 … ramp_start_x  (hull wedge, see below)
    //   • Plain section:     X=ramp_start_x … length+2  (cube)
    // Together they cover the full original extent with no gaps or overruns.
    ramp_start_x = 1 + snap_ramp_x;  // X = 6 mm from void origin
    translate([ramp_start_x, 0, rail_lip_h])
        cube([length + 2 - ramp_start_x, rail_channel_w,
              rail_channel_h - rail_lip_h]);

    // Snap-ramp section: the stem void tapers from full height at
    // x = ramp_start_x down to (rail_channel_h − snap_ramp_z) at x = 1,
    // then back up slightly – approximated as a hull wedge.
    // This creates a gentle crest that provides the "snap" feel.
    hull() {
        // Near −X end: reduced void height (crest of ramp)
        translate([1, 0, rail_lip_h])
            cube([0.01, rail_channel_w, rail_channel_h - rail_lip_h - snap_ramp_z]);
        // At ramp_start_x: full void height (merges with plain stem void)
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
// Magnet-pocket module  (5 mm × 2 mm neodymium disc)
// ============================================================================
// Cylindrical press-fit pocket for one neodymium disc magnet (5 mm × 2 mm).
// Bore = magnet_diameter − magnet_press_fit (4.9 mm) → press-fit retention.
//
// A shallow retention lip at the pocket entrance (magnet_offset mm narrower,
// 0.5 mm deep) acts as a snap-in retainer: the magnet is pushed past the lip
// and cannot back out under normal handling.
//
// The pocket is 0.5 mm deeper than the magnet so the magnet sits 0.5 mm
// below the face — this recess, combined with the 1 mm rail standoff, gives
// a guaranteed 2 mm air gap between opposing magnet faces:
//
//   gap = rail_standoff + 2 × pocket_recess = 1.0 + 0.5 + 0.5 = 2.0 mm  ✓
// ============================================================================
module magnet_pocket() {
    retention_d = magnet_pocket_d - magnet_offset;  // 4.7 mm – narrow lip
    retention_h = 0.5;                              // depth of retention lip zone

    // Retention lip (slightly under-bore at the pocket mouth)
    cylinder(h = retention_h + 0.1, d = retention_d);

    // Main pocket body (press-fit bore)
    translate([0, 0, retention_h])
        cylinder(h = magnet_pocket_h - retention_h + 0.1, d = magnet_pocket_d);
}
