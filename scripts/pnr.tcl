# Place & route with IC Compiler II (ASAP7): floorplan -> power grid -> place -> CTS -> route
set DESIGN mac
set A      $::env(ASAP7)
set_host_options -max_cores 4
file mkdir rpt

file delete -force $DESIGN.nlib
create_lib $DESIGN.nlib -technology $A/asap7.tf -ref_libs [list $A/ndm/asap7sc7p5t_lvt.ndm]
read_verilog -top $DESIGN out/$DESIGN.v
current_block $DESIGN
link_block
source $A/asap7_dirs.tcl

# parasitics + one functional scenario, constraints from synthesis
read_parasitic_tech -tlup $A/tlup/asap7.tluplus -layermap $A/tlup/asap7.tluplus.map -name tlup_typ
remove_modes -all; remove_corners -all; remove_scenarios -all
create_mode func; create_corner tt
set_parasitic_parameters -corners tt -early_spec tlup_typ -late_spec tlup_typ
create_scenario -name func_tt -mode func -corner tt
current_scenario func_tt
read_sdc out/$DESIGN.sdc
set_scenario_status func_tt -active true -setup true -hold true

# ---------------------------------------------------------------- floorplan
set_attribute [get_site_defs asap7sc7p5t] is_default true
set_attribute [get_site_defs asap7sc7p5t] symmetry {Y}
initialize_floorplan -core_utilization 0.6 -shape R -side_ratio {1 1} -core_offset {0.54}
remove_tracks -all
foreach {l d off p} {M1 X 0.009 0.036  M3 X 0.009 0.036  M4 Y 0.012 0.048  M5 X 0.012 0.048
                     M6 Y 0.016 0.064  M7 X 0.016 0.064  M8 Y 0.116 0.08   M9 X 0.116 0.08} {
  create_track -layer $l -dir $d -coord $off -space $p
}
foreach off {0.045 0.081 0.117 0.153 0.189 0.225} { create_track -layer M2 -dir Y -coord $off -space 0.27 }
set_ignored_layers -min_routing_layer M2 -max_routing_layer M6
set_block_pin_constraints -self -allowed_layers {M4 M5} -sides {1 2 3 4}
place_pins -self

# ---------------------------------------------------------------- power grid: M1/M2 rails + M5/M6 mesh
create_net -power VDD; create_net -ground VSS
connect_pg_net -automatic
create_pg_std_cell_conn_pattern rail -layers {M1 M2} -rail_width {0.018 0.018}
create_pg_mesh_pattern m5m6 -layers { \
  {{vertical_layer: M5}   {width: 0.12}  {spacing: interleaving} {pitch: 5.4} {offset: 0.3}} \
  {{horizontal_layer: M6} {width: 0.288} {spacing: interleaving} {pitch: 5.4} {offset: 0.513}}}
set_pg_strategy rails -core -pattern {{name: rail} {nets: {VDD VSS}}}
set_pg_strategy mesh  -core -pattern {{name: m5m6} {nets: {VDD VSS}}}
compile_pg -strategies {rails mesh}

# ---------------------------------------------------------------- place / CTS / route
place_opt
clock_opt
route_auto
route_opt
connect_pg_net -automatic

report_qor -summary                      > rpt/pnr.qor
report_timing                            > rpt/pnr.timing
report_timing -delay_type min            > rpt/pnr_hold.timing
report_utilization                       > rpt/pnr.util
check_routes                             > rpt/pnr.drc
save_block
write_verilog -exclude {pg_objects} out/$DESIGN.pnr.v
write_def out/$DESIGN.def
puts PNR_DONE
exit
