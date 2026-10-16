# Logic synthesis with Design Compiler (ASAP7 LVT, TT corner; units: ps, fF)
set DESIGN mac
set PERIOD 500
set ROOT   [file normalize [file dirname [info script]]/..]
file mkdir out rpt

set_app_var search_path    ". $::env(ASAP7)/db"
set_app_var target_library asap7sc7p5t_LVT_TT_merged.db
set_app_var link_library   "* $target_library"

analyze -format verilog $ROOT/rtl/$DESIGN.v
elaborate $DESIGN
link

create_clock -name clk -period $PERIOD [get_ports clk]
set_clock_uncertainty 20 [get_clocks clk]
set din [remove_from_collection [all_inputs] [get_ports {clk rst_n}]]
set_input_delay  [expr {0.2*$PERIOD}] -clock clk $din
set_output_delay [expr {0.2*$PERIOD}] -clock clk [all_outputs]
set_false_path -from [get_ports rst_n]
set_load 1.0 [all_outputs]

compile_ultra -no_autoungroup

report_qor              > rpt/syn.qor
report_timing           > rpt/syn.timing
report_area             > rpt/syn.area
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output out/$DESIGN.v
write_sdc out/$DESIGN.sdc
exit
