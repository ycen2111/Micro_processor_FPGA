`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 04.03.2023 18:29:58
// Design Name: Yang Cen
// Module Name: ROM
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: Read only file, can be read as the programe
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//read onlt 256*8
module ROM(
    //standard signals
    input CLK,
    //BUS signals
    output reg [7:0] DATA,
    input [7:0] ADDR
);
    parameter RAMAddrWidth = 8;
    //Memory
    reg [7:0] ROM [2**RAMAddrWidth-1:0];
    // Load program
    
    initial $readmemh("Complete_Demo_ROM.txt", ROM);
    //single port ram
    
    always@(posedge CLK)
        DATA <= ROM[ADDR];
endmodule
