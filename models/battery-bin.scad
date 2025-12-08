// Battery bin: 3x5 with asymmetrical division for AA (51mm) and AAA (45mm) batteries
// Includes CR2032 coin cell battery slots (3.5mm each) in the remaining space

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

/* [Base Hole Options] */
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;
//Use gridfinity refined hole style. Not compatible with magnet_holes!
refined_holes = false;
// Base will have holes for 6mm Diameter x 2mm high magnets.
magnet_holes = false;
// Base will have holes for M3 screws.
screw_holes = false;
// Magnet holes will have crush ribs to hold the magnet.
crush_ribs = false;
// Magnet/Screw holes will have a chamfer to ease insertion.
chamfer_holes = false;
// Magnet/Screw holes will be printed so supports are not needed.
printable_hole_top = false;
// Enable "gridfinity-refined" thumbscrew hole in the center of each base: https://www.printables.com/model/413761-gridfinity-refined
enable_thumbscrew = false;

hole_options = bundle_hole_options(refined_holes, magnet_holes, screw_holes, crush_ribs, chamfer_holes, printable_hole_top);

// Battery bin: 3 units wide, 1 unit deep, 3 units tall
bin_battery = new_bin(
  grid_size = [3,5],
  height_mm = fromGridfinityUnits(6),
  include_lip = true,
  grid_dimensions = GRID_DIMENSIONS_MM,
  hole_options = hole_options,
  );

// Simple rectangular cutter for narrow slots (no rounded corners)
module rectangular_slot_cutter(size_mm, center_top=true) {
    translate_by = center_top ? [0, 0, 0]
        : [size_mm.x/2, size_mm.y/2, 0];
    translate(translate_by)
    translate([0, 0, -size_mm.z])
    cube(size_mm);
}

// ===== RENDER ===== //
bin_render(bin_battery) {
    depth = bin_get_infill_size_mm(bin_battery).z;
    infill_size = bin_get_infill_size_mm(bin_battery);
    
    // Divider width - make dividers more substantial
    divider_width = 1.5;
    
    // AA battery compartment: 51mm wide, full depth
    // Position at lower left corner of infill area
    bin_translate(bin_battery, [0, 0])
    compartment_cutter([51, infill_size.y, depth], center_top=false);
    
    // AAA battery compartment: 45mm wide, full depth
    // Position after AA compartment + divider (51mm + divider_width)
    aa_end = 51 + divider_width;
    bin_translate(bin_battery, [aa_end/42, 0])
    compartment_cutter([45, infill_size.y, depth], center_top=false);
    
    // CR2032 battery slots: oriented along width, 3.5mm deep each with dividers between
    // Position after AAA compartment + divider
    aaa_end = aa_end + 45 + divider_width;
    // Use full remaining width (from aaa_end to the right edge of infill)
    remaining_width = infill_size.x - aaa_end;
    
    // CR2032 slot height - shorter than full bin depth (batteries are only 3.2mm thick)
    cr2032_slot_height = 10; // mm - enough for easy insertion/removal
    // Divider height between slots - shorter than slot height
    cr2032_divider_height = 5; // mm - dividers are shorter than slots
    
    lip_size = 3;
    divider_width_cr = 1;

    
    // Calculate how many CR2032 slots fit along the depth (Y direction)
    // Each slot is 3.5mm deep, with divider_width between slots
    // Formula: n * 3.5 + (n-1) * divider_width <= infill_size.y - lip_size;
    // Solving: n <= (infill_size.y - lip_size + divider_width) / (3.5 + divider_width)
    slot_depth = 3.5;
    num_slots = floor((infill_size.y - lip_size + divider_width_cr) / (slot_depth + divider_width_cr));
    
    echo(str("aaa_end: ", aaa_end));
    echo(str("infill width: ", infill_size.x));
    // Create slots with shorter dividers
    // Cut individual slots (full height at bottom)
    for (i = [0:num_slots-1]) {
        slot_position_y = i * (slot_depth + divider_width_cr) + lip_size;
        bin_translate(bin_battery, [(aaa_end)/42, slot_position_y/42])
        rectangular_slot_cutter([remaining_width, slot_depth, 22], center_top=true);
    }
    
    bin_translate(bin_battery, [(aaa_end)/42, 0])
    rectangular_slot_cutter([remaining_width, infill_size.y, 12], center_top=true);

    
    /*
    // Cut away the top portion of the entire slot area to make dividers shorter
    // This cuts a rectangular area covering all slots, removing the top portion
    total_slots_depth = num_slots * slot_depth + (num_slots - 1) * divider_width;
    slot_area_center_y = lip_size + total_slots_depth / 2;
    cut_height = depth - cr2032_divider_height;
    
    bin_translate(bin_battery, [aaa_end/42, slot_area_center_y/42])
    translate([0, 0, -cr2032_divider_height])
    cube([remaining_width, total_slots_depth, cut_height], center=false);
    */
}

