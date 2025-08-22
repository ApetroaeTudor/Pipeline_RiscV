`timescale 1ns / 1ns

module ID_EX(
    input clk,
    input reset,
    input flush,

    //forwarding
    input[4:0] if_id_rs1,
    input[4:0] if_id_rs2,
    input[4:0] if_id_rd,

    //wb
    input reg_write,
    input[1:0] mem_reg_pc,

    //mem
    input mem_read,
    input mem_write,
    input branch,
    input jl,
    input jlr,


    //ex
    input alu_src,
    input[1:0] alu_op,

    input[31:0] pc_inc,
    input[31:0] pc_original,
    input[31:0] read_data_1,
    input[31:0] read_data_2,
    input[31:0] imm32,
    
    input f7_bit,
    input [2:0] f3,



    //forwarding
    output reg[4:0] if_id_rs1_reg,
    output reg[4:0] if_id_rs2_reg,
    output reg[4:0] if_id_rd_reg,


    //wb
    output reg reg_write_reg,
    output reg[1:0] mem_reg_pc_reg,

    //mem
    output reg mem_read_reg,
    output reg mem_write_reg,
    output reg branch_reg,
    output reg jl_reg,
    output reg jlr_reg,


    //ex
    output reg alu_src_reg,
    output reg[1:0] alu_op_reg,

    output reg[31:0] pc_inc_reg,
    output reg[31:0] pc_original_reg,
    output reg[31:0] read_data_1_reg,
    output reg[31:0] read_data_2_reg,
    output reg[31:0] imm32_reg,
    output reg f7_bit_reg,
    output reg[2:0] f3_reg
    
);

    always@(posedge clk)
    begin
        if(reset)
        begin
            if_id_rs1_reg<=5'b0;
            if_id_rs2_reg<=5'b0;
            if_id_rd_reg<=5'b0;

            reg_write_reg<=1'b0;
            mem_reg_pc_reg<=2'b0;
            mem_read_reg<=1'b0;
            mem_write_reg<=1'b0;
            branch_reg<=1'b0;
            jl_reg<=1'b0;
            jlr_reg<=1'b0;
            alu_src_reg<=1'b0;
            alu_op_reg<=2'b0;
            pc_inc_reg<=32'b0;
            pc_original_reg<=32'b0;
            read_data_1_reg<=32'b0;
            read_data_2_reg<=32'b0;
            imm32_reg<=32'b0;
            f7_bit_reg<=1'b0;
            f3_reg<=3'b0;
        end
        else if(flush==1'b0)
        begin
            if_id_rs1_reg<=if_id_rs1;
            if_id_rs2_reg<=if_id_rs2;
            if_id_rd_reg<=if_id_rd;

            reg_write_reg<=reg_write;
            mem_reg_pc_reg<=mem_reg_pc;
            mem_read_reg<=mem_read;
            mem_write_reg<=mem_write;
            branch_reg<=branch;
            jl_reg<=jl;
            jlr_reg<=jlr;
            alu_src_reg<=alu_src;
            alu_op_reg<=alu_op;
            pc_inc_reg<=pc_inc;
            pc_original_reg<=pc_original;
            read_data_1_reg<=read_data_1;
            read_data_2_reg<=read_data_2;
            imm32_reg<=imm32;
            f7_bit_reg<=f7_bit;
            f3_reg<=f3;
        end
        else
        begin
            reg_write_reg<=1'b0;
            mem_read_reg<=1'b0;
            mem_write_reg<=1'b0;
            branch_reg<=1'b0;
            jl_reg<=1'b0;
            jlr_reg<=1'b0;
        end
    end




endmodule