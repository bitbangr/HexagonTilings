
//---------------------------------------------
// Params
//---------------------------------------------
edge_len  = 20;
tab_len   = 3;
tab_wid   = 3;
thickness = 3;

SHOW_GRID  = true;   // ← toggle this for 3×3 tiling preview

//---------------------------------------------
// Hex geometry
//---------------------------------------------
radius = edge_len;
function vert_ang(i) = 60*i;
function vert(i) = radius * [cos(vert_ang(i)), sin(vert_ang(i))];
function edge_dir_ang(i) = vert_ang(i) + 30;   // direction of edge i→i+1

// 2D regular hex
module base_hex() {
  polygon(points=[for(i=[0:5]) vert(i)]);
}

/*
// Tab starting at vertex i, along edge i→i+1, outward by tab_wid
module edge_tab(i, len=tab_len, wid=tab_wid) {
  translate(vert(i))                 // move origin to vertex
    rotate(edge_dir_ang(i))          // align +X with the edge
      translate([0, +wid])     // drop outward; keep inner edge on the edge
        square([len, wid], center=false);
  // If you ever want the tab inward instead: replace the previous translate with:
  // mirror([0,1,0]) translate([0, eps]) square([len, wid], center=false);
}
*/
// Tab starting at vertex i, along edge i→i+1, outward by tab_wid
module edge_tab(i, len=tab_len, wid=tab_wid) {
  translate(vert(i))            // anchor at vertex
    rotate(edge_dir_ang(i))     // align +X with edge (interior is +Y)
      translate([0, 0])      // put square at y∈[-wid, 0] → inner edge at y=0
        #square([len, wid], center=false);
}

/*
// Slot starting at vertex i, along edge i→i+1, inward by tab_wid
module edge_slot(i, len=tab_len, wid=tab_wid) {
  translate(vert(i))              // move origin to vertex
    rotate(edge_dir_ang(i))       // align +X with the edge (interior = +Y)
      translate([-wid, 0])           // inner edge sits at y=0 (edge line)
        square([len, wid], center=false);
}
*/
// Slot starting at vertex i, along edge i→i+1, inward by tab_wid
module edge_slot(i, len=tab_len, wid=tab_wid) {
  eps = 0.01;                        // small inset so subtraction works
  translate(vert(i))                 // move origin to vertex
    rotate(edge_dir_ang(i))          // align +X with edge (interior = +Y)
      translate([-wid, -eps])           // push slot slightly inward
        square([len, wid + eps], center=false);
}



// Combine hex with tabs on alternating edges
module hex_with_tabs() {
  union() {
    base_hex();
    for(i=[0:2:4]) #edge_tab(i);      // tabs on edges 0,2,4
  }
}

// Combine hex with tabs on alternating edges
module hex_with_slots() {
  
  difference() {
    base_hex();                           // the solid
    for(i=[1,3,5]) #edge_slot(i);          // remove slots on edges 1,3,5
  }
}


module hex_with_tabs_and_slots(){
    
    difference() {
    // minuend: what we keep (hex + tabs)
      union() {
        base_hex();
        for (i=[0:2:5]) edge_tab(i);    // edges 0,2,4
        }

        // subtrahends: what we remove (slots)
        for (i=[1,3,5]) edge_slot(i);     // edges 1,3,5
    }

}

// 3D
//linear_extrude(height=thickness)
//  hex_with_slots_and_tabs();



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
  //linear_extrude(height=thickness)
    hex_with_tabs_and_slots();



/*

//---------------------------------------------
// Params
//---------------------------------------------
edge_len  = 20;
tab_len   = 3;
tab_wid   = 3;
thickness = 3;
slot_eps  = 0;     // set to 0.01 if CGAL ever leaves coplanar artifacts

//---------------------------------------------
// Hex geometry
//---------------------------------------------
radius = edge_len;
function vert_ang(i)     = 60*i;
function vert(i)         = radius * [cos(vert_ang(i)), sin(vert_ang(i))];
function edge_dir_ang(i) = vert_ang(i) + 30;

module base_hex() { polygon(points=[for(i=[0:5]) vert(i)]); }

// Tab: anchored at vertex, along edge, outward by tab_wid
module edge_tab(i, len=tab_len, wid=tab_wid) {
  translate(vert(i))
    rotate(edge_dir_ang(i))
      translate([0, 0])                 // inner edge on y=0
        square([len, wid], center=false);
}

// Slot (cut): anchored at vertex, along edge, inward by tab_wid
module edge_slot(i, len=tab_len, wid=tab_wid) {
  translate(vert(i))
    rotate(edge_dir_ang(i))
      translate([0, 0 + slot_eps])      // tiny +eps pushes area inside hex if needed
        square([len, wid], center=false);
}

//---------------------------------------------
// Final shape: (hex + tabs) MINUS slots
//---------------------------------------------
linear_extrude(height=thickness)
difference() {
  // minuend: what we keep (hex + tabs)
  union() {
    base_hex();
    for (i=[0:2:5]) edge_tab(i);    // edges 0,2,4
  }

  // subtrahends: what we remove (slots)
  for (i=[1,3,5]) edge_slot(i);     // edges 1,3,5
}


*/



























/*
//---------------------------------------------
// Parameters
//---------------------------------------------
edge_len  = 20;   // side length of the hexagon (mm)
tab_len   = 3;    // length of each tab along the edge (mm)
tab_wid   = 3;    // width of each tab (outward) (mm)
thickness = 3;    // extrusion height (mm)

//---------------------------------------------
// Derived geometry
//---------------------------------------------
radius = edge_len;                     // for regular hex, side = radius
function vert_ang(i) = 60 * i;         // vertex angle (°)
function vert(i) = radius * [cos(vert_ang(i)), sin(vert_ang(i))];
function edge_dir_ang(i) = vert_ang(i) + 30;  // edge direction angle

//---------------------------------------------
// Modules
//---------------------------------------------

// 2D regular hex centered at [0,0]
module base_hex() {
    polygon(points = [for (i = [0:5]) vert(i)]);
}

// Rectangular tab starting at vertex(i),
// aligned with edge (i→i+1), extending outward
module edge_tab(i, tab_len, tab_wid) {
    translate(vert(i))
        rotate(edge_dir_ang(i))
            translate([0, -tab_wid])  // move outward from edge
                square([tab_len, tab_wid], center = false);
}

// Combine hex with tabs on alternating edges
module hex_with_tabs() {
    union() {
        base_hex();
        for (i = [0:2:5]) edge_tab(i, tab_len, tab_wid);  // 0,2,4 = alternating edges
    }
}

//---------------------------------------------
// Final model (3D)
//---------------------------------------------
//linear_extrude(height = thickness)
    hex_with_tabs();
*/
/*
//

SHOW_GRID = false;  // preview 3×3 tiling


module base_hex_by_side(s=20) {
  function V(i) = s * [cos(60*i), sin(60*i)];
  polygon(points=[for (i=[0:5]) V(i)]);
}


// ---- build one tile: tabs on 0..2, matching slots on 3..5 ----
module tile() {
  difference() {
    union() {
      base_hex_by_side(20);
//      tabs_on_edge(0, 0);
//      tabs_on_edge(1, 0);
//      tabs_on_edge(2, 0);
    }
//    slots_on_edge(3, 0);
//    slots_on_edge(4, 0);
//    slots_on_edge(5, 0);
  }
}

tile();
*/