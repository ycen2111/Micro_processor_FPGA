`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Lei Xia
// 
// Create Date: 2023/02/27 11:58:52
// Design Name: Frame_Buffer
// Module Name: Frame_Buffer
// Project Name: VGA_Interface
// Target Devices: XC7A35TCPG236-1
// Tool Versions: Vivado 2015.2
// Description: Frame buffer for VGA signal generator
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Frame_Buffer(
    /// Port A - Read/Write
    input A_CLK,
    input [14:0] A_ADDR, // 8 + 7 bits = 15 bits hence [14:0]
    input A_DATA_IN, // Pixel Data In
    output reg A_DATA_OUT,
    input A_WE, // Write Enable
    //Port B - Read Only
    input B_CLK,
    input [14:0] B_ADDR, // Pixel Data Out
    output reg B_DATA
    );
    // A 256 x 128 1-bit memory to hold frame data
    //The LSBs of the address correspond to the X axis, and the MSBs to the Y axis
    reg [0:0] Mem [2**15-1:0];
    // Load initial pattern
    initial $readmemh("InitialVGAFrameBuffer.txt", Mem);
    // Port A - Read/Write e.g. to be used by microprocessor
    always@(posedge A_CLK) begin
    if(A_WE)
    Mem[A_ADDR] <= A_DATA_IN;
    A_DATA_OUT <= Mem[A_ADDR];
    end
    // Port B - Read Only e.g. to be read from the VGA signal generator module for display
    always@(posedge B_CLK)
    B_DATA <= Mem[B_ADDR];
endmodule
