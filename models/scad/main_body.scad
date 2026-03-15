// ============================================================================
// Meshtastic Sliding Phone – Main Body  (backward-compatible alias)
// ============================================================================
// This file is a backward-compatible alias for top_shell.scad.
// The canonical file for the unified top enclosure is top_shell.scad.
//
// Print orientation : Display face DOWN (viewport and button recesses print
//                     cleanly without supports)
// Print settings    : 0.2 mm layer height, 25 % infill, 3 perimeters
// ============================================================================

include <parameters.scad>
use <utilities.scad>
use <top_shell.scad>

module main_body() {
    top_shell();
}

// --- Render ---
main_body();

