// ============================================================================
// Meshtastic Sliding Phone – Shared Parameters
// ============================================================================
// All dimensions in millimeters.
//
// Form factor: landscape slider phone (Nokia N900-style).
//   Closed: 95 × 120 × 27 mm (X × Y × Z)   Open: ~160 × 120 × 27 mm
//
// Mechanism: the keyboard tray slides in the −X direction (shortways, along
// the 95 mm short axis) along two parallel captured T-slot rails.
// Holding the phone in landscape (120 mm horizontal, 95 mm vertical), the
// keyboard slides downward to expose the CardKB.
//
// Rail system: T-slot captured-lip, rail_width=3 mm, rail_height=2 mm,
// clearance=0.35 mm.  Magnets: 10 mm × 4 mm neodymium disc, pockets 10.3 mm
// bore × 4.2 mm deep with 0.5 mm retention lip.  Slider travel = 65 mm,
// exposing ≥ 60 mm of tray / CardKB area.
//
// STRUCTURE (2-piece design)
//   top_shell     – unified enclosure: display, PCB, battery, rails, ports
//   keyboard_tray – sliding component: CardKB, T-runners, magnets
//   (bottom_shell is an alias for keyboard_tray)
// ============================================================================

// --- Overall phone body footprint (closed) ---
phone_length    = 120;   // Y: body length
// phone_width is 95 mm to give adequate rail engagement at 65 mm travel:
//   engagement = phone_width − slider_travel = 95 − 65 = 30 mm  ✓
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

// --- LiPo battery (slim 3.7 V pouch, ~50×40×5 mm nominal) ---
lipo_thickness  =  6;    // 5 mm + 1 mm tolerance
lipo_width      = 42;    // 40 mm + 2 mm tolerance
lipo_length     = 52;    // 50 mm + 2 mm tolerance

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
keyboard_clearance       = 0.5;  // Per-side clearance around keyboard in X and Y
keyboard_pocket_depth    = 8;    // Pocket depth (≥ cardkb_thickness + clearance)
keyboard_height_clearance = 10;  // Minimum internal Z clearance when keyboard is inside

// --- Keyboard slide travel ---
// slider_travel = 65 mm exposes the full 54 mm CardKB height plus margin.
// Exposed tray area at full extension = slider_travel = 65 mm ≥ 60 mm spec.  ✓
slider_travel    = 65;   // mm; fully exposes CardKB
keyboard_travel  = slider_travel;  // Backward-compatible alias

// ============================================================================
// Parallel captured-lip rail system (T-slot)
// ============================================================================
// Two T-shaped runners on the keyboard-tray top face protrude upward into
// matching T-slot channels cut into the top-shell underside.
// Runners run along the X axis, positioned at Y = ±rail_y from phone centreline.
//
// Runner cross-section (Y–Z plane):
//   ┌─────────────────┐  ← lip cap  (rail_w + 2×rail_lip_w wide, rail_lip_h tall)
//   └───┐       ┌─────┘
//       │ stem  │           (rail_w wide, rail_h − rail_lip_h tall)
//       └───────┘
//
// Channel standoff = rail_channel_h − rail_h = 4.5 − 2.0 = 2.5 mm
// (extra clearance accommodates the slight typing angle at full extension)
// ============================================================================
rail_w          =  3.0;  // Runner stem width   (Y direction) – per spec
rail_h          =  2.0;  // Runner height       (Z) – per spec
rail_y          = 40.0;  // ±Y distance from phone centreline to runner centre

// Captured-lip geometry
rail_lip_h      =  1.0;  // Height of T-rail lip cap
rail_lip_w      =  1.5;  // Width of lip overhang each side beyond stem (Y)

// Printing-tolerance clearance for the rail
rail_clearance  =  0.35; // Per-side clearance between runner and channel – per spec

// Entry chamfer at the +X insertion end of the channel
rail_entry_chamfer = 0.6;
rail_chamfer       = rail_entry_chamfer;  // Alias

// Channel dimensions derived from rail geometry
rail_channel_w  = rail_w  + 2 * rail_clearance;  // 3.7 mm  – stem void width
rail_channel_h  = rail_h  + 2.5;                 // 4.5 mm  – 2.5 mm standoff
rail_height     = rail_channel_h;                 // Alias

// --- Snap-ramp geometry (auto-finish open action, last 5 mm of travel) ---
snap_ramp_x     =  5.0;  // Length of ramp zone along X (mm)
snap_ramp_z     =  0.4;  // Peak height of ramp above channel floor (mm)

// --- Typing angle ---
// A slight typing angle (~3°) is produced passively when the keyboard is fully
// extended: the generous 2.5 mm standoff in the T-slot channel allows the tray
// to rest at a natural incline under gravity / hand pressure.  No angled rails
// are required — the design uses the standoff clearance for this effect.
typing_angle    =  3.0;  // degrees (design target; achieved passively)

// ============================================================================
// End-stop system (stop blocks inside rail channels)
// ============================================================================
// Small rectangular blocks fixed to the channel floor near the open end of
// the body prevent the tray from being accidentally removed.
//
// The runner -X tip has a matching stop_cutout notch that allows the runner to
// pass the block during initial assembly from the +X entry end.  After assembly
// the block is trapped inside the runner travel zone and acts as a hard stop.
//
//   Stop block +X face at body X = −(slider_travel − tab_stop_margin − phone_width/2)
//                               = −(65 − 2 − 47.5) = −15.5 mm from body centre
// ============================================================================
stop_block_height = 2.0;   // Height of stop block above channel floor – per spec
stop_cutout       = 2.5;   // Depth of runner tip cutout enabling assembly – per spec
stop_block_depth  = 2.0;   // X-dimension of stop block (must be ≤ stop_cutout)
tab_stop_margin   = 2.0;   // Travel margin before hard stop (mm before slider_travel)

// Assembly constraint: stop_cutout must exceed stop_block_depth so the runner
// -X tip can clear the stop block during initial assembly from the +X entry.
assert(stop_cutout > stop_block_depth,
       "stop_cutout must exceed stop_block_depth for assembly clearance");

// Legacy tab-stop aliases (kept for compatibility)
tab_w_extra     =  2.0;
tab_depth       =  3.0;
tab_z_extra     =  1.5;

// ============================================================================
// Neodymium disc-magnet detents (10 mm × 4 mm, N35 grade)
// ============================================================================
// Magnets: 10 mm diameter, 4 mm thick.
// Pocket bore = 10.3 mm (0.15 mm per-side clearance for FDM ease-of-fit).
// A retention lip (0.5 mm wide, 0.5 mm deep) at the pocket entrance snaps
// the magnet in: entrance bore = 10.3 − 2×0.5 = 9.3 mm < 10 mm magnet dia.
// The FDM lip deflects slightly on insertion; magnet cannot back out.
// Pocket depth 4.2 mm keeps magnet 0.2 mm recessed below the face.
//
//   Air gap between opposing faces = 2 × 0.2 mm recess + rail standoff = 2.9 mm  ✓
// ============================================================================
magnet_d         = 10.0;  // Physical magnet diameter (mm)
magnet_h         =  4.0;  // Physical magnet thickness (mm)
magnet_diameter  = 10.3;  // Pocket bore diameter – per spec
magnet_depth     =  4.2;  // Pocket depth – per spec
magnet_lip       =  0.5;  // Retention lip width (narrows entrance to 9.3 mm) – per spec

// Convenience aliases used by pocket module
magnet_pocket_d  = magnet_diameter;  // 10.3 mm
magnet_pocket_h  = magnet_depth;     // 4.2 mm

// Deprecated small-magnet aliases (kept for compatibility)
magnet_height    = magnet_h;
magnet_press_fit = 0.1;
magnet_offset    = magnet_lip;

// Magnet Y positions (between the two rails at ±rail_y = ±40 mm)
magnet_y        = 20.0;  // ±Y from phone centreline

// Detent X positions in the BODY frame:
//   Closed snap : body_X = +detent_x_offset  = +32 mm
//   Open   snap : body_X = +detent_x_offset − slider_travel = 32 − 65 = −33 mm
//
// Both are symmetric about X = 0 (detent_x_offset ≈ slider_travel / 2).
// Both are within the body footprint (|33| < phone_width/2 = 47.5 mm).  ✓
detent_x_offset = 32.0;  // mm from body centre toward +X

// ============================================================================
// Antenna, ports, PCB fasteners
// ============================================================================

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

// --- Legacy aliases (used by antenna_mount) ---
bot_shell_length = phone_length;
bot_shell_width  = phone_width;

// --- Quality ---
$fn = 48;  // Facet count for circles (increase for final export)
