
# 100MHz system clock
set_property PACKAGE_PIN P17 [get_ports sys_clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk_in]
create_clock -period 10.000 -name sys_clk_in [get_ports sys_clk_in]

# Reset
set_property PACKAGE_PIN P15 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

# SW0-SW7
set_property PACKAGE_PIN P5 [get_ports {sw_pin[0]}]
set_property PACKAGE_PIN P4 [get_ports {sw_pin[1]}]
set_property PACKAGE_PIN P3 [get_ports {sw_pin[2]}]
set_property PACKAGE_PIN P2 [get_ports {sw_pin[3]}]
set_property PACKAGE_PIN R2 [get_ports {sw_pin[4]}]
set_property PACKAGE_PIN M4 [get_ports {sw_pin[5]}]
set_property PACKAGE_PIN N4 [get_ports {sw_pin[6]}]
set_property PACKAGE_PIN R1 [get_ports {sw_pin[7]}]

# SW8-SW15
set_property PACKAGE_PIN U3 [get_ports {dip_pin[0]}]
set_property PACKAGE_PIN U2 [get_ports {dip_pin[1]}]
set_property PACKAGE_PIN V2 [get_ports {dip_pin[2]}]
set_property PACKAGE_PIN V5 [get_ports {dip_pin[3]}]
set_property PACKAGE_PIN V4 [get_ports {dip_pin[4]}]
set_property PACKAGE_PIN R3 [get_ports {dip_pin[5]}]
set_property PACKAGE_PIN T3 [get_ports {dip_pin[6]}]
set_property PACKAGE_PIN T5 [get_ports {dip_pin[7]}]

# LED0-LED15
set_property PACKAGE_PIN F6 [get_ports {led_pin[0]}]
set_property PACKAGE_PIN G4 [get_ports {led_pin[1]}]
set_property PACKAGE_PIN G3 [get_ports {led_pin[2]}]
set_property PACKAGE_PIN J4 [get_ports {led_pin[3]}]
set_property PACKAGE_PIN H4 [get_ports {led_pin[4]}]
set_property PACKAGE_PIN J3 [get_ports {led_pin[5]}]
set_property PACKAGE_PIN J2 [get_ports {led_pin[6]}]
set_property PACKAGE_PIN K2 [get_ports {led_pin[7]}]
set_property PACKAGE_PIN K1 [get_ports {led_pin[8]}]
set_property PACKAGE_PIN H6 [get_ports {led_pin[9]}]
set_property PACKAGE_PIN H5 [get_ports {led_pin[10]}]
set_property PACKAGE_PIN J5 [get_ports {led_pin[11]}]
set_property PACKAGE_PIN K6 [get_ports {led_pin[12]}]
set_property PACKAGE_PIN L1 [get_ports {led_pin[13]}]
set_property PACKAGE_PIN M1 [get_ports {led_pin[14]}]
set_property PACKAGE_PIN K3 [get_ports {led_pin[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led_pin[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw_pin[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dip_pin[*]}]
