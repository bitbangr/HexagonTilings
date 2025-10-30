//---------------------------------------------
// Parameters
//---------------------------------------------
edge_len  = 20;
tab_len   = 3;
tab_wid   = 3;     // half-thickness each way (tab out, slot in)
thickness = 3;

//---------------------------------------------
// Geometry setup
//---------------------------------------------
radius = edge_len;
function ang(i)         = 60*i;
function V(i)           = radius * [cos(ang(i)), sin(ang(i))];
function edge_dir_ang(i)= ang(i) + 30;

//---------------------------------------------
// Base hex
//---------------------------------------------
module base_hex() {
  polygon(points=[for (i=[0:5]) V(i)]);
}

//---------------------------------------------
// Edge features: symmetric tab+slot on each edge
//---------------------------------------------
module edge_feature(i, len=tab_len, wid=tab_wid) {
  translate(V(i))
    rotate(edge_dir_ang(i)) {
      // tab (outward)
      translate([0,0])
        square([len, wid], center=false);
      // slot (inward)
      translate([0,-wid])
        square([len, wid], center=false);
    }
}

//---------------------------------------------
// One tile (hex + symmetric features)
//---------------------------------------------
module tile2d(){
  difference(){
    union(){
      base_hex();
      for (i=[0:5]) edge_feature(i);  // add tabs
    }
    // subtract slots
    for (i=[0:5])
      translate(V(i))
        rotate(edge_dir_ang(i))
          translate([0,-tab_wid])
            square([tab_len, tab_wid], center=false);
  }
}

//---------------------------------------------
// 3D version
//---------------------------------------------
module tile3d(){ linear_extrude(height=thickness) tile2d(); }

//---------------------------------------------
// Geometry-driven lattice (orientation independent)
//---------------------------------------------
function mid(i) = (V(i) + V((i+1)%6))/2;
b0 = 2*mid(0);
b1 = 2*mid(1);

module grid(rows=2, cols=2){
  for (r=[-rows:rows])
    for (c=[-cols:cols]){
      pos = [ r*b0[0] + c*b1[0], r*b0[1] + c*b1[1] ];
      %translate(pos) tile3d();    // preview neighbors
    }
}

//---------------------------------------------
// Render
//---------------------------------------------
//tile3d();
tile3d();
grid(2,2);
