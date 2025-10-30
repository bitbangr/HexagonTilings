// ==== Interlocking hex with tabs/slots correctly on edges (OpenSCAD 2021) ====
R = 50;            // circumradius (mm)
TEETH = 3;         // hooks/slots per edge
TAB = 8;           // tab/slot depth (mm)
DUTY = 0.55;       // width fraction per tooth (0..1)
FILLET = 0.8;      // corner round (mm); 0 = sharp
SHOW_GRID = false;  // preview 3×3 tiling



module base_hex_by_side(s=20) {
  function V(i) = s * [cos(60*i), sin(60*i)];
  polygon(points=[for (i=[0:5]) V(i)]);
}


// ---- basic hex geometry ----
function ang(i) = 60*i;
function V(i) = R * [cos(ang(i)), sin(ang(i))];
EL = 2*R*sin(60);                    // edge length = R*sqrt(3)
function edge_angle(i) = ang(i) + 30; // direction along edge (i→i+1)
function mid(i) = (V(i) + V(i+1)) / 2;

// ---- base hex ----
module base_hex() {
  polygon(points=[V(0),V(1),V(2),V(3),V(4),V(5)]);
}

// ---- one strip of rectangular teeth in local coords ----
module teeth_strip(phase=0) {
  period = EL/TEETH;
  solid_w = DUTY * period;
  for (n=[0:TEETH-1]) {
    is_solid = ((n + phase) % 2 == 0);
    if (is_solid) {
      translate([-EL/2 + n*period + solid_w/2, 0]) {
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

// ---- place tabs/slots on a specific edge ----
// rotate by (edge_angle - 90) so +Y points OUTWARD from the hex
module tabs_on_edge(i, phase=0) {
  translate(mid(i))
    rotate(edge_angle(i) - 90)
    translate([0, TAB/2])  // move the strip fully outside
    teeth_strip(phase);
}

module slots_on_edge(i, phase=0) {
  translate(mid(i))
    rotate(edge_angle(i) - 90)
    translate([0, -TAB/2]) // move the strip fully inside
    teeth_strip(phase);
}

// ---- build one tile: tabs on 0..2, matching slots on 3..5 ----
module tile() {
  difference() {
    union() {
      base_hex();
//      tabs_on_edge(0, 0);
//      tabs_on_edge(1, 0);
//      tabs_on_edge(2, 0);
    }
//    slots_on_edge(3, 0);
//    slots_on_edge(4, 0);
//    slots_on_edge(5, 0);
  }
}

// ---- hex grid placement for preview ----
function hex_to_xy(q, r) =
  let(x = sqrt(3)*R*(q + r/2),
      y = 1.5*R*r)
  [x, y];

// ---- render ----
if (SHOW_GRID) {
  for (q=[-1:1]) for (r=[-1:1])
    translate(hex_to_xy(q,r)) tile();
} else {
  tile();
}
