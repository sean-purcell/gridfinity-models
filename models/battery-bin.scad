// Battery bin: 3x1 with asymmetrical division for AA (51mm) and AAA (45mm) batteries
// Includes a third compartment that fills the remaining space

include <../src/core/standard.scad>
use <../src/core/gridfinity-rebuilt-utility.scad>
use <../src/core/gridfinity-rebuilt-holes.scad>
use <../src/core/bin.scad>
use <../src/core/cutouts.scad>
use <../src/helpers/generic-helpers.scad>
use <../src/helpers/grid.scad>
use <../src/helpers/grid_element.scad>

// ===== PARAMETERS ===== //
$fa = 4;
$fs = 0.25;

// Battery bin: 3 units wide, 1 unit deep, 3 units tall
bin_battery = new_bin([3, 1], fromGridfinityUnits(3));

// ===== RENDER ===== //
bin_render(bin_battery) {
    depth = bin_get_infill_size_mm(bin_battery).z;
    infill_size = bin_get_infill_size_mm(bin_battery);
    
    // AA battery compartment: 51mm wide, full depth
    // Position at lower left corner of infill area
    bin_translate(bin_battery, [0, 0])
    compartment_cutter([51, infill_size.y, depth], center_top=false);
    
    // AAA battery compartment: 45mm wide, full depth
    // Position after AA compartment + divider (51mm + 1.2mm divider = 52.2mm from left edge)
    // Convert to base units: 52.2mm / 42mm per base = ~1.243 base units
    bin_translate(bin_battery, [52.2/42, 0])
    compartment_cutter([45, infill_size.y, depth], center_top=false);
    
    // Third compartment: fills remaining space
    // Position after AAA compartment + divider (52.2mm + 45mm + 1.2mm = 98.4mm from left edge)
    // Width is remaining space: infill_size.x - 98.4mm
    remaining_width = infill_size.x - 98.4;
    bin_translate(bin_battery, [98.4/42, 0])
    compartment_cutter([remaining_width, infill_size.y, depth], center_top=false);
}

