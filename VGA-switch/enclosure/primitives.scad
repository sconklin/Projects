// create a countersink cone with the large flat side centered at the axes
// and pointed down
module countersink(hole_radius, angle, depth) {
   halfangle = angle/2;
   largeradius = hole_radius+(sin(halfangle)*depth);
   translate([0,0,-(depth/2)])
      cylinder(h=depth,r1=hole_radius, r2=largeradius, center=true); 
}
