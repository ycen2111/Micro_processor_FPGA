`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 10.03.2023 18:28:54
// Design Name: Yang Cen
// Module Name: Button
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: button driver. collects button release operation from buttonDetector, and output it to bus with an interrupt
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Button(
    //standard signals
    input CLK,
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    output BUS_INTERRUPT_RAISE,
    input BUS_INTERRUPT_ACK,
    //input button signal
    input [3:0] BUTTON_IN
    );
    
    parameter [7:0] ButtonBaseAddr = 8'hA5; // Button Base Address in the Memory Map
    parameter InitialIterruptEnable = 1'b1; // By default the Interrupt is Enabled
    
    //////////////////////
    //BaseAddr + 0 -> Read button state 1 for down, 2 for up, 3 for right, 4 for left
    //BaseAddr + 1 -> enable button [0]
    
    //buttonState[3:0] = {left, right, up, down}
    
    wire [3:0] BUTTON_EDGE_OUT;
    wire INTERRUPT_OUT;
    reg interrupt;
    reg interruptEnable;
    
    //read button's falling edge
    buttonDetecor buttonDetector_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //button signal in
        .BUTTON_IN(BUTTON_IN),
        .BUTTON_EDGE_OUT(BUTTON_EDGE_OUT),
        .INTERRUPT_OUT(INTERRUPT_OUT)
    );
    
    //whether enable the interruption
    always @(posedge CLK) begin
        if (RESET) begin
            interruptEnable <= InitialIterruptEnable;
        end
        else if ((BUS_ADDR == ButtonBaseAddr + 8'h01) && BUS_WE)
            interruptEnable <= BUS_DATA[0];
    end
    
    //save button edge to reg
    reg [7:0] buttonState;
    
    always @(posedge CLK) begin
        if (RESET)
            buttonState <= 0;
        else if (INTERRUPT_OUT)
            buttonState <= BUTTON_EDGE_OUT;
        else
            buttonState <= buttonState;
    end
    
    //output button falling state to bus
    reg transmitButtonValue;
    
    always @(posedge CLK) begin
        if (RESET)
            transmitButtonValue <= 0;
        else if (BUS_ADDR == ButtonBaseAddr)
            transmitButtonValue <= 1;
        else
            transmitButtonValue <= 0;
    end
    
    assign BUS_DATA = transmitButtonValue ? ((buttonState == 4'b0000) ? 8'd0 : (buttonState == 4'b0001) ? 8'd1 : (buttonState == 4'b0010) ? 8'd2 : (buttonState == 4'b0100) ? 8'd3 :(buttonState == 4'b1000) ? 8'd4 : 8'hZZ) : 8'hZZ;
    
    //control interruption signal
    always @(posedge CLK) begin
        if (RESET)
            interrupt <= 0;
        else begin
            if (INTERRUPT_OUT && interruptEnable)
                interrupt <= 1;
            else if (BUS_INTERRUPT_ACK)
                interrupt <= 0;
        end
    end
    
    assign BUS_INTERRUPT_RAISE = interrupt;
    
endmodule
