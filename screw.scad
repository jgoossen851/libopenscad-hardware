// Parametric screw and bolt models for hole negatives

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

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

// Screw Previews in loose holes
#samples(thread = "nominal");

// Screw Previews in threaded holes
translate([0, 10, 0])
#samples(thread = "nominal");

difference() {
  union() {
    dx = 100;
    dy = 10;
    dz = 50;
    translate([0, 0, -dz])
    cube([dx, dy, dz]);
    translate([0, (dy - 0.6*dy)/2, 0])
    cube([dx, 0.6*dy, 5]);
  }

  samples("loose");

  translate([0, 10, 0])
  samples("threaded");
}

// Get internal parameters with the screw_dims() function:
echo(["threadD", "headD", "headH", "nutW"]);
echo(screw_dims("cap", "M3", "loose"));


// ### Module ########################################################

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
function screw_dims(head, size, thread = "nominal") =
  // Dimensions: [nominal, threaded, loose]
  let( tt = ( thread == "nominal" )   ? 0 :
            ( thread == "threaded" )  ? 1 :
                                        2 )
  let( ss = ( size == "M3" )  ? 1 :
            ( size == "no4" ) ? 2 :
            ( size == "no6" ) ? 3 :
            ( size == "no8" ) ? 4 :
                                0 )
  // https://www.boltdepot.com/fastener-information/machine-screws/machine-screw-diameter.aspx
  let( threadD = [
  //    n    t    l
    [   1,   1,   1], // default
    [   3, 3.2, 3.6], // M3 coarse
    [2.85, 2.4, 3.5], // #4 wood
    [3.51, 3.1, 4.1], // #6 wood
    [4.17, 3.8, 4.8]  // #8 wood
  ] )
  // https://www.mcfeelys.com/screw_size_comparisons
  let( headD = [
  //     n    t    l
    [    1,   1,   1], // default
    [  5.3,   6,   6], // M3 coarse
    [5.715, 6.3, 6.3], // #4 wood
    [7.087, 7.6, 7.6], // #6 wood
    [8.433, 9.1, 9.1]  // #8 wood
  ] )
  let( headH = [
  // n    t    l
    [1,   1,   1], // default
    [3, 3.5, 3.5], // M3 coarse
    [1,   1,   1], // #4 wood
    [1,   1,   1], // #6 wood
    [1,   1,   1]  // #8 wood
  ] )
  let( nutW = [ // (flat-to-flat)
  //   n    t    l
    [  1,   1,   1], // default
    [5.5, 6.0, 6.1], // M3 coarse
    [  1,   1,   1], // #4 wood
    [  1,   1,   1], // #6 wood
    [  1,   1,   1]  // #8 wood
  ] )
  [ threadD[ss][tt], headD[ss][tt], headH[ss][tt], nutW[ss][tt] ];

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
module screw(head, size, length = 10, thread = "nominal", taper = false) {
  eps = 0.01;
  inch2mm = 25.4;

  dims = screw_dims(head, size, thread = thread);
  threadD = dims[0];
  headD = dims[1];
  headH = dims[2];

  // Convert imperial to metric, adjust for cap/clearance
  l = length
        * (( size == "no4" || size == "no6" || size == "no8" )  ? inch2mm : 1)
        + (( head == "cap" )                                    ? headH   : 0)
        + (( thread == "nominal" )                              ? 0       : 0.5);
  h = ( head == "flat" )  ? (headD - threadD) / 2 / tan(40) : headH;
  t = taper ? 1.0*threadD : 0;

  if ( head == "cap" || head == "flat" ) {
    color( "Silver" )
    rotate_extrude()
    screw_profile(head = head, id = threadD, od = headD, l = l, h = h, t = t, thread = thread);

  } else if ( head == "nut" ) {
    nominalDims = screw_dims("cap", size, "nominal");
    nutW = dims[3];
    nutH = 0.8 * nominalDims[0];
    color( "Silver" )
    difference() {
      rotate_extrude($fn = 6)
      screw_profile(head = "cap", od = nutW / sqrt(3) * 2, h = nutH);
      
      if ( thread == "nominal" ) {
        cylinder( h = 3*nutH, d = nominalDims[0]);
      }
    }

  } else {
    assert(false, "Screw head is not yet supported");
  }
}


module screw_profile(head, id = 0, od, l = 0, h, t = 0, thread = "nominal") {
  eps = 0.01;
  pts = [
    // 7 - 6
    // `   `
    // 0---5
    // | 3-4
    // | |
    // | 2
    // 1'
    [0, 0],
    [0, -l - eps],
    [id / 2, -l - eps + t],
    [id / 2, -h],
    [od / 2, -h],
    [od / 2, 0],
    [od / 2, l],
    [0, l]
  ];

  if ( head == "cap" ) {
    translate([0, h + eps])
    polygon(
      points = pts,
      paths = [
        (thread == "nominal") ? [0, 1, 2, 3, 4, 5] : [7, 1, 2, 3, 4, 6]
      ],
      convexity = 1
    );
  } else if ( head == "flat" ) {
    translate([0, eps])
    polygon(
      points = pts,
      paths = [
        (thread == "nominal") ? [0, 1, 2, 3, 5] : [7, 1, 2, 3, 5, 6]
      ],
      convexity = 1
    );
  }
}
