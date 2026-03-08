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
// Shortways (X-axis) slider – captured dovetail rail modules
// ============================================================================
// The keyboard tray has two parallel dovetail runners on its top face.
// Each runner has a narrow base (attached to tray) and a wider cap (free end).
// The runners slide inside matching dovetail grooves in the top-shell underside,
// constraining front/back (Y-axis) drift AND preventing vertical (Z-axis)
// separation (the wide cap cannot exit through the narrow groove opening).
//
// Runner cross-section (Y–Z plane):
//
//   ┌──────────────────────┐  ← cap  (rail_base_width = 4.0 mm, free end)
//    \                    /
//     \                  /   ← angled sides (~65° from horizontal, FDM printable)
//      └────────────────┘    ← base (rail_top_width  = 1.2 mm, tray face)
//
// Groove in top shell (Y–Z plane, opens at Z = 0 / shell face):
//
//   ┌──┐                ┌──┐  ← shell face (solid; groove opening = 1.9 mm wide)
//    \  └──────────────┘  /   ← tapered walls (Z = 0 … rail_height)
//     └──────────────────┘    ← inner zone   (4.7 mm wide; Z = rail_height … groove_depth)
//
// Capture: runner cap (4 mm) > groove opening (1.9 mm) → tray captured  ✓
// Passive typing angle ≈ atan(channel_standoff / rail_engagement) ≈ 3° at full ext.
//
// Assembly:
//   1. Align runners with grooves at the +X entry end.
//   2. Slide tray −X.  Entry chamfer guides cap into inner zone.
//   3. Press-fit magnets.  Runner −X tip stop-cutout clears stop blocks.
//
// Parameters:
//   rail_base_width = 4.0 mm (cap)
//   rail_top_width  = 1.2 mm (base)
//   rail_height     = 3.0 mm
//   rail_clearance  = 0.35 mm (per side)
//   channel_standoff = 2.0 mm (extra depth for passive tilt)
// ============================================================================

// A single dovetail runner – placed on the tray top face, protruding upward.
//   length = X-axis extent of the runner (typically phone_width = 95 mm)
//   Origin: X = 0, Y centred at 0, Z = 0 at tray face.
module rail_runner(length) {
    // Narrow base at Z = 0 (tray-face attachment)
    // Wide cap at Z = rail_height (free end, captured in groove)
    hull() {
        translate([0, -rail_top_width / 2, 0])
            cube([length, rail_top_width, 0.01]);
        translate([0, -rail_base_width / 2, rail_height])
            cube([length, rail_base_width, 0.01]);
    }
}

// The dovetail groove void subtracted from the top-shell underside.
//   length = X-axis extent (pass phone_width)
//
// Profile: narrow opening at Z = 0 (shell face), tapered to inner width at
//          Z = rail_height, then a straight channel_standoff zone beyond that.
// Entry chamfer at +X end flares the opening for smooth runner insertion.
module rail_channel_void(length) {
    groove_opening = rail_top_width  + 2 * rail_clearance;  // 1.9 mm
    groove_inner   = rail_base_width + 2 * rail_clearance;  // 4.7 mm
    groove_depth   = rail_height + channel_standoff;        // 5.0 mm
    ch             = rail_entry_chamfer;                    // 1.0 mm

    // ── Tapered section (Z = 0 … rail_height): narrow opening → inner width
    hull() {
        translate([0, -groove_opening / 2, 0])
            cube([length + 2, groove_opening, 0.01]);
        translate([0, -groove_inner / 2, rail_height])
            cube([length + 2, groove_inner, 0.01]);
    }

    // ── Straight standoff zone (Z = rail_height … groove_depth)
    translate([0, -groove_inner / 2, rail_height])
        cube([length + 2, groove_inner, channel_standoff]);

    // ── Entry chamfer at +X insertion end (flares to groove_inner width)
    hull() {
        // At the +X face: full inner width, full depth
        translate([length + 1, -groove_inner / 2, 0])
            cube([0.01, groove_inner, groove_depth]);
        // Chamfer distance back: tapered to open wider
        translate([length + 2 - ch, -(groove_inner / 2 + ch), 0])
            cube([0.01, groove_inner + 2 * ch, groove_depth + ch]);
    }
}

// ============================================================================
// Wire routing groove module
// ============================================================================
// A shallow channel alongside the rail system for the keyboard flex cable.
// Prevents the cable from being pinched by the sliding tray.
//   length = X-axis extent; place adjacent to a rail on the tray top face.
module wire_routing_groove(length) {
    translate([0, 0, -0.1])
        cube([length, wire_tunnel_width, wire_tunnel_height + 0.1]);
}

// ============================================================================
// Magnet-pocket module  (10 mm × 4 mm neodymium disc)
// ============================================================================
// Cylindrical pocket for one 10 mm × 4 mm neodymium disc magnet.
//
// Bore = magnet_diameter = 10.3 mm (0.15 mm per-side clearance from 10 mm
// physical magnet; FDM tolerance allows easy insertion).
//
// Retention lip: the pocket entrance (top 0.6 mm = magnet_lip deep) is
// narrowed to (magnet_diameter − 2 × magnet_lip) = 9.1 mm.  The 10 mm magnet
// is pressed past this lip — the FDM wall deflects slightly and springs back,
// locking the magnet in place.
//
// Pocket depth = magnet_depth = 3.6 mm, leaving the magnet 0.4 mm proud.
// ============================================================================
module magnet_pocket() {
    retention_lip_d = magnet_diameter - 2 * magnet_lip;  // 9.1 mm – snap-fit entrance
    lip_depth       = magnet_lip;                         // 0.6 mm retention zone

    // Retention lip zone (narrow entrance)
    cylinder(h = lip_depth + 0.1, d = retention_lip_d);

    // Main pocket bore (full diameter)
    translate([0, 0, lip_depth])
        cylinder(h = magnet_depth - lip_depth + 0.1, d = magnet_diameter);
}
