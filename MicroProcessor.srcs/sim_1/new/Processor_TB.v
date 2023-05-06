`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2023 14:48:52
// Design Name: 
// Module Name: Processor_TB
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


module Processor_TB();

    reg CLK,
    reg RESET,
    //BUS Signals
    wire [7:0] BUS_DATA,
    wire [7:0] BUS_ADDR,
    wire BUS_WE,
    // ROM signals
    wire [7:0] ROM_ADDRESS,
    reg [7:0] ROM_DATA,
    // INTERRUPT signals
    reg [2:0] BUS_INTERRUPTS_RAISE,
    output [2:0] BUS_INTERRUPTS_ACK

    Processor(
        //Standard Signals
        input CLK,
        input RESET,
        //BUS Signals
        inout [7:0] BUS_DATA,
        output [7:0] BUS_ADDR,
        output BUS_WE,
        // ROM signals
        output [7:0] ROM_ADDRESS,
        input [7:0] ROM_DATA,
        // INTERRUPT signals
        input [2:0] BUS_INTERRUPTS_RAISE,
        output [2:0] BUS_INTERRUPTS_ACK
    );

    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RESET = 1;
        BUTTON_IN = 0;
        #50 RESET = 0; 
    end

endmodule
