`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2023 14:50:39
// Design Name: 
// Module Name: Stack
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


module Stack(
    //standard signals
    input CLK,
    input RESET,
    //BUS signals
    output reg [7:0] DATA_OUT,
    input [7:0] DATA_IN,
    input PUSH,
    input PULL,
    //output mark sign
    output EMPTY,
    output FULL
    );
    
    parameter STACKAddrWidth = 8;
    //Memory
    reg [7:0] STACK [2**STACKAddrWidth-1:0];
    reg [8:0] stackCounter;
    
    reg empty, full;
    
    // Load program
//    initial $readmemh("FILO_STACK.txt", RAM);
    
    //determine full signal
    always @(posedge CLK) begin
        if (RESET)
            full <= 0;
        else if (stackCounter[8])
            full <= 1;
        else
            full <= 0;
    end
    
    //determine empty signal
    always @(posedge CLK) begin
        if (RESET)
            empty <= 1;
        else if (stackCounter == 9'd0)
            empty <= 1;
        else
            empty <= 0;
    end
    
    assign FULL = full;
    assign EMPTY = empty;
    
    //stackCOunter control, -1 in pull and +1 in push
    always @(posedge CLK) begin
        if (RESET)
            stackCounter <= 9'd0;
        else if (PUSH && ~full)
            stackCounter <= stackCounter + 9'd1;
        else if (PULL && ~empty)
            stackCounter <= stackCounter - 9'd1;
    end
    
    //input or return data from stack
    always @(posedge CLK) begin
        if (PUSH && ~full) begin
            STACK [stackCounter[7:0]] <= DATA_IN;
        end
        else if (PULL && ~empty) begin
            DATA_OUT <= STACK [stackCounter[7:0] - 8'd1];
        end
    end
    
endmodule
