#Clock

#set_property -dict { PACKAGE_PIN AB11 IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_200_p]
#set_property -dict { PACKAGE_PIN AC11 IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_200_n]
#create_clock -period  5.000 [get_ports sysclk_200_p]

#set_property -dict { PACKAGE_PIN F6   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_150_p]
#set_property -dict { PACKAGE_PIN F5   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_150_n]
#create_clock -period  6.667 [get_ports sysclk_150_p]

#set_property -dict { PACKAGE_PIN D6   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_156_p]
#set_property -dict { PACKAGE_PIN D5   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_156_n]
#create_clock -period  6.400 [get_ports sysclk_156_p]

set_property -dict { PACKAGE_PIN F17  IOSTANDARD LVCMOS33    } [get_ports sysclk_50]
create_clock -period 20.000 [get_ports sysclk_50]


#Reset Button 
set_property IOSTANDARD LVCMOS15 [get_ports sys_rst_n]
set_property PACKAGE_PIN AC16 [get_ports sys_rst_n]

#UART 
set_property PACKAGE_PIN K21 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN L23 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

#Built In LEDs 
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
#set_property PACKAGE_PIN Y12 [get_ports {leds[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
#set_property PACKAGE_PIN V11 [get_ports {leds[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
#set_property PACKAGE_PIN W11 [get_ports {leds[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
#set_property PACKAGE_PIN AE10 [get_ports {leds[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[4]}]
#set_property PACKAGE_PIN Y10 [get_ports {leds[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[5]}]
#set_property PACKAGE_PIN W10 [get_ports {leds[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[6]}]
#set_property PACKAGE_PIN AD5 [get_ports {leds[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[7]}]
#set_property PACKAGE_PIN AA2 [get_ports {leds[7]}]


#############SPI Configurate Setting##################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]