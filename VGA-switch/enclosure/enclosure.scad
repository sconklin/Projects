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
head_clearance_r = 3.5;

//
// case sizing
//
edge_clearance   = 0.3; // clearance between board edges and inside of case wall
wall_thk         = 3.0; // case wall thickness
base_thk         = 2.0; // case bottom thickness
bottom_clearance = 3.0; // clearance between case bottom and board, to clear compontent leads
top_clearance    = 15.0; // clearance above board
top_thk          = 2.0; // thickness of case top
lip_w            = 2.0; // width of lip on bottom inside top
lip_h            = 2.0; // height of lip
logo_thk         = -0.1; // thickness of the thin parts of the lid (0.8 is the solid shell)


//
// board dimensions
//
bd_x            = 64.44; // Board X size
bd_y            = 63.5;  // Board Y size
bd_thk          = 1.40;  // board thickness
support_radius   = 4.0;  // How big the board supports are

// Gaaah. Hole offsets are not the same from left and right edges of board
// So - hole locations are referenced from the bottom left corner of the board
// Adjust the hole location, because the board is centered
bd_xoff = -bd_x/2;
bd_yoff = -bd_y/2;

// The problem is that the board center is not in the case center because of 
// the way the holes are placed

hlox = bd_xoff+(.15*25.4); // .15 inches
hloy = bd_yoff+(.15*25.4);
hhiy = bd_yoff+(2.35*25.4);
hhix = bd_xoff+(2.4*25.4);

//
// Calculated values for convenience, don't edit
//
holes = [[hlox,hloy],[hhix,hloy],[hhix,hhiy],[hlox,hhiy]];
outside_x = bd_x + 2*(edge_clearance+wall_thk);
outside_y = bd_y + 2*(edge_clearance+wall_thk);
inside_x = outside_x-wall_thk;
inside_y = outside_y-wall_thk;
top_height = bottom_clearance+bd_thk+top_clearance+top_thk; // height of actual top piece

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
		// The supports for the board
		intersection() {
			// Limit the supports to the inside dimension of the case
			translate([0,0,(base_thk+bottom_clearance)/2])
				cube([inside_x,inside_y,base_thk+bottom_clearance], center=true);
			// The block supports for the board
			for (i = [0 : 3]) {
				translate(holes[i]) {
					translate([0,0,base_thk])
					rotate([0,0,(i*90)+180])
						minkowski() {
							cylinder(r=support_radius, h=bottom_clearance/2);
							cube([5, 5, bottom_clearance/2]);
						}
				}
			}
		}
	}
}

//
// All the holes to be made in the base
//
module baseholes() {
	union() {
		for (i = [0 : 3] ) {
			translate(holes[i]) {
				cylinder(r=n6clearance_radius, h=12);
				rotate([0,180,0])
					recessed_countersink(n6clearance_radius, head_clearance_r, base_thk);
			}
		}
	}
}

module base() {
	difference() {
		basesolid();
		baseholes();
	}
}

//
// End of base, begin top components
//

module topsolid() {
	// Build the top in place in the same location as the bottom, keeping everything aligned
	top_remove_h = top_height-top_thk;
	union() {
		// the basic shell
		difference() {
			// The outside box for the top
			translate([0,0,(top_height/2)+base_thk])
				cube([outside_x,outside_y,top_height], center=true);
			// The hole removed from the center
			translate([0,0,(top_remove_h/2)+base_thk])
				cube([inside_x,inside_y,top_remove_h], center=true);
		}
		// The screw supports and board retainer
		intersection() {
			// Limit the supports to the inside dimension of the case
			translate([0,0,top_height/2])
				cube([inside_x,inside_y,top_height], center=true);
			// The block supports for the board
			for (i = [0 : 3]) {
				translate(holes[i]) {
					translate([0,0,base_thk+bottom_clearance+bd_thk])
					rotate([0,0,(i*90)+180])
						minkowski() {
							cylinder(r=support_radius, h=top_clearance/2);
							cube([5, 5, top_clearance/2]);
						}
				}
			}
		}
	}
}

//
// For holes in the sides, we set these up so the y=0 plane of the hole
// is what should be aligned with the board edge, the hole is centered on x=0,
// and z=0 should be aligned at the top of the PC board
//

module generic_hole(w, h, d) {
	// h is height above the board, bottom of hole will extend to edge of top
	hole_h = h + bd_thk +bottom_clearance;
	translate([-w/2,-d,base_thk])
		cube([w,d,hole_h]);
}

module switch_hole() {
	// along the front face, 14mm from the left end of the board
	translate([14-(bd_x/2),-bd_y/2,0])
		generic_hole(w = 16, h = 7, d = 12);
}

module vga_hole() {
	// centered 33mm up from the edge of the board
	translate([-bd_x/2,1.2,0])
		rotate([0,0,-90])
			generic_hole(w = 32, h = 13, d = 10);
}

module power_hole() {
	// w=9.7, h=11.5, d=4
	// 14mm from left end of board, on the back of the case
	translate([14-(bd_x/2),bd_y/2,0])
		rotate([0,0,180])
			generic_hole(w = 9.7, h = 11.5, d = 6);

}

module topholes() {
	union() {
		// The holes for self-tapping screws
		for (hole = holes) {
			translate(hole) {
				cylinder(r=n6tapping_radius, top_height);
			}
		}
		// The parts that stick out
		switch_hole();
		vga_hole();
		mirror([1,0,0])
			vga_hole();
		power_hole();

		// The Ubuntu circle of friends
		translate([0,0,top_clearance+base_thk+bd_thk+bottom_clearance+top_thk-logo_thk])
			rotate([180,0,0])
				scale([0.2,0.2,1.0])
					import("ubuntu.stl", convexity=5);
	}
}

module top() {
	rv = 180;
	tv = -(top_height+base_thk);
	//rv = 0;
	//tv = 0;
	rotate([rv,0,0])
		translate([0,0,tv])
			difference() {
				topsolid();
				topholes();
			}
}

color("White")
	base();

//color("OrangeRed")
//	top();
