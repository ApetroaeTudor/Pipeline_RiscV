`include "Constants.vh"
module ALU_Main #(
    parameter [1:0] XLEN = `XLEN_64b    
)(
    input [((1<<(XLEN+4))-1):0] i_op_a,
    input [((1<<(XLEN+4))-1):0] i_op_b,

    input [2:0] i_alu_op,
    input [1:0] i_alu_shift,

    output o_zero,

    output [((1<<(XLEN+4))-1):0] o_alu_out
);

wire [$clog2(1<<XLEN+4)-1:0] w_shift_nr;
assign w_shift_nr = i_op_b[$clog2(1<<XLEN+4)-1:0];

wire w_signed_less_comparison;
assign w_signed_less_comparison = $signed(i_op_a)<$signed(i_op_b);

wire [((1<<(XLEN+4))-1):0] w_sll;
assign w_sll = i_op_a << w_shift_nr;
wire [((1<<(XLEN+4))-1):0] w_srl;
assign w_srl = i_op_a >> w_shift_nr;
wire [((1<<(XLEN+4))-1):0] w_sra;
assign w_sra = $signed(i_op_a) >>> w_shift_nr;

wire [((1<<(XLEN+4))-1):0] w_selected_shift;
assign w_selected_shift = (i_alu_shift==`ALU_SHIFT_SLL)?w_sll:
                          (i_alu_shift==`ALU_SHIFT_SRL)?w_srl:
                          (i_alu_shift==`ALU_SHIFT_SRA)?w_sra:31'd0;

assign o_zero = ((i_op_a-i_op_b) == 0)?1:0;

assign o_alu_out = (i_alu_op==`ALU_CTL_ADD     ) ? (i_op_a+i_op_b):
                   (i_alu_op==`ALU_CTL_SUB     ) ? (i_op_a-i_op_b):
                   (i_alu_op==`ALU_CTL_AND     ) ? (i_op_a&i_op_b):
                   (i_alu_op==`ALU_CTL_OR      ) ? (i_op_a|i_op_b):
                   (i_alu_op==`ALU_CTL_LESS_SIG) ? ((w_signed_less_comparison)?32'd1:32'd0):
                   (i_alu_op==`ALU_CTL_LESS_UNS) ? ((i_op_a<i_op_b)?32'd1:32'd0):
                   (i_alu_op==`ALU_CTL_XOR     ) ? (i_op_a^i_op_b):
                   (i_alu_op==`ALU_CTL_SHIFT   ) ? (w_selected_shift):
                    32'd0;



endmodule