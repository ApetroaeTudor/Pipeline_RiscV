`include "riscv_defines.vh"
module Control_ALU(
    input [2:0] i_alu_op,
    input [2:0] i_f3,
    input i_f7_b6,

    output [2:0] o_alu_ctl,

    output [1:0] o_alu_shift 
);

    assign o_alu_shift = (o_alu_ctl == `ALU_CTL_SHIFT)?
                                                     ((i_f3 == `SLL_F3)?`ALU_SHIFT_SLL:
                                                      (i_f3 == `SRL_SRA_F3)?( (i_f7_b6 )?`ALU_SHIFT_SRA :
                                                                                        (!i_f7_b6)?`ALU_SHIFT_SRL : 2'b00   
                                                                                        ): 
                                                    2'b00  
                                                     ):
    2'b00;

    assign o_alu_ctl =
    (i_alu_op == `ALU_OP_ADD)?`ALU_CTL_ADD:
    (i_alu_op == `ALU_OP_SUB)?`ALU_CTL_SUB:
    (i_alu_op == `ALU_OP_R)? 
                        ((i_f3 == `ADD_F3)?( (i_f7_b6 == 1'b0 )?`ALU_CTL_ADD:   // add
                                            (i_f7_b6 == 1'b1 )?`ALU_CTL_SUB:`ALU_CTL_ADD ): // sub
                         (i_f3 == `SLT_F3)?`ALU_CTL_LESS_SIG: // slt
                         (i_f3 == `SLTU_F3)?`ALU_CTL_LESS_UNS: // sltu
                         (i_f3 == `OR_F3)?`ALU_CTL_OR: // or
                         (i_f3 == `AND_F3)?`ALU_CTL_AND:
                         (i_f3 == `SLL_F3 || i_f3 == `SRL_SRA_F3)?`ALU_CTL_SHIFT:
                         (i_f3 == `XOR_F3)?`ALU_CTL_XOR:
                         3'b000 // and
                        ): 
    (i_alu_op == `ALU_OP_COMPARISON)?
                        ((i_f3 ==  `BNE_F3 || i_f3 == `BEQ_F3) ? `ALU_CTL_SUB: // beq or bne
                         (i_f3 ==  `BLT_F3 || i_f3 == `BGE_F3) ? `ALU_CTL_LESS_SIG: // blt or bge
                         (i_f3 == `BLTU_F3 || i_f3 == `BGEU_F3) ? `ALU_CTL_LESS_UNS:3'b000): // bltu or bgeu
    (i_alu_op == `ALU_OP_I)?
                        ((i_f3 == `ADD_F3)?`ALU_CTL_ADD:
                         (i_f3 == `SLL_F3 || i_f3 == `SRL_SRA_F3)?`ALU_CTL_SHIFT:
                         (i_f3 == `SLT_F3)?`ALU_CTL_LESS_SIG:
                         (i_f3 == `SLTU_F3)?`ALU_CTL_LESS_UNS:
                         (i_f3 == `XOR_F3)?`ALU_CTL_XOR:
                         (i_f3 == `OR_F3)?`ALU_CTL_OR:
                         (i_f3 == `AND_F3)?`ALU_CTL_AND:3'b000
                        ):
    3'b000;

endmodule