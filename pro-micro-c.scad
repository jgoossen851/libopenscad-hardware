
// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

pro_micro_c();

// ### Module ########################################################

module pro_micro_c() {
  width = 18;
  length = 37;
  height = 3.5; // Height including components (excluding USB connector)
  height_pcb = 1.6;
  width_usbc = 9.1;
  length_usbc = 7.5;
  height_usbc = 3.4;
  offset_usbc_y = 1.3; // Amount USB-C sticks off end of PCB
  offset_usbc_x = 0.9; // Amount USB-C is shifted from center (right positive)

  mount_x = -7.5; // Mount hole (if present) relative to center of USB interface plane
  mount_y = -3.1; // Mount hole (if present) relative to center of USB interface plane
  mount_d = 1.3;
  
  // USB-C connector
  color("Silver")
  translate([0, -length_usbc / 2, 0])
  cube([width_usbc, length_usbc, height_usbc], center = true);

  // PCB
  difference() {
    color("Teal")
    translate([-width/2 - offset_usbc_x, -length - offset_usbc_y, -height_pcb - height_usbc/2])
    cube([width, length, height_pcb]);

    translate([mount_x, mount_y, 0])
    cylinder(h = 3*height_usbc, d = mount_d, center = true);
  }

  // PCB components (clearance)
  color("DimGray")
  translate([-width/2 - offset_usbc_x,  -length - offset_usbc_y, -height_usbc/2])
  cube([width, length - length_usbc + offset_usbc_y, height - height_pcb]);
}
