set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX_OUT[0]}]
set_property PACKAGE_PIN V7 [get_ports {HEX_OUT[7]}]
set_property PACKAGE_PIN U7 [get_ports {HEX_OUT[6]}]
set_property PACKAGE_PIN V5 [get_ports {HEX_OUT[5]}]
set_property PACKAGE_PIN U5 [get_ports {HEX_OUT[4]}]
set_property PACKAGE_PIN V8 [get_ports {HEX_OUT[3]}]
set_property PACKAGE_PIN U8 [get_ports {HEX_OUT[2]}]
set_property PACKAGE_PIN W6 [get_ports {HEX_OUT[1]}]
set_property PACKAGE_PIN W7 [get_ports {HEX_OUT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG_SELECT_OUT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG_SELECT_OUT[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG_SELECT_OUT[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG_SELECT_OUT[0]}]
set_property PACKAGE_PIN W4 [get_ports {SEG_SELECT_OUT[3]}]
set_property PACKAGE_PIN V4 [get_ports {SEG_SELECT_OUT[2]}]
set_property PACKAGE_PIN U4 [get_ports {SEG_SELECT_OUT[1]}]
set_property PACKAGE_PIN U2 [get_ports {SEG_SELECT_OUT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property PACKAGE_PIN W5 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK_MOUSE]
set_property PULLUP true [get_ports CLK_MOUSE]
set_property PULLUP true [get_ports DATA_MOUSE]
set_property IOSTANDARD LVCMOS33 [get_ports DATA_MOUSE]
set_property IOSTANDARD LVCMOS33 [get_ports IR_LED]
set_property PACKAGE_PIN C16 [get_ports IR_LED]
set_property PACKAGE_PIN C17 [get_ports CLK_MOUSE]
set_property PACKAGE_PIN B17 [get_ports DATA_MOUSE]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]
set_property PACKAGE_PIN R2 [get_ports RESET]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[3]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[4]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[5]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[6]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {LED_signal[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {BUTTON_IN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BUTTON_IN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BUTTON_IN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BUTTON_IN[0]}]
set_property PACKAGE_PIN W19 [get_ports {BUTTON_IN[3]}]
set_property PACKAGE_PIN T17 [get_ports {BUTTON_IN[2]}]
set_property PACKAGE_PIN T18 [get_ports {BUTTON_IN[1]}]
set_property PACKAGE_PIN U17 [get_ports {BUTTON_IN[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[0]}]
set_property PACKAGE_PIN G19 [get_ports {VGA_COLOUR[0]}]
set_property PACKAGE_PIN H19 [get_ports {VGA_COLOUR[1]}]
set_property PACKAGE_PIN J19 [get_ports {VGA_COLOUR[2]}]
set_property PACKAGE_PIN N18 [get_ports {VGA_COLOUR[6]}]
set_property PACKAGE_PIN J17 [get_ports {VGA_COLOUR[3]}]
set_property PACKAGE_PIN H17 [get_ports {VGA_COLOUR[4]}]
set_property PACKAGE_PIN G17 [get_ports {VGA_COLOUR[5]}]
set_property PACKAGE_PIN L18 [get_ports {VGA_COLOUR[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS]
set_property PACKAGE_PIN P19 [get_ports VGA_HS]
set_property PACKAGE_PIN R19 [get_ports VGA_VS]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets CLK_IBUF_BUFG]
