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
