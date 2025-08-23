`include "Constants.vh"
module ALU_Main(
    input [31:0] i_op_a,
    input [31:0] i_op_b,

    input [2:0] i_alu_op,

    output o_zero,

    output [31:0] o_alu_out
);

wire w_signed_less_comparison;
assign w_signed_less_comparison = $signed(i_op_a)<$signed(i_op_b);

assign o_zero = ((i_op_a-i_op_b) == 0)?1:0;

assign o_alu_out = (i_alu_op==`ALU_CTL_ADD     ) ? (i_op_a+i_op_b):
                   (i_alu_op==`ALU_CTL_SUB     ) ? (i_op_a-i_op_b):
                   (i_alu_op==`ALU_CTL_AND     ) ? (i_op_a&i_op_b):
                   (i_alu_op==`ALU_CTL_OR      ) ? (i_op_a|i_op_b):
                   (i_alu_op==`ALU_CTL_LESS_SIG) ? ((w_signed_less_comparison)?32'h0000_0001:32'h0000_0000):
                   (i_alu_op==`ALU_CTL_LESS_UNS) ? ((i_op_a<i_op_b)?32'h0000_0001:32'h0000_0000):
                    32'h0000_0000;



endmodule