`include "Constants.vh"

module Control_Unit(
    input [6:0] i_opcode,

    output [1:0] o_result_src,
    output o_mem_write,
    output o_reg_write,
    output o_jmp,
    output o_branch,
    output [1:0] o_alu_op,
    output o_alu_src,
    output [2:0] o_imm_src

);


    assign                        {o_result_src , o_mem_write , o_reg_write , o_jmp , o_branch , o_alu_op , o_alu_src , o_imm_src} = 
    (i_opcode == `OP_R_TYPE)?     {    2'b00    ,     1'b0    ,    1'b1     ,  1'b0 ,    1'b0  ,   2'b10  ,    1'b0   ,    3'bxxx}: // r type
    (i_opcode == `OP_I_TYPE_LW)?  {    2'b01    ,     1'b0    ,    1'b1     ,  1'b0 ,    1'b0  ,   2'b00  ,    1'b1   ,    3'b000}: // i type (lw)
    (i_opcode == `OP_I_TYPE_ADDI)?{    2'b00    ,     1'b0    ,    1'b1     ,  1'b0 ,    1'b0  ,   2'b00  ,    1'b1   ,    3'b000}: // i type (addi)
    (i_opcode == `OP_I_TYPE_JALR)?{    2'b10    ,     1'b0    ,    1'b1     ,  1'b1 ,    1'b0  ,   2'b00  ,    1'b1   ,    3'b000}: // i type (jalr)
    (i_opcode == `OP_S_TYPE)?     {    2'b11    ,     1'b1    ,    1'b0     ,  1'b0 ,    1'b0  ,   2'b00  ,    1'b1   ,    3'b001}: // s type (sw)
    (i_opcode == `OP_J_TYPE)?     {    2'b10    ,     1'b0    ,    1'b1     ,  1'b1 ,    1'b0  ,   2'bxx  ,    1'bx   ,    3'b011}: // j type (jal)
    (i_opcode == `OP_B_TYPE_BEQ)? {    2'b11    ,     1'b0    ,    1'b0     ,  1'b0 ,    1'b1  ,   2'b01  ,    1'b0   ,    3'b010}: // b type (beq)
    (i_opcode == `OP_U_TYPE)?     {    2'b00    ,     1'b0    ,    1'b1     ,  1'b0 ,    1'b0  ,   2'b11  ,    1'b1   ,    3'b100}:
    12'b0;


endmodule