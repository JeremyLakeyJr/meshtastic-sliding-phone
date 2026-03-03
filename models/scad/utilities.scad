// ============================================================================
// Meshtastic Sliding Phone - Utility Modules
// ============================================================================
// Reusable shapes and helpers for all phone components.
// ============================================================================

include <parameters.scad>

// Rounded rectangle (2D profile for linear_extrude)
module rounded_rect(w, h, r) {
    offset(r = r)
        square([w - 2*r, h - 2*r], center = true);
}

// Rounded box (3D)
module rounded_box(w, h, d, r) {
    linear_extrude(height = d)
        rounded_rect(w, h, r);
}

// Hollow rounded box (shell)
module rounded_shell(w, h, d, r, t) {
    difference() {
        rounded_box(w, h, d, r);
        translate([0, 0, t])
            rounded_box(w - 2*t, h - 2*t, d, max(r - t, 0.5));
    }
}

// Screw post (solid cylinder with screw hole)
module screw_post(h, od, id) {
    difference() {
        cylinder(h = h, d = od);
        translate([0, 0, -0.1])
            cylinder(h = h + 0.2, d = id);
    }
}

// Grid of rounded rectangles (for speaker grille, ventilation)
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

// Dovetail profile (2D) for slide rails
module dovetail_profile(w, h, taper = 0.7) {
    polygon(points = [
        [-w/2,        0],
        [-w*taper/2,  h],
        [ w*taper/2,  h],
        [ w/2,        0]
    ]);
}

// Dovetail rail (3D extrusion)
module dovetail_rail(w, h, length) {
    rotate([90, 0, 0])
        linear_extrude(height = length, center = true)
            dovetail_profile(w, h);
}

// Dovetail channel (3D, with clearance)
module dovetail_channel(w, h, length, cl) {
    rotate([90, 0, 0])
        linear_extrude(height = length + 0.2, center = true)
            dovetail_profile(w + cl*2, h + cl);
}
