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
// Shortways (X-axis) slider – rail modules
// ============================================================================
// The keyboard tray has two parallel rectangular runners on its top face.
// These runners slide inside matching channels in the bottom-shell underside,
// constraining front/back (Y-axis) drift and keeping the slide straight.
// Rails run along the X axis (the 74 mm short side) and are positioned at
// Y = ±rail_y from the phone centreline (near the top and bottom long edges).
//
// The channel is intentionally 1 mm deeper than the runner is tall, creating
// a 1 mm air-gap standoff between the tray top face and the shell underside.
// This standoff reduces friction during sliding and sets a predictable gap
// for the neodymium magnet detents.
// ============================================================================

// A single rectangular runner – placed on the tray top face, protruding up.
//   length = X-axis extent of the runner
module rail_runner(length) {
    cube([length, rail_w, rail_h]);
}

// The void to subtract from the bot-shell underside to form one rail channel.
//   length = X-axis extent (pass phone_width; +2 extra mm for open ends)
module rail_channel_void(length) {
    cube([length + 2, rail_channel_w, rail_channel_h]);
}

// ============================================================================
// Magnet-pocket module
// ============================================================================
// Cylindrical press-fit pocket for one neodymium disc magnet (5 mm × 2 mm).
// The pocket is 0.5 mm deeper than the magnet so the magnet sits 0.5 mm
// below the face — this recess, combined with the 1 mm rail standoff, gives
// a guaranteed 2 mm air gap between opposing magnet faces:
//
//   gap = rail_standoff + 2 × pocket_recess = 1.0 + 0.5 + 0.5 = 2.0 mm
//
// The extra 0.1 mm on the cylinder height ensures a clean boolean cut.
// ============================================================================
module magnet_pocket() {
    cylinder(h = magnet_pocket_h + 0.1, d = magnet_pocket_d);
}
