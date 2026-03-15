// ============================================================================
// Meshtastic Sliding Phone – Shared Parameters
// ============================================================================
// All dimensions in millimeters.
//
// Form factor: landscape slider phone (Nokia N900-style).
//   Closed: 95 × 120 × 27 mm (X × Y × Z)   Open: ~160 × 120 × 27 mm
//
// Mechanism: the keyboard tray slides in the −X direction (shortways, along
// the 95 mm short axis) guided by two parallel captured rectangular rails.
// Holding the phone in landscape (120 mm horizontal, 95 mm vertical), the
// keyboard slides downward to expose the CardKB.
//
// Rail system: rectangular cross-section, rail_width=3 mm × rail_height=3 mm,
// additive on the interior side walls of the top shell.  Rail length = 70 mm
// (≥70 % of tray width, reduces cantilever flex).  Rails protrude BELOW the
// top-shell bottom face (Z = −rail_height … 0) and engage matching grooves
// in the keyboard tray.
//
// RAIL CROSS-SECTION (Y–Z plane, additive on top-shell interior wall):
//
//   ┌──────────────────┐  ← rail_width = 3 mm (Y protrusion from wall face)
//   │                  │
//   │                  │  ← rail_height = 3 mm (Z extent below shell face)
//   └──────────────────┘
//
// Tray groove (captures rail with rail_clearance = 0.35 mm per side):
//   Groove width  = rail_width  + 2 × rail_clearance = 3.7 mm
//   Groove depth  = rail_height + rail_clearance      = 3.35 mm
//
// Magnets: 10 mm × 4 mm neodymium disc, pockets 10.3 mm bore × 3.6 mm deep
// with 0.6 mm retention lip, 6 mm detent offset (creates X-axis snap force).
// Slider travel = 65 mm, exposing ≥ 60 mm of tray (full CardKB height).
//
// STRUCTURE (2-piece design)
//   top_shell     – unified enclosure: display, PCB, battery, rails, ports
//   keyboard_tray – sliding component: CardKB, rail grooves, magnets
//   (bottom_shell is an alias for keyboard_tray)
// ============================================================================

// --- Overall phone body footprint (closed) ---
phone_length    = 120;   // Y: body length
// phone_width = 95 mm: slider_travel(65) + rail_engagement(30) = 95  ✓
phone_width     =  95;   // X: body width

// --- Component heights (Z) ---
top_shell_z     =  10;   // Display / PCB section height
bot_shell_z     =   9;   // Battery / ports section height
body_z          = top_shell_z + bot_shell_z;  // 19 mm – unified top_shell height
tray_z          =   8;   // Keyboard tray height

// Total closed thickness (informational)
phone_thickness = body_z + tray_z;   // 27 mm

// --- Wall thickness and tolerances ---
wall_thickness  = 2.2;   // Minimum wall thickness (≥ 2 mm per spec)
wall            = wall_thickness;   // Backwards-compatible alias
clearance       = 0.3;   // General sliding-fit clearance per side (non-rail)
corner_radius   = 4.0;   // Rounded corner radius

// --- Display viewport (Heltec V4 built-in 0.96″ OLED, 128×64) ---
display_w        = 23;   // Viewable width
display_h        = 13;   // Viewable height
display_offset_y = 12;   // Distance from top edge of body to viewport centre
display_depth    =  2.0; // Countersink depth

// --- Heltec WiFi LoRa 32 V4 board (ESP32-S3 + SX1262 + 0.96″ OLED) ---
pcb_length      = 52;    // Board Y length
pcb_width       = 26;    // Board X width
pcb_thickness   =  1.6;  // PCB thickness
pcb_clearance   =  9;    // Component height above PCB

// PCB standoffs (M2 screws, Heltec V3/V4)
standoff_height   = 4.0;  // Standoff height
standoff_diameter = 6.0;  // Standoff outer diameter
screw_hole_d      = 3.0;  // Screw clearance hole diameter
standoff_floor_thickness = 1.5;  // Solid floor thickness beneath blind standoff hole

geom_epsilon = 0.1;     // Small overlap offset to prevent coincident-face artifacts

// --- PCB mounting platform (structural floor reinforcement under Heltec board) ---
platform_thickness = 2.0;  // Platform slab height above case floor

// --- USB-C port cutout ---
usbc_width  = 11.0;  // USB-C opening width
usbc_height =  4.0;  // USB-C opening height

// --- Battery pocket (MakerFocus 3000 mAh 3.7 V LiPo, ~71×51×9 mm) ---
battery_pocket_x =  71.0;  // Pocket X dimension
battery_pocket_y =  51.0;  // Pocket Y dimension
battery_pocket_z =   9.0;  // Pocket depth (Z)

// ============================================================================
// CardKB keyboard module (M5Stack CardKB v1.1, I²C)
// ============================================================================
// Physical board: 88 × 54 × 7 mm
//   cardkb_w  – long axis, runs along the phone Y-axis when installed
//   cardkb_h  – short axis, along the sliding X-axis
// Pocket sized with keyboard_clearance on all edges; depth = keyboard_pocket_depth.
// ============================================================================
cardkb_w         = 88;   // CardKB long axis (along phone Y)
cardkb_h         = 54;   // CardKB short axis (along sliding X)
cardkb_thickness =  7;   // CardKB height (Z)

// Keyboard fit parameters
keyboard_clearance    = 0.5;  // Per-side clearance around keyboard in X and Y
keyboard_pocket_depth = 8;    // Pocket depth (≥ cardkb_thickness + clearance)

// --- Keyboard slide travel ---
// slider_travel = 65 mm exposes the full 54 mm CardKB height plus margin.
// Exposed tray area at full extension = slider_travel = 65 mm ≥ 60 mm spec.  ✓
slider_travel    = 65;   // mm; fully exposes CardKB
keyboard_travel  = slider_travel;  // Backward-compatible alias

// ============================================================================
// Parallel captured rectangular rail system
// ============================================================================
// Two rectangular rails are additive features on the interior side walls of
// the top shell.  One rail along each long interior wall (Y = ±wall_inner_y),
// protruding inward by rail_width and running along the X axis for rail_length.
//
// Rail cross-section (Y–Z plane):
//   Width  : rail_width  = 3.0 mm (Y protrusion from the interior wall face)
//   Height : rail_height = 3.0 mm (Z extent below the top-shell bottom face)
//
// The rails protrude BELOW the top-shell bottom face (Z = −rail_height … 0).
// In world coordinates (top_shell placed at world Z = tray_z = 8 mm):
//   Rail world Z = tray_z − rail_height … tray_z = 5.0 … 8.0 mm
//
// Matching grooves in the keyboard tray capture the rails:
//   Groove width  = rail_width  + 2 × rail_clearance = 3.7 mm
//   Groove depth  = rail_height + rail_clearance      = 3.35 mm
//   Groove world Z = tray_z − groove_depth … tray_z  = 4.65 … 8.0 mm
//   Vertical clearance at groove floor = rail_clearance = 0.35 mm  ✓
//
// Rail placement:
//   Y = ±(phone_length/2 − wall_thickness)  (one per interior side wall)
//   X = phone_width/2 − rail_length … phone_width/2   (≥ 70 % of tray width)
//
// Rail length = 70 mm = 73.7 % of tray width (95 mm) ≥ 70 % spec  ✓
// ============================================================================
rail_height     = 3.0;   // Rail height (Z)
rail_width      = 3.0;   // Rail protrusion width from interior wall (Y)
rail_clearance  = 0.35;  // Per-side clearance between rail and tray groove
rail_length     = 70.0;  // Runner and groove length along X

// --- Wire routing tunnel (for keyboard flex cable alongside rail) ---
wire_tunnel_width  = 6.0;  // Tunnel width (Y direction)
wire_tunnel_height = 2.0;  // Tunnel height (Z direction)

// ============================================================================
// Neodymium disc-magnet detents (10 mm × 4 mm, N35 grade)
// ============================================================================
// Pocket bore = 10.3 mm (0.15 mm per-side clearance for FDM ease-of-fit).
// A retention lip (0.6 mm wide, 0.6 mm deep) at the pocket entrance snaps
// the magnet in: entrance bore = 10.3 − 2×0.6 = 9.1 mm < 10 mm magnet dia.
// The FDM lip deflects slightly on insertion; magnet cannot back out.
// Pocket depth = 3.6 mm, leaving the magnet 0.4 mm proud of the face
// for better magnetic contact.
//
// OFFSET DETENT CONFIGURATION (magnet_offset = 6 mm)
// ─────────────────────────────────────────────────────
// The body-shell magnet pockets are displaced ±magnet_offset in the sliding
// direction (X) from the tray magnet pockets.  At the closed position the
// tray magnet (at tray-local X = detent_x_offset) faces a body magnet at
// body-X = detent_x_offset + magnet_offset.  The resulting off-axis
// attraction has an X-component that PULLS the tray into the closed stop
// rather than simply creating a Z-axis normal force.  This guides the tray
// into position without excessive resistance during mid-travel.
// ============================================================================
magnet_d         = 10.0;  // Physical magnet diameter (mm)
magnet_h         =  4.0;  // Physical magnet thickness (mm)
magnet_diameter  = 10.3;  // Pocket bore diameter
magnet_depth     =  3.6;  // Pocket depth (magnet sits 0.4 mm proud)
magnet_lip       =  0.6;  // Retention lip width (narrows entrance to 9.1 mm)

// X-axis offset between tray and body magnet pockets.
// Body closed pocket at detent_x_offset + magnet_offset (pulls tray closed).
// Body open   pocket at detent_x_offset − slider_travel − magnet_offset (pulls tray open).
magnet_offset    =  6.0;  // Detent offset

// Magnet Y positions (centred between the two rails)
magnet_y        = 20.0;  // ±Y from phone centreline

// Detent X positions in the BODY frame (accounting for 6 mm offset):
//   Closed snap body pocket : body_X = detent_x_offset + magnet_offset = +38 mm
//   Open   snap body pocket : body_X = detent_x_offset − slider_travel
//                                      − magnet_offset              = −39 mm
//   Tray pockets            : tray-local X = detent_x_offset        = +32 mm
//
// Both body pockets are within the body footprint (|39| < phone_width/2 = 47.5 mm).  ✓
detent_x_offset = 32.0;  // mm from body centre toward +X (tray magnet position)

// ============================================================================
// Antenna, ports, PCB fasteners
// ============================================================================

// --- Antenna (SMA connector) ---
sma_diameter    =  6.5;
sma_flat_width  =  8.0;

// --- Speaker / microphone ---
mic_diameter    =  2;

// --- Structural reinforcement ribs ---
rib_width  = 2.0;  // Rib thickness

// --- Legacy bot_shell aliases (used by antenna_mount) ---
bot_shell_length = phone_length;
bot_shell_width  = phone_width;

// --- Quality ---
$fn = 48;  // Facet count for circles (increase for final export)
