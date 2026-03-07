// ============================================================================
// Meshtastic Sliding Phone - Shared Parameters
// ============================================================================
// All dimensions in millimeters. Adjust these values to fit your specific
// hardware revision and printer tolerances.
// ============================================================================

// --- Overall phone dimensions (closed position) ---
phone_length    = 165;   // Y-axis (tall) — accommodates PCB + battery + keyboard in same footprint
phone_width     = 74;    // X-axis (wide) — accommodates 58.2mm CardKB + rails
phone_thickness = 24;    // Z-axis (thick) — top_shell_z + bot_shell_z

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

// --- LiPo battery (MakerFocus, 3.7 V, 3000 mAh, ~65×36×10 mm) ---
lipo_thickness  = 12;    // Battery thickness with tolerance (10 mm + 2 mm)
lipo_width      = 38;    // Battery width with tolerance  (36 mm + 2 mm)
lipo_length     = 67;    // Battery length with tolerance (65 mm + 2 mm)

// --- CardKB keyboard module (M5Stack CardKB, I²C) ---
cardkb_length    = 59;   // Module length (58.2 mm nominal + 0.8 mm tolerance)
cardkb_width     = 28;   // Module width  (27.6 mm nominal + 0.4 mm tolerance)
cardkb_thickness = 8;    // Module thickness (7.5 mm nominal + 0.5 mm tolerance)

// --- Keyboard travel (how far the top shell slides to expose CardKB) ---
keyboard_travel  = 35;   // Must be ≥ cardkb_width + wall margins

// --- Arc slide mechanism (Sony Xperia-style curved slider) ---
// The top shell slides along a curved arc path, tilting upward as it opens.
// Guide pins on the top shell ride inside arc-shaped channels in the bottom.
arc_radius       = 200;  // Radius of the curved arc path (mm)
tilt_angle       = 25;   // Maximum tilt angle when fully open (degrees)
guide_pin_d      = 3;    // Diameter of guide pins on top shell
guide_pin_h      = 3;    // Height of guide pins (how far they protrude)
guide_slot_width = 3.6;  // Width of arc channel (guide_pin_d + clearance)
guide_slot_depth = 3.5;  // Depth of arc channel in side wall
num_guide_pins   = 2;    // Number of guide pins per side
detent_depth     = 0.4;  // Depth of snap detent notches (open/closed positions)
detent_width     = 2;    // Width of each detent notch

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
top_shell_z       = 9;    // Top shell height (display face + buttons)

bot_shell_length  = phone_length;      // Same footprint as top shell
bot_shell_width   = phone_width;
bot_shell_z       = 15;   // Bottom shell height (fits 12 mm MakerFocus battery + mechanics)

// --- Quality settings ---
$fn = 40;  // Facet count for curves (increase for smoother exports)
