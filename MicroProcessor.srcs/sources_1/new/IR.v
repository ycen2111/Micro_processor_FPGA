`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 08.03.2023 16:14:28
// Design Name: Yang Cen
// Module Name: IR
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: IR driver. collects command value from bus and combine 10hZ clk and IR transmitter together
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IR(
    //standard signals
    input CLK,
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    //IR output
    output IR_LED
);

    parameter [7:0] IRBaseAddr = 8'h90; // IR Base Address in the Memory Map
    
    //////////////////////
    //BaseAddr + 0 -> read BUS_DATA[3:0] to command[3:0]
    //BaseAddr + 1 -> read BUS_DATA[1:0] to car_ID

    wire SEND_PACKET;
    reg [3:0] COMMAND;
    reg [1:0] car_ID;
    reg [8:0] StartBurstSize;
    reg [8:0] GapSize;
    reg [8:0] CarSelectBurstSize;
    reg [8:0] AsserBurstSize;
    reg [8:0] DeAssertBurstSize;
    reg [11:0] half_div;
    
    //10Hz pulse output, inlength of 1 system clk
    TenHz_cnt clk_10Hz (.CLK(CLK),.RESET(RESET),.pulse_10Hz(SEND_PACKET));
    //generate IR LED signal
    IRTransmitterSM ir_signal (.CLK(CLK),.RESET(RESET),.COMMAND(COMMAND),.SEND_PACKET(SEND_PACKET),.StartBurstSize(StartBurstSize),.GapSize(GapSize),.CarSelectBurstSize(CarSelectBurstSize),.AsserBurstSize(AsserBurstSize),.DeAssertBurstSize(DeAssertBurstSize),.half_div(half_div),.IR_LED(IR_LED));
    
    always @(posedge CLK) begin
        if (RESET) begin
            COMMAND <= 4'd0;
            car_ID <= 2'd0;
        end
        else if ((BUS_ADDR == IRBaseAddr) & BUS_WE)
            COMMAND <= BUS_DATA[3:0];
        else if ((BUS_ADDR == IRBaseAddr + 8'h01) & BUS_WE)
            car_ID <= BUS_DATA[1:0];
    end
    
    /*
        blue:   f=36k,   191,25,47,47,22
        yellow: f=40k,   88 ,40,22,44,22
        green:  f=37.5k, 88 ,40,44,44,22
        red:    f=36k,   192,24,24,48,24
        */
        
    always @(*) begin
        if (RESET) begin
            StartBurstSize = 0;
            GapSize = 0;
            CarSelectBurstSize = 0;
            AsserBurstSize = 0;
            DeAssertBurstSize = 0;
            half_div = 0;
        end
        else begin
            case (car_ID)
                0: begin //blue
                    StartBurstSize = 191-1;
                    GapSize = 25-1;
                    CarSelectBurstSize = 47-1;
                    AsserBurstSize = 47-1;
                    DeAssertBurstSize = 22-1;
                    half_div = 1389;
                end
                1: begin //yellow
                    StartBurstSize = 88-1;
                    GapSize = 40-1;
                    CarSelectBurstSize = 22-1;
                    AsserBurstSize = 44-1;
                    DeAssertBurstSize = 22-1;
                    half_div = 1250;
                end
                2: begin //green
                    StartBurstSize = 88-1;
                    GapSize = 40-1;
                    CarSelectBurstSize = 44-1;
                    AsserBurstSize = 44-1;
                    DeAssertBurstSize = 22-1;
                    half_div = 1333;
                end
                3: begin //red
                    StartBurstSize = 192-1;
                    GapSize = 24-1;
                    CarSelectBurstSize = 24-1;
                    AsserBurstSize = 48-1;
                    DeAssertBurstSize = 24-1;
                    half_div = 1389;
                end
            endcase
        end
    end

endmodule