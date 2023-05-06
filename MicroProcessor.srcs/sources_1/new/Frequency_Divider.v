`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Lei Xia
// 
// Create Date: 2023/03/01 18:07:12
// Design Name: Frequency_Divider
// Module Name: Frequency_Divider
// Project Name: VGA_Interface
// Target Devices: XC7A35TCPG236-1
// Tool Versions: Vivado 2015.2
// Description: Divide 100MHz to 50MHz for VGA_Sig_Gen
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*Just divided the 100MHz to 50MHz*/
module Frequency_Divider(
    input CLK,
    input RESET,
    output CLK_Divided
    );
    reg CLK_2 = 1'b0;
    always@(posedge CLK) begin
        if(RESET)
            CLK_2 <= 0;
        else
            CLK_2 <= ~CLK_2; 
    end
    assign CLK_Divided = CLK_2;    
endmodule
