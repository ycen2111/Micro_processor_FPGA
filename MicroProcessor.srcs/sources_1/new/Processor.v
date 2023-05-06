`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 04.03.2023 18:38:29
// Design Name: Yang Cen
// Module Name: Processor
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: Main micro processor. it contains ALU and ROM, can read programes from ROM and operate those instructions, 
//              and control other blocks by edit bus data and bus address
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Processor(
    //Standard Signals
    input CLK,
    input RESET,
    //BUS Signals
    inout [7:0] BUS_DATA,
    output [7:0] BUS_ADDR,
    output BUS_WE,
    // ROM signals
    output [7:0] ROM_ADDRESS,
    input [7:0] ROM_DATA,
    // INTERRUPT signals
    input [2:0] BUS_INTERRUPTS_RAISE,
    output [2:0] BUS_INTERRUPTS_ACK
);

    parameter InitialProgCounter = 8'h00;

    //The main data bus is treated as tristate, so we need a mechanism to handle this.
    //Tristate signals that interface with the main state machine
    wire [7:0] BusDataIn;
    reg [7:0] CurrBusDataOut, NextBusDataOut;
    reg CurrBusDataOutWE, NextBusDataOutWE;
    
    //Tristate Mechanism
    assign BusDataIn = BUS_DATA;
    assign BUS_DATA = CurrBusDataOutWE ? CurrBusDataOut : 8'hZZ;
    assign BUS_WE = CurrBusDataOutWE;
    
    //Address of the bus
    reg [7:0] CurrBusAddr, NextBusAddr;
    
    assign BUS_ADDR = CurrBusAddr;
    
    //The processor has two internal registers to hold data between operations, and a third to hold
    //the current program context when using function calls.
    reg [7:0] CurrRegA, NextRegA;
    reg [7:0] CurrRegB, NextRegB;
    reg CurrRegSelect, NextRegSelect;
    reg [7:0] CurrProgContext, NextProgContext;
    //Dedicated Interrupt output lines - one for each interrupt line
    reg [2:0] CurrInterruptAck, NextInterruptAck;

    //Stack data and signal
    reg [7:0] CurrStackDataIn, NextStackDataIn;
    reg CurrPush,NextPush;
    reg CurrPull,NextPull;
    
    assign BUS_INTERRUPTS_ACK = CurrInterruptAck;
    
    //Instantiate program memory here
    //There is a program counter which points to the current operation. The program counter
    //has an offset that is used to reference information that is part of the current operation
    reg [7:0] CurrProgCounter, NextProgCounter;
    reg [1:0] CurrProgCounterOffset, NextProgCounterOffset;
    wire [7:0] ProgMemoryOut;
    wire [7:0] ActualAddress;
    
    assign ActualAddress = CurrProgCounter + CurrProgCounterOffset;
    // ROM signals
    assign ROM_ADDRESS = ActualAddress;
    assign ProgMemoryOut = ROM_DATA;
    
    //Instantiate the ALU
    //The processor has an integrated ALU that can do several different operations
    wire [7:0] AluOut;
    wire [7:0] StackDataOut;
    
    ALU ALU_0(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //I/O
        .IN_A(CurrRegA),
        .IN_B(CurrRegB),
        .ALU_Op_Code(ProgMemoryOut[7:4]),
        .OUT_RESULT(AluOut)
    );
    
    Stack STACK_0(
        //standard_signals
        .CLK(CLK),
        .RESET(RESET),
        //I/0
        .PUSH(CurrPush),
        .PULL(CurrPull),
        .DATA_IN(CurrStackDataIn),
        .FULL(),
        .EMPTY(),
        .DATA_OUT(StackDataOut)
    );

    //The microprocessor is essentially a state machine, with one sequential pipeline
    //of states for each operation.
    //The current list of operations is:
    // 0: Read from memory to A
    // 1: Read from memory to B
    // 2: Write to memory from A
    // 3: Write to memory from B
    // 4: Do maths with the ALU, and save result in reg A
    // 5: Do maths with the ALU, and save result in reg B
    // 6: if A (== or < or > B) GoTo ADDR
    // 7: Goto ADDR
    // 8: End thread, goto idle state and wait for interrupt.
    // 9: Function call
    // 10: Return from function call
    // 11: Dereference A
    // 12: Dereference B
    // 13: Input data to A
    // 14: Input data to B
    // 15: Input data to RAM
    
    parameter [7:0] //Program thread selection
    IDLE                    = 8'hF0, //Waits here until an interrupt wakes up the processor.
    GET_THREAD_START_ADDR_0 = 8'hF1, //Wait.
    GET_THREAD_START_ADDR_1 = 8'hF2, //Apply the new address to the program counter.
    GET_THREAD_START_ADDR_2 = 8'hF3, //Wait. Goto ChooseOp.
    
    //Operation selection
    //Depending on the value of ProgMemOut, goto one of the instruction start states.
    CHOOSE_OPP = 8'h00,
    
    //Data Flow
    READ_FROM_MEM_TO_A = 8'h10, //Wait to find what address to read, save reg select.
    READ_FROM_MEM_TO_B = 8'h11, //Wait to find what address to read, save reg select.
    READ_FROM_MEM_0 = 8'h12, //Set BUS_ADDR to designated address.
    READ_FROM_MEM_1 = 8'h13, //wait - Increments program counter by 2. Reset offset.
    READ_FROM_MEM_2 = 8'h14, //Writes memory output to chosen register, end op.
    WRITE_TO_MEM_FROM_A = 8'h20, //Reads Op+1 to find what address to Write to.
    WRITE_TO_MEM_FROM_B = 8'h21, //Reads Op+1 to find what address to Write to.
    WRITE_TO_MEM_0 = 8'h22, //wait - Increments program counter by 2. Reset offset.
    
    //Data Manipulation
    DO_MATHS_OPP_SAVE_IN_A = 8'h30, //The result of maths op. is available, save it to Reg A.
    DO_MATHS_OPP_SAVE_IN_B = 8'h31, //The result of maths op. is available, save it to Reg B.
    DO_MATHS_OPP_0 = 8'h32, //wait for new op address to settle. end op.
    
    /*
    Complete the above parameter list for In/Equality, Goto Address, Goto Idle, function start, Return from
    function, and Dereference operations.
    */
    /*....................
    FILL IN THIS AREA
    ...................*/
    IF_A_EQUALITY_B_GOTO = 8'h40, //compare A and B with =, >, and <, move to IF_A_EQUALITY_B_GOTO_PASS if pass the comparesion
    IF_A_EQUALITY_B_GOTO_PASS = 8'h41, //have pass the comparesion, dereference the ROM value
    IF_A_EQUALITY_B_0 = 8'h42, //Wait state for new prog address to settle.
    
    GOTO = 8'h50, //Wait to find what address to read
    GOTO_0 = 8'h51, //move programe's address to next ROM's value
    GOTO_1 = 8'h52, //Wait state for new prog address to settle
    
    DE_REFERENCE_A = 8'h80, //send value from reg A to BUS ADDR
    DE_REFERENCE_B = 8'h81, //send value from reg B to BUS ADDR
    DE_REFERENCE_0 = 8'h82, //Wait state for new Bus data, increame the programe counter
    DE_REFERENCE_1 = 8'h83, //read returned bus data to register A/B
    
    FUNCTION_START = 8'h60, //Wait to find the address to be read and store the current program counter
    FUNCTION_START_0 = 8'h61, //Move program's address to ROM value
    FUNCTION_START_1 = 8'h62, //Wait state for new prog address to settle
    
    RETURN = 8'h70, //Move program's address to origin value
    RETURN_0 = 8'h71, //Wait to for stack output
    RETURN_1 = 8'h72, //Set next program counter as the stack output
    RETURN_2 = 8'h73, //Wait state for new prog address to settle

    WRITE_IMME_TO_A = 8'h90, //Wait for the immediate value in ROM arrive, save reg select.
    WRITE_IMME_TO_B = 8'h91, //Wait for the immediate value in ROM arrive, save reg select.
    WRITE_IMME_0 = 8'h92, //Store the immediate value from ROM to register, Increments program counter by 2.
    WRITE_IMME_1 = 8'h93; //Wait for new prog address to settle.
    
    //Sequential part of the State Machine.
    reg [7:0] CurrState, NextState;
    
    always@(posedge CLK) begin
        if(RESET) begin
            CurrState <= 8'h00;
            CurrProgCounter <= InitialProgCounter;
            CurrProgCounterOffset <= 2'h0;
            CurrBusAddr <= 8'hFF; //Initial instruction after reset.
            CurrBusDataOut <= 8'h00;
            CurrBusDataOutWE <= 1'b0;
            CurrRegA <= 8'h00;
            CurrRegB <= 8'h00;
            CurrRegSelect <= 1'b0;
            CurrProgContext <= 8'h00;
            CurrInterruptAck <= 2'b00;
            CurrStackDataIn <= 8'h00;
            CurrPush <= 1'b0;
            CurrPull <= 1'b0;
        end 
        else begin
            CurrState <= NextState;
            CurrProgCounter <= NextProgCounter;
            CurrProgCounterOffset <= NextProgCounterOffset;
            CurrBusAddr <= NextBusAddr;
            CurrBusDataOut <= NextBusDataOut;
            CurrBusDataOutWE <= NextBusDataOutWE;
            CurrRegA <= NextRegA;
            CurrRegB <= NextRegB;
            CurrRegSelect <= NextRegSelect;
            CurrProgContext <= NextProgContext;
            CurrInterruptAck <= NextInterruptAck;
            CurrStackDataIn <= NextStackDataIn;
            CurrPush <= NextPush;
            CurrPull <= NextPull;
        end
    end
    
    //Combinatorial section - large!
    always@(*) begin
        //Generic assignment to reduce the complexity of the rest of the S/M
        NextState = CurrState;
        NextProgCounter = CurrProgCounter;
        NextProgCounterOffset = 2'h0;
        NextBusAddr = 8'hFF;
        NextBusDataOut = CurrBusDataOut;
        NextBusDataOutWE = 1'b0;
        NextRegA = CurrRegA;
        NextRegB = CurrRegB;
        NextRegSelect = CurrRegSelect;
        NextProgContext = CurrProgContext;
        NextInterruptAck = 2'b00;
        NextPush = 1'b0;
        
        //Case statement to describe each state
        case (CurrState)
            ///////////////////////////////////////////////////////////////////////////////////////
            //Thread states.
            IDLE: begin
                if(BUS_INTERRUPTS_RAISE[2]) begin // Interrupt Request C. For the Button
                    NextState = GET_THREAD_START_ADDR_0;
                    NextProgCounter = 8'hFD;
                    NextInterruptAck = 3'b100;
                end 
                else if(BUS_INTERRUPTS_RAISE[1]) begin //Interrupt Request B. For the Timer
                    NextState = GET_THREAD_START_ADDR_0;
                    NextProgCounter = 8'hFE;
                    NextInterruptAck = 3'b010;
                end 
                else if(BUS_INTERRUPTS_RAISE[0]) begin //Interrupt Request A. For the Mouse
                    NextState = GET_THREAD_START_ADDR_0;
                    NextProgCounter = 8'hFF;
                    NextInterruptAck = 3'b001;
                end 
                else begin
                    NextState = IDLE;
                    NextProgCounter = 8'hFF; //Nothing has happened.
                    NextInterruptAck = 3'b000;
                end
            end
            
            //Wait state - for new prog address to arrive.
            GET_THREAD_START_ADDR_0: begin
                NextState = GET_THREAD_START_ADDR_1;
            end
            
            //Assign the new program counter value
            GET_THREAD_START_ADDR_1: begin
                NextState = GET_THREAD_START_ADDR_2;
                NextProgCounter = ProgMemoryOut;
            end
            
            //Wait for the new program counter value to settle
            GET_THREAD_START_ADDR_2:
                NextState = CHOOSE_OPP;
                
            ///////////////////////////////////////////////////////////////////////////////////////
            //CHOOSE_OPP - Another case statement to choose which operation to perform
            CHOOSE_OPP: begin
                case (ProgMemoryOut[3:0])
                    4'h0: NextState = READ_FROM_MEM_TO_A;
                    4'h1: NextState = READ_FROM_MEM_TO_B;
                    4'h2: NextState = WRITE_TO_MEM_FROM_A;
                    4'h3: NextState = WRITE_TO_MEM_FROM_B;
                    4'h4: NextState = DO_MATHS_OPP_SAVE_IN_A;
                    4'h5: NextState = DO_MATHS_OPP_SAVE_IN_B;
                    4'h6: NextState = IF_A_EQUALITY_B_GOTO;
                    4'h7: NextState = GOTO;
                    4'h8: NextState = IDLE;
                    4'h9: NextState = FUNCTION_START;
                    4'hA: NextState = RETURN;
                    4'hB: NextState = DE_REFERENCE_A;
                    4'hC: NextState = DE_REFERENCE_B;
                    4'hD: NextState = WRITE_IMME_TO_A;
                    4'hE: NextState = WRITE_IMME_TO_B;
                    default:
                        NextState = CurrState;
                endcase
                
                NextProgCounterOffset = 2'h1;
            end
            
            ///////////////////////////////////////////////////////////////////////////////////////
            //READ_FROM_MEM_TO_A : here starts the memory read operational pipeline.
            //Wait state - to give time for the mem address to be read. Reg select is set to 0
            READ_FROM_MEM_TO_A:begin
                NextState = READ_FROM_MEM_0;
                NextRegSelect = 1'b0;
            end
            
            //READ_FROM_MEM_TO_B : here starts the memory read operational pipeline.
            //Wait state - to give time for the mem address to be read. Reg select is set to 1
            READ_FROM_MEM_TO_B:begin
                NextState = READ_FROM_MEM_0;
                NextRegSelect = 1'b1;
            end
            
            //The address will be valid during this state, so set the BUS_ADDR to this value.
            READ_FROM_MEM_0: begin
                NextState = READ_FROM_MEM_1;
                NextBusAddr = ProgMemoryOut;
            end
            
            //Wait state - to give time for the mem data to be read
            //Increment the program counter here. This must be done 2 clock cycles ahead
            //so that it presents the right data when required.
            READ_FROM_MEM_1: begin
                NextState = READ_FROM_MEM_2;
                NextProgCounter = CurrProgCounter + 2;
            end
            
            //The data will now have arrived from memory. Write it to the proper register.
            READ_FROM_MEM_2: begin
                NextState = CHOOSE_OPP;
                if(!CurrRegSelect)
                    NextRegA = BusDataIn;
                else
                    NextRegB = BusDataIn;
            end
            
            ///////////////////////////////////////////////////////////////////////////////////////
            //WRITE_TO_MEM_FROM_A : here starts the memory write operational pipeline.
            //Wait state - to find the address of where we are writing
            //Increment the program counter here. This must be done 2 clock cycles ahead
            //so that it presents the right data when required.
            WRITE_TO_MEM_FROM_A:begin
                NextState = WRITE_TO_MEM_0;
                NextRegSelect = 1'b0;
                NextProgCounter = CurrProgCounter + 2;
            end
            
            //WRITE_TO_MEM_FROM_B : here starts the memory write operational pipeline.
            //Wait state - to find the address of where we are writing
            //Increment the program counter here. This must be done 2 clock cycles ahead
            // so that it presents the right data when required.
            WRITE_TO_MEM_FROM_B:begin
                NextState = WRITE_TO_MEM_0;
                NextRegSelect = 1'b1;
                NextProgCounter = CurrProgCounter + 2;
            end
            
            //The address will be valid during this state, so set the BUS_ADDR to this value,
            //and write the value to the memory location.
            WRITE_TO_MEM_0: begin
                NextState = CHOOSE_OPP;
                NextBusAddr = ProgMemoryOut;
                if(!NextRegSelect)
                    NextBusDataOut = CurrRegA;
                else
                    NextBusDataOut = CurrRegB;
                NextBusDataOutWE = 1'b1;
            end
            
            ///////////////////////////////////////////////////////////////////////////////////////
            //DO_MATHS_OPP_SAVE_IN_A : here starts the DoMaths operational pipeline.
            //Reg A and Reg B must already be set to the desired values. The MSBs of the
            // Operation type determines the maths operation type. At this stage the result is
            // ready to be collected from the ALU.
            DO_MATHS_OPP_SAVE_IN_A: begin
                NextState = DO_MATHS_OPP_0;
                NextRegA = AluOut;
                NextProgCounter = CurrProgCounter + 1;
            end
            
            //DO_MATHS_OPP_SAVE_IN_B : here starts the DoMaths operational pipeline
            //when the result will go into reg B.
            DO_MATHS_OPP_SAVE_IN_B: begin
                NextState = DO_MATHS_OPP_0;
                NextRegB = AluOut;
                NextProgCounter = CurrProgCounter + 1;
            end
            
            //Wait state for new prog address to settle.
            DO_MATHS_OPP_0: NextState = CHOOSE_OPP;
            
            /*
            Complete the above case statement for In/Equality, Goto Address, Goto Idle, function start, Return from
            function, and Dereference operations.
            */
            /*....................
            FILL IN THIS AREA
            ...................*/
            ///////////////////////////////////////////////////////////////////////////////////////
            //IF_A_EQUALITY_B_GOTO: here starts the equality and jump pipeline
            //compare A and B with =, >, and <, move to IF_A_EQUALITY_B_GOTO_PASS if pass the comparesion
            IF_A_EQUALITY_B_GOTO: begin
                if (AluOut)
                    NextState = IF_A_EQUALITY_B_GOTO_PASS;
                else begin
                    //skip ROM add and move to next code if fail
                    NextProgCounter = CurrProgCounter + 2;
                    NextState = IF_A_EQUALITY_B_0;
                end
            end
            
            //pass the comparesion, dereference the ROM value
            IF_A_EQUALITY_B_GOTO_PASS: begin
                NextProgCounter = ProgMemoryOut;
                NextState = IF_A_EQUALITY_B_0;
            end
            
            //Wait state for new prog address to settle.
            IF_A_EQUALITY_B_0: begin
                NextState = CHOOSE_OPP;
            end
            
            ///////////////////////////////////////////////////////////////////////////////////////
            //GOTO: here starts the jump pipeline, move programe's address to next ROM's value
            //Wait to find what address to read
            GOTO: begin
                NextState = GOTO_0;
            end
            
            //move programe's address to next ROM's value
            GOTO_0: begin
                NextProgCounter = ProgMemoryOut;
                NextState = GOTO_1;
            end
            
            //Wait state for new prog address to settle
            GOTO_1: begin
                NextState = CHOOSE_OPP;
            end
            
            ///////////////////////////////////////////////////////////////////////////////////////
            //DE_REFERENCE_A: here starts the dereference pipline, put value from RAM address[register A's value] to register A
            //send value from reg A to BUS ADDR
            DE_REFERENCE_A: begin
                NextBusAddr = CurrRegA;
                NextRegSelect = 1'b0;
                NextState = DE_REFERENCE_0;
            end
            
            ///////////////////////////////////////////////////////////////////////////////////////
            //DE_REFERENCE_B: here starts the dereference pipline, put value from RAM address[register B's value] to register B
            //send value from reg B to BUS ADDR
            DE_REFERENCE_B: begin
                NextBusAddr = CurrRegB;
                NextRegSelect = 1'b1;
                NextState = DE_REFERENCE_0;
            end
            
            //Wait state for new Bus data
            //increame the programe counter
            DE_REFERENCE_0: begin
                NextState = DE_REFERENCE_1;
                NextProgCounter = CurrProgCounter + 1;
            end
            
            //read returned bus data to register A/B
            DE_REFERENCE_1: begin
                NextState = CHOOSE_OPP;
                if(!CurrRegSelect)
                    NextRegA = BusDataIn;
                else
                    NextRegB = BusDataIn;
            end
            ///////////////////////////////////////////////////////////////////////////////////////
            //FUNCTION_CALL_ADDR: here starts the function call pipline, jump to the function address
            //Wait state - to find the address to be read and store the current program counter
            FUNCTION_START: begin
                NextState = FUNCTION_START_0;
                NextStackDataIn = CurrProgCounter + 2;
                NextPush = 1'b1;
            end
            
            //Move program's address to ROM value
            FUNCTION_START_0: begin
                NextProgCounter = ProgMemoryOut;
                NextState = FUNCTION_START_1;
            end

            //Wait state for new prog address to settle
            FUNCTION_START_1: begin
                NextState = CHOOSE_OPP;
            end

            ///////////////////////////////////////////////////////////////////////////////////////
            //RETURN: here starts the return pipeline, end the function and return origin program
            //Move program's address to origin value
            RETURN: begin
                NextProgCounter = CurrProgContext;
                NextPull = 1'b1;
                NextProgContext = 8'h00;
                NextState = RETURN_0;
            end

            //Wait to for stack output
            RETURN_0: begin
            
                NextState = RETURN_1;
            end

            //Set next program counter as the stack output
            RETURN_1: begin
                NextProgCounter = StackDataOut;
                NextState = RETURN_2;
            end

            //Wait state for new prog address to settle
            RETURN_2: begin
                NextState = CHOOSE_OPP;
            end

            ///////////////////////////////////////////////////////////////////////////////////////
            //WRITE_IMME_TO_A: here starts the immediate value store operation pipeline
            //Wait state for the immediate value in ROM arrive, save reg select.
            WRITE_IMME_TO_A: begin
                NextState = WRITE_IMME_0;
                NextRegSelect = 1'b0;
            end

            ///////////////////////////////////////////////////////////////////////////////////////
            //WRITE_IMME_TO_B: here starts the immediate value store operation pipeline
            //Wait state for the immediate value in ROM arrive, save reg select.
            WRITE_IMME_TO_B: begin
                NextState = WRITE_IMME_0;
                NextRegSelect = 1'b1;
            end

            //Store the immediate value from ROM to register
            //Increment the program counter here. This must be done 2 clock cycles ahead
            WRITE_IMME_0: begin
                NextState = WRITE_IMME_1;
                NextProgCounter = CurrProgCounter + 2;
                if(!CurrRegSelect)
                    NextRegA = ProgMemoryOut;
                else
                    NextRegB = ProgMemoryOut;
            end

            //Wait state for new prog address to settle.
            WRITE_IMME_1: begin
                NextState = CHOOSE_OPP;
            end
        endcase
    end
    

endmodule