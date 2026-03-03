// ============================================================================
// Meshtastic Sliding Phone - Shared Parameters
// ============================================================================
// All dimensions in millimeters. Adjust these values to fit your specific
// hardware revision and printer tolerances.
// ============================================================================

// --- Overall phone dimensions (closed position) ---
phone_length    = 120;   // Y-axis (tall)
phone_width     = 74;    // X-axis (wide) — accommodates 58.2mm CardKB + rails
phone_thickness = 15;    // Z-axis (thick) — slimmer with flat LiPo

// --- Wall thickness and tolerances ---
wall            = 1.8;   // General wall thickness
clearance       = 0.3;   // Sliding fit clearance per side
corner_radius   = 4;     // Rounded corner radius

// --- Display viewport (Heltec V4 built-in 0.96" OLED, 128×64) ---
display_w       = 21;    // Viewable width
display_h       = 11;    // Viewable height
display_offset_y = 15;   // Offset from top edge of top shell
display_depth   = 2.0;   // Viewport depth (through top-shell wall only)

// --- Heltec WiFi LoRa 32 V4 board dimensions ---
pcb_length      = 55;    // Board length
pcb_width       = 27;    // Board width
pcb_thickness   = 1.6;   // PCB thickness
pcb_clearance   = 10;    // Component height above PCB (incl. OLED module)

// --- LiPo battery (503450, 3.7 V, ~1200 mAh) ---
lipo_thickness  = 6;     // Battery thickness with tolerance
lipo_width      = 35;    // Battery width with tolerance
lipo_length     = 51;    // Battery length with tolerance

// --- CardKB keyboard module (M5Stack CardKB, I²C) ---
cardkb_length    = 59;   // Module length (58.2 mm nominal + 0.8 mm tolerance)
cardkb_width     = 28;   // Module width  (27.6 mm nominal + 0.4 mm tolerance)
cardkb_thickness = 8;    // Module thickness (7.5 mm nominal + 0.5 mm tolerance)

// --- Keyboard travel (how far the top shell slides to expose CardKB) ---
keyboard_travel  = 35;   // Must be ≥ cardkb_width + wall margins

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
