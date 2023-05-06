`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 10.03.2023 18:01:08
// Design Name: Yang Cen
// Module Name: buttonDetecor
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: detect button;s falling edge and combine them in an 4 bits array
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module buttonDetecor(
    //standard signals
    input CLK,
    input RESET,
    //button signal in
    input [3:0] BUTTON_IN,
    output [3:0] BUTTON_EDGE_OUT,
    output INTERRUPT_OUT
    );
    
    //button's delay signal
    reg [3:0] button_DLY;
    
    //record last button's state
    always @(posedge CLK) begin
        if (RESET)
            button_DLY <= 4'd0;
        else
            button_DLY <= BUTTON_IN;
    end
    
    //find their falling edges
    assign BUTTON_EDGE_OUT = button_DLY & ~BUTTON_IN;
    assign INTERRUPT_OUT = |BUTTON_EDGE_OUT;
    
endmodule
