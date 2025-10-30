// ===== Interlocking Hexagon — OpenSCAD 2021 compatible =====
R = 50;          // circumradius (mm)
SAMPLES = 100;   // points per edge (smoothness)
AMP = 4;         // tab depth (mm)
SHOW_TEST_GRID = false;   // true = preview 3x3 tiling

// ---- Edge profile (sin uses DEGREES in OpenSCAD 2021) ----
function f(t) = AMP * sin(180 * t);  // smooth tab: 0→AMP→0

// ---- Helpers (simple expressions only) ----
function ang(i) = 60 * i;
function v(a) = [cos(a), sin(a)];
function P(i) = R * v(ang(i));
function edge_start(i) = P(i);
function edge_end(i)   = P(i + 1);
function edge_nrm(i)   = v(ang(i) + 120);   // 30+90 = 120

// point on edge i at parameter t∈[0,1], with signed offset s∈{+1,-1}
function edge_pt(i, t, s) =
    let(p = (1 - t) * edge_start(i) + t * edge_end(i))
    p + edge_nrm(i) * (s * f(t));

// Build each edge separately (avoid multi-arg concat)
function E0() = [ for (k = [0:SAMPLES]) edge_pt(0, k/SAMPLES, +1) ];
function E1() = [ for (k = [0:SAMPLES]) edge_pt(1, k/SAMPLES, +1) ];
function E2() = [ for (k = [0:SAMPLES]) edge_pt(2, k/SAMPLES, +1) ];
function E3() = [ for (k = [0:SAMPLES]) edge_pt(3, 1 - k/SAMPLES, -1) ];
function E4() = [ for (k = [0:SAMPLES]) edge_pt(4, 1 - k/SAMPLES, -1) ];
function E5() = [ for (k = [0:SAMPLES]) edge_pt(5, 1 - k/SAMPLES, -1) ];

// Join edges with nested two-arg concat (works in 2021)
function hex_path() =
    concat(
      concat(concat(E0(), E1()), E2()),
      concat(concat(E3(), E4()), E5())
    );

// Draw one tile
module interlocking_hex() {
  polygon(points = hex_path());
}

// Axial hex grid coordinate → world XY (kept OUT of if/else)
function hex_to_xy(q, r) =
    let(x = sqrt(3) * R * (q + r/2),
        y = 1.5 * R * r)
    [x, y];

// ---- Render ----
if (SHOW_TEST_GRID) {
  for (q = [-1:1])
  for (r = [-1:1])
    translate(hex_to_xy(q, r)) interlocking_hex();
} else {
  interlocking_hex();
}
