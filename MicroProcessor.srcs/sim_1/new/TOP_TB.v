`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2023 14:15:43
// Design Name: 
// Module Name: TOP_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP_TB();

    reg CLK, RESET;
    wire CLK_MOUSE, DATA_MOUSE;
    //reg [2:0] BUS_INTERRUPTS_RAISE_IN;
    wire IR_LED;
    wire [3:0] SEG_SELECT_OUT;
    wire [7:0] HEX_OUT;
    reg [3:0] BUTTON_IN;
    

    TOP UUT(
        //.BUS_INTERRUPTS_RAISE_IN(BUS_INTERRUPTS_RAISE_IN),
        //Basic signal
        .CLK(CLK),
        .RESET(RESET),
        //Mouse Bus
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        //IR output
        .IR_LED(IR_LED),
        //7 segments output
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_OUT),
        //Button
        .BUTTON_IN(BUTTON_IN)
        );
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RESET = 1;
        BUTTON_IN = 0;
        //BUS_INTERRUPTS_RAISE_IN = 3'b000;
        #50 RESET = 0; 
        //#50 BUS_INTERRUPTS_RAISE_IN = 3'b001;
        //#50 BUS_INTERRUPTS_RAISE_IN = 3'b000;
        #50000 BUTTON_IN = 4'b0001;
        #50 BUTTON_IN = 4'b0000;
        #5000 BUTTON_IN = 4'b0010;
        #50 BUTTON_IN = 4'b0000;
    end

endmodule
