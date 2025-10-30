// ------------------------------------------------------------
// Hexagon adjacency test with vertex labels
// A at origin, B translated by (√3/2 * s, 1.5 * s)
// Vertex numbering: 0..5 (matching your scheme)
// ------------------------------------------------------------

s = 20;                // side length (also radius)
thickness = 1.2;       // extrusion height
label_size = 3;        // 2D text size
edge_highlight_w = 0.9;

// ------------------------------------------------------------
// Geometry helpers
// ------------------------------------------------------------
function hex_pts(side) = [ for (i = [0:5]) [ side*cos(30 + i*60), side*sin(30 + i*60) ] ];

module hex2d(side) {
    polygon(points = hex_pts(side));
}

module hex3d(side, col=[1,0.84,0], alpha=1.0) {
    color(col, alpha)
    linear_extrude(height = thickness)
        hex2d(side);
}

module label_vertices(name, side) {
    pts = hex_pts(side);
    // small marker at each vertex + label above it
    for (i = [0:5]) {
        p = pts[i];
        // vertex marker
        color("red")
        translate([p[0], p[1], thickness])
            cylinder(h=0.6, r=0.6, $fn=18);

        // label text (lifted slightly above marker)
        color("black")
        translate([p[0], p[1], thickness + 0.65])
            linear_extrude(height=0.4)
                text(str(name, " ", i), size=label_size, halign="center", valign="center");
    }
}

module highlight_edge(side, i, col=[0,0.5,1]) {
    // draws a thin extruded rectangle along edge (i -> i+1)
    pts = hex_pts(side);
    p0 = pts[i];
    p1 = pts[(i+1)%6];
    d  = [p1[0]-p0[0], p1[1]-p0[1]];
    len = sqrt(d[0]*d[0] + d[1]*d[1]);
    ang = atan2(d[1], d[0]);

    color(col)
    translate([p0[0], p0[1], thickness+0.2])
        rotate([0,0,ang])
            translate([len/2, 0, 0])
                linear_extrude(height=0.4)
                    square([len, edge_highlight_w], center=true);
}

// ------------------------------------------------------------
// Scene
// ------------------------------------------------------------

// Centers
dx = sqrt(3)/2 * s;
dy = 1.5 * s;

echo("Translation (dx, dy) = ", [dx, dy]);
echo("Expected contacting edges:  A(0–1)  with  B(3–4)");

// Hex A at origin
hex3d(s, col=[1,0.84,0], alpha=1.0);     // gold-ish
label_vertices("A", s);
highlight_edge(s, 0, col=[0,0.5,1]);     // A(0–1) in blue

// Hex B translated
translate([dx, dy, 0]) {
    hex3d(s, col=[1,0.55,0], alpha=0.6); // orange, semi-transparent
    label_vertices("B", s);
    highlight_edge(s, 3, col=[0,0.5,1]); // B(3–4) in blue
}

// Optional: mark centers
color("crimson") translate([0,0,thickness]) sphere(r=0.6);
color("crimson") translate([dx,dy,thickness]) sphere(r=0.6);
