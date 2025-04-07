#Clock
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property PACKAGE_PIN M21 [get_ports sys_clk]

#Reset Button 
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property PACKAGE_PIN H7 [get_ports sys_rst_n]

#UART 
set_property PACKAGE_PIN F3 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN E3 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

#Built In LEDs 
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN G20 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN G21 [get_ports {leds[1]}]


#PMOD A
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[4]}]
#set_property PACKAGE_PIN P23 [get_ports {pmod_a[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[5]}]
#set_property PACKAGE_PIN R23 [get_ports {pmod_a[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[6]}]
#set_property PACKAGE_PIN T24 [get_ports {pmod_a[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[7]}]
#set_property PACKAGE_PIN T25 [get_ports {pmod_a[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[0]}]
#set_property PACKAGE_PIN N24 [get_ports {pmod_a[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[1]}]
#set_property PACKAGE_PIN P24 [get_ports {pmod_a[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[2]}]
#set_property PACKAGE_PIN R22 [get_ports {pmod_a[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a[3]}]
#set_property PACKAGE_PIN T23 [get_ports {pmod_a[3]}]