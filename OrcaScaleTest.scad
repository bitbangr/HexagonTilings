orca_scale = [1.5, 1.5];
orca_pos   = [30, 10];

color("orange")
translate(orca_pos)
  scale(orca_scale)
    import("OrcaOpenSCAD_Plain.svg", center=true, dpi=25.4);