// primitives
cube(10);
sphere(5);
cylinder(h=20, r=5);

// transformations
translate([10, 0, 0]) cube(10);
rotate([0, 0, 45]) cylinder(h=20, r=3);
scale([1, 2, 1]) sphere(5);
