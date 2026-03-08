// ============================================================================
// Meshtastic Sliding Phone – Bottom Shell  (sliding keyboard tray)
// ============================================================================
// In the 2-piece design the "bottom shell" IS the sliding keyboard tray.
// This file provides the bottom_shell() module as a named alias for
// keyboard_tray() and renders it for standalone STL export.
//
// Use top_shell.scad + bottom_shell.scad (or keyboard_tray.scad) for the
// complete 2-piece assembly.  See assembly.scad for the combined preview.
//
// Print orientation : TOP FACE DOWN (runners print upward; no supports needed)
// Print settings    : 0.2 mm layer height, 30 % infill, brim recommended
// ============================================================================

include <parameters.scad>
use <utilities.scad>
use <keyboard_tray.scad>

module bottom_shell() {
    keyboard_tray();
}

// --- Render ---
bottom_shell();
