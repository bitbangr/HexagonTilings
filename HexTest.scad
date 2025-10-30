// ------------------------------------------------------------
// Hexagon adjacency test
// Draws two identical regular hexagons A and B
// Both start centered at [0,0]
// B is translated by (√3/2 * s, 1.5 * s)
// ------------------------------------------------------------

// === Parameters ===
s = 20;                // side length (also radius)
thickness = 1;         // extrusion height
show_labels = true;

// === Base hexagon ===
module hex2d(side) {
    polygon([for (i = [0:5])
        [side * cos(30 + i * 60), side * sin(30 + i * 60)]
    ]);
}

module hex3d(side) {
    linear_extrude(height = thickness)
        hex2d(side);
}

// === Draw reference A (centered) ===
color("gold")
hex3d(s);

// === Draw second hex B, translated ===
dx = sqrt(3)/2 * s;
dy = 1.5 * s;

color("orange", 0.6)
translate([dx, dy, 0])
hex3d(s);

// === Optional labels and guides ===
if (show_labels) {
    color("red") {
        translate([0, 0, thickness]) sphere(0.5);                // center A
        translate([dx, dy, thickness]) sphere(0.5);              // center B
    }
    echo("Translation (dx, dy): ", [dx, dy]);
    echo("Expected contact: edge A(0–1) ↔ edge B(3–4)");
}
