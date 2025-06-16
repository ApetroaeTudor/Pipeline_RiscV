`timescale 1ns / 1ns

module EX_MEM(
    input clk,
    input reset,

    //forwarding
    input[4:0] id_ex_rd,

    // wb
    input reg_write,
    input[1:0] mem_reg_pc,

    //mem
    input mem_read,
    input mem_write,
    input jl,
    input jlr,
    input branch,

    input[31:0] pc_inc,
    input[31:0] pc_plus_imm,
    input zero,
    input[31:0] alu_out,
    input[31:0] read_data_2,



    //forwarding
    output reg[4:0] id_ex_rd_reg,

    // wb
    output reg reg_write_reg,
    output reg[1:0] mem_reg_pc_reg,

    //mem
    output reg mem_read_reg,
    output reg mem_write_reg,
    output reg jl_reg,
    output reg jlr_reg,
    output reg branch_reg,

    output reg[31:0] pc_inc_reg,
    output reg[31:0] pc_plus_imm_reg,
    output reg zero_reg,
    output reg[31:0] alu_out_reg,
    output reg[31:0] read_data_2_reg
);

    always@(posedge clk)
    begin
        if(reset)
        begin
            id_ex_rd_reg<=5'b0;

            reg_write_reg<=1'b0;
            mem_reg_pc_reg<=2'b0;
            mem_read_reg<=1'b0;
            mem_write_reg<=1'b0;
            jl_reg<=1'b0;
            jlr_reg<=1'b0;
            branch_reg<=1'b0;
            pc_inc_reg<=32'b0;
            pc_plus_imm_reg<=32'b0;
            zero_reg<=1'b0;
            alu_out_reg<=32'b0;
            read_data_2_reg<=32'b0;
        end
        else
        begin
            id_ex_rd_reg<=id_ex_rd;

            reg_write_reg<=reg_write;
            mem_reg_pc_reg<=mem_reg_pc;
            mem_read_reg<=mem_read;
            mem_write_reg<=mem_write;
            jl_reg<=jl;
            jlr_reg<=jlr;
            branch_reg<=branch;
            pc_inc_reg<=pc_inc;
            pc_plus_imm_reg<=pc_plus_imm;
            zero_reg<=zero;
            alu_out_reg<=alu_out;
            read_data_2_reg<=read_data_2;
        end
    end

endmodule