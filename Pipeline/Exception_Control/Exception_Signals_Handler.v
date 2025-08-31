`include "Constants.vh"
module Exception_Signals_Handler#(
  parameter [1:0] XLEN = `XLEN_64b,
  parameter ENABLED_PMP_REGISTERS = 12
)(
    input [((1<<(XLEN+4))-1):0] i_pc_f,  //
    input [6:0] i_opcode_f, //
    input [3:0] i_imm_ms_4b_f, //


    input [1:0] i_res_src_e, //01 = load

    input [((1<<(XLEN+4))-1):0] i_alu_out_e,
    input i_mem_write_e,

    input i_ecall_e,
    input i_store_byte_e,
    input i_store_half_e,
    input [2:0] i_f3_e,

    input [1:0] i_current_privilege,
 

    output [3:0] o_exception_code_f, 
    output [3:0] o_exception_code_e
);

wire w_illegal_csr_instr = (i_opcode_f==`OP_I_TYPE_CSR && i_imm_ms_4b_f>{2'b00,i_current_privilege});

wire w_illegal_opcode = ( i_opcode_f!=`OP_R_TYPE                         &&
                          i_opcode_f!=`OP_I_TYPE_LOAD                    &&
                          i_opcode_f!=`OP_I_TYPE_OPERATION               &&
                          i_opcode_f!=`OP_I_TYPE_JALR                    &&
                          i_opcode_f!=`OP_I_TYPE_CSR                     &&
                          i_opcode_f!=`OP_S_TYPE                         &&
                          i_opcode_f!=`OP_J_TYPE                         &&
                          i_opcode_f!=`OP_B_TYPE                         &&
                          i_opcode_f!=`OP_U_TYPE_LUI                     &&
                          i_opcode_f!=`OP_U_TYPE_AUIPC                   &&
                          i_opcode_f!=`OP_NOP);

wire w_fetch_misaligned = (i_pc_f[1:0]!=2'b00); // this will be changed with c extension in the future

wire w_load_addr_misaligned_4b = (i_res_src_e==2'b01) &&
                                 (i_alu_out_e[1:0]!=2'b00) &&
                                 (i_f3_e!=`LB_F3 && i_f3_e!= `LH_F3 && i_f3_e!=`LBU_F3 && i_f3_e!=`LHU_F3);

wire w_load_addr_misaligned_2b = (i_res_src_e==2'b01) &&
                                 (i_alu_out_e[0]!=0) &&
                                 (i_f3_e == `LH_F3 || i_f3_e == `LHU_F3);


endmodule