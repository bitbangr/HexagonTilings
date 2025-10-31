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
pair_2_5 = false;     // Edges 2 & 5 (top-left & bottom-right)


// ---- choose feature types per opposite-edge pair ----
// Valid types: "rect", "triangle", "dovetail", "hook", "Lhook"
pair_0_3_type = "Lhook";     // A edge 0 tab, edge 3 slot
pair_1_4_type = "Lhook";
pair_2_5_type = "Lhook";

/* [Preview Options] */
show_grid = false;
show_measurements = true;  // Show debug measurement markers

// --- tweakables for fit ---
embed_eps  = 0.05;    // how far feature crosses into the hex (mm)
fit_clear = 0.15;     // positive = looser fit. Try 0.1–0.3 for FDM
edge_margin = 0.02;   // keep features away from vertices by this much


// ============================================================
// FEATURE SHAPE
// ============================================================

// Hook proportions (feel free to tweak)
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
// If tab=true it faces outward; if tab=false (slot), it faces inward by +180°.
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

// 2D tile with complementary features on opposite edges.
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
    // translate([xy[0], xy[1], 0]) tile3d();
    // translate([xy[0], xy[1], 0]) tile3d_through_orca();  
    translate([xy[0], xy[1], 0]) tile3d_through_orca_unit();  
  
   color(orca_insert_color)
          translate([xy[0], xy[1], 0])
            orca_insert();  
    
}

// Preview: rectangular block in axial coords
// Preview grid
COLS = 3;
ROWS = 3;

module show_tile_grid_pointy() {
  for (r = [0:ROWS-1])
    for (q = [0:COLS-1])
      tile_at_axial(q, r);

      echo("=====> show_tile_grid_pointy()");
}

// ============================================================
// Orca Inlay Parameters
// ============================================================
orca_svg      = "OrcaOpenSCAD_Plain.svg";
orca_scale    = [1.0, 1.0];     // XY scale for the SVG
orca_pos      = [15, 07];         // XY translation inside the tile
inlay_depth   = 3.4;            // how deep the pocket is in the tileq
insert_height = 3.4;            // how tall the separate orca insert is
inlay_clear   = 0.10;           // XY clearance (mm) so insert fits the pocket
orca_insert_color = "orange";

orca_rot     = 0;            // degrees

//fit_clear    = 0.20;         // clearance so the insert fits the cutout
//insert_height= thickness;    // height for printed insert (adjust as you like)


// 2D Orca outline from SVG (centered)
module orca2d() {
//color(orca_insert_colour);
  translate(orca_pos)
    rotate(orca_rot)
      scale(orca_scale)
        import(orca_svg, center=true, dpi=25.4);
}


// Separate 3D Orca insert
module orca_insert() {
color(orca_insert_color)
  // Slightly smaller XY (negative offset) so it slides into the pocket
  linear_extrude(height = insert_height)
    offset(delta = -inlay_clear)
      orca2d();
}

// Tile with an Orca pocket cut into the top face
module tile_with_orca_pocket() {
  difference() {
    // your existing 3D tile (with edge features)
    tile3d();

    // Cut the pocket down from the top by 'inlay_depth'
    translate([0,0,thickness - inlay_depth])
      linear_extrude(height = inlay_depth + 0.01)  // +ε to guarantee a clean cut
        offset(delta = +inlay_clear)               // pocket a bit larger than insert
          orca2d();
  }
}

module tile3d_through_orca() {
  difference() {
    tile3d();  // your existing tile (with edge features)
    // Cut completely through (add a tiny extra to guarantee the cut)
    translate([0,0,-0.05])
      linear_extrude(thickness + 0.1)
        // make the cutout slightly larger for a slip fit
        offset(delta = +fit_clear)
          orca2d();
  }
}


// Build the repeating Orca motif in THIS TILE'S local frame.
// A small window of axial offsets (-1..1) is enough to capture neighbors.
module repeating_orca_cutters_local(qmin=-1, qmax=1, rmin=-1, rmax=1) {
  for (r = [rmin:rmax])
    for (q = [qmin:qmax]) {
      ctr = axial_to_xy(q, r, edge_len);   // neighbor tile center offset
      translate(ctr)
        orca2d();                          // your existing pose (translate->rotate->scale->import)
    }
}

module tile3d_through_orca_unit() {
  difference() {
    tile3d();  // your existing tile with edge features
    // subtract all nearby Orca repeats so fin/tail/nose show on this one tile
    translate([0,0,-0.05])
      linear_extrude(thickness + 0.1)
        offset(delta = +fit_clear)
          repeating_orca_cutters_local(-1, 1, -1, 1);
  }
}


// ============================================================
// RENDER
// ============================================================

if (show_grid) {
  show_tile_grid_pointy();
  if (show_measurements) {
    translate([0, 0, 0]) show_debug_markers();
  }
//} else {
//  tile3d_through_orca();
//  orca_insert();
//  if (show_measurements) {
//    show_debug_markers();
//  }
//}
    } else {
      // Single “unit” tile that shows nose/fin/tail cutouts from neighbors
      tile3d_through_orca_unit();

      // (Optional) comment out the next line; the single insert at origin
      // does not match the unit-tile fragments.
      orca_insert();

      if (show_measurements) show_debug_markers();
    }



////// comment out the grid preview while exporting
////// show_tile_grid_pointy();
////tile_with_orca_pocket();
////
////color ("brown")
////orca_insert();
