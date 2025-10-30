//---------------------------------------------
// Params
//---------------------------------------------
edge_len  = 20;
tab_len   = 3;
tab_wid   = 3;
thickness = 3;
SHOW_GRID = true;   // false = single tile, true = tiled preview

//---------------------------------------------
// Hex geometry (CCW)
//---------------------------------------------
radius = edge_len;
function ang(i)         = 60*i;
function V(i)           = radius * [cos(ang(i)), sin(ang(i))];
function edge_dir_ang(i)= ang(i) + 30;
function mid(i)         = (V(i) + V((i+1)%6))/2;

//---------------------------------------------
// Base 2D hex
//---------------------------------------------
module base_hex() {
  polygon(points=[for (i=[0:5]) V(i)]);
}

//---------------------------------------------
// Edge features (2D)
// Tabs on edges 0,2,4; Slots remove on 1,3,5
//---------------------------------------------
module edge_tab(i, len=tab_len, wid=tab_wid) {
  translate(V(i))
    rotate(edge_dir_ang(i))
      translate([0,0])                 // inner edge on y=0 (the edge line)
        square([len, wid], center=false);
}

module edge_slot(i, len=tab_len, wid=tab_wid) {
  translate(V(i))
    rotate(edge_dir_ang(i))
      translate([0,0])                 // same placement; used in difference()
        square([len, wid], center=false);
}

//---------------------------------------------
// One tile (2D): (hex + tabs) - slots
//---------------------------------------------
module tile2d(){
  difference(){
    union(){
      base_hex();
      for (i=[0,2,4]) edge_tab(i);     // tabs 0,2,4
    }
    for (i=[1,3,5]) edge_slot(i);      // slots 1,3,5
  }
}

// 3D
module tile3d(){ linear_extrude(height=thickness) tile2d(); }

//---------------------------------------------
// Orientation-agnostic tiling preview
// Lattice basis = center-to-center jumps across edges 0 and 1
//---------------------------------------------
module preview_grid(rows=2, cols=2){
  b0 = 2*mid(0);
  b1 = 2*mid(1);

  // real, exportable center tile
  tile3d();

  // neighbors as preview-only so CGAL won’t complain
  for (r=[-rows:rows])
    for (c=[-cols:cols]){
      if (!(r==0 && c==0)){
        pos = [ r*b0[0] + c*b1[0],  r*b0[1] + c*b1[1] ];
        %translate(pos) tile3d();
      }
    }
}

//---------------------------------------------
// Render
//---------------------------------------------
if (SHOW_GRID) preview_grid(2,2);
else           tile3d();
