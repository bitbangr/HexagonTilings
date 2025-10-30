// ------------------------------------------------------------
// Full ring adjacency test around A (pointy-top hex, start 30°)
// A at origin; B,C,D,E,F,G placed so each A edge i touches
// neighbor edge (i+3) mod 6.
// ------------------------------------------------------------

s = 20;                // side length (also radius)
thickness = 1.2;       // extrusion height
label_size = 3;
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
        color("red")
        translate([p[0], p[1], thickness])
            cylinder(h=0.6, r=0.6, $fn=18);
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

// ------------------------ Neighbor vectors ------------------
// Pointy-top axial->pixel (q,r):
// x = s*sqrt(3)*(q + r/2),  y = s*1.5*r
// Around A (counter-clockwise from E):
dxE =  sqrt(3)*s;     dyE =  0;        // (q=1,  r=0)  -> A(5–0)
dxG =  sqrt(3)/2*s;   dyG = -1.5*s;    // (q=1,  r=-1) -> A(4–5)
dxF = -sqrt(3)/2*s;   dyF = -1.5*s;    // (q=0,  r=-1) -> A(3–4)
dxD = -sqrt(3)/2*s;   dyD =  1.5*s;    // (q=-1, r=1)  -> A(1–2)
dxW = -sqrt(3)*s;     dyW =  0;        // (q=-1, r=0)  -> A(2–3)
dxB =  sqrt(3)/2*s;   dyB =  1.5*s;    // (q=0,  r=1)  -> A(0–1)

echo("B (NE): ", [dxB,dyB], " matches A(0–1) ↔ B(3–4)");
echo("C (E):  ", [dxE,dyE], " matches A(5–0) ↔ C(2–3)");
echo("D (NW): ", [dxD,dyD], " matches A(1–2) ↔ D(4–5)");
echo("E (W):  ", [dxW,dyW], " matches A(2–3) ↔ E(5–0)");
echo("F (SW): ", [dxF,dyF], " matches A(3–4) ↔ F(0–1)");
echo("G (SE): ", [dxG,dyG], " matches A(4–5) ↔ G(1–2)");

// ------------------------ Draw tiles ------------------------
// A at origin
hex3d(s, col=[1,0.84,0], alpha=1.0);           // A: gold
label_vertices("A", s);

// Highlight all six A edges (optional: comment out if noisy)
highlight_edge(s, 0, col=[0,0.5,1]);
highlight_edge(s, 1, col=[0,0.5,1]);
highlight_edge(s, 2, col=[0,0.5,1]);
highlight_edge(s, 3, col=[0,0.5,1]);
highlight_edge(s, 4, col=[0,0.5,1]);
highlight_edge(s, 5, col=[0,0.5,1]);

// B for A(0–1) ↔ B(3–4)
translate([dxB, dyB, 0]) {
    hex3d(s, col=[1,0.55,0], alpha=0.65);      // B: orange
    label_vertices("B", s);
    highlight_edge(s, 3, col=[0,0.5,1]);
}

// C for A(5–0) ↔ C(2–3)
translate([dxE, dyE, 0]) {
    hex3d(s, col=[0.2,0.8,0.6], alpha=0.65);   // C: teal
    label_vertices("C", s);
    highlight_edge(s, 2, col=[0,0.5,1]);
}

// D for A(1–2) ↔ D(4–5)
translate([dxD, dyD, 0]) {
    hex3d(s, col=[0.6,0.7,1.0], alpha=0.65);   // D: light blue
    label_vertices("D", s);
    highlight_edge(s, 4, col=[0,0.5,1]);
}

// E for A(2–3) ↔ E(5–0)
translate([dxW, dyW, 0]) {
    hex3d(s, col=[0.85,0.6,0.95], alpha=0.65); // E: lavender
    label_vertices("E", s);
    highlight_edge(s, 5, col=[0,0.5,1]);
}

// F for A(3–4) ↔ F(0–1)
translate([dxF, dyF, 0]) {
    hex3d(s, col=[0.95,0.75,0.5], alpha=0.65); // F: peach
    label_vertices("F", s);
    highlight_edge(s, 0, col=[0,0.5,1]);
}

// G for A(4–5) ↔ G(1–2)
translate([dxG, dyG, 0]) {
    hex3d(s, col=[0.4,0.9,0.9], alpha=0.65);   // G: aqua
    label_vertices("G", s);
    highlight_edge(s, 1, col=[0,0.5,1]);
}

// Mark centers
color("crimson") translate([0,0,thickness]) sphere(r=0.6);            // A
color("crimson") translate([dxB,dyB,thickness]) sphere(r=0.6);        // B
color("crimson") translate([dxE,dyE,thickness]) sphere(r=0.6);        // C
color("crimson") translate([dxD,dyD,thickness]) sphere(r=0.6);        // D
color("crimson") translate([dxW,dyW,thickness]) sphere(r=0.6);        // E
color("crimson") translate([dxF,dyF,thickness]) sphere(r=0.6);        // F
color("crimson") translate([dxG,dyG,thickness]) sphere(r=0.6);        // G
