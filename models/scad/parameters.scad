// ============================================================================
// Meshtastic Sliding Phone - Shared Parameters
// ============================================================================
// All dimensions in millimeters. Adjust these values to fit your specific
// hardware revision and printer tolerances.
// ============================================================================

// --- Overall phone dimensions (closed position) ---
phone_length    = 140;   // Y-axis (tall)
phone_width     = 68;    // X-axis (wide)
phone_thickness = 18;    // Z-axis (thick)

// --- Wall thickness and tolerances ---
wall            = 1.8;   // General wall thickness
clearance       = 0.3;   // Sliding fit clearance per side
corner_radius   = 4;     // Rounded corner radius

// --- Display cutout (2.8" IPS LCD, 320x240) ---
display_w       = 57;    // Viewable width
display_h       = 43;    // Viewable height
display_offset_y = 18;   // Offset from top edge of top shell
display_depth   = 3.5;   // Module thickness

// --- T-Beam V1.2 board dimensions ---
pcb_length      = 100;   // Board length
pcb_width       = 33;    // Board width
pcb_thickness   = 1.6;   // PCB thickness
pcb_clearance   = 12;    // Component height above PCB

// --- 18650 Battery ---
battery_diameter = 18.5; // With wrapper tolerance
battery_length   = 65.5;

// --- Keyboard area (revealed by slide) ---
keyboard_travel  = 52;   // How far the top shell slides
keyboard_rows    = 4;
keyboard_cols    = 10;
key_size         = 5;    // Individual key cap size
key_spacing      = 1;    // Gap between keys

// --- Slide rail mechanism ---
rail_width       = 4;    // Width of each rail
rail_height      = 2;    // Height/depth of rail channel
rail_length_top  = 100;  // Rail length on top shell
rail_length_bot  = 100;  // Rail length on bottom shell

// --- Antenna (SMA connector) ---
sma_diameter     = 6.5;  // SMA connector hole
sma_flat_width   = 8;    // Wrench flat width

// --- USB-C port ---
usbc_width       = 9.5;
usbc_height      = 3.5;

// --- Speaker and microphone ---
speaker_diameter = 12;
mic_diameter     = 2;

// --- Screw posts ---
screw_hole_d     = 2.2;  // M2 screw
screw_post_d     = 5;
screw_post_h     = 6;

// --- Derived dimensions ---
top_shell_length  = phone_length;
top_shell_width   = phone_width;
top_shell_z       = phone_thickness / 2;

bot_shell_length  = phone_length + keyboard_travel;
bot_shell_width   = phone_width;
bot_shell_z       = phone_thickness / 2;

// --- Quality settings ---
$fn = 40;  // Facet count for curves (increase for smoother exports)
