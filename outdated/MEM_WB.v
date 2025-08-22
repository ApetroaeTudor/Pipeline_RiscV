`timescale 1ns / 1ns


module MEM_WB(
    input clk,
    input reset,

    //forwarding
    input[4:0] ex_mem_rd,

    // wb
    input reg_write,
    input[1:0] mem_reg_pc,
    
    input[31:0] mem_data,
    input[31:0] alu_out,
    input[31:0] pc_inc,



    //forwarding
    output reg[4:0] ex_mem_rd_reg,
    // wb
    output reg reg_write_reg,
    output reg[1:0] mem_reg_pc_reg,
    
    output reg[31:0] mem_data_reg,
    output reg[31:0] alu_out_reg,
    output reg[31:0] pc_inc_reg
);

    always@(posedge clk)
    begin
        if(reset)
        begin
                ex_mem_rd_reg<=5'b0;

                reg_write_reg<=1'b0;
                mem_reg_pc_reg<=2'b0;
                mem_data_reg<=32'b0;
                alu_out_reg<=32'b0;
                pc_inc_reg<=32'b0;
        end
        else
        begin
                ex_mem_rd_reg<=ex_mem_rd;

                reg_write_reg<=reg_write;
                mem_reg_pc_reg<=mem_reg_pc;
                mem_data_reg<=mem_data;
                alu_out_reg<=alu_out;
                pc_inc_reg<=pc_inc;
        end
    end

endmodule