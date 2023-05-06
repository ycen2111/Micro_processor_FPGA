`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 16.02.2023 10:13:19
// Design Name: Yang Cen
// Module Name: TenHz_cnt
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: generate 10 Hz clk signal pulse
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TenHz_cnt(
    input CLK,
    input RESET,
    output pulse_10Hz
);

    // based on 100Mhz system clk
    // 100M/10=10M times
    parameter div_num=10000000;
    parameter half_div = div_num/2;
    
    wire n_RESET;
    
    reg [23:0] div_counter=24'd0;
    //reg CLK10Hz=1'd0;
    
    assign n_RESET = ~RESET;
    
    // counting the input clk
    always @(posedge CLK or negedge n_RESET) begin
        if (!n_RESET)
            div_counter<=24'd0;
        else begin
            if (div_counter==(div_num-'d1))
                div_counter<=24'd0;
            else
                div_counter<=div_counter+1'd1;
         end
     end
    
    //output a 1clk pulse, in frequency of 10 HZ
    assign pulse_10Hz=n_RESET?(div_counter==24'd1):1'd0;
    
endmodule
