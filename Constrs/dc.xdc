set Tclk 20
set unc_perc 0.02
create_clock -period $Tclk [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports clk]

set timing_remove_clock_reconvergence_pessimism true
set_critical_range [expr $Tclk * 0.1] $current_design 
set ideal_ports "clk rst_n"
set_ideal_network clk
set_ideal_network rst_n
set_input_delay [expr 0.2*$Tclk] -clock clk [remove_from_collection [all_inputs] $ideal_ports]
set_output_delay [expr 0.2*$Tclk] [all_outputs]
set_clock_uncertainty -setup [expr $Tclk * $unc_perc] [get_clocks clk]
set_clock_uncertainty -hold [expr $Tclk * [expr $unc_perc * 0.5]] [get_clocks clk]
set_input_transition 2.0 [remove_from_collection [all_inputs] $ideal_ports]
set_load 5 [all_outputs]

set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cs[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_dig_sel[0]}]


set_property PACKAGE_PIN N15 [get_ports rst_n]
set_property PACKAGE_PIN K17 [get_ports {o_dig_sel[6]}]
set_property PACKAGE_PIN M19 [get_ports {o_dig_sel[5]}]
set_property PACKAGE_PIN L19 [get_ports {o_dig_sel[4]}]
set_property PACKAGE_PIN J18 [get_ports {o_dig_sel[3]}]
set_property PACKAGE_PIN G19 [get_ports {o_dig_sel[2]}]
set_property PACKAGE_PIN F19 [get_ports {o_dig_sel[1]}]
set_property PACKAGE_PIN F16 [get_ports {o_dig_sel[0]}]
set_property PACKAGE_PIN K19 [get_ports {o_dig_sel[7]}]
set_property PACKAGE_PIN F17 [get_ports {cs[0]}]
set_property PACKAGE_PIN F20 [get_ports {cs[1]}]
set_property PACKAGE_PIN G20 [get_ports {cs[2]}]
set_property PACKAGE_PIN H18 [get_ports {cs[3]}]
set_property PACKAGE_PIN L20 [get_ports {cs[4]}]
set_property PACKAGE_PIN M20 [get_ports {cs[5]}]
set_property PACKAGE_PIN K18 [get_ports {cs[6]}]
set_property PACKAGE_PIN J19 [get_ports {cs[7]}]


set_property IOSTANDARD LVCMOS33 [get_ports {key[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[0]}]
set_property PACKAGE_PIN G17 [get_ports {key[5]}]
set_property PACKAGE_PIN E19 [get_ports {key[4]}]
set_property PACKAGE_PIN E18 [get_ports {key[3]}]
set_property PACKAGE_PIN G18 [get_ports {key[2]}]
set_property PACKAGE_PIN D20 [get_ports {key[1]}]
set_property PACKAGE_PIN D19 [get_ports {key[0]}]


set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN M14 [get_ports {led[0]}]
set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property PACKAGE_PIN K16 [get_ports {led[2]}]
set_property PACKAGE_PIN J16 [get_ports {led[3]}]




set_operating_conditions -grade extended
