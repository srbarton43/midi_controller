## This file is a general .xdc for the Basys3 rev B board for ENGS31/CoSc56
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##====================================================================
## External_Clock_Port
##====================================================================
set_property PACKAGE_PIN W5 [get_ports hw_clk_port]							
	set_property IOSTANDARD LVCMOS33 [get_ports hw_clk_port]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports hw_clk_port]

##====================================================================
## Pmod Header JA
##====================================================================
#Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {spi_cs_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs_port}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {spi_data_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_data_port}]
#Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA_port[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {JA_port[2]}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {spi_sclk_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_sclk_port}]

#sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {take_sample_port}]
#set_property IOSTANDARD LVCMOS33 [get_ports {take_sample_port}]

##====================================================================
## Pmod Header JB
##====================================================================
##Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {midi_in_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {midi_in_port}]

##====================================================================
## Implementation Assist
##====================================================================	
## These additional constraints are recommended by Digilent, do not remove!
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

##Pmod Header JB


##Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {JB[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[4]}]
##Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {JB[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[5]}]
##Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {JB[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[6]}]
##Sch name = JB10 
#set_property PACKAGE_PIN C16 [get_ports {JB[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[7]}]
 
