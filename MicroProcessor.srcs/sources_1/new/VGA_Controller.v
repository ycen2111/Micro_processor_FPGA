`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Lei Xia
// 
// Create Date: 2023/02/27 12:01:38
// Design Name: VGA_Controller
// Module Name: VGA_Controller
// Project Name: VGA_Controller
// Target Devices: XC7A35TCPG236-1
// Tool Versions: Vivado 2015.2
// Description: Receive BUS data from CPU to control VGA
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Controller(
    //Standard Signals
    input CLK,
    input RESET,
    //BUS Signals
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA,
    //VGA Signals
    output  VGA_HS,
    output  VGA_VS,
    output [7:0] VGA_COLOUR
//    output DPR_CLK
    );
    wire B_DATA;
    wire [14:0] B_ADDR;    
    wire CLK_50M;
    wire A_DATA_IN, A_DATA_OUT;
    wire [14:0] A_ADDR;
    wire A_WE;
    wire [15:0] CONFIG_COLOURS;
    wire DPR_CLK;
    //If initialization complete, become 1
    wire initialed;

    Frequency_Divider Frequency_Divider(
        .CLK(CLK),
        .RESET(RESET),
        .CLK_Divided(CLK_50M)
        );
    
    Frame_Buffer Frame_Buffer(
        .A_CLK(CLK),
        .A_ADDR(A_ADDR), // 8 + 7 bits = 15 bits hence [14:0]
        .A_DATA_IN(A_DATA_IN), // Pixel Data In
        .A_DATA_OUT(A_DATA_OUT),
        .A_WE(A_WE), // Write Enable
        //Port B - Read Only
        .B_CLK(CLK_50M),
        .B_ADDR(B_ADDR), // Pixel Data Out
        .B_DATA(B_DATA)
    );
    VGA_Sig_Gen VGA_Sig_Gen(
        .CLK(CLK_50M),
        .RESET(RESET),
        //Colour Configuration Interface
        .CONFIG_COLOURS(CONFIG_COLOURS),
        // Frame Buffer (Dual Port memory) Interface
        .DPR_CLK(DPR_CLK),
        .VGA_ADDR(B_ADDR),
        .VGA_DATA(B_DATA),
        //VGA Port Interface
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR(VGA_COLOUR)
    );
    
    reg [7:0]DATA1,DATA2,COLOUR1,COLOUR2;
    reg currWE,nextWE,pixel;
    reg pre_pixel;
    reg RE;
    always @(posedge CLK) begin
        currWE = nextWE;
        if (RESET) begin
            DATA1 = 8'b0;
            DATA2 = 8'b0;
            COLOUR1 = 8'b0;
            COLOUR2 = 8'b0;
            currWE = 1'b0;
            pixel = 1'b0;
        end
        else if( BUS_ADDR == 8'hB0) begin
            DATA1 = BUS_DATA;
        end
        else if( BUS_ADDR == 8'hB1) begin
            DATA2 = BUS_DATA[6:0];
        end
        else if( BUS_ADDR == 8'hB2) begin
            COLOUR1 = BUS_DATA;
        end
        else if( BUS_ADDR == 8'hB3) begin
            COLOUR2 = BUS_DATA;
        end
        else if( BUS_ADDR == 8'hB4) begin
            nextWE = BUS_DATA[0];
            pixel = BUS_DATA[4];
            RE = BUS_DATA[1];
        end        
        if (currWE == 1'b1) begin
            nextWE = 1'b0;
            pre_pixel = A_DATA_OUT;
        end
        if (RE == 1'b1) begin
            pixel = pre_pixel;
            RE = 1'b0;
            nextWE = 1'b1;
        end                        
    end    
    
    assign A_WE =  currWE;
    assign A_ADDR = {DATA2[6:0],DATA1};      
    assign A_DATA_IN = pixel;
    assign CONFIG_COLOURS = {COLOUR1,COLOUR2};
    
endmodule