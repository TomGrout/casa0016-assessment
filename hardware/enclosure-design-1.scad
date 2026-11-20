// Chem-Kinetic Disdrometer - flat waterproof enclosure (OpenSCAD)

// Coordinates: TOP VIEW of the PCB, x right, y up (KiCad y is flipped, so the
// back-side wire pads at KiCad y=-55 appear here at y=+55).

$fn = 120;

PCB_R      = 75;      // board radius
PCB_T      = 1.6;
HOLE_R     = 68;      // mounting-hole circle radius
HOLE_ANG   = 45;      // first hole angle, then every 90 deg
PIEZO_D    = 27;      // glued at centre, underside
PAD_Y      = 55;      // 4 wire pads at y=+55, x = -3.81,-1.27,+1.27,+3.81 (underside)

TILT       = 3;       // deg, board slopes so water runs off (+y side high, -y low)
FLOOR      = 4;       // floor thickness
H_CAV      = 30;      // cavity depth under PCB (at centre)
Z0         = FLOOR + H_CAV;   // PCB underside height at board centre

R_OUT      = 76;      // outer wall radius (1 mm proud of PCB edge)
R_WALL_IN  = 72.5;    // outer wall inner radius (3.5 mm wall)
R_RING     = 63;      // inner sealing ring, outer radius
R_CAV      = 57.8;    // electronics chamber radius (pads sit at r<=56.7)

G_R        = 60.5;    // gasket groove centre radius (clear of back traces at r>=62.2)
G_W        = 2.4;     // groove width
G_D        = 1.5;     // groove depth (use 2.0 mm EPDM/silicone cord -> ~25% squeeze)

BOSS_R     = 5;       // screw boss radius (fuses inner ring to outer wall)
INSERT_D   = 4.2;     // hole for M3 heat-set insert
INSERT_DEP = 6;

DRAIN_D    = 3;       // trough drain holes
GLAND_D    = 12.6;    // PG7 cable gland
VENT_D     = 12.2;    // M12x1.5 breather vent (stops condensation / pressure swings)
GZ         = FLOOR + 14;   // tunnel axis height

EAR_T      = 4;       // mounting ears (3x, for pole/wall clamp, M5)
ESP_L      = 55;      // ESP32 DevKit length  (check your board!)
ESP_W      = 28.5;
TRAY_CY    = 32;      // tray centre y (close to the wire pads, keeps piezo leads short)
RIM_H      = 6;

SHOW_PCB   = true;    // ghost the PCB, gasket and piezo for fit-checking (preview only)

module pcb_frame() { translate([0,0,Z0]) rotate([TILT,0,0]) children(); }
module above_pcb_plane() pcb_frame() translate([-200,-200,0]) cube([400,400,100]);

module trough() {            // hollow annulus between ring and outer wall (saves plastic, catches screw-hole water)
  translate([0,0,FLOOR]) difference() {
    cylinder(r=R_WALL_IN, h=100);
    translate([0,0,-1]) cylinder(r=R_RING, h=102);
    for (k=[0:3]) rotate([0,0,HOLE_ANG+90*k]) translate([HOLE_R,0,-1]) cylinder(r=BOSS_R, h=102);
  }
}
module cavity() translate([0,0,FLOOR]) cylinder(r=R_CAV, h=100);

module gasket_groove() pcb_frame() translate([0,0,-G_D]) difference() {
  cylinder(r=G_R+G_W/2, h=G_D+1);
  translate([0,0,-1]) cylinder(r=G_R-G_W/2, h=G_D+3);
}
module insert_holes() pcb_frame() for (k=[0:3])
  rotate([0,0,HOLE_ANG+90*k]) translate([HOLE_R,0,-INSERT_DEP]) cylinder(d=INSERT_D, h=INSERT_DEP+1);

module drains() for (a=[22.5:45:360]) rotate([0,0,a])
  translate([R_WALL_IN-1, 0, FLOOR+DRAIN_D/2]) rotate([0,90,0]) cylinder(d=DRAIN_D, h=6);

// side tunnel: sleeve carries a gland/vent through the trough; counterbore leaves 5.5 mm wall for the thread
module tunnel_add(a) rotate([0,0,a]) {
  translate([57,0,GZ]) rotate([0,90,0]) cylinder(d=26, h=21);
  translate([72,-13,0]) cube([7,26,GZ+13]);          // flat seat for the gland flange
}
module tunnel_cut(a, d) rotate([0,0,a]) {
  translate([50,0,GZ]) rotate([0,90,0]) cylinder(d=d, h=40);
  translate([50,0,GZ]) rotate([0,90,0]) cylinder(d=22, h=73.5-50);
}

module ears() for (a=[30,150,270]) rotate([0,0,a]) difference() {
  hull() {
    translate([R_OUT-4,0,0])  cylinder(r=6, h=EAR_T);
    translate([R_OUT+11,0,0]) cylinder(r=7, h=EAR_T);
  }
  translate([R_OUT+11,0,-1]) cylinder(d=5.5, h=EAR_T+2);
}

module esp_tray() translate([0,TRAY_CY,FLOOR-0.01]) difference() {
  translate([-(ESP_L+4)/2, -(ESP_W+4)/2, 0]) cube([ESP_L+4, ESP_W+4, RIM_H]);
  translate([-(ESP_L+1)/2, -(ESP_W+1)/2, -1]) cube([ESP_L+1, ESP_W+1, RIM_H+2]);
  translate([-10,-30,2]) cube([20,60,RIM_H]);        // side relief for wires / airflow
}

// ---- the part --------------------------------------------------------------
module body() difference() {
  union() {
    difference() {
      cylinder(r=R_OUT, h=Z0+10);
      trough();
      cavity();
    }
    tunnel_add(0);
    tunnel_add(180);
    ears();
    esp_tray();
  }
  tunnel_cut(180, GLAND_D);   // cable out on -x
  tunnel_cut(0,   VENT_D);    // breather on +x
  drains();
  gasket_groove();
  insert_holes();
  above_pcb_plane();
}

body();

// ---- ghosts for preview only (not exported if SHOW_PCB=false) --------------
if (SHOW_PCB) {
  %pcb_frame() difference() {
    cylinder(r=PCB_R, h=PCB_T);
    for (k=[0:3]) rotate([0,0,HOLE_ANG+90*k]) translate([HOLE_R,0,-1]) cylinder(d=3.2, h=PCB_T+2);
  }
  %pcb_frame() translate([0,0,-0.6]) cylinder(d=PIEZO_D, h=0.6);
  %pcb_frame() translate([0,0,-G_D]) rotate_extrude() translate([G_R,0]) circle(d=2);
}
