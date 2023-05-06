`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering 
// 
// Create Date: 04.03.2023 18:35:34
// Design Name: DR ALISTER HAMILTON & Yang Cen
// Module Name: ALU
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: Basic mathmatic operations.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*  
Basic ALU module, contins 12 operations
4'h0: add
4'h1: sub
4'h2: multi
4'h3: A shift left
4'h4: A shift right
4'h5: A add 1
4'h6: B add 1
4'h7: A sub 1
4'h8: B sub 1
4'h9: if A = B
4'hA: if A > B
4'hB: if A < B
default: output A
*/
module ALU(
    //standard signals
    input CLK,
    input RESET,
    //I/O
    input [7:0] IN_A,
    input [7:0] IN_B,
    input [3:0] ALU_Op_Code,
    output [7:0] OUT_RESULT
);
    reg [7:0] Out;
    
    //Arithmetic Computation
    always@(posedge CLK) begin
        if(RESET)
            Out <= 0;
        else begin
            case (ALU_Op_Code)
                //Maths Operations
                //Add A + B
                4'h0: Out <= IN_A + IN_B;
                //Subtract A - B
                4'h1: Out <= IN_A - IN_B;
                //Multiply A * B
                4'h2: Out <= IN_A * IN_B;
                //Shift Left A << 1
                4'h3: Out <= IN_A << 1;
                //Shift Right A >> 1
                4'h4: Out <= IN_A >> 1;
                //Increment A+1
                4'h5: Out <= IN_A + 1'b1;
                //Increment B+1
                4'h6: Out <= IN_B + 1'b1;
                //Decrement A-1
                4'h7: Out <= IN_A - 1'b1;
                //Decrement B+1
                4'h8: Out <= IN_B - 1'b1;
                // In/Equality Operations
                //A == B
                4'h9: Out <= (IN_A == IN_B) ? 8'h01 : 8'h00;
                //A > B
                4'hA: Out <= (IN_A > IN_B) ? 8'h01 : 8'h00;
                //A < B
                4'hB: Out <= (IN_A < IN_B) ? 8'h01 : 8'h00;
                //Default A
                default: Out <= IN_A;
            endcase
        end
    end
    
    assign OUT_RESULT = Out;
endmodule
