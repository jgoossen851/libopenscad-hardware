
// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

pro_micro_c();

// ### Module ########################################################

eps = 0.01;
width = 18; // 0.7 * 25.4 (+0.22)
length = 37; // 1.3 * 25.4 (+3.98)
height = 3.5; // Height including components (excluding USB connector)
height_pcb = 1.6;
width_usbc = 9.1;
length_usbc = 7.5;
height_usbc = 3.4;
offset_usbc_y = 0.05*25.4; // Amount USB-C sticks off end of PCB
offset_usbc_x = 0.5; // Amount USB-C is shifted from center (right positive)
pin_header_width = 2.54;

mount_x = -7.5; // Mount hole (if present) relative to center of USB interface plane
mount_y = -3.1; // Mount hole (if present) relative to center of USB interface plane
mount_d = 1.3;

module pro_micro_c(mount = true) {
  
  // USB-C connector
  color("Silver")
  pro_micro_usbc();

  // PCB
  difference() {
    color("Teal")
    pro_micro_pcb();

    if (mount == true)
    translate([mount_x, mount_y, 0])
    cylinder(h = 3*height_usbc, d = mount_d, center = true);
  }

  // PCB components (clearance)
  comp_width = width - 2*pin_header_width;
  comp_length = length - length_usbc + offset_usbc_y;
  color("DimGray")
  translate([-comp_width/2 - offset_usbc_x, -comp_length - length_usbc, -height_usbc/2])
  cube([comp_width, comp_length + eps, height - height_pcb]);
}

module pro_micro_pcb(offset_xy = 0) {
  translate([0, 0, -height_pcb - height_usbc/2])
  linear_extrude(height = height_pcb)
  offset(delta = offset_xy)
  translate([-width/2 - offset_usbc_x, -length - offset_usbc_y])
  square([width, length]);
}

module pro_micro_usbc(offset_xy = 0) {
  linear_extrude(height = height_usbc, center = true)
  offset(delta = offset_xy)
  translate([0, -length_usbc / 2])
  square([width_usbc, length_usbc], center = true);
}
