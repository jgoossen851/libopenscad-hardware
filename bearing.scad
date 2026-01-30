// Parametric bearing and bearing profile models

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

// Supported Bearings
//  608, 623

translate([-20, 0, 0])
Bearing("608");

translate([20, 0, 0])
rotate_extrude()
Bearing_Profile("608", cutout = true);


// ### Parameters ####################################################

// 608 Roller Bearing
bearing608_id = 8;
bearing608_od = 22;
bearing608_w  = 7;

// 623 Roller Bearing
bearing623_id = 3;
bearing623_od = 10;
bearing623_w  = 4;


// ### Module ########################################################

module Bearing (type, cutout = false) {
  color("Silver")
  rotate_extrude(convexity = 3)
  Bearing_Profile (type = type, cutout = cutout);
}

module Bearing_Profile (type, cutout = false) {
  if (type == "608") {
    Bearing_Dims_Profile(id = bearing608_id, od = bearing608_od, h = bearing608_w, cutout = cutout);
  } else if (type == "623") {
    Bearing_Dims_Profile(id = bearing623_id, od = bearing623_od, h = bearing623_w, cutout = cutout);
  } else {
    Bearing_Dims_Profile(cutout = cutout);
  }
}

module Bearing_Dims_Profile (id = 8, od = 22, h = 7, cutout = false) {
  bevel = cutout ? 0.01 : 0.5;
  w = (od - id)/2;
  difference() {
    // Body
    hull()
    for (ix = [-0.5, 0.5] * (w - 2*bevel))
    for (iy = [-0.5, 0.5] * (h - 2*bevel))
    translate([id/2 + w/2 + ix, iy])
    circle(r = bevel, $fn = 4);

    // Raceways
    if (cutout == false)
    BearingRaceways_Profile(od = od, id = id, width = w/2, separation = h, depth = 0.2);
  }

  // Add clearance around raceways
  if (cutout == true)
  BearingRaceways_Profile(od = od, id = id, width = w/2, separation = h, depth = 0.4);
}

module BearingRaceways_Profile (od = 22, id = 8, width = 3.5, separation = 7, depth = 0.4) {
  for (iy = [-separation/2, separation/2])
  translate([(od + id)/4, iy])
  square([width, 2*depth], center = true);
}
