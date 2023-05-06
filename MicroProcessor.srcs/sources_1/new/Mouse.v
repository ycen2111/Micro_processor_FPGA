`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 08.03.2023 12:33:08
// Design Name: Yang Cen
// Module Name: Mouse
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: Mouse driver. It receives exact mouse position from transciver, and output it with an interrupt
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mouse(
    //standard signals
    input CLK,
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    output BUS_INTERRUPT_RAISE,
    input BUS_INTERRUPT_ACK,
    //Mouse Bus
    inout CLK_MOUSE,
    inout DATA_MOUSE
    );
    
    parameter [7:0] MouseBaseAddr = 8'hA0; // Mouse Base Address in the Memory Map
    parameter InitialIterruptEnable = 1'b1; // By default the Interrupt is Enabled
    parameter InitialSensitivity = 2'b00;
    
    //////////////////////
    //BaseAddr + 0 -> Read X value
    //BaseAddr + 1 -> Read Y vlaue
    //BaseAddr + 2 -> enable/disable mouse interrupt
    //BaseAddr + 3 -> set mouse sensitivity (0100 for adding, 1000 for sub)
    //BaseAddr + 4 -> Read Sensitivity

    wire [7:0] MouseX, MouseY;
    wire [3:0] MouseStatus;
    
    wire INTERRUPT_OUT;
    reg interrupt;
    
    reg [1:0] sensitivity;
    reg Interrupt_Enable;
    //send X or Y value to bus data
    reg send_A, send_B, send_sensitivity;
    
    //transmite with mouse device and output interrupt sign and mouse x/y axis value
    MouseTransceiver Transceiver(
        //output [3:0] M_state_check,
        //output [3:0] T_state_check,
        //output [2:0] R_state_check,
        
        .distance_times(sensitivity),
    
        //Standard Inputs
        .RESET(RESET),
        .CLK(CLK),
        //IO - Mouse side
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        // Mouse data information
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY),
        //Interrupt signal
        .INTERRUPT_OUT(INTERRUPT_OUT)
    );
    
    //read interrupt state and mouse sensitivity
    always@(posedge CLK) begin
        if (RESET)
            Interrupt_Enable <= InitialIterruptEnable;
        else if ((BUS_ADDR == MouseBaseAddr + 8'h2) && BUS_WE) begin
            Interrupt_Enable <= BUS_DATA[0];
        end
    end
    
    //receive button state to set sensitivity
    always @(posedge CLK) begin
        if (RESET)
            sensitivity <= InitialSensitivity;
        else if ((BUS_ADDR == MouseBaseAddr + 8'h3) && BUS_WE) begin
                if (BUS_DATA[3:2] == 2'b01)
                    sensitivity <= sensitivity + 2'd1;
                else if (BUS_DATA[3:2] == 2'b10)
                    sensitivity <= sensitivity - 2'd1;
                else
                    sensitivity <= sensitivity;
        end
    end
    
    //maek the interrupt
    always @(posedge CLK) begin
        if (RESET)
            interrupt <= 0;
        else begin
            if (INTERRUPT_OUT && Interrupt_Enable)
                interrupt <= 1;
            else if (BUS_INTERRUPT_ACK)
                interrupt <= 0;
        end
    end
    //assign BUS_INTERRUPT_RAISE = Interrupt_Enable ? INTERRUPT_OUT : 1'b0;
    assign BUS_INTERRUPT_RAISE = interrupt;

    // send X axis to bus data
    always@(posedge CLK) begin
        if (BUS_ADDR == MouseBaseAddr)
            send_A <= 1'd1;
        else
            send_A <= 1'd0;
    end
    
    //send Y axis to bus data
    always@(posedge CLK) begin
        if (BUS_ADDR == MouseBaseAddr + 8'h1)
            send_B <= 1'd1;
        else
            send_B <= 1'd0;
    end
    
    //send sensitivity to bus data
        always@(posedge CLK) begin
            if (BUS_ADDR == MouseBaseAddr + 8'h4)
                send_sensitivity <= 1'd1;
            else
                send_sensitivity <= 1'd0;
        end
    
    assign BUS_DATA = send_A ? MouseX : send_B ? MouseY : send_sensitivity ? {6'd0,sensitivity} : 8'hZZ;

endmodule
