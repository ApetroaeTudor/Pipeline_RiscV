module ID_EX(
    input i_clk,
    input i_rst,
    input i_clk_en,

    input i_id_ex_flush,

    input [4:0] i_rs1_d,
    input [4:0] i_rs2_d,
    input [4:0] i_rd_d,
    input [31:0] i_pc_p4_d,
    input [31:0] i_imm32_d,
    input [31:0] i_regs_do1_d,
    input [31:0] i_regs_do2_d,
    input [31:0] i_pc_d,

    input i_reg_wr_d,
    input [1:0] i_result_src_d,
    input i_mem_write_d,
    input i_jmp_d,
    input i_branch_d,
    input [2:0] i_alu_ctl_d,
    input i_alu_src_d,

    input [6:0] i_opcode_d,
    input i_csr_reg_write_d,
    input [31:0] i_new_csr_d,
    input [31:0] i_old_csr_d,
    input [11:0] i_csr_rd_d,
    input i_ecall_d,
    input i_mret_d,
    input [2:0] i_f3_d,
    input [11:0] i_imm_12b_d,

    input i_id_ex_flush_exception_m,
    input [31:0] i_mepc_d,

    
    output [4:0] o_rs1_e,
    output [4:0] o_rs2_e,
    output [4:0] o_rd_e,
    output [31:0] o_pc_p4_e,
    output [31:0] o_imm32_e,
    output [31:0] o_regs_do1_e,
    output [31:0] o_regs_do2_e,
    output [31:0] o_pc_e,
    output [31:0] o_mepc_e,
    output [2:0] o_f3_e,
    output [11:0] o_imm_12b_e,

    output o_reg_wr_e,
    output [1:0] o_result_src_e,
    output o_mem_write_e,
    output o_jmp_e,
    output o_branch_e,
    output [2:0] o_alu_ctl_e,
    output o_alu_src_e,
    output [6:0] o_opcode_e,
    
    output o_csr_reg_write_e,
    output [31:0] o_new_csr_e,
    output [31:0] o_old_csr_e,
    output [11:0] o_csr_rd_e,
    output o_ecall_e,
    output o_mret_e

);

    wire w_id_ex_final_flush;
    assign w_id_ex_final_flush = i_id_ex_flush || i_id_ex_flush_exception_m;

    reg [2:0] r_f3_e;
    assign o_f3_e = r_f3_e;

    reg [11:0] r_imm_12b_e;
    assign o_imm_12b_e = r_imm_12b_e;

    reg [31:0] r_new_csr_e;
    assign o_new_csr_e = r_new_csr_e;

    reg [31:0] r_mepc_e;
    assign o_mepc_e = r_mepc_e;

    reg [31:0] r_old_csr_e;
    assign o_old_csr_e = r_old_csr_e;

    reg [11:0] r_csr_rd_e;
    assign o_csr_rd_e = r_csr_rd_e;

    reg r_ecall_e;
    assign o_ecall_e = r_ecall_e;

    reg r_mret_e;
    assign o_mret_e = r_mret_e;


    reg r_csr_reg_write_e;
    assign o_csr_reg_write_e = r_csr_reg_write_e;

    reg[31:0] r_pc_e;
    assign o_pc_e = r_pc_e;

    reg [6:0] r_opcode_e;
    assign o_opcode_e = r_opcode_e;

    reg [4:0] r_rs1_e;
    assign o_rs1_e = r_rs1_e;

    reg [4:0] r_rs2_e;
    assign o_rs2_e = r_rs2_e;

    reg [4:0] r_rd_e;
    assign o_rd_e = r_rd_e;

    reg [31:0] r_pc_p4_e;
    assign o_pc_p4_e = r_pc_p4_e;

    reg [31:0] r_imm32_e;
    assign o_imm32_e = r_imm32_e;

    reg [31:0] r_regs_do1_e;
    assign o_regs_do1_e = r_regs_do1_e;

    reg [31:0] r_regs_do2_e;
    assign o_regs_do2_e = r_regs_do2_e;

    reg r_reg_wr_e;
    assign o_reg_wr_e = r_reg_wr_e;

    reg [1:0] r_result_src_e;
    assign o_result_src_e = r_result_src_e;

    reg r_mem_write_e;
    assign o_mem_write_e = r_mem_write_e;

    reg r_jmp_e;
    assign o_jmp_e = r_jmp_e;

    reg r_branch_e;
    assign o_branch_e = r_branch_e;

    reg [2:0] r_alu_ctl_e;
    assign o_alu_ctl_e = r_alu_ctl_e;

    reg r_alu_src_e;
    assign o_alu_src_e = r_alu_src_e;

    always@(posedge i_clk)
    begin
        if(i_rst || w_id_ex_final_flush)
        begin
            r_rs1_e <=0;
            r_rs2_e <=0;
            r_rd_e <=0;
            r_pc_p4_e <=0;
            r_imm32_e <=0;
            r_regs_do1_e <=0;
            r_regs_do2_e<=0;
            r_opcode_e<=0;
            r_pc_e<=0;

            r_csr_reg_write_e<=0;
            r_new_csr_e<=0;
            r_old_csr_e<=0;
            r_ecall_e<=0;
            r_mret_e<=0;
            r_mepc_e<=0;
            r_f3_e<=0;
            r_imm_12b_e<=0;

            r_reg_wr_e<=0;
            r_result_src_e<=0;
            r_mem_write_e<=0;
            r_jmp_e<=0;
            r_branch_e<=0;
            r_alu_ctl_e<=0;
            r_alu_src_e<=0;
        end
        else if(i_clk_en)
        begin
            r_rs1_e <=i_rs1_d;
            r_rs2_e <=i_rs2_d;
            r_rd_e <=i_rd_d;
            r_pc_p4_e <=i_pc_p4_d;
            r_imm32_e <=i_imm32_d;
            r_regs_do1_e <=i_regs_do1_d;
            r_regs_do2_e<=i_regs_do2_d;
            r_opcode_e<=i_opcode_d;
            r_pc_e<=i_pc_d;

            r_csr_reg_write_e<=i_csr_reg_write_d;
            r_new_csr_e<=i_new_csr_d;
            r_old_csr_e<=i_old_csr_d;
            r_csr_rd_e<=i_csr_rd_d;
            r_ecall_e<=i_ecall_d;
            r_mret_e<=i_mret_d;
            r_mepc_e<=i_mepc_d;
            r_f3_e<=i_f3_d;
            r_imm_12b_e<=i_imm_12b_d;

            r_reg_wr_e<=i_reg_wr_d;
            r_result_src_e<=i_result_src_d;
            r_mem_write_e<=i_mem_write_d;
            r_jmp_e<=i_jmp_d;
            r_branch_e<=i_branch_d;
            r_alu_ctl_e<=i_alu_ctl_d;
            r_alu_src_e<=i_alu_src_d;
        end
        
    end

endmodule