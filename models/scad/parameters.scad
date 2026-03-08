// ============================================================================
// Meshtastic Sliding Phone – Shared Parameters
// ============================================================================
// All dimensions in millimeters.
//
// Form factor: landscape slider phone (Nokia N900-style).
//   Closed: 95 × 120 × 27 mm (X × Y × Z)   Open: ~160 × 120 × 27 mm
//
// Mechanism: the keyboard tray slides in the −X direction (shortways, along
// the 95 mm short axis) along two parallel captured dovetail rails.
// Holding the phone in landscape (120 mm horizontal, 95 mm vertical), the
// keyboard slides downward to expose the CardKB.
//
// Rail system: trapezoidal dovetail, rail_base_width=4 mm (cap/free end),
// rail_top_width=1.2 mm (base/tray-attachment end), rail_height=3 mm,
// clearance=0.35 mm.  Rail length = 70 mm (≥70 % of tray width, reduces
// cantilever flex).  Magnets: 10 mm × 4 mm neodymium disc, pockets 10.3 mm
// bore × 3.6 mm deep with 0.6 mm retention lip, 6 mm detent offset (guides
// tray into position).  Slider travel = 65 mm, exposing ≥ 60 mm of tray.
//
// RAIL CROSS-SECTION (Y–Z plane, runner on keyboard tray):
//
//   ┌──────────────────────┐  ← free end cap  (rail_base_width = 4 mm)
//    \                    /
//     \                  /   ← angled sides (~65° from horizontal, FDM printable)
//      └────────────────┘    ← tray-face base (rail_top_width  = 1.2 mm)
//
// Groove in top shell opens narrow (1.9 mm) at shell face, widens to 4.7 mm
// at rail_height depth, then has channel_standoff straight zone for passive
// ~3° typing angle at full extension.
//
// STRUCTURE (2-piece design)
//   top_shell     – unified enclosure: display, PCB, battery, rails, ports
//   keyboard_tray – sliding component: CardKB, dovetail runners, magnets
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

// --- PCB standoffs (M2 screws, Heltec V3/V4) ---
standoff_height   = 4.0;  // Standoff height – per spec
standoff_diameter = 6.0;  // Standoff outer diameter sized for blind-hole strength
screw_hole_d      = 3.0;  // Screw clearance hole (M3 clearance target) per requirement
standoff_floor_thickness = 1.5;  // Thickness of solid floor beneath blind standoff hole
screw_post_d      = standoff_diameter;   // Alias
screw_post_h      = standoff_height;     // Alias

// Internal side rails for module support along enclosure walls
side_rail_length = 16;  // Rail length along Y
side_rail_height = 3;   // Rail height above interior floor
geom_epsilon = 0.1;     // Small overlap offset to prevent coincident-face artifacts

// --- PCB mounting platform (structural floor reinforcement under Heltec board) ---
platform_thickness = 2.0;  // Platform slab height above case floor – per spec

// --- USB-C port cutout ---
usbc_width      = 11.0;  // USB-C opening width – per spec (was 9.5 mm)
usbc_height     =  4.0;  // USB-C opening height – per spec (was 3.5 mm)

// --- Battery pocket (MakerFocus 3000 mAh 3.7 V LiPo, ~70×50×8 mm nominal) ---
battery_pocket_x =  71.0;  // Pocket X dimension – per spec
battery_pocket_y =  51.0;  // Pocket Y dimension – per spec
battery_pocket_z =   9.0;  // Pocket depth (Z) – per spec

// Battery retention clip height (small tabs that snap over the battery)
battery_clip_height = 1.5;  // Clip overhang height – per spec

// Wire routing channel from battery pocket to Heltec JST connector
wire_channel_w   =  2.0;   // Channel width
wire_channel_h   =  6.0;   // Channel height (Z)

// --- Antenna keepout zone ---
antenna_keepout_radius = 12.0;  // No battery/wiring within this radius of SMA

// Legacy LiPo parameters (kept for backward compatibility)
lipo_thickness  =  6;
lipo_width      = 42;
lipo_length     = 52;

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
keyboard_clearance        = 0.5;  // Per-side clearance around keyboard in X and Y
keyboard_pocket_depth     = 8;    // Pocket depth (≥ cardkb_thickness + clearance)
keyboard_height_clearance = 10;   // Minimum internal Z clearance when keyboard is inside

// --- Keyboard slide travel ---
// slider_travel = 65 mm exposes the full 54 mm CardKB height plus margin.
// Exposed tray area at full extension = slider_travel = 65 mm ≥ 60 mm spec.  ✓
slider_travel    = 65;   // mm; fully exposes CardKB
keyboard_travel  = slider_travel;  // Backward-compatible alias

// ============================================================================
// Parallel captured dovetail rail system
// ============================================================================
// Two trapezoidal dovetail runners on the keyboard-tray top face protrude
// upward into matching dovetail grooves cut into the top-shell underside.
// Runners run along the X axis at Y = ±rail_y from the phone centreline.
//
// Runner cross-section (Y–Z plane):
//   Narrow base (rail_top_width  = 1.2 mm) at tray face (Z = tray_z)
//   Wide cap   (rail_base_width  = 4.0 mm) at free end (Z = tray_z + rail_height)
//   Height: rail_height = 3.0 mm
//
// Groove cross-section in top shell:
//   Opening (Z = 0, shell face): rail_top_width  + 2×rail_clearance = 1.9 mm  (narrow)
//   Inner   (Z = rail_height):   rail_base_width + 2×rail_clearance = 4.7 mm  (wide)
//   Standoff zone (Z = rail_height … rail_height+channel_standoff): straight 4.7 mm
//   Total groove depth = rail_height + channel_standoff = 5.0 mm
//
// Capture: runner cap (4 mm) > groove opening (1.9 mm) → tray cannot separate
// Passive typing angle at full extension ≈ atan(channel_standoff/30 mm) ≈ 3.8° ≈ 3°
//
// Rail spacing: rail_spacing = 80 mm → rail_y = ±40 mm (prevents rotational tilt)
// ============================================================================
rail_base_width = 4.0;   // Runner cap width (wide, free end) – per spec
rail_top_width  = 1.2;   // Runner base width (narrow, tray-attachment) – per spec
rail_height     = 3.0;   // Runner height (Z) – per spec
rail_angle      = 45.0;  // Reference dovetail side angle (degrees) – per spec
rail_spacing    = 80.0;  // Centre-to-centre Y distance between rails – per spec
rail_y          = rail_spacing / 2;  // ±Y from phone centreline = 40.0 mm

// Printing-tolerance clearance for the rail
rail_clearance  = 0.35;  // Per-side clearance between runner and groove – per spec

// Progressive clearance values (FDM tolerance compensation along travel)
clearance_start = 0.30;  // Start of travel (insertion / closed end)
clearance_mid   = 0.35;  // Mid-travel nominal (= rail_clearance)
clearance_end   = 0.45;  // End of travel (fully open; slightly looser)

// Entry chamfer at the +X insertion end of the groove
rail_entry_chamfer = 1.0;  // Per spec (was 0.6 mm)
rail_chamfer       = rail_entry_chamfer;  // Alias

// Rail length: runners and grooves are 70 mm long (< full tray width) to
// reduce the unsupported cantilever when the tray is fully extended.
// At full travel (65 mm), 5 mm of runner remains captured in the groove.
// The shorter runner is stiffer and resists tray flex during typing.
rail_length = 70.0;  // Runner and groove length – per spec

// Channel standoff: extra depth beyond rail_height for passive typing tilt.
// At full extension (30 mm engagement, 65 mm keyboard arm):
//   tilt ≈ atan(channel_standoff / 30) ≈ atan(2/30) ≈ 3.8° ≈ 3°  ✓
channel_standoff = 2.0;   // mm of straight zone beyond rail_height

// Derived channel dimensions (used by top_shell stop-block placement)
rail_channel_w     = rail_top_width  + 2 * rail_clearance;   // 1.9 mm groove opening
rail_channel_inner = rail_base_width + 2 * rail_clearance;   // 4.7 mm groove inner
rail_channel_h     = rail_height + channel_standoff;          // 5.0 mm total depth

// Pop-up mechanism parameters (passive via channel_standoff)
rail_slope_angle    = 3.0;  // Target typing angle (degrees) – per spec
maximum_lift_height = 3.0;  // Maximum tray lift at full extension (mm) – per spec

// Travel stop and detent bump heights
stop_bump_height = 1.2;  // Travel stop bump height – per spec
detent_height    = 0.3;  // Tactile detent bump height along rail – per spec

// Legacy T-slot aliases (kept for backward compatibility)
rail_w      = rail_top_width;    // Old stem width alias
rail_h      = rail_height;       // Old rail height alias
rail_lip_h  = 0.0;
rail_lip_w  = 0.0;
snap_ramp_x = 5.0;
snap_ramp_z = 0.4;
typing_angle = rail_slope_angle;

// --- Wire routing tunnel (for keyboard flex cable alongside rail) ---
wire_tunnel_width  = 6.0;  // Tunnel width (Y direction) – per spec
wire_tunnel_height = 2.0;  // Tunnel height (Z direction) – per spec

// ============================================================================
// End-stop system (stop blocks inside rail grooves)
// ============================================================================
// Small rectangular blocks fixed to the groove entrance face (Z = 0) prevent
// the tray from being pulled too far out (over-travel).
//
// The runner −X tip has a matching stop_cutout notch (stop_cutout deep × stop
// block width) that allows the runner tip to pass the stop block during initial
// assembly from the +X entry end.  After assembly, the solid runner body hits
// the stop block face when the tray is pulled to slider_travel − tab_stop_margin.
//
//   Stop block +X face: body X = −(slider_travel − tab_stop_margin − phone_width/2)
//                               = −(65 − 2 − 47.5) = −15.5 mm from body centre
// ============================================================================
stop_block_height = 2.0;   // Stop block height (Z) – per spec
stop_cutout       = 2.5;   // Runner tip cutout depth (X) enabling assembly – per spec
stop_block_depth  = 2.0;   // Stop block X dimension (must be < stop_cutout)
tab_stop_margin   = 2.0;   // Travel margin before hard stop (mm)

// Assembly constraint: stop_cutout must exceed stop_block_depth
assert(stop_cutout > stop_block_depth,
       "stop_cutout must exceed stop_block_depth for assembly clearance");

// Legacy tab-stop aliases (kept for compatibility)
tab_w_extra     =  2.0;
tab_depth       =  3.0;
tab_z_extra     =  1.5;

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
magnet_diameter  = 10.3;  // Pocket bore diameter – per spec
magnet_depth     =  3.6;  // Pocket depth – per spec (magnet sits 0.4 mm proud)
magnet_lip       =  0.6;  // Retention lip width (narrows entrance to 9.1 mm) – per spec

// X-axis offset between tray and body magnet pockets – per spec.
// Body closed pocket at detent_x_offset + magnet_offset (pulls tray closed).
// Body open   pocket at detent_x_offset − slider_travel − magnet_offset (pulls tray open).
magnet_offset    =  6.0;  // Detent offset – per spec

// Convenience aliases used by pocket module
magnet_pocket_d  = magnet_diameter;  // 10.3 mm
magnet_pocket_h  = magnet_depth;     // 3.6 mm

// Deprecated small-magnet aliases (kept for compatibility)
magnet_height    = magnet_h;
magnet_press_fit = 0.1;

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

// --- Speaker / microphone ---
speaker_diameter = 12;
mic_diameter     =  2;

// --- Structural reinforcement ribs ---
rib_width  = 2.0;  // Rib thickness – per spec
rib_height = 6.0;  // Rib height (Z span inside cavity) – per spec

// --- Lightening pockets (shallow recesses to reduce material without
//     compromising structural integrity or component clearances) ---
pocket_depth = 1.5;  // Pocket depth – per spec

// --- Legacy aliases (used by antenna_mount) ---
bot_shell_length = phone_length;
bot_shell_width  = phone_width;

// --- Quality ---
$fn = 48;  // Facet count for circles (increase for final export)
