$fn=100;

include<primitives.scad>;

// This file describes an enclosure for the Ubuntu VGA switch
// in openscad format, suitable for 3d printing

// Copyright 2012, Canonical, Inc
// Released under the Apache 2.0 license

// All dimensions in mm

// screw sizes
n6clearance_radius = 1.905;
n6tapping_radius = 1.6;

//
// case sizing
//
edge_clearance   = 2.0; // clearance between board edges and inside of case wall
wall_thk         = 3.0; // case wall thickness
base_thk         = 3.0; // case bottom thickness
bottom_clearance = 3.0; // clearance between case bottom and board, to clear compontent leads
top_clearance    = 15.0; // clearance above board
top_thk          = 3.0; // thickness of case top
lip_w            = 2.0; // width of lip on bottom inside top
lip_h            = 2.0; // height of lip

//
// board dimensions
//
bd_x            = 64.44; // Board X size
bd_y            = 63.5;   // Board Y size
bd_thk          = 1.58;  // board thickness
support_inset   = 7.5;   // how far in the corner supports come under the board
// Gaaah. Hole offsets are not the same from left and right edges of board
// So - hole locations are referenced from the bottom left corner of the board
bd_xoff = -bd_x/2;
bd_yoff = -bd_y/2;

// The problem is that the board center is not in the case center because of 
// the way the holes are placed

//bd_xoff = -(bd_x+edge_clearance)/2;
//bd_yoff = -(bd_y+edge_clearance)/2;

hlox = bd_xoff+3.81;
hloy = bd_yoff+3.81;
hhix = bd_xoff+60.96;
hhiy = bd_yoff+57.34;

//
// Calculated values for convenience, don't edit
//
holes = [[hlox,hloy],[hhix,hloy],[hlox,hhiy],[hhix,hhiy]];
outside_x = bd_x + 2*(edge_clearance+wall_thk);
outside_y = bd_y + 2*(edge_clearance+wall_thk);
inside_x = outside_x-wall_thk;
inside_y = outside_y-wall_thk;

support_clearance = support_inset+edge_clearance;

//
// The base part, without the holes
//
module basesolid() {
	union() {
		// a flat base plate
		translate([0,0,base_thk/2])
			cube([outside_x,outside_y,base_thk], center=true);
		// The lip just inside the top
		translate([0,0,(lip_h/2)+base_thk])
			difference() {
				cube([inside_x,inside_y,lip_h], center=true);
				cube([inside_x-(2*lip_w),inside_y-(2*lip_w),lip_h], center=true);
			}
		// The corner supports for the board
		difference() {
			translate([0,0,(bottom_clearance/2)+base_thk])
				cube([outside_x-wall_thk,outside_y-wall_thk,bottom_clearance], center=true);
			union() {
				// remove the center areas to leave square supports
				translate([0,0,(bottom_clearance/2)+base_thk])
					cube([bd_x-(2*support_clearance), outside_y+2, bottom_clearance+2], center=true);
				translate([0,0,(bottom_clearance/2)+base_thk])
					cube([inside_x+2, bd_y-(2*support_clearance), bottom_clearance+2], center=true);
			}
		}
	}
}

module baseholes() {
	union() {
		for (hole = holes) {
			translate(hole)
				cylinder(r=n6clearance_radius, h=10);
		}
	}
}

module base() {
	difference() {
		basesolid();
		baseholes();
	}
}

base();