// ==== Hex tile with alternating hooks & holes (boolean method, 2021-safe) ====
R = 50;            // circumradius of the hex (mm)
TEETH = 3;         // how many tab/slot repeats per edge (≥1)
TAB = 8;           // depth of tab/slot measured normal to the edge (mm)
DUTY = 0.55;       // fraction of each tooth period that is "solid" (0.2..0.8)
FILLET = 0.8;      // small rounding on tab corners (mm); set 0 for sharp
SHOW_GRID = false;  // preview 3×3 tiling

// --- basic hex geometry (pointy-top)
function ang(i) = 60*i;
function V(i) = R * [cos(ang(i)), sin(ang(i))];
function E_len() = 2*R*sin(60);           // edge length = R*sqrt(3)
EL = E_len();
function mid(i) = (V(i)+V(i+1))/2;        // edge midpoint
function edge_angle(i) = ang(i)+30;       // local x-axis along the edge

// base hex polygon
module base_hex() {
  polygon(points=[ V(0),V(1),V(2),V(3),V(4),V(5) ]);
}

// one strip of rectangular "teeth" projecting +y in local coords
// phase=0/1 flips which half-period is solid vs empty (alternation)
module teeth_strip(phase=0) {
  period = EL/TEETH;
  solid_w = DUTY * period;
  for (n=[0:TEETH-1]) {
    // even/odd alternation with phase
    is_solid = ((n + phase) % 2 == 0);
    if (is_solid) {
      translate([ -EL/2 + n*period + solid_w/2, 0 ]) {
        if (FILLET > 0) {
          minkowski() {
            square([solid_w, TAB], center=true);
            circle(r=FILLET, $fn=24);
          }
        } else {
          square([solid_w, TAB], center=true);
        }
      }
    }
  }
}

// add tabs to edge i (outward) or cut slots from edge i (inward)
module tabs_on_edge(i, phase=0) {
  translate(mid(i)) rotate(edge_angle(i))
    translate([0, TAB/2]) teeth_strip(phase);
}

module slots_on_edge(i, phase=0) {
  translate(mid(i)) rotate(edge_angle(i))
    translate([0, -TAB/2]) mirror([0,1,0]) teeth_strip(phase);
}

// Build one tile: edges 0–2 get tabs; opposite edges 3–5 get complementary slots
module tile() {
  difference() {
    union() {
      base_hex();
      tabs_on_edge(0, 0);
      tabs_on_edge(1, 0);
      tabs_on_edge(2, 0);
    }
    slots_on_edge(3, 0);
    slots_on_edge(4, 0);
    slots_on_edge(5, 0);
  }
}

// axial → XY for tiling preview (pointy-top axial coords)
function hex_to_xy(q, r) =
  let(x = sqrt(3)*R*(q + r/2),
      y = 1.5*R*r)
  [x,y];

// ---- render ----
if (SHOW_GRID) {
  for (q=[-1:1]) for (r=[-1:1])
    translate(hex_to_xy(q,r)) tile();
} else {
  tile();
}
