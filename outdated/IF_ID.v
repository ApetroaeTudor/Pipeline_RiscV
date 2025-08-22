`timescale 1ns / 1ns

module IF_ID(
    input clk,
    input reset,
    input[31:0] pc_inc,
    input[31:0] pc_original,
    input[31:0] instr,
    input if_id_write,
    input flush,

    output reg[31:0] pc_inc_reg,
    output reg[31:0] pc_original_reg,
    output reg[31:0] instr_reg
);
    always@(posedge clk)
    begin
        if(reset)
        begin
            pc_original_reg<=32'b0;
            pc_inc_reg<=32'b0;
            instr_reg<=32'b0;
        end
        else if(flush)
        begin
            pc_original_reg<=32'b0;
            pc_inc_reg<=32'b0;
            instr_reg<=32'b0; // nop
        end
        else if(if_id_write) 
        begin 
            pc_original_reg<=pc_original;
            pc_inc_reg<=pc_inc; 
            instr_reg<=instr; 
        end

    end

endmodule