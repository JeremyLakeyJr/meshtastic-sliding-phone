// ============================================================================
// Meshtastic Sliding Phone – Shared Parameters
// ============================================================================
// All dimensions in millimeters.
//
// Form factor: landscape slider phone (Nokia N900-style).
//   Closed: 74 × 120 × 27 mm (X × Y × Z)   Open: ~116 × 120 × 27 mm
//
// Mechanism: the keyboard tray slides in the −X direction (shortways, along
// the 74 mm short axis) along two parallel rectangular top/bottom rails.
// Holding the phone in landscape (120 mm horizontal, 74 mm vertical), the
// keyboard slides downward to expose the CardKB — the same motion as the
// Nokia N900.  Small recessed neodymium disc magnets create snap detents at
// the closed and open positions and provide continuous Z-axis retention that
// keeps the tray against the phone body during sliding.
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
wall_thickness  = 2.2;   // Normalised wall thickness for all enclosure shells
wall            = wall_thickness;   // Backwards-compatible alias
clearance       = 0.3;   // General sliding-fit clearance per side (non-rail)
corner_radius   = 4.0;   // Rounded corner radius

// --- Display viewport (Heltec V4 built-in 0.96″ OLED, 128×64) ---
// Cutout is sized with a small margin to accept an optional capacitive
// touch-overlay panel on top of the OLED glass (the V4 exposes 7 touch pins).
display_w        = 23;   // Viewable width  (21 mm OLED + 2 mm touch-overlay margin)
display_h        = 13;   // Viewable height (11 mm OLED + 2 mm touch-overlay margin)
display_offset_y = 12;   // Distance from top edge of top shell to viewport centre
display_depth    =  2.0; // Countersink depth (protects display / touch glass)

// --- Heltec WiFi LoRa 32 V4 board (ESP32-S3 + SX1262 + 0.96″ OLED) ---
// Actual PCB dimensions: 51.7 × 25.4 × 10.7 mm (with display casing).
pcb_length      = 52;    // Board Y length (rounded from 51.7 mm)
pcb_width       = 26;    // Board X width  (rounded from 25.4 mm)
pcb_thickness   =  1.6;  // PCB thickness
pcb_clearance   =  9;    // Component height above PCB (OLED casing, antenna, etc.)

// --- LiPo battery (slim 3.7 V pouch, ~50×40×5 mm nominal) ---
lipo_thickness  =  6;    // 5 mm nominal + 1 mm tolerance
lipo_width      = 42;    // 40 mm + 2 mm tolerance
lipo_length     = 52;    // 50 mm + 2 mm tolerance

// --- CardKB keyboard module (M5Stack CardKB, I²C) ---
cardkb_length    = 59;   // Long axis – runs along phone Y-axis when installed
cardkb_width     = 28;   // Short axis – along sliding X-axis (sets min travel)
cardkb_thickness =  7;   // Height (Z)

// --- Keyboard slide travel ---
keyboard_travel  = 42;   // mm; fully exposes CardKB (≥ cardkb_width + 14 mm margin)

// ============================================================================
// Parallel captured-lip rail system (T-slot)
// ============================================================================
// Two T-shaped runners on the keyboard-tray top face protrude upward into
// matching T-slot channels cut into the bottom-shell underside.
// The runners run along the X axis (the 74 mm SHORT side of the phone),
// positioned at Y = ±rail_y from the phone centreline (top and bottom edges).
//
// Each runner has a narrow stem and a wider lip cap at the top.  The channel
// has a matching T-slot profile: a narrow upper section for the stem and a
// wider lower section for the lip.  The lip captures the runner vertically so
// the keyboard tray cannot tilt away from the phone body.
//
// The stem void is intentionally deeper than the runner is tall so the runners
// do NOT touch the channel ceiling – this creates a 1 mm air-gap standoff
// between the tray top face and the shell underside, giving low-friction
// sliding.
//
//   Standoff = rail_channel_h − rail_h = 3.5 − 2.5 = 1.0 mm
//
// The stem void ENDS FLUSH with the −X face of the bottom shell; this leaves
// shell material at Y positions outside the stem void as natural stop walls
// that intercept the keyboard-tray over-travel tabs at maximum slide.
//
// A rail_entry_chamfer flares the lip void at the +X (insertion) end so the
// runner lip slides in easily.
// ============================================================================
rail_w          =  4.0;  // Runner stem width   (Y direction)
rail_h          =  2.5;  // Runner height       (Z, protrudes above tray top face)
rail_y          = 40.0;  // ±Y distance from phone centreline to runner centre

// Captured-lip geometry
rail_lip_h      =  1.0;  // Height of T-rail lip cap (top portion of runner)
rail_lip_w      =  1.5;  // Width of lip overhang each side beyond stem (Y)

// Printing-tolerance clearances for the rail
rail_clearance  =  0.35; // Per-side clearance between runner and channel

// Entry chamfer at the +X insertion end of the channel
rail_entry_chamfer = 0.6;

// Channel in bot-shell underside
rail_channel_w  = rail_w  + 2 * rail_clearance;  // 4.7 mm  – stem void width
rail_channel_h  = rail_h  + 1.0;                 // 3.5 mm  – 1 mm standoff

// ============================================================================
// Neodymium disc-magnet detents
// ============================================================================
// Standard part: 5 mm dia × 2 mm thick, N42 grade.
// Each pocket is sized for a press-fit (0.1 mm under-bore) so magnets are
// retained without glue.  A shallow retention lip at the pocket entrance
// (0.2 mm under-bore, 0.5 mm deep) acts as a snap-in retainer that prevents
// the magnet from backing out.  Both opposing pockets are 0.5 mm deeper than
// the magnet so the magnet sits 0.5 mm below the face.  Guaranteed gap:
//
//   gap = standoff + 2 × recess = 1.0 + 0.5 + 0.5 = 2.0 mm  ✓
//
// Magnets must NEVER touch – the rail standoff makes this a hard guarantee.
// ============================================================================
magnet_d        =  5.0;              // Disc diameter
magnet_h        =  2.0;             // Disc thickness
magnet_pocket_d =  magnet_d - 0.1;  // 4.9 mm – press-fit bore
magnet_pocket_h =  2.5;             // Pocket depth = magnet_h + 0.5 mm recess

// Magnet Y positions (centred between the two rails at ±rail_y = ±40 mm)
magnet_y        = 20.0;  // ±Y from phone centreline

// Detent X positions in the PHONE-BODY frame (bot-shell local coordinates):
//   Closed snap : body_X = +detent_x_offset
//   Open   snap : body_X = +detent_x_offset − keyboard_travel  (= +28 − 42 = −14 mm)
//
// The keyboard-tray magnets sit at tray-local X = +detent_x_offset.
// • When travel = 0  (closed): tray magnets align with body closed-snap pockets. ✓
// • When travel = 42 (open):   tray magnets align with body open-snap pockets.  ✓
detent_x_offset = 28.0;  // mm from body centre toward +X (right edge)

// --- Keyboard-tray over-travel stop tabs ---
// Small tabs on each runner that are wider than the channel and contact the
// shell's natural stop walls at full slide travel.
tab_w_extra     =  2.0;  // Extra Y width beyond rail_channel_w (1 mm per side)
tab_depth       =  3.0;  // Tab X dimension (contact bearing length)
tab_z_extra     =  1.5;  // Extra Z height above rail_h
tab_stop_margin =  2.0;  // Travel margin before hard stop (mm before keyboard_travel)

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
