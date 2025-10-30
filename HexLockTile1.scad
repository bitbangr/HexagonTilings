// ===== Interlocking Hexagon — fixed path + obvious tabs (OpenSCAD 2021) =====
R = 50;            // circumradius (mm)
SAMPLES = 80;      // points per edge
AMP = 35;          // tab depth (mm)  <-- make big so you can see it
SHOW_TEST_GRID = false;

// Smooth latch profile (OpenSCAD trig uses DEGREES)
function f(t) = AMP * sin(180 * t);   // 0→AMP→0

// ---- helpers ----
function ang(i) = 60 * i;
function v(a) = [cos(a), sin(a)];
function P(i) = R * v(ang(i));
function edge_start(i) = P(i);
function edge_end(i)   = P(i + 1);
function edge_nrm(i)   = v(ang(i) + 120);  // outward normal

function edge_pt(i, t, s) =
    let(p = (1 - t) * edge_start(i) + t * edge_end(i))
    p + edge_nrm(i) * (s * f(t));

// Build each edge separately (consistent CCW order)
function E0() = [ for (k = [0:SAMPLES]) edge_pt(0, k/SAMPLES, +1) ];
function E1() = [ for (k = [0:SAMPLES]) edge_pt(1, k/SAMPLES, +1) ];
function E2() = [ for (k = [0:SAMPLES]) edge_pt(2, k/SAMPLES, +1) ];
function E3() = [ for (k = [0:SAMPLES]) edge_pt(3, 1 - k/SAMPLES, -1) ];
function E4() = [ for (k = [0:SAMPLES]) edge_pt(4, 1 - k/SAMPLES, -1) ];
function E5() = [ for (k = [0:SAMPLES]) edge_pt(5, 1 - k/SAMPLES, -1) ];

// Join edges (two-arg concat works in 2021)
function hex_pts() =
    concat(
      concat(concat(E0(), E1()), E2()),
      concat(concat(E3(), E4()), E5())
    );

// Draw polygon with an explicit path so OpenSCAD doesn't re-triangulate
module interlocking_hex() {
  pts = hex_pts();
  polygon(points = pts,
          paths = [ [ for (i = [0:len(pts)-1]) i ] ],
          convexity = 10);
}

// axial → world XY kept top-level for 2021
function hex_to_xy(q, r) =
    let(x = sqrt(3) * R * (q + r/2),
        y = 1.5 * R * r)
    [x, y];

// --- Render ---
if (SHOW_TEST_GRID) {
  for (q = [-1:1])
  for (r = [-1:1])
    translate(hex_to_xy(q, r)) interlocking_hex();
} else {
  interlocking_hex();
}
