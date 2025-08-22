`include "Constants.vh"

module Imm_32(
    input [2:0] i_imm_ctl,

 

    input [24:0] i_instr_bits,

    output [31:0] o_extended_imm
);

    assign o_extended_imm = 
    (i_imm_ctl==`IMM_I_TYPE  )? { {20{i_instr_bits[24]}},i_instr_bits[24:13]}:
    (i_imm_ctl==`IMM_S_TYPE  )? { {20{i_instr_bits[24]}},i_instr_bits[24:18],i_instr_bits[4:0]}:
    (i_imm_ctl==`IMM_B_TYPE  )? { {20{i_instr_bits[24]}},i_instr_bits[0],i_instr_bits[23:18],i_instr_bits[4:1],1'b0}:
    (i_imm_ctl==`IMM_J_TYPE  )? { {12{i_instr_bits[24]}},i_instr_bits[12:5],i_instr_bits[13],i_instr_bits[23:14],1'b0}:
    (i_imm_ctl==`IMM_U_TYPE  )? { {i_instr_bits[24:5]},12'b0 }:
     32'b0;

endmodule