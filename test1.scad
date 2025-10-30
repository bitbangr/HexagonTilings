//union() {          // add shapes
//  cube(10);
//  translate([5, 5, 5]) sphere(15);
//}
//
//*difference() {     // subtract
//  cube(20);
//  cylinder(h=20, r=5);
//}
//
//*intersection() {   // overlap only
//  sphere(10);
//  cube(15);
//}

//union(){
//for(i=[0:36])
//    translate([i*5,0,0])
//       cylinder(r=5,h=cos(i*10)*50+60);
//
//cube([100,50,150]);
//}

*union() {
  for(i = [0:36])
    translate([i*5, 0, 0])
      cylinder(r=5, h=cos(i*10)*50 + 60, $fn=64);

  // overlap cube slightly so it fuses cleanly
  translate([-0.1, 0, 0]) cube([100.2, 50, 150]);
}

translate([10,0,0]) polygon(60);