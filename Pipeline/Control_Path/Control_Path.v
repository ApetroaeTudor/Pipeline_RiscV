module Control_Path(
    input [6:0] i_opcode,
    input [2:0] i_f3,
    input i_f7_b6,

    output [1:0] o_result_src,
    // output [1:0] o_pc_src,
    output o_branch,
    output o_jmp,
    output o_mem_write,
    output o_reg_write,
    output [2:0] o_alu_ctl,
    output o_alu_src,
    output [2:0] o_imm_src
);

   


    wire w_jmp;
    wire w_branch;
    wire [1:0] w_alu_op;
    Control_Unit Control_Unit_Inst(.i_opcode(i_opcode),
                                   .o_result_src(o_result_src),
                                   .o_mem_write(o_mem_write),
                                   .o_reg_write(o_reg_write),
                                   .o_jmp(w_jmp),
                                   .o_branch(w_branch),
                                   .o_alu_op(w_alu_op),
                                   .o_alu_src(o_alu_src),
                                   .o_imm_src(o_imm_src));


    Control_ALU Control_ALU_Inst(.i_alu_op(w_alu_op),
                                 .i_f3(i_f3),
                                 .i_f7_b6(i_f7_b6),
                                 .o_alu_ctl(o_alu_ctl));

    assign o_branch = w_branch;
    assign o_jmp = w_jmp;

    
endmodule