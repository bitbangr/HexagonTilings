//---------------------------------------------
// Parameters
//---------------------------------------------
edge_len   = 20;
tab_len    = 3;
tab_wid    = 3;
thickness  = 3;
slot_eps   = 0;
SHOW_GRID  = true;   // ← toggle this for 3×3 tiling preview

//---------------------------------------------
// Geometry functions
//---------------------------------------------
radius = edge_len;
function vert_ang(i)     = 60*i;
function vert(i)         = radius * [cos(vert_ang(i)), sin(vert_ang(i))];
function edge_dir_ang(i) = vert_ang(i) + 30;

//---------------------------------------------
// Base geometry
//---------------------------------------------
module base_hex() {
  polygon(points=[for(i=[0:5]) vert(i)]);
}

// Tab (outward)
module edge_tab(i, len=tab_len, wid=tab_wid) {
  translate(vert(i))
    rotate(edge_dir_ang(i))
      square([len, wid], center=false);
}

// Slot (inward cut)
module edge_slot(i, len=tab_len, wid=tab_wid) {
  translate(vert(i))
    rotate(edge_dir_ang(i))
      translate([0, slot_eps])
        square([len, wid], center=false);
}

//---------------------------------------------
// One full hex tile (tabs + slots)
//---------------------------------------------
module hex_with_tabs_and_slots() {
  difference() {
    union() {
      base_hex();
      for(i=[0:2:5]) edge_tab(i);   // edges 0,2,4
    }
    for(i=[1,3,5]) edge_slot(i);    // edges 1,3,5
  }
}

//---------------------------------------------
// Hex tiling pattern
//---------------------------------------------
module show_grid(rows=3, cols=3) {
  dx = edge_len * 1.5;               // horizontal spacing between hex centers
  dy = edge_len * sqrt(3);           // vertical spacing between rows
  for (r=[0:rows-1])
    for (c=[0:cols-1]) {
      x = c * dx;
      y = r * dy + (c % 2 == 1 ? dy/2 : 0);  // offset every other column
      translate([x, y])
        linear_extrude(height=thickness)
          hex_with_tabs_and_slots();
    }
}

//---------------------------------------------
// Render
//---------------------------------------------
if (SHOW_GRID)
  show_grid(3,3);
else
  linear_extrude(height=thickness)
    hex_with_tabs_and_slots();
