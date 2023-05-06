`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Lei Xia
// 
// Create Date: 04/04/2023 02:59:33 PM
// Design Name: LED_Controller
// Module Name: LED_Controller
// Project Name: LED_Controller
// Target Devices: XC7A35TCPG236-1
// Tool Versions: Vivado 2015.2
// Description: Control LED according to the data send from BUS
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LED_Controller(
    //Standard Signals
    input CLK,
    input RESET,
    //BUS Signals
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA,
    //Output LED
    output [7:0] LED_signal
    );
    reg LED_selected;

    initial begin
        LED_selected = 8'b0;
    end

    always @(posedge CLK) begin
        if (RESET) begin
            LED_selected = 8'b0;
        end
        else if (BUS_ADDR == 8'hC0) begin
            LED_selected = BUS_DATA;
        end
    end

    assign LED_signal = LED_selected;
    
endmodule
