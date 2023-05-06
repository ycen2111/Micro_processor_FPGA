`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: The School og Engineering
// 
// Create Date: 16.02.2023 10:11:26
// Design Name: Yang Cen
// Module Name: IRTransmitterSM
// Project Name: MicroProcessor
// Target Devices: BAYSY 3 XC7A35T-l CPG236C
// Tool Versions: Vivado 2015.2
// Description: output target IR signal by given command
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IRTransmitterSM(
    input CLK,
    input RESET,
    input [3:0] COMMAND,
    input SEND_PACKET,
    input [8:0] StartBurstSize,
    input [8:0] GapSize,
    input [8:0] CarSelectBurstSize,
    input [8:0] AsserBurstSize,
    input [8:0] DeAssertBurstSize,
    input [11:0] half_div,
    output IR_LED
);

    /*parameter StartBurstSize     = {8'd190, 8'd87, 8'd87, 8'd191};
    parameter GapSize            = {8'd24, 8'd39, 8'd39, 8'd23};
    parameter CarSelectBurstSize = {8'd46, 8'd21, 8'd43, 8'd23};
    parameter AsserBurstSize     = {8'd46, 8'd43, 8'd43, 8'd47};
    parameter DeAssertBurstSize  = {8'd21, 8'd21, 8'd21, 8'd23};
    parameter half_div           = {11'd1389, 11'd1250, 11'd1333, 11'd1389};*/
    //100MHz/36kHz=2778 times
    //100MHz/40kHz=2500 times
    //parameter div_number         = 2778;
    //parameter half_div           = div_number/2;

    //next clk the state will change
    wire state_change;
    //next step for FSM
    wire next_step;
    //the LED pulse generator is working
    wire in_count;
    //reverse RESET signal
    wire n_RESET;
    //permit to output the IR signal
    wire out_permit;
    
    //count how many LED pulse is counted
    reg [7:0] pulse_counter=8'd0;
    //count the system clk to divided clk
    reg [12:0] div_counter=13'd0;
    //generaged car's frequency
    reg div_clk=1'd0;
    //state for FSM, be initialized as 11
    reg [3:0] state=4'd11;
    //next state for FSM
    reg [3:0] d_state=4'd11;
    //count how many LED pulse have generated
    reg [7:0] pulse_num=8'd0;
    
    //keep counting if counted pulse is not equal with target number
    assign in_count=(pulse_counter!=pulse_num);
    //sign to move to FSM's next state if pulse counter is steop counting
    assign next_step= ~(in_count);
    //reserve input RESET signal only
    assign n_RESET= ~RESET;
    //output IR signal if FSM is in odd number
    assign out_permit= (state[0]==1'd0);
    // enable pulse generator if FSM's state changes
    assign state_change = state^d_state;
    
    /*
    Generate the pulse signal here from the main clock running at 100MHz to generate the right frequency for
    the car in question
    */
    
    // switch the div_clk when counter equals (n/2)-1 of div_number (divide the input clk into seet times)
    always @(posedge CLK or negedge n_RESET) begin
        if (!n_RESET)
            div_clk<=1'd0;
        else begin
            if (div_counter==1'd0)
                div_clk<=!div_clk;
            else
                div_clk<=div_clk;
        end
    end
    
    // counting the input clk
    always @(posedge CLK or negedge n_RESET) begin
        if (!n_RESET)
            div_counter<='d0;
        else begin
            if (div_counter==half_div)
                div_counter<=10'd0;
            else
                div_counter<=div_counter+1'd1;
        end
    end
    
    /*
    Simple state machine to generate the states of the packet i.e. Start, Gaps, Right Assert or De-Assert, Left
    Assert or De-Assert, Backward Assert or De-Assert, and Forward Assert or De-Assert
    */     
    //copy the naxt FSM into current one
    always @(posedge div_clk or negedge n_RESET) begin
        if (!n_RESET)
            state<=4'd11;
        else
            state <= d_state;
    end
    
    //0: start, 1: start gap, 2: selest, 3: select gap, 4: right, 5: right gap, 6: left, 7: left gap, 8: backward, 9: back gap, 10: forward, 11: forward gap  
    //determine what the next state is
    always @(posedge CLK  or negedge n_RESET) begin
        if (!n_RESET) begin
            d_state<=4'd0;
        end
        else begin
            case (state)
                4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9,4'd10:
                    begin
                        if (next_step)
                            d_state<=state+1'd1;
                        else
                            d_state<=d_state;
                    end
                4'd11:
                    begin
                        if (SEND_PACKET) //10 Hz clk positive edge
                            d_state<=3'd0;
                        else
                            d_state<=d_state;
                    end
                default:
                    d_state<=4'd11;
            endcase
        end
    end
    
    //output pulse number with tipical state state
    always @(posedge div_clk) begin
        case (state)
            4'd0: //start
                begin
                    pulse_num<=StartBurstSize;
                    //out_permit<=1'd1;
                end
            4'd2: //select
                begin
                    pulse_num<=CarSelectBurstSize;
                    //out_permit<=1'd1;
                end
            4'd4: //right
                begin
                    if (COMMAND[0])
                        pulse_num<=AsserBurstSize;
                    else
                        pulse_num<=DeAssertBurstSize;
                        
                    //out_permit<=1'd1;
                end
            4'd6: //left
                begin
                    if (COMMAND[1])
                        pulse_num<=AsserBurstSize;
                    else
                        pulse_num<=DeAssertBurstSize;
                        
                    //out_permit<=1'd1;
                end
            4'd8: //backward
                begin
                    if (COMMAND[2])
                        pulse_num<=AsserBurstSize;
                    else
                        pulse_num<=DeAssertBurstSize;
                        
                    //out_permit<=1'd1;
                end
             4'd10: //forward
                 begin
                     if (COMMAND[3])
                         pulse_num<=AsserBurstSize;
                     else
                         pulse_num<=DeAssertBurstSize;
                         
                     //out_permit<=1'd1;
                 end
             4'd1,4'd3,4'd5,4'd7,4'd9,4'd11: //gap
                begin
                    pulse_num<=GapSize;
                    //out_permit<=1'd0;
                end
            default:
                begin
                    pulse_num<=8'd0;
                    //out_permit<=1'd0;
                end
        endcase
    end
    
    /*
    Finally, tie the pulse generator with the packet state to generate IR_LED
    */    
    
    // count pulse numbers
    always @(posedge div_clk or negedge n_RESET) begin
        if (!n_RESET)
            pulse_counter<=8'd0;
        else begin
            if (state_change)
                pulse_counter<=8'd0;
            else if (in_count)
                pulse_counter<=pulse_counter+'d1;
            else
                pulse_counter<=pulse_counter;
        end
    end
    
    //generate IR_LED signal
    assign IR_LED=(out_permit)?div_clk:1'd0;

endmodule