$fn=100;
module ubuntu_inner(height=10) {
	difference() {
		// everything we want
		union() {
			cylinder(r=82, h=height);
			for (i = [0 : 120 : 300])
			{
				rotate([0,0,i])
					translate([-96.8,0,0])
						cylinder(r=19.01, h=height);
			}
		}
		// everything to take away
		union() {
			translate([0,0,-1])
				cylinder(r=54.4, h=height+2);
			for (i = [0 : 120 : 300])
			{
				rotate([0,0,i]) {
					translate([-96.8,0,-1])
						difference() {
							cylinder(r=26.7, h=height+2);
							cylinder(r=19.01, h=height+2);
						}
					translate([0,-5.06,-1])
						cube([145, 10.12, height+2]);
				}
			}
		}
	}
}

module ubuntu(uheight=10) {
	difference() {
		cylinder(r=141.625, h=uheight);
		translate([0,0,-1])
			ubuntu_inner(height=uheight+2);
	}
}

// ubuntu should display the correct logo but it crashes openscad

//ubuntu(); // this crashes
ubuntu_inner(height=20); // this works