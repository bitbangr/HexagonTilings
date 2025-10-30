// ------------------------------------------------------------
// Hex adjacency test: A at origin,
// B translated to touch A(0–1) ↔ B(3–4),
// C translated to touch A(5–0) ↔ C(2–3).
// Vertex numbering 0..5, pointy-top (start angle 30°).
// ------------------------------------------------------------

s = 20;                // side length (also radius)
thickness = 1.2;       // extrusion height
label_size = 3;        // 2D text size
edge_highlight_w = 0.9;

// ------------------------ Helpers ---------------------------
function hex_pts(side) = [
    for (i = [0:5]) [ side*cos(30 + i*60), side*sin(30 + i*60) ]
];

module hex2d(side) {
    polygon(points = hex_pts(side));
}

module hex3d(side, col=[1,0.84,0], alpha=1.0) {
    color(col, alpha)
    linear_extrude(height = thickness)
        hex2d(side);
}

module label_vertices(prefix, side) {
    pts = hex_pts(side);
    for (i = [0:5]) {
        p = pts[i];
        // vertex marker
        color("red")
        translate([p[0], p[1], thickness])
            cylinder(h=0.6, r=0.6, $fn=18);
        // label text
        color("black")
        translate([p[0], p[1], thickness + 0.65])
            linear_extrude(height=0.4)
                text(str(prefix, " ", i), size=label_size, halign="center", valign="center");
    }
}

module highlight_edge(side, i, col=[0,0.5,1]) {
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

// ------------------------ Scene -----------------------------

// Neighbor translations for pointy-top hex (center-based)
dx_B = sqrt(3)/2 * s;   // NE neighbor
dy_B = 1.5 * s;

dx_C = sqrt(3) * s;     // E neighbor (right)
dy_C = 0;

echo("B translation (dx,dy) = ", [dx_B, dy_B], "  -> matches A(0–1) with B(3–4)");
echo("C translation (dx,dy) = ", [dx_C, dy_C], "  -> matches A(5–0) with C(2–3)");

// A at origin
hex3d(s, col=[1,0.84,0], alpha=1.0);     // gold-ish
label_vertices("A", s);

// Highlight A edges that are in contact
highlight_edge(s, 0, col=[0,0.5,1]);     // A(0–1) for B contact (blue)
highlight_edge(s, 5, col=[0,0.5,1]);     // A(5–0) for C contact (blue)

// B translated to contact A(0–1) ↔ B(3–4)
translate([dx_B, dy_B, 0]) {
    hex3d(s, col=[1,0.55,0], alpha=0.6); // orange, semi-transparent
    label_vertices("B", s);
    highlight_edge(s, 3, col=[0,0.5,1]); // B(3–4) in blue
}

// C translated to contact A(5–0) ↔ C(2–3)
translate([dx_C, dy_C, 0]) {
    hex3d(s, col=[0.2,0.8,0.6], alpha=0.6); // teal/green, semi-transparent
    label_vertices("C", s);
    highlight_edge(s, 2, col=[0,0.5,1]);    // C(2–3) in blue
}

// Optional: mark centers
color("crimson") translate([0,0,thickness]) sphere(r=0.6);                // A center
color("crimson") translate([dx_B,dy_B,thickness]) sphere(r=0.6);          // B center
color("crimson") translate([dx_C,dy_C,thickness]) sphere(r=0.6);          // C center
