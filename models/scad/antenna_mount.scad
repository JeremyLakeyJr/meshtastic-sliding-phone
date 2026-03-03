// ============================================================================
// Meshtastic Sliding Phone - Antenna Mount
// ============================================================================
// Protective cap and strain relief for the SMA LoRa antenna connector.
// Attaches to the top edge of the bottom shell. Can be used with a
// stubby antenna or as a feed-through for an external whip antenna.
//
// Print settings: 0.2mm layer height, 40% infill
// ============================================================================

include <parameters.scad>
use <utilities.scad>

module antenna_mount() {
    mount_w    = 16;
    mount_l    = 12;
    mount_h    = 10;
    flange_h   = 3;
    flange_ext = 3;  // How far the flange extends past the shell wall

    difference() {
        union() {
            // --- Mount body ---
            rounded_box(mount_w, mount_l, mount_h, 2);

            // --- Flange (sits against inside of shell wall) ---
            translate([0, -mount_l/2 + flange_h/2, 0])
                rounded_box(mount_w + 2*flange_ext, flange_h, mount_h, 1.5);
        }

        // --- SMA connector through-hole ---
        translate([0, 0, mount_h/2 + 1])
            rotate([90, 0, 0])
                cylinder(h = mount_l + flange_h + 1, d = sma_diameter, center = true);

        // --- Wrench flat relief (hexagonal for SMA nut) ---
        translate([0, -mount_l/2 - 0.1, mount_h/2 + 1])
            rotate([90, 0, 0])
                cylinder(h = 3, d = sma_flat_width + 1, $fn = 6);

        // --- Screw mounting holes ---
        for (side = [-1, 1]) {
            translate([side * (mount_w/2 - 2), mount_l/2 - 3, -0.1])
                cylinder(h = mount_h + 0.2, d = screw_hole_d);
        }

        // --- Cable routing channel (bottom) ---
        translate([0, 0, 1])
            rotate([0, 90, 0])
                cylinder(h = mount_w + 1, d = 3, center = true);
    }
}

// --- Render ---
antenna_mount();
