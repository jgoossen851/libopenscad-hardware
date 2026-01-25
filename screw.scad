// Parametric screw and bolt models for hole negatives

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

// Test print, with horizontal and vertical screw holes
//   Heads:   flat, hex, lag, pan, cap, carriage, nut, washer
//   Sizes:   no4, no6, no8, no10, M3
//   Threads: nominal, loose, threaded
head = "cap";
size = "M3";
thread = "threaded";

// Nominal test print
screw_calibration(head = head, size = size, thread = thread);

// Over- & Under-sized test prints
// (then modify tables below with best-fitting value)
delta = 0.1;
nomD = screw_dims(size = size, thread = "nominal")[0];
moduleSep = 4.7 * nomD;
for (ix = [-1, 1]) {
  translate([ix*moduleSep, 0, 0])
  screw_calibration(head = head, size = size, thread = thread, adjust = ix * delta);

  // Labels: "+"/"-"
  rotate([90, 0, ix*90])
  translate([0, 0, 5*nomD/2 + moduleSep])
  linear_extrude(height = 0.5, center = true)
  text(ix < 0 ? "-" : "+",  size = 3*nomD, halign = "center");
}

// Display some sample configurations
translate([0, 20, 0])
%samples(thread = "nominal");

module samples(thread) {
  translate([10, 0, 0])
  screw("cap", "M3", 16, thread);
  translate([10, 0, -10])
  screw("nut", "M3", thread = thread);

  translate([20, 0, 0])
  screw("flat", "no4", 1/2, thread, taper = true);
  translate([30, 0, 0])
  screw("flat", "no6", 1/2, thread, taper = true);
}

// Demonstrate access to internal parameters with the screw_dims() function:
echo(["threadD", "headD", "headH", "nutW"]);
echo(screw_dims("cap", "M3", "loose"));


// ### Module ########################################################

// Test Bed for tuning dimension tables to printer
module screw_calibration( head = "cap", size = "M3", thread = "threaded", adjust = 0) {
  difference() {
    // Read nominal dimensions
    dims = screw_dims(size = size, thread = "nominal");
    diameter_shaft  = dims[0];
    diameter_head   = dims[1];
    height_head     = dims[2];
    width_nut       = dims[3];

    // Set test-block dimensions
    dx = diameter_shaft * 5;
    dy = min(diameter_head * 1.75, diameter_head + 4);
    dz = min(diameter_head * 1.5, diameter_head + 2);

    inset = head == "cap" ? height_head
          : head == "hex" ? height_head
          : head == "nut" ? 0.8 * diameter_shaft
          :                 0;

    // translate([0, 0, -dz])
    linear_extrude(height = dz)
    square([dx, dy], center = true);

    // Vertical screw
    translate([diameter_shaft, 0, dz - inset]) {
      screw(head = head, size = size, length = dx, thread = thread, adjust = adjust);
      %screw(head = head, size = size, length = dx, thread = "nominal");
    }

    // Horizontal screw
    translate([-diameter_shaft, dy/2 - inset, dz/2])
    rotate([-90, 90, 0]){
      screw(head = head, size = size, length = dx, thread = thread, adjust = adjust);
      %screw(head = head, size = size, length = dx, thread = "nominal");
    }
  }
}

// Dimensions

// * Heads (string)
// flat      : Countersunk
// hex       : Hex head with flange
// lag       : Hex head with no flange
// pan       : Rounded top
// cap       : Socket type head
// carriage  : Rounded top with square drive below
// nut       : Hex nut
// washer    : Washer

// * Sizes (string)
// M3, M5, etc.   : Metric
// no6, no8, etc. : ANSI

// * Thread (string)
// nominal  : dimensions of bolt
// loose    : bolt clearance without engagement
// threaded : tight clearance allowing threads to be cut

// * Adjust
//   Amount to add (or subtract) from all dimensions to account for additional
//   desired clearances
function screw_dims(head, size, thread = "nominal", adjust = 0) =
  // Dimensions: [nominal, threaded, loose]
  let( tt = ( thread == "threaded" )  ? 1
          : ( thread == "loose" )     ? 2
          :                             0
  )
  let( ss = ( size == "M3" )   ? 1
          : ( size == "no4" )  ? 2
          : ( size == "no6" )  ? 3
          : ( size == "no8" )  ? 4
          : ( size == "no10" ) ? 5  // #10 machine
          :                      0
  )
  // https://www.boltdepot.com/fastener-information/machine-screws/machine-screw-diameter.aspx
  let( threadD = [
  //    n    t    l
    [    1,    1,    1],  // default
    [    3,  2.6,  3.6],  //? M3 coarse
    [ 2.85,  2.4,  3.5],  //? #4 wood
    [ 3.51,  3.1,  4.1],  //? #6 wood
    [ 4.17,  3.8,  4.8],  //? #8 wood
    [4.826, 4.40, 5.00],  //? #10 machine
  ] )
  // https://www.mcfeelys.com/screw_size_comparisons
  let( headD = [
  //     n    t    l
    [    1,    1,    1],  // default
    [  5.3,    6,    6],  // M3 coarse
    [5.715,  6.3,  6.3],  // #4 wood
    [7.087,  7.6,  7.6],  // #6 wood
    [8.433,  9.1,  9.1],  // #8 wood
    [ 0.00, 0.00, 0.00],  //? #10 machine
  ] )
  let( headH = [
  // n    t    l
    [   1,    1,    1],  // default
    [   3,  3.5,  3.5],  // M3 coarse
    [   1,    1,    1],  //? #4 wood
    [   1,    1,    1],  //? #6 wood
    [   1,    1,    1],  //? #8 wood
    [0.00, 0.00, 0.00],  //? #10 machine
  ] )
  let( nutW = [ // (flat-to-flat)
  //   n    t    l
    [   1,    1,    1],  // default
    [ 5.5,  6.0,  6.1],  // M3 coarse
    [   1,    1,    1],  //? #4 wood
    [   1,    1,    1],  //? #6 wood
    [   1,    1,    1],  //? #8 wood
    [0.00, 0.00, 0.00],  //? #10 machine
  ] )
  [ threadD[ss][tt], headD[ss][tt], headH[ss][tt], nutW[ss][tt] ]
    + adjust * [1, 1, 1, 1];

// Screws

// Heads
// flat      : Countersunk
// hex       : Hex head with flange
// lag       : Hex head with no flange
// pan       : Rounded top
// cap       : Socket type head
// carriage  : Rounded top with square drive below
// nut       : Hex nut
// washer    : Washer

// Sizes
// M3, M5, etc.   : Metric
// no6, no8, etc. : ANSI

// Length
// Length in mm (metric) or inches (ANSI)

// Thread
// nominal  : dimensions of bolt
// loose    : bolt clearance without engagement
// threaded : tight clearance allowing threads to be cut
module screw(head, size, length = 10, thread = "nominal", taper = false, adjust = 0) {
  eps = 0.01;
  inch2mm = 25.4;

  dims = screw_dims(head, size, thread = thread, adjust = adjust);
  threadD = dims[0];
  headD = dims[1];
  headH = dims[2];

  // Convert imperial to metric, adjust for cap/clearance
  l = length
        * (( size == "no4" || size == "no6" || size == "no8" )  ? inch2mm : 1)
        + (( head == "cap" || head == "hex" )                   ? headH   : 0)
        + (( thread == "nominal" )                              ? 0       : 0.5);
  h = ( head == "flat" )  ? (headD - threadD) / 2 / tan(40) : headH;
  t = taper ? 1.0*threadD : 0;

  if ( head == "cap" || head == "flat" || head == "hex"  ) {
    // Scale the given threaded radius for the pentagon circumradius
    scaleD = thread == "threaded" ? 1 / cos (180 / 5) : 1;

    // Convert side-to-side diameter to corner-to-corner
    // Assume that the side-to-side hex width (inscribed diameter) is the same as the socket cap diameter
    scaleOD = head == "hex" ? 2 / sqrt(3) : 1;

    // Head
    rotate([0, 0, 90])
    rotate_extrude($fn = head == "hex" ? 6 : 0)
    screw_headProfile(head = head, id = scaleD * threadD, od = scaleOD * headD, l = l, h = h, t = t, thread = thread);

    // Shaft
    rotate_extrude($fn = thread == "threaded" ? 5 : 0)
    screw_shaftProfile(head = head, id = scaleD * threadD, od = headD, l = l, h = h, t = t, thread = thread);

  } else if ( head == "nut" ) {
    nominalDims = screw_dims("cap", size, "nominal");
    nutW = dims[3];
    nutH = 0.8 * nominalDims[0];
    difference() {
      rotate_extrude($fn = 6)
      screw_headProfile(head = "cap", od = nutW / sqrt(3) * 2, h = nutH);
      
      if ( thread == "nominal" ) {
        cylinder( h = 3*nutH, d = nominalDims[0]);
      }
    }

  } else {
    assert(false, "Screw head is not yet supported");
  }
}

module screw_shaftProfile(head, id = 0, od, l = 0, h, t = 0, thread = "nominal") {
  eps = 0.01;
  pts = [
    // 0-3-,  Origin
    // | .-'
    // | |
    // | 2    Taper
    // 1'     Base
    [0, 0],
    [0, -l - eps],
    [id / 2, -l - eps + t],
    [id / 2, 0]
  ];

  translate([0, (head == "cap" || head == "hex" ? h : 0) + eps])
  polygon(
    points = pts,
    paths = [[0, 1, 2, 3]],
    convexity = 1
  );
}

module screw_headProfile(head, id = 0, od, l = 0, h, t = 0, thread = "nominal") {
  eps = 0.01;
  pts = [
    // 6 - 5  Installation Clearance
    // `   `
    // 0---4  Origin
    // 1 2-3  Cap/Countersink Depth
    // 7 |
    // | |
    // |'
    [0, 0],
    [0, -h],
    [id / 2, -h],
    [od / 2, -h],
    [od / 2, 0],
    [od / 2, l],
    [0, l],
    [0, -h - 3*id/2]
  ];

  if ( head == "cap" || head == "hex") {
    translate([0, h + eps])
    polygon(
      points = pts,
      paths = [
          (thread == "nominal")  ? [0, 1, 3, 4]
        : (thread == "threaded") ? [6, 7, 2, 3, 5]
        :                          [6, 1, 3, 5]
      ],
      convexity = 1
    );
  } else if ( head == "flat" ) {
    translate([0, eps])
    polygon(
      points = pts,
      paths = [
          (thread == "nominal")  ? [0, 1, 2, 4]
        : (thread == "threaded") ? [6, 7, 2, 4, 5]
        :                          [6, 1, 2, 4, 5]
      ],
      convexity = 1
    );
  }
}
