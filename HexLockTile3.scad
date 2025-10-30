// ==== Interlocking hex with tabs/slots aligned to edges (OpenSCAD 2021) ====
R = 50;            // circumradius (mm)
TEETH = 3;         // hooks/slots per edge
TAB = 8;           // tab depth (mm)
DUTY = 0.55;       // width fraction per hook
FILLET = 0.8;      // corner rounding (mm)
SHOW_GRID = false; // true = show 3×3 tiling

// ---- Basic hex geometry ----
function ang(i) = 60 * i;
function V(i) = R * [cos(ang(i)), sin(ang(i))];
EL = 2 * R * sin(60);             // edge length
function edge_angle(i) = ang(i) + 30;
function mid(i) = (V(i) + V(i+1)) / 2;

// ---- Base hex polygon ----
module base_hex() {
  polygon(points=[V(0),V(1),V(2),V(3),V(4),V(5)]);
}

// ---- Teeth pattern (rectangular) ----
module teeth_strip(phase=0) {
  period = EL / TEETH;
  solid_w = DUTY * period;
  for (n = [0:TEETH-1]) {
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

// ---- Place tabs or slots on edge i ----
module tabs_on_edge(i, phase=0) {
  // Move to the midpoint, orient to edge direction, then push outward
  translate(mid(i)) 
    rotate(edge_angle(i)) 
    translate([0, R * 0.57735]) // <-- correction: move from center to hex edge
    teeth_strip(phase);
}

module slots_on_edge(i, phase=0) {
  translate(mid(i)) 
    rotate(edge_angle(i)) 
    translate([0, -R * 0.57735]) // opposite edge inward
    mirror([0,1,0]) 
    teeth_strip(phase);
}

// ---- Construct full tile ----
module tile() {
  difference() {
    union() {
      base_hex();
      tabs_on_edge(0);
      tabs_on_edge(1);
      tabs_on_edge(2);
    }
    slots_on_edge(3);
    slots_on_edge(4);
    slots_on_edge(5);
  }
}

// ---- Hex grid positioning for preview ----
function hex_to_xy(q, r) =
  let(x = sqrt(3) * R * (q + r/2),
      y = 1.5 * R * r)
  [x, y];

// ---- Render ----
if (SHOW_GRID) {
  for (q=[-1:1]) for (r=[-1:1])
    translate(hex_to_xy(q,r)) tile();
} else {
  tile();
}
