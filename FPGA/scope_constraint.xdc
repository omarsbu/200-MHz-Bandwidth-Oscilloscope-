## Clock: 100 MHz onboard oscillator
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0 5} [get_ports clk]

## Reset: BTN0
set_property PACKAGE_PIN U18 [get_ports i_reset]
set_property IOSTANDARD LVCMOS33 [get_ports i_reset]

## Timebase (5 switches: SW0–SW4)
set_property PACKAGE_PIN V17 [get_ports {i_timebase[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_timebase[0]}]

set_property PACKAGE_PIN V16 [get_ports {i_timebase[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_timebase[1]}]

set_property PACKAGE_PIN W16 [get_ports {i_timebase[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_timebase[2]}]

set_property PACKAGE_PIN W17 [get_ports {i_timebase[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_timebase[3]}]

set_property PACKAGE_PIN W15 [get_ports {i_timebase[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_timebase[4]}]

## Trigger type (SW5)
set_property PACKAGE_PIN V15 [get_ports i_trigger_type]
set_property IOSTANDARD LVCMOS33 [get_ports i_trigger_type]

## VGA RGB (12-bit)
set_property PACKAGE_PIN G19 [get_ports {RED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RED[0]}]

set_property PACKAGE_PIN H19 [get_ports {RED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RED[1]}]

set_property PACKAGE_PIN J19 [get_ports {RED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RED[2]}]

set_property PACKAGE_PIN N19 [get_ports {RED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RED[3]}]

set_property PACKAGE_PIN J17 [get_ports {GREEN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GREEN[0]}]

set_property PACKAGE_PIN H17 [get_ports {GREEN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GREEN[1]}]

set_property PACKAGE_PIN G17 [get_ports {GREEN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GREEN[2]}]

set_property PACKAGE_PIN D17 [get_ports {GREEN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GREEN[3]}]

set_property PACKAGE_PIN N18 [get_ports {BLUE[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BLUE[0]}]

set_property PACKAGE_PIN L18 [get_ports {BLUE[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BLUE[1]}]

set_property PACKAGE_PIN K18 [get_ports {BLUE[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BLUE[2]}]

set_property PACKAGE_PIN J18 [get_ports {BLUE[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BLUE[3]}]

## VGA Syncs
set_property PACKAGE_PIN P19 [get_ports H_SYNC]
set_property IOSTANDARD LVCMOS33 [get_ports H_SYNC]

set_property PACKAGE_PIN R19 [get_ports V_SYNC]
set_property IOSTANDARD LVCMOS33 [get_ports V_SYNC]
