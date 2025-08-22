`include "Constants.vh"
module Hazard_Unit(
    input [6:0] i_opcode_d, 
    input [2:0] i_f3_d, 
    input [11:0] i_imm_d,

    input [6:0] i_opcode_e,
    input [2:0] i_f3_e,
    input i_mret_e,
    input [11:0] i_imm_e,

    input [6:0] i_opcode_m,
    input [2:0] i_f3_m,
    input [11:0] i_imm_m,

    input [6:0] i_opcode_w,
    input [2:0] i_f3_w,
    input [11:0] i_imm_w,

    
    
    input [4:0] i_rs1_d, //
    input [4:0] i_rs2_d, //
    input [4:0] i_rs1_e, //
    input [4:0] i_rs2_e, //

    input [4:0] i_rd_e, //
    input [4:0] i_rd_m, //
    input [4:0] i_rd_wb, //
    input i_jmp_e, //
    input i_res_src_b0_e, //
    input [1:0] i_pc_src_e, // 01=> branch taken //


    output [1:0] o_fw_a_e, //
    output [1:0] o_fw_b_e, //
    output o_fw_a_d, //
    output o_fw_b_d, //



    output [1:0] o_fw_csr_into_normal_a_e, // 01 is rs1_data_ex = old_csr_mem, 10 is rs1_data_ex = old_csr_wb
    output [1:0] o_fw_csr_into_normal_b_e,

    output [1:0] o_fw_normal_into_csr_d, // 01 is rs1_d_d = alu_out_ex, 10 is rs1_d_d = alu_out_mem, 11 is rs1_d_d = res_wb
    
    output [1:0] o_fw_csr_csr_reg_d, // 01 is rs1_d_d = old_csr_e, 10 is old_csr_m, 11 is old_csr_wb
    output [1:0] o_fw_csr_csr_csr_d, // 01 is csr_data_d = new_csr_e, 10 is new_csr_m, 11 is new_csr_wb

    output [1:0] o_fw_mret_e,


    output o_if_id_flush, // 
    output o_if_id_stall, //
    output o_id_ex_flush, //
    output o_pc_stall //
);

    assign o_fw_csr_into_normal_a_e = ((i_opcode_m==`OP_I_TYPE_CSR && i_f3_m!=`CSR_CONTROL_F3) && (i_rd_m == i_rs1_e) && i_rd_m!=0 && i_rs1_e!=0 ) ? 2'b01:
                                      ((i_opcode_w==`OP_I_TYPE_CSR && i_f3_w!=`CSR_CONTROL_F3) && (i_rd_wb == i_rs1_e) && i_rd_wb!=0 && i_rs1_e!=0) ? 2'b10:2'b00;

    assign o_fw_csr_into_normal_b_e = ((i_opcode_m==`OP_I_TYPE_CSR && i_f3_m!=`CSR_CONTROL_F3) && (i_rd_m == i_rs2_e) && i_rd_m!=0 && i_rs2_e!=0) ? 2'b01:
                                      ((i_opcode_w==`OP_I_TYPE_CSR && i_f3_w!=`CSR_CONTROL_F3) && (i_rd_wb == i_rs2_e) && i_rd_wb!=0 && i_rs2_e!=0) ? 2'b10:2'b00;
    // additional forwards
        // if instr_m is csr and the rd in mem == rs1 in ex -> then rs1_data_ex = old_csr_mem
        // if instr_w is csr and the rd in wb == rs1 in ex -> then rs1_data_ex = old_csr_wb 
            // csr followed by non csr, ->> o_fw_csr_into_normal_a_e/ b_e

    
    assign o_fw_normal_into_csr_d = ((i_opcode_d==`OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) && (i_opcode_e!=`OP_I_TYPE_CSR) &&
                                    (i_rd_e == i_rs1_d) && i_rd_e!=0 && i_rs1_d!=0)?2'b01:
                                    ((i_opcode_d==`OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) && (i_opcode_m!=`OP_I_TYPE_CSR) &&
                                    (i_rd_m == i_rs1_d) && i_rd_m!=0 && i_rs1_d!=0)?2'b10:
                                    ((i_opcode_d==`OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) && (i_opcode_w!=`OP_I_TYPE_CSR) &&
                                    (i_rd_wb == i_rs1_d) && i_rd_wb!=0 && i_rs1_d!=0)?2'b11:2'b00;
        // if instr in ID is csr and instr in EX is NOT csr, and rd_ex == rs1_d -> rs1_data_d = alu_out_ex 
        // if instr in ID is csr and instr in MEM is NOT csr, and rd_mem == rs1_d -> rs1_data_d = alu_out_mem
        // if instr in ID is csr and instr in WB is NOT csr, and rd_wb == rs1_d -> rs1_data_d = res_wb
            // non csr followed by csr ->> [1:0] o_fw_normal_into_csr_e / m / w

    
    assign o_fw_csr_csr_reg_d = ((i_opcode_e == `OP_I_TYPE_CSR && i_f3_e!=`CSR_CONTROL_F3) && (i_opcode_d == `OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) &&
                                (i_rs1_d == i_rd_e) && i_rd_e!=0 && i_rs1_d!=0)?2'b01:
                                ((i_opcode_m == `OP_I_TYPE_CSR && i_f3_m!=`CSR_CONTROL_F3) && (i_opcode_d == `OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) &&
                                (i_rs1_d == i_rd_m) && i_rd_m!=0 && i_rs1_d!=0)?2'b10:
                                ((i_opcode_w == `OP_I_TYPE_CSR && i_f3_w!=`CSR_CONTROL_F3) && (i_opcode_d == `OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) &&
                                (i_rs1_d == i_rd_wb) && i_rd_wb!=0 && i_rs1_d!=0)?2'b11:2'b00;
        // if instr in EX is csr and instr in ID is csr, and ID_rs1 == EX_rd -> rs1_data_d = old_csr_e
        // if instr in MEM is csr and instr in ID is csr, and ID_rs1 == MEM_rd -> rs1_data_d = old_csr_m
        // if instr in WB is csr and instr in ID is csr, and ID_rs1 == WB_rd -> rs1_data_d = old_csr_wb
            // csr followed by csr, register data forwarding ->> [1:0] o_fw_csr_csr_reg_e / m /w

    assign o_fw_csr_csr_csr_d = ((i_opcode_e == `OP_I_TYPE_CSR && i_f3_e!=`CSR_CONTROL_F3) && (i_opcode_d == `OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) &&
                                (i_imm_d == i_imm_e))?2'b01:
                                ((i_opcode_m == `OP_I_TYPE_CSR && i_f3_m!=`CSR_CONTROL_F3) && (i_opcode_d == `OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) &&
                                (i_imm_d == i_imm_m))?2'b10:
                                ((i_opcode_w == `OP_I_TYPE_CSR && i_f3_w!=`CSR_CONTROL_F3) && (i_opcode_d == `OP_I_TYPE_CSR && i_f3_d!=`CSR_CONTROL_F3) &&
                                (i_imm_d == i_imm_w))?2'b11:2'b00;
        // if instr in EX is csr and instr in ID is csr, and ID_imm == EX_imm (csr addr) -> csr_data_d = new_csr_ex
        // if instr in MEM is csr and instr in ID is csr, and ID_imm == MEM_imm (csr addr) -> csr_data_d = new_csr_mem
        // if instr in WB is csr and instr in ID is csr, and ID_imm == WB_imm (csr addr) -> csr_data_d = new_csr_wb
            // csr followed by csr, csr register data forwarding ->> [1:0] o_fw_csr_csr_csr_e / m / w

        // if i_mret_e -> flush if_id, flush id_ex


    assign o_fw_mret_e = ((i_mret_e && i_opcode_m == `OP_I_TYPE_CSR && i_f3_m!=`CSR_CONTROL_F3) &&     
                         ( i_imm_m == `mepc))?2'b01:
                         ((i_mret_e && i_opcode_w == `OP_I_TYPE_CSR && i_f3_w!=`CSR_CONTROL_F3) &&     
                         ( i_imm_w == `mepc))?2'b10:2'b00;
    // if mret_e and the instruction in mem is CSR, then pc<= new_csr_mem
    // if mret_e and the instruction in wb is CSR, then pc<= new_csr_wb

    assign o_fw_a_e = 
    ((i_rs1_e == i_rd_m)  && (i_rs1_e!=5'b0))?2'b10: // alu_out_m
    ((i_rs1_e == i_rd_wb) && (i_rs1_e!=5'b0))?2'b01: // res_wb
    2'b00; // normal

    assign o_fw_b_e = 
    ((i_rs2_e == i_rd_m)  && (i_rs2_e!=5'b0))?2'b10:
    ((i_rs2_e == i_rd_wb) && (i_rs2_e!=5'b0))?2'b01:
    2'b00;

    assign o_fw_a_d =
    ((i_rs1_d == i_rd_wb) &&(i_rs1_d!=5'b0))?1'b1: // res_wb_d
    1'b0; // normal

    assign o_fw_b_d =
    ((i_rs2_d == i_rd_wb) &&(i_rs2_d!=5'b0))?1'b1:
    1'b0;


    wire w_lw_stall;
    assign w_lw_stall =
    (i_res_src_b0_e && 
    i_rd_e!=0 && 
    ((i_rs1_d == i_rd_e && i_rs1_d!=0) ||
    (i_rs2_d == i_rd_e  && i_rs2_d!=0)))?1'b1:1'b0;
    assign o_if_id_stall = w_lw_stall;
    assign o_pc_stall = w_lw_stall;


    assign o_if_id_flush = (i_pc_src_e == 2'b01 || i_jmp_e || i_mret_e) ?1'b1:1'b0;
    assign o_id_ex_flush = ((i_pc_src_e == 2'b01) || w_lw_stall || i_mret_e)?1'b1:1'b0;



endmodule