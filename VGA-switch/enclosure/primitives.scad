// create a countersink cone with the large flat side centered at the axes
// and pointed down
module countersink(hole_radius, angle, depth) {
   halfangle = angle/2;
   largeradius = hole_radius+(sin(halfangle)*depth);
   translate([0,0,-(depth/2)])
      cylinder(h=depth,r1=hole_radius, r2=largeradius, center=true);
}

// Create a countersink at the bottom of a larger hole
// the depth is from the surface to the 'top' of the countersink
module recessed_countersink(small_radius, large_radius, countersink_depth, angle=80) {
   csh = 1/((large_radius-small_radius)*sin(angle/2));
   union() {
      translate([0,0,-(countersink_depth+csh/2)])
         cylinder(h=csh,r1=small_radius, r2=large_radius, center=true);
      translate([0,0,-(countersink_depth)])
         cylinder(h=countersink_depth+.1, r=large_radius);
	}
}

//recessed_countersink(1.9, 3.375, 1);