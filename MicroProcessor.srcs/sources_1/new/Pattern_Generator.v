`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Lei Xia
// 
// Create Date: 2023/03/01 18:07:49
// Design Name: Pattern_Generator
// Module Name: Pattern_Generator
// Project Name: VGA_Controller
// Target Devices: XC7A35TCPG236-1
// Tool Versions: Vivado 2015.2
// Description: Generate initial pattern to frame buffer
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Pattern_Generator(
    input CLK,
    input RESET,
    output A_WE,
    output [14:0] pixel_ADDR,
    output Pixel_DATA,
    output initialed
//    output [15:0] CONFIG_COLOURS        
    );
    reg [6:0] VADDR;
    reg [7:0] HADDR;
    reg [31:0] cnt;
//    reg [7:0] colour1;
//    reg [7:0] colour2;
    reg initial_complete;
    parameter Vmax = 120;
    parameter Hmax = 160;

    
    initial begin
//        colour1 = 8'b10101010;
//        colour2 = 8'b01010101;
        VADDR = 7'b0;
        HADDR = 8'b0;
        cnt = 32'b0;
        initial_complete = 1'b0;
    end
    
    //Add h address per clock cycle
    always @(posedge CLK or posedge RESET) begin
        if(RESET) begin
            HADDR <= 8'b0;
        end
        else begin
            if(HADDR < Hmax-1'b1) begin
                HADDR <= HADDR + 1'b1;
            end
            else begin
                HADDR <= 8'b0;
            end
        end
    end    
    //Add v address per 160 h address changes
    always @(posedge CLK or posedge RESET) begin
        if(RESET) begin
            VADDR <= 7'b0;
        end
        else if(HADDR == Hmax-1'b1) begin
            if(VADDR < Vmax-1'b1) begin
                VADDR <= VADDR + 1'b1;
            end
            else begin
                VADDR <= 7'b0;
                initial_complete <= 1'b1;
            end
        end
    end
    
    assign pixel_ADDR = initial_complete ? 15'bz: {VADDR, HADDR};
    // to show the specified pattern
    assign Pixel_DATA = initial_complete ? 1'bz: (((VADDR[0] == 0)&&(HADDR[0] == 0)) ? 1'b1 : 1'b0);
    //need to write 160*120 pixels data
    assign A_WE =  initial_complete ? 1'bz:((cnt < (Vmax * Hmax)) ? 1'b1 : 1'b0);
//    assign CONFIG_COLOURS = initial_complete ? 16'bz:{colour1,colour2};
    assign initialed = initial_complete;
endmodule
