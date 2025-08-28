`include "Constants.vh"

module Imm_32#(
    parameter [1:0] XLEN = `XLEN_64b
)(
    input [2:0] i_imm_ctl,

    input i_sign_ext,

 

    input [24:0] i_instr_bits,

    output [(1<<(XLEN+4))-1:0] o_extended_imm
);


    assign o_extended_imm = 
    (i_imm_ctl==`IMM_I_TYPE  )? { i_sign_ext?{ ((1<<(XLEN+4))-7'd12){i_instr_bits[24]}}: {((1<<(XLEN+4))-7'd12){1'b0}}  ,i_instr_bits[24:13]}:
    (i_imm_ctl==`IMM_S_TYPE  )? { {((1<<(XLEN+4))-7'd12){i_instr_bits[24]}},i_instr_bits[24:18],i_instr_bits[4:0]}:
    (i_imm_ctl==`IMM_B_TYPE  )? { {((1<<(XLEN+4))-7'd12){i_instr_bits[24]}},i_instr_bits[0],i_instr_bits[23:18],i_instr_bits[4:1],1'b0}:
    (i_imm_ctl==`IMM_J_TYPE  )? { {((1<<(XLEN+4))-7'd20){i_instr_bits[24]}},i_instr_bits[12:5],i_instr_bits[13],i_instr_bits[23:14],1'b0}:
    (i_imm_ctl==`IMM_U_TYPE  )? { {((1<<(XLEN+4))-7'd32){i_instr_bits[24]}} ,{i_instr_bits[24:5]},12'b0 }:
     {(1<<(XLEN+4)){1'b0}};

endmodule