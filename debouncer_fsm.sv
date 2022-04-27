`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2022 02:38:29 PM
// Design Name: 
// Module Name: debouncer_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer_fsm(
  input     logic   i_clk,  i_nrst,
  input     logic   i_signal,
  output    logic   o_db_level, o_db_tick);  

localparam N=22;

typedef enum {zero, wait0, one, wait1} state_type;

//signal delcaration
state_type state_reg, state_next;
logic   [N-1:0] counter_reg,  counter_next;
logic   q_zero;
logic   counter_load, counter_dec;

//fsmd state & data registers
always_ff @(posedge i_clk, negedge i_nrst)
    if(!i_nrst)
        begin
            state_reg   <=  zero;
            counter_reg <= 1'b0;
        end
     else
        begin
            state_reg   <=  state_next;
            counter_reg <=  counter_next;
        end
        
//FSMD dtata path (counter) next-state logic
assign  counter_next  =     (counter_load)    ?   {N{1'b1}}   :
                            (counter_dec)     ?   counter_reg - 1'b1:
                                                   counter_reg;
                                    
//status signal
assign  q_zero  =   (counter_next==0);

//FSMD control path next-state logic
always_comb
begin
    state_next  =   state_reg;  //default state: the same
    counter_load      =   1'b0;       //default output: 0
    counter_dec       =   1'b0;       //default output: 0
    o_db_tick         =   1'b0;       //default output: 0
    o_db_level        =   1'b0;       //default output: 0
    case(state_reg)
    
        zero:  
        begin
            if(i_signal)
                state_next = wait1;
                counter_load     =    1'b1;
        end
        
        wait1:
        begin
            if(i_signal)
                counter_dec = 1'b1;
                if (q_zero)
                begin
                    state_next = one;
                    o_db_tick = 1'b1;
                end
        end
        
        one:
        begin
            o_db_level = 1'b1;
            if(~i_signal)
                begin
                state_next = wait0;
                counter_load = 1'b1;
                end
        end
        
        wait0:
        begin
            o_db_level = 1'b1;
            if(~i_signal)
            begin
                counter_dec = 1'b1;
                if(q_zero)
                    state_next = zero;
            end
            else
                state_next = one;     
        end
    endcase
end   
endmodule
