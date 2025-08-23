`include "Constants.vh"
module Control_ALU(
    input [1:0] i_alu_op,
    input [2:0] i_f3,
    input i_f7_b6,

    output [2:0] o_alu_ctl
);



    assign o_alu_ctl =
    (i_alu_op == `ALU_OP_ADD)? `ALU_CTL_ADD:
    (i_alu_op == `ALU_OP_SUB)?`ALU_CTL_SUB:
    (i_alu_op == `ALU_OP_SPECIAL)? 
                        ((i_f3 == 3'b000)?( (i_f7_b6 == 1'b0 )?`ALU_CTL_ADD:   // add
                                            (i_f7_b6 == 1'b1 )?`ALU_CTL_SUB:`ALU_CTL_ADD ): // sub
                         (i_f3 == 3'b010)?`ALU_CTL_LESS_SIG: // slt
                         (i_f3 == 3'b011)?`ALU_CTL_LESS_UNS: // sltu
                         (i_f3 == 3'b110)?`ALU_CTL_OR: // or
                         (i_f3 == 3'b111)?`ALU_CTL_AND:`ALU_CTL_ADD // and
                        ): 
    (i_alu_op == `ALU_OP_COMPARISON)?
                        ((i_f3 == 3'b000 || i_f3 == 3'b001) ? `ALU_CTL_SUB: // beq or bne
                         (i_f3 == 3'b100 || i_f3 == 3'b101) ? `ALU_CTL_LESS_SIG: // blt or bge
                         (i_f3 == 3'b110 || i_f3 == 3'b111) ? `ALU_CTL_LESS_UNS:3'b000): // bltu or bgeu
    3'b000;

endmodule