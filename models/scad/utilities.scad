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

// ---------------------------------------------------------------------------
// Arc slider modules (Sony Xperia-style curved sliding mechanism)
// ---------------------------------------------------------------------------
// The top shell slides along an arc path so that it tilts upward when opened,
// providing a comfortable viewing angle.  Guide pins on the top shell ride
// inside arc-shaped channels cut into the inner side walls of the bottom shell.
// Small detent bumps at the open and closed positions provide tactile snap.
// ---------------------------------------------------------------------------

// Guide pin (cylindrical pin protruding from top-shell underside)
module guide_pin(d, h) {
    cylinder(h = h, d = d);
}

// 2D arc slot profile – a slot that follows a circular arc.
//   r     = arc radius (center of curvature is below the shell)
//   angle = sweep angle of the arc (degrees)
//   sw    = slot width (perpendicular to arc direction)
module arc_slot_2d(r, angle, sw) {
    difference() {
        // Outer arc ring
        intersection() {
            difference() {
                circle(r = r + sw/2);
                circle(r = r - sw/2);
            }
            // Limit to the desired angular sweep (centered on +Y axis)
            polygon(points = [
                [0, 0],
                [r * 1.5 * sin(-angle/2), r * 1.5 * cos(-angle/2)],
                [0, r * 1.5],
                [r * 1.5 * sin(angle/2), r * 1.5 * cos(angle/2)]
            ]);
        }
    }
}

// 3D arc guide channel – extrudes the arc slot profile to form a channel
// cut into a side wall.
//   r     = arc radius
//   angle = sweep angle (degrees)
//   sw    = slot width
//   depth = depth of the channel (extrusion thickness)
module arc_guide_channel(r, angle, sw, depth) {
    linear_extrude(height = depth)
        arc_slot_2d(r, angle, sw);
}

// Detent bump – small raised bump placed inside an arc channel to create
// a snap-in position.  The guide pin rides over it with a slight click.
//   d = bump diameter, h = bump height
module detent_bump(d, h) {
    sphere(d = d);
    // Add a small cylinder base for printability
    cylinder(h = h, d1 = d, d2 = d * 0.6);
}
