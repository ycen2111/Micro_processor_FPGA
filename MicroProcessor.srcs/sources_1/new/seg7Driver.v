`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 22.02.2023 14:16:16
// Design Name: Yang Cen
// Module Name: seg7Driver
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description:  7 segments driver. read seperatly X and Y value from bus and output them to 7-segments display.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seg7Driver(
    //standard signals
    input CLK, 
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    //7 segments output
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT
    );
    
    parameter [7:0] seg7BaseAddr = 8'hD0; // 7 segments Base Address in the Memory Map
        
    //////////////////////
    //BaseAddr + 0 -> read bus data to X (left two numbers)
    //BaseAddr + 1 -> read bus data to Y (right two numbers)
    
    //turn on or off dot LED
    parameter DOT = 1'd0;
    //display a "-"
    parameter DASH_SIGN = 8'b10111111;
    parameter SPEED = 2'b00;
    parameter init_process = 1'b0;
    
    //sweep switch counter and select
    reg [7:0] curr_counter, next_counter = 0;
    reg [1:0] curr_SEG_SELECT, next_SEG_SELECT = 2'b00;
    //record past clk's value
    reg [1:0] SPEED_DLY;
    reg [7:0] DATA_X_DLY, DATA_Y_DLY;
    reg Curr_disPosition, Next_disPosition;
    //4 bytes HEX display value
    wire [15:0] displayStream;
    //one byte that will be displayed in this moment
    wire [3:0] inputData;
    //decoded byte code
    wire [7:0] HEX_read;
    
    reg [7:0] DATA_X,DATA_Y;
    
    //decoded one byte to output
    seg7decoder seg(
        .SEG_SELECT_IN(curr_SEG_SELECT),
        .BIN_IN(inputData),
        .DOT_IN(DOT),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_read)
    );
    
    //read x value from bus
    always @(posedge CLK) begin
        if (RESET)
            DATA_X <= 8'h00;
        else if ((BUS_ADDR == seg7BaseAddr) & BUS_WE)
            DATA_X <= BUS_DATA;
    end
    
    //read y value from bus
        always @(posedge CLK) begin
            if (RESET)
                DATA_Y <= 8'h00;
            else if ((BUS_ADDR == seg7BaseAddr + 8'h01) & BUS_WE)
                DATA_Y <= BUS_DATA;
        end
    
    //counting sweep frequency
    always @(posedge CLK) begin
        if (curr_counter == 0)
            next_SEG_SELECT <= curr_SEG_SELECT + 1'b1;

        next_counter <= curr_counter + 1'b1;
    end
    
    //record past clk's vlaues
    always @(posedge CLK) begin
        if (RESET) begin
            SPEED_DLY <= 0;
            DATA_X_DLY <= 0;
            DATA_Y_DLY <= 0;
        end
        else begin
            SPEED_DLY <= SPEED;
            DATA_X_DLY <= DATA_X;
            DATA_Y_DLY <= DATA_Y;
        end
    end
    
    //copy next value into current variables
    always @(posedge CLK) begin
        curr_counter <= next_counter;
        curr_SEG_SELECT <= next_SEG_SELECT;
        Curr_disPosition <= Next_disPosition;
    end
    
    //determine whether display speed level or position value
    always @(*) begin
        Next_disPosition = Curr_disPosition;
    
        if ((DATA_X_DLY != DATA_X) || (DATA_Y_DLY != DATA_Y))
            Next_disPosition = 1'd1;
        else if (SPEED_DLY != SPEED)
            Next_disPosition = 1'd0;
    end
    
    //determine whether display speed level or position value
    assign displayStream = Curr_disPosition ? {DATA_X,DATA_Y} : {14'd0,SPEED_DLY};
    //pass 1 byte into 7-segments decoder in each time
    assign inputData = (curr_SEG_SELECT == 2'b00) ? displayStream[3:0] : (curr_SEG_SELECT == 2'b01) ? displayStream[7:4] : (curr_SEG_SELECT == 2'b10) ? displayStream[11:8] : displayStream[15:12];
    //output "-" sign if mouse is in init state
    assign HEX_OUT = init_process ? DASH_SIGN : HEX_read;
    
endmodule
