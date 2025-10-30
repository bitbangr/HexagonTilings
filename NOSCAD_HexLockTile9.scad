// Parametric Interlocking Hexagonal Tile System
// Features placed at fixed distance from vertex on opposite edges

/* [Tile Dimensions] */
edge_len = 20;        // Edge length of hexagon
thickness = 3;        // Tile thickness (z-height)

/* [Feature Parameters] */
feat_dist = 10;       // Distance C from vertex to feature center
feat_size = 4;        // Feature size
feat_depth = 2;       // Feature protrusion depth

/* [Feature Enable Pairs] */
pair_0_3 = true;      // Edges 0 & 3 (right & left)
pair_1_4 = true;      // Edges 1 & 4 (top-right & bottom-left)
pair_2_5 = false;     // Edges 2 & 5 (top-left & bottom-right)

/* [Preview Options] */
show_grid = true;
show_measurements = true;  // Show debug measurement markers

// ============================================================
// FEATURE SHAPE
// ============================================================

// Generic feature shape A - centered at origin
// Feature is oriented to protrude in +X direction
module feature_shape() {
  polygon([
    [0, -feat_size/2],           // Left bottom (on hex edge)
    [0, feat_size/2],            // Left top (on hex edge)
    [feat_depth, feat_size/3],   // Right top (angled)
    [feat_depth, -feat_size/3]   // Right bottom (angled)
  ]);
}

// ============================================================
// DEBUG HELPERS
// ============================================================

// Show vertex positions and edge measurements
module show_debug_markers() {
  for (i=[0:5]) {
    ang = 30 + i * 60;
    v = [edge_len * cos(ang), edge_len * sin(ang)];
    echo(str("Vertex ", i, ": "), v);
    color("red") translate([v[0], v[1], thickness])
      cylinder(h=2, r=0.5, $fn=8);
    color("blue") translate([v[0], v[1], thickness+2])
      linear_extrude(0.5) text(str(i), size=3, halign="center");
  }
  echo("Flat-to-flat should be:", edge_len * sqrt(3));
}

// ============================================================
// CORE GEOMETRY
// ============================================================

module base_hex(e) {
  r = e;
  polygon([for(i=[0:5]) [r*cos(30+i*60), r*sin(30+i*60)]]);
}

// Place feature at distance from starting vertex of edge
module place_feature_on_edge(e, idx, dist, add) {
  // Vertices of flat-top hexagon
  v0_ang = 30 + idx * 60;
  v1_ang = 30 + (idx + 1) * 60;
  
  v0 = [e * cos(v0_ang), e * sin(v0_ang)];  // Starting vertex
  v1 = [e * cos(v1_ang), e * sin(v1_ang)];  // Ending vertex
  
  // Direction along edge
  edge_dir = v1 - v0;
  edge_len_actual = sqrt(edge_dir[0]*edge_dir[0] + edge_dir[1]*edge_dir[1]);
  edge_unit = edge_dir / edge_len_actual;
  
  // Position at distance from v0
  feat_pos = v0 + edge_unit * dist;
  
  // Angle perpendicular to edge (pointing outward)
  edge_ang = atan2(edge_dir[1], edge_dir[0]);
  perp_ang = edge_ang - 90;  // Changed from +90 to -90
  
  translate(feat_pos)
    rotate(perp_ang)
      if (add) {
        # translate([0, 0]) feature_shape();
      } else {
        # translate([0, 0]) mirror([1, 0]) feature_shape();
      }
}

// 2D tile with complementary features
module tile2d() {
  pairs = [
    [0, 3, pair_0_3],
    [1, 4, pair_1_4],
    [2, 5, pair_2_5]
  ];
  
  difference() {
    union() {
      base_hex(edge_len);
      // Add protruding features - measure from starting vertex
      for (p = pairs) {
        if (p[2]) {
          place_feature_on_edge(edge_len, p[0], feat_dist, true);
        }
      }
    }
    // Subtract recessed features - measure from opposite end
    for (p = pairs) {
      if (p[2]) {
        // Calculate edge length and measure from opposite end
        v0_ang = 30 + p[1] * 60;
        v1_ang = 30 + (p[1] + 1) * 60;
        v0 = [edge_len * cos(v0_ang), edge_len * sin(v0_ang)];
        v1 = [edge_len * cos(v1_ang), edge_len * sin(v1_ang)];
        edge_dir = v1 - v0;
        edge_length = sqrt(edge_dir[0]*edge_dir[0] + edge_dir[1]*edge_dir[1]);
        
        place_feature_on_edge(edge_len, p[1], edge_length - feat_dist, false);
      }
    }
  }
}

module tile3d() {
  linear_extrude(thickness) tile2d();
}

// ============================================================
// GRID (pointy-top) — with random colors
// ============================================================

// Convert axial hex coords (q,r) -> 2D center
function axial_to_xy(q, r, s) = [ s*sqrt(3)*(q + r/2), 1.5*s*r ];

// Generate a reproducible random color for each (q,r)
function random_color(q, r) = 
    let(seed = q*100 + r*17)           // unique per tile
    [ for (c = rands(0, 1, 3, seed)) c ];  // 3 floats [0–1]

// Place one tile at axial (q,r)
module tile_at_axial(q, r) {
  xy = axial_to_xy(q, r, edge_len);
  col = random_color(q, r);
  color(col)
    translate([xy[0], xy[1], 0]) tile3d();
}

// Preview: rectangular block in axial coords
// Preview grid
COLS = 2;
ROWS = 2;

module show_tile_grid_pointy() {
  for (r = [0:ROWS-1])
    for (q = [0:COLS-1])
      tile_at_axial(q, r);
}

// ============================================================
// RENDER
// ============================================================

if (show_grid) {
  show_tile_grid_pointy();
  if (show_measurements) {
    translate([0, 0, 0]) show_debug_markers();
  }
} else {
  tile3d();
  if (show_measurements) {
    show_debug_markers();
  }
}