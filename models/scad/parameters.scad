// ============================================================================
// Meshtastic Sliding Phone – Shared Parameters
// ============================================================================
// All dimensions in millimeters.
//
// Form factor: horizontal slider phone (Nokia N900-style).
//   Closed: 120 × 74 × 27 mm     Open: ~162 × 74 × 27 mm
//
// Mechanism: the keyboard tray slides horizontally in the −Y direction
// along two parallel rectangular side rails.  Small recessed neodymium disc
// magnets create snap detents at the closed and open positions and provide
// continuous Z-axis retention that keeps the tray against the phone body
// during sliding.
// ============================================================================

// --- Overall phone body footprint (closed) ---
phone_length    = 120;   // Y: body length (Nokia N900 = 110.9 mm for reference)
phone_width     =  74;   // X: body width  (accommodates 59 mm CardKB + rails)

// --- Shell / tray heights ---
top_shell_z     =  10;   // Top shell    – display face, Heltec PCB
bot_shell_z     =   9;   // Bottom shell – LiPo battery, USB-C, SMA, rail channels
tray_z          =   8;   // Keyboard tray – CardKB pocket, rail runners, magnets

// Total closed thickness (informational)
phone_thickness = top_shell_z + bot_shell_z + tray_z;   // 27 mm

// --- Wall thickness and tolerances ---
wall            = 2.0;   // General wall / shell thickness
clearance       = 0.3;   // Sliding-fit clearance per side
corner_radius   = 4.0;   // Rounded corner radius

// --- Display viewport (Heltec V4 built-in 0.96″ OLED, 128×64) ---
display_w        = 21;   // Viewable width
display_h        = 11;   // Viewable height
display_offset_y = 12;   // Distance from top edge of top shell to viewport centre
display_depth    =  2.0; // Countersink depth (protects display glass)

// --- Heltec WiFi LoRa 32 V4 board ---
pcb_length      = 55;    // Board Y length
pcb_width       = 27;    // Board X width
pcb_thickness   =  1.6;  // PCB thickness
pcb_clearance   =  8;    // Component height above PCB (OLED module, antenna, etc.)

// --- LiPo battery (slim 3.7 V pouch, ~50×40×5 mm nominal) ---
lipo_thickness  =  6;    // 5 mm nominal + 1 mm tolerance
lipo_width      = 42;    // 40 mm + 2 mm tolerance
lipo_length     = 52;    // 50 mm + 2 mm tolerance

// --- CardKB keyboard module (M5Stack CardKB, I²C) ---
cardkb_length    = 59;   // Long axis – runs along phone X-axis when installed
cardkb_width     = 28;   // Short axis – along sliding Y-axis (sets min travel)
cardkb_thickness =  7;   // Height (Z)

// --- Keyboard slide travel ---
keyboard_travel  = 42;   // mm; fully exposes CardKB (≥ cardkb_width + 14 mm margin)

// ============================================================================
// Parallel side-rail system
// ============================================================================
// Two rectangular-section runners on the keyboard-tray top face protrude
// upward into matching channels cut into the bottom-shell underside.
// The runner width (X) constrains lateral drift; the channel depth is
// intentionally greater than the runner height so the runners do NOT touch
// the channel ceiling – this creates a 1 mm air gap (standoff) between the
// tray top face and the shell underside, giving low-friction sliding.
//
//   Standoff = rail_channel_h − rail_h = 3.5 − 2.5 = 1.0 mm
// ============================================================================
rail_w          =  4.0;  // Runner width  (X direction)
rail_h          =  2.5;  // Runner height (Z, protrudes above tray top face)
rail_x          = 32.0;  // ±X distance from phone centreline to runner centre

// Channel in bot-shell underside (slightly wider + intentionally deeper)
rail_channel_w  = rail_w + 2 * clearance;   // 4.6 mm  – snug sliding fit
rail_channel_h  = rail_h + 1.0;             // 3.5 mm  – 1 mm standoff

// ============================================================================
// Neodymium disc-magnet detents
// ============================================================================
// Standard part: 5 mm dia × 2 mm thick, N42 grade.
// Each pocket is sized for a light press-fit (0.1 mm under-bore).
// Both opposing pockets are 0.5 mm deeper than the magnet so the magnet sits
// 0.5 mm below the face.  Guaranteed gap between opposing faces:
//
//   gap = standoff + 2 × recess = 1.0 + 0.5 + 0.5 = 2.0 mm  ✓
//
// Magnets must NEVER touch – the rail standoff makes this a hard guarantee.
// ============================================================================
magnet_d        =  5.0;  // Disc diameter
magnet_h        =  2.0;  // Disc thickness
magnet_pocket_d =  5.2;  // Pocket bore  (light press-fit)
magnet_pocket_h =  2.5;  // Pocket depth = magnet_h + 0.5 mm recess

// Magnet X positions (centred between the two rails at ±rail_x = ±32 mm)
magnet_x        = 16.0;  // ±X from phone centreline

// Detent Y positions in the PHONE-BODY frame (bot-shell local coordinates):
//   Closed snap : body_Y = +detent_y_offset
//   Open   snap : body_Y = +detent_y_offset − keyboard_travel  (= +35 − 42 = −7 mm)
//
// The keyboard-tray magnets sit at tray-local Y = +detent_y_offset.
// • When travel = 0  (closed): tray magnets align with body closed-snap pockets. ✓
// • When travel = 42 (open):   tray magnets align with body open-snap pockets.  ✓
detent_y_offset = 35.0;  // mm from body centre toward +Y (top edge)

// --- Antenna (SMA connector) ---
sma_diameter    =  6.5;
sma_flat_width  =  8.0;

// --- USB-C port ---
usbc_width      =  9.5;
usbc_height     =  3.5;

// --- Speaker / microphone ---
speaker_diameter = 12;
mic_diameter     =  2;

// --- Screw posts (M2) ---
screw_hole_d    =  2.2;
screw_post_d    =  5.0;
screw_post_h    =  5.0;

// --- Legacy aliases (used by battery_cover / antenna_mount) ---
bot_shell_length = phone_length;
bot_shell_width  = phone_width;

// --- Quality ---
$fn = 48;  // Facet count for circles (increase for final export)
