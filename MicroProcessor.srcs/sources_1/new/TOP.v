`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 05.03.2023 16:32:09
// Design Name: Yang Cen
// Module Name: TOP
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: TOP file to conbine all blockes together
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP(
    //Standard Signal
    input CLK,
    input RESET,
    //Mouse Bus
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    //IR output
    output IR_LED,
    //7 segments output
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT,
    //four buttons input
    input [3:0] BUTTON_IN,
    //VGA Signals
    output  VGA_HS,
    output  VGA_VS,
    output [7:0] VGA_COLOUR,
    output [7:0] LED_signal
    );
    
    //ROM data and address, which saved programes
    wire [7:0] ROM_DATA,ROM_ADDRESS;
    //bus data and address
    wire [7:0] BUS_DATA,BUS_ADDR;
    //write ensble, telling module to read the data from bus
    wire BUS_WE;
    //the interrupt signal, sepretely {button, IR, Mouse}
    wire [2:0] BUS_INTERRUPTS_RAISE, BUS_INTERRUPTS_ACK;
    
    /*
    micro processor. it controls bus address and bus data, output write enable signal, and read ROM to output instruments
    
    Instruction            First Byte          Second Byte 
    --------------------------------------------------------
    A <- [Mem_ADD]         X0                  Mem_ADD
    B <- [Mem_ADD]         X1                  Mem_ADD
    [Mem_ADD] <- A         X2                  Mem_ADD
    [Mem_ADD] <- B         X3                  Mem_ADD
    A <- ALU_OP(A,B)       {ALU_code,4}     /
    B <- ALU_OP(A,B)       {ALU_code,5}     /
    BREQ ADDR (A=B)        96                  Mem_ADD
    BGTQ ADDR (A>B)        A6                  Mem_ADD
    BLTQ ADDR (A<B)        B6                  Mem_ADD
    GOTO ADDR              X7                  Mem_ADD
    GOTO_IDLE              X8                  /
    FUNCTION_CALL ADDR     X9                  Mem_ADD
    RETURN                 XA                  /
    A <- [A]               XB                  /
    B <- [B]               XC                  /
    */
    Processor P_0(
        //Standard Signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS Signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // ROM signals
        .ROM_ADDRESS(ROM_ADDRESS),
        .ROM_DATA(ROM_DATA),
        // INTERRUPT signals
        .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
        .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)
    );
    
    //ROM block. read only memery. saved running programes to run in FPGA. has 256 address
    ROM ROM_0(
        //standard signals
        .CLK(CLK),
        //BUS signals
        .DATA(ROM_DATA),
        .ADDR(ROM_ADDRESS)
    );
    
    //RAM block. read and write memory. save other register values. has 128 address
    RAM RAM_0(
        //standard signals
        .CLK(CLK),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE)
    );
    
    /*
    Timer block. will default output 1 interrupt after 1s
    
    Address             Description
    ----------------------------------
    F0                  read current timer value (timer[7:0])
    F1                  set interrupt ratio (send 100 as 100ms)
    F2                  reset timer to 0
    F3                  set whether interrupt enable [0]
    */
    Timer Timer_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPTS_RAISE[1]),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPTS_ACK[1])
    );
    
    /*
    Mouse block. read the value from mouse, and send an interrupt to output the value. can set sensitivity.
    
    Address             Description
    --------------------------------------
    A0                  Read X axis
    A1                  Read Y axis
    A2                  set whether interrupt enable [0]
    A3                  set mouse sensitivity (0100 for adding, 1000 for sub)
    A4                  Read Sensitivity
    */
    Mouse Mouse_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPTS_RAISE[0]),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPTS_ACK[0]),
        //Mouse Bus
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE)
    );
    
    /*
    IR block. it reads the command from bus, and output IR signal to car
    
     Address             Description
     --------------------------------------
     90                  send command[3:0]
    */
    IR IR_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        //IR output
        .IR_LED(IR_LED)
    );
    
    /*
    7 segments display block. it reads seperatly x and y values, and output them out
    
    Address             Description
     --------------------------------------
     D0                  read bus data to X (left two numbers)
     D1                  read bus data to Y (right two numbers)
    */
    seg7Driver seg7_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        //7 segment output
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_OUT)
    );
    
    /*
    button blobk. output release operation from user based on four buttons
    
    Address             Description
    --------------------------------------
    A5                  Read button triggle state
    A6                  enable button
    */
    Button Button_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPTS_RAISE[2]),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPTS_ACK[2]),
        //input button signal
        .BUTTON_IN(BUTTON_IN)
    );
    
    VGA_Controller VGA_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        //VGA Signals
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR(VGA_COLOUR)
    //    output DPR_CLK
    );

    LED_Controller LED_0(
        //Standard Signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS Signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        //Output LED
        .LED_signal(LED_signal)
    );

endmodule
