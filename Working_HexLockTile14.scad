// Parametric Interlocking Hexagonal Tile System
// Features placed at fixed distance from vertex on opposite edges

/* [Tile Dimensions] */
edge_len = 20;        // Edge length of hexagon
thickness = 3;        // Tile thickness (z-height)

/* [Feature Parameters] */
feat_dist = 10;       // Distance C from vertex to feature center
feat_size = 4;        // Feature size
feat_depth = 4;       // Feature protrusion depth

/* [Feature Enable Pairs] */
pair_0_3 = true;      // Edges 0 & 3 (right & left)
pair_1_4 = true;      // Edges 1 & 4 (top-right & bottom-left)
pair_2_5 = true;     // Edges 2 & 5 (top-left & bottom-right)


// ---- choose feature types per opposite-edge pair ----
// Valid types: "rect", "triangle", "dovetail", "hook", "Lhook"
pair_0_3_type = "rect";     // A edge 0 tab, edge 3 slot
pair_1_4_type = "dovetail";
pair_2_5_type = "Lhook";

/* [Preview Options] */
show_grid = true;
show_measurements = true;  // Show debug measurement markers

// --- tweakables for fit ---
embed_eps  = 0.05;    // how far feature crosses into the hex (mm)
fit_clear = 0.15;     // positive = looser fit. Try 0.1–0.3 for FDM
edge_margin = 0.02;   // keep features away from vertices by this much

// ============================================================
// FEATURE SHAPE
// ============================================================

// Feature shape oriented so its edge lies on x=0 and protrudes along +X
// We'll inflate slots by fit_clear to make assembly tolerant.
/*
module feature_shape(tab=true) {
  local_depth = tab ? feat_depth : (feat_depth + fit_clear);
  local_size  = tab ? feat_size  : (feat_size  + fit_clear);

  x0 = -embed_eps;  // <— was 0; push slightly inside the hex
  polygon([
    [x0, -local_size/2],    // slightly off the edge line
    [x0,  local_size/2],
    [local_depth,  local_size/3],
    [local_depth, -local_size/3]
  ]);
}
*/

// ============================================================
// FEATURE SHAPE
// ============================================================

// Hook proportions (feel free to tweak)
//hook_neck_ratio   = 0.45;  // neck width vs height
//hook_step_ratio   = 0.28;  // how far up/down the notches are
//hook_retract_frac = 0.40;  // how much the hook retracts backward
//hook_shank_frac   = 0.58;  // where the shank sits before the retract
//hook_tip_frac     = 1.00;  // tip reaches full depth

hook_neck_ratio   = 0.60;  // ↑ wider neck (0.5..0.75) // neck width vs height
hook_step_ratio   = 0.35;  // deeper notch (0.25..0.45) how far up/down the notches are
hook_retract_frac = 0.50;  // barb retract (0.35..0.6) how much the hook retracts backward
hook_shank_frac   = 0.70;  // shank x (0.55..0.8) // where the shank sits before the retract
hook_tip_frac     = 1.05;  // forward tip reach (1.0..1.2)
hook_min_neck     = 1.2;   // absolute minimum neck (mm)
hook_fillet       = 0.3;   // corner round (0 for sharp)

// Lhook tuning
lhook_under       = 2.0;   // mm; flange returns this far back from the tip (undercut)
lhook_stem_ratio  = 0.45;  // stem thickness as a fraction of feat_size (0.2..0.9)
lhook_side        = 1;     // +1 = flange on +Y side, -1 = flange on -Y side


// feature factory (2D) — left edge sits slightly inside hex (x = -embed_eps)
// 'tab=true' uses nominal size; 'tab=false' inflates by fit_clear
module feature_shape_by_type(ftype="rect", tab=true) {
  local_depth = tab ? feat_depth : (feat_depth + fit_clear);
  local_size  = tab ? feat_size  : (feat_size  + fit_clear);
  x0 = -embed_eps;

  if (ftype == "rect") {
    polygon([
      [x0, -local_size/2], [x0,  local_size/2],
      [local_depth,  local_size/2], [local_depth, -local_size/2]
    ]);
  } else if (ftype == "triangle") {
    polygon([
      [x0, -local_size/2], [x0,  local_size/2],
      [local_depth, 0]
    ]);
  } else if (ftype == "dovetail") {
    // narrow neck near edge, flares outward
    neck = max(local_size*0.45, 0.5);
    flare = local_size*0.75;
    polygon([
      [x0, -neck/2], [x0,  neck/2],
      [local_depth*0.55,  flare/2],
      [local_depth,       flare/3],
      [local_depth,      -flare/3],
      [local_depth*0.55, -flare/2]
    ]);
    } else if (ftype == "Lhook") {
      // L-shaped feature: stem attached to edge, flange parallel to edge creating an undercut
      // Uses feat_size as total width along the edge, feat_depth as outward extent.
      h = local_size;          // total width along edge
      d = local_depth;         // outward extent

      // Stem thickness and undercut (clamped to sane ranges)
      stem = clampv(lhook_stem_ratio * h, 0.2*h, 0.9*h);
      u    = clampv(lhook_under, 0.2, 0.9*d);     // how far flange returns toward the edge
      sgn  = (lhook_side >= 0) ? 1 : -1;         // which side gets the flange (+Y / -Y)

      x0 = -embed_eps;                           // sink slightly into the hex for robust CSG

      // CCW outline of an L shape. Two variants depending on which side the flange is on.
      pts = (sgn == 1)  // flange on +Y side
        ? [
            [x0,   -stem/2],
            [x0,    stem/2],
            [d-u,   stem/2],   // start flange
            [d-u,   h/2],
            [d,     h/2],
            [d,     stem/2],   // end flange
            [d,    -stem/2],
            [x0,   -stem/2]
          ]
        : [               // flange on -Y side
            [x0,   -stem/2],
            [x0,   -h/2],
            [d,    -h/2],
            [d,    -stem/2],
            [d-u,  -stem/2],   // start flange
            [d-u,   stem/2],
            [x0,    stem/2],
            [x0,   -stem/2]
          ];

      polygon(pts);

  /* }  else if (ftype == "hook") {
    // small step like a latch
    step = local_size*0.35;
    polygon([
      [x0, -local_size/2], [x0,  local_size/2],
      [local_depth*0.65,  local_size/2],
      [local_depth*0.65,  step/2],
      [local_depth,       step/2],
      [local_depth,      -step/2],
      [local_depth*0.65, -step/2],
      [local_depth*0.65, -local_size/2]
    ]); */
    } else if (ftype == "hook") {
      // Proper asymmetric hook/tooth:
      //   - narrow neck at the edge
      //   - shank extends outward
      //   - retracts back (barb)
      //   - then a short forward tip
      // Works for tab and (inflated) slot via the same outline.
      h = local_size;
      d = local_depth;

      neck  = max(hook_neck_ratio * h, 0.5);
      yK    = hook_step_ratio * h;     // notch height
      d_sh  = hook_shank_frac * d;     // shank x
      d_ret = hook_retract_frac * d;   // retract back x
      d_tip = hook_tip_frac * d;       // forward tip x

      x0 = -embed_eps;

      // CCW polygon around the shape
      polygon([
        [x0,   -neck/2],
        [x0,    neck/2],
        [d_sh,  neck/2],     // shank outward at top
        [d_sh,  yK],
        [d_ret, yK],         // retract back (barb)
        [d_tip, 0.35*yK],    // small forward tip
        [d_tip,-0.35*yK],
        [d_ret,-yK],         // mirror retract
        [d_sh, -yK],
        [d_sh, -neck/2]
      ]);
  } else {
    // fallback
    polygon([
      [x0, -local_size/2], [x0,  local_size/2],
      [local_depth,  local_size/3], [local_depth, -local_size/3]
    ]);
  }
}

// 2D debug marker for use inside tile2d()
module dot(pt, r=0.6) {
  color("magenta")
    translate([pt[0], pt[1]])
      circle(r=r, $fn=24);  // 2D circle, not sphere
}


// OpenSCAD has clamp(), but to be safe we define our own:
function clampv(x, lo, hi) = max(lo, min(hi, x));

// --- utility: edge info ---  
function edge_vertices(e, idx) =
  let(
    a0 = 30 + 60*idx,
    a1 = 30 + 60*((idx+1)%6),
    v0 = [e*cos(a0), e*sin(a0)],
    v1 = [e*cos(a1), e*sin(a1)]
  ) [v0, v1];

function edge_length(e, idx) =
  let(v = edge_vertices(e, idx), d = [v[1][0]-v[0][0], v[1][1]-v[0][1]])
  sqrt(d[0]*d[0] + d[1]*d[1]);
  
// Place feature of given type on edge idx at distance 'dist' from v0.
// tab=true -> outward; tab=false -> inward (+180°).
module place_feature_on_edge(e, idx, dist, tab=true, ftype="rect") {
  v  = edge_vertices(e, idx);
  v0 = v[0]; v1 = v[1];
  d  = [v1[0]-v0[0], v1[1]-v0[1]];
  L  = sqrt(d[0]*d[0] + d[1]*d[1]);
  u  = [d[0]/L, d[1]/L];
  t  = clampv(dist, edge_margin, L-edge_margin);
  pos = [ v0[0] + u[0]*t, v0[1] + u[1]*t ];

  edge_ang = atan2(d[1], d[0]);
  face_ang = (edge_ang - 90) + (tab ? 0 : 180);

  translate(pos)
    rotate(face_ang)
      feature_shape_by_type(ftype, tab);
}


// Place a feature on edge idx at a distance 'dist' from v0.
// If tab=true it faces outward; if tab=false (slot), it faces inward by +180°.
/*module place_feature_on_edge(e, idx, dist, tab=true) {
  v  = edge_vertices(e, idx);
  v0 = v[0];
  v1 = v[1];
  d  = [v1[0]-v0[0], v1[1]-v0[1]];
  L  = sqrt(d[0]*d[0] + d[1]*d[1]);
  u  = [d[0]/L, d[1]/L];                         // along-edge unit
  pos = [ v0[0] + u[0]*clampv(dist, edge_margin, L-edge_margin),
          v0[1] + u[1]*clampv(dist, edge_margin, L-edge_margin) ];
  //dot(pos); 

  edge_ang = atan2(d[1], d[0]);                  // edge direction
  face_ang = (edge_ang - 90) + (tab ? 0 : 180);  // slot faces inward

  translate(pos)
    rotate(face_ang)
      feature_shape(tab);
}
*/

module tile2d() {
  pairs = [
    [0, 3, pair_0_3, pair_0_3_type],
    [1, 4, pair_1_4, pair_1_4_type],
    [2, 5, pair_2_5, pair_2_5_type]
  ];

  difference() {
    union() {
      base_hex(edge_len);
      // tabs
      for (p = pairs)
        if (p[2]) place_feature_on_edge(edge_len, p[0], feat_dist, true,  p[3]);
    }
    // slots (mirrored offset along opposite edge)
    for (p = pairs)
      if (p[2]) place_feature_on_edge(edge_len, p[1], edge_len - feat_dist, false, p[3]);
  }
}

/*
// 2D tile with complementary features on opposite edges.
module tile2d() {
  pairs = [
    [0, 3, pair_0_3],   // edge 0 = tab, edge 3 = slot
    [1, 4, pair_1_4],
    [2, 5, pair_2_5]
  ];

  difference() {
    union() {
      base_hex(edge_len);

      // tabs
      for (p = pairs)
        if (p[2]) place_feature_on_edge(edge_len, p[0], feat_dist, true);
    }
    // slots (position mirrored along opposite edge)
//    for (p = pairs)
//      if (p[2]) {
//        L = edge_len;                  // for a regular hex, side length = e
//        // Edge length along each side equals 'edge_len'
//        // Mirror the offset along the opposite edge by measuring from its start:
//        place_feature_on_edge(edge_len, p[1], L - feat_dist, false);
//      }
    // slots (mirrored offset along the opposite edge)
    for (p = pairs)
      if (p[2]) {
        // For a regular hex, side length = edge_len for every edge.
        place_feature_on_edge(edge_len, p[1], edge_len - feat_dist, false);
      }

  }
}

*/

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

/*
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

*/

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
COLS = 3;
ROWS = 3;

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