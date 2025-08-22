`default_nettype none
`include "Constants.vh"
module Data_Path(
    input i_clk,
    input i_rst,
    input i_clk_en,

    input i_pc_wr_en_h,
    input i_if_id_flush_h,
    input i_if_id_stall_h,
    input i_id_ex_flush_h,

    input [1:0] i_fw_a_e,
    input [1:0] i_fw_b_e,
    input i_fw_a_d,
    input i_fw_b_d,

    // -----------------------------------------
    // input [1:0] i_pc_src_e, // 00 - pcp4, 01 - imm, 10 - rs1+imm
    input i_reg_write_d,
    input [1:0] i_result_src_d,
    input i_mem_write_d,
    input i_jmp_d,
    input i_branch_d,
    input [2:0] i_alu_ctl_d,
    input i_alu_src_d,
    input [2:0] i_imm_src_d, // outputs from Control Path
    // -----------------------------------------


    // -------------------------------------------
    input [1:0] i_fw_csr_into_normal_a_e, // 01 is rs1_data_ex = old_csr_mem, 10 is rs1_data_ex = old_csr_wb
    input [1:0] i_fw_csr_into_normal_b_e,

    input [1:0] i_fw_normal_into_csr_d, // 01 is rs1_d_d = alu_out_ex, 10 is rs1_d_d = alu_out_mem, 11 is rs1_d_d = res_wb

    input [1:0] i_fw_csr_csr_reg_d, // 01 is rs1_d_d = old_csr_e, 10 is old_csr_m, 11 is old_csr_wb
    input [1:0] i_fw_csr_csr_csr_d, // 01 is csr_data_d = new_csr_e, 10 is new_csr_m, 11 is new_csr_wb

    input [1:0] i_fw_mret_e, // 01 is pc<=new_csr_mem, 10 is pc<=new_csr_wb 

    // ------------------------------------------- outputs for csr type instruction hazards


    output o_f7_b6_d,
    output o_jmp_e,

    output [4:0] o_rs1_d,
    output [4:0] o_rs2_d,
    output [4:0] o_rs1_e,
    output [4:0] o_rs2_e,
    output [4:0] o_rd_e,
    output [4:0] o_rd_m,
    output [4:0] o_rd_w,

    output o_res_src_b0_e,
    output [1:0] o_pc_src_e,



    output [6:0] o_opcode_d, //
    output [2:0] o_f3_d, //
    output [11:0] o_imm_d, //

    output [6:0] o_opcode_e, // 
    output [2:0] o_f3_e, //
    output [11:0] o_imm_e, //
    output o_mret_e, //

    output [6:0] o_opcode_m, //
    output [2:0] o_f3_m, //
    output [11:0] o_imm_m, //

    output [6:0] o_opcode_w, //
    output [2:0] o_f3_w, //
    output [11:0] o_imm_w //

);

    wire [31:0] w_pc_in_f;
    wire [31:0] w_pc_out_f;
    wire [31:0] w_pc_p4_f;
    wire [3:0] w_exception_code_f;
    wire w_pc_trap_sel_f;
    reg [3:0] r_exception_code_f;
    reg [31:0]r_exception_pc_f;


    wire [31:0] w_instr_d;
    wire [31:0] w_pc_d;
    wire [31:0] w_pc_p4_d;
    wire [31:0] w_imm_32b_d;
    wire [31:0] w_regs_do1_d;
    wire [31:0] w_regs_do2_d;
    wire [31:0] w_haz_do1_d;
    wire [31:0] w_haz_do2_d;
    wire w_csr_reg_write_d;
    wire [31:0] w_new_csr_d;
    wire [31:0] w_old_csr_d;
    wire w_ecall_d;
    wire w_mret_d;
    wire [31:0] w_csr_read_data_d;
    wire [11:0] w_csr_rd_d;
    reg [3:0] r_exception_code_f_d_ff;
    reg [31:0]r_exception_pc_f_d_ff;
    wire [31:0] w_mepc_d;
    wire [31:0] w_csr_unit_rs1_data_d;
    wire [31:0] w_csr_unit_csr_data_d;
    

    
    wire [31:0] w_alu_out_e;
    wire [4:0] w_rs1_e;
    wire [4:0] w_rs2_e;
    wire [4:0] w_rd_e;
    wire [31:0] w_pc_p4_e;
    wire [31:0] w_pc_e;
    wire [31:0] w_imm_32b_e;
    wire [31:0] w_regs_do1_e;
    wire [31:0] w_regs_do2_e;
    wire w_reg_write_e;
    wire [1:0] w_result_src_e;
    wire w_mem_write_e;
    wire w_jmp_e;
    wire w_branch_e;
    wire [2:0] w_alu_ctl_e;
    wire w_alu_src_e;
    wire [31:0] w_haz_rs1_e;
    wire [31:0] w_haz_rs2_e;
    wire [31:0] w_alu_op_b_e;
    wire w_zero_e;
    wire [6:0] w_opcode_e;
    wire [1:0] w_pc_src_e;
    wire w_pc_trap_sel_e;
    wire [3:0] w_exception_code_e;
    wire [31:0] w_pc_target_branch_or_jal_e;
    wire w_csr_reg_write_e;
    wire [31:0] w_new_csr_e;
    wire [31:0] w_old_csr_e;
    wire [11:0] w_csr_rd_e;
    wire w_ecall_e;
    wire w_mret_e;
    reg [31:0]r_exception_pc_e;
    reg [3:0] r_exception_code_e;
    reg [31:0] r_exception_addr_e;
    wire [31:0] w_mepc_e;
    wire [11:0] w_imm_12b_e;
    wire [2:0] w_f3_e;
    wire [31:0] w_mret_target_pc_e;


    wire [31:0] w_alu_out_m;
    wire [4:0] w_rd_m;
    wire [31:0] w_haz_b_m;
    wire [31:0] w_pc_p4_m;
    wire w_reg_wr_m;
    wire [1:0] w_result_src_m;
    wire w_mem_write_m;
    wire [31:0] w_mem_out_m;
    wire [31:0] w_effective_addr_m;
    wire w_dm_en_m;
    wire w_if_id_flush_exception_m;
    wire w_id_ex_flush_exception_m;
    wire w_csr_reg_write_m;
    wire [31:0] w_new_csr_m;
    wire [31:0] w_old_csr_m;
    wire [11:0] w_csr_rd_m;
    reg [3:0] r_exception_code_e_m_ff;
    reg [31:0]r_exception_pc_e_m_ff;
    reg [31:0]r_exception_addr_e_m_ff;
    wire [6:0] w_opcode_m;
    wire [2:0] w_f3_m;
    wire [11:0] w_imm_12b_m;



    wire [4:0] w_rd_w;    
    wire [31:0] w_result_w;
    wire w_reg_write_w;
    wire [31:0] w_alu_out_w;
    wire [31:0] w_mem_out_w;
    wire [31:0] w_pc_p4_w;
    wire [1:0] w_result_src_w;
    wire w_csr_reg_write_w;
    wire [31:0] w_new_csr_w;
    wire [31:0] w_old_csr_w;
    wire [11:0] w_csr_rd_w;
    wire [6:0] w_opcode_w;
    wire [2:0] w_f3_w;
    wire [11:0] w_imm_12b_w;


    wire w_pc_in_txt;
    assign w_pc_in_txt = !w_pc_out_f[20] && w_pc_out_f[19] && !w_pc_out_f[18];



    reg r_reset_permission = 1'b1;
    reg r_trap_permission = 1'b0;

    // ccN: PC_out_f (current PC) checked for exceptions
	// 	- exception_code_f generated using past permissions.
    // ccN+1: PC_trap_sel_f redirects PC_in_f if exception occurred.
	//     - Permissions update based on exception_code_f from cycle N.


    always @(posedge i_clk or posedge i_rst) 
    begin
        if (i_rst) begin
            r_reset_permission <= 1'b1;
            r_trap_permission  <= 1'b0;
        end else if (i_clk_en) begin
            if (r_reset_permission && w_pc_in_txt)
                r_reset_permission <= 1'b0;
            else if (i_rst)
                r_reset_permission <= 1'b1;

            if ((w_exception_code_e != `NO_E || w_exception_code_f != `NO_E) && !i_rst)
                r_trap_permission <= 1'b1;
            else if (w_pc_in_txt)
                r_trap_permission <= 1'b0;

            if (w_exception_code_f!=`NO_E)
            begin
                r_exception_code_f_d_ff<=r_exception_code_f;
                r_exception_pc_f_d_ff<=r_exception_pc_f;
            end
            else
            begin
                r_exception_code_f_d_ff<=`NO_E;
                r_exception_pc_f_d_ff<=0;
            end

            if(w_exception_code_e!=`NO_E)
            begin
                r_exception_code_e_m_ff<=r_exception_code_e;
                r_exception_pc_e_m_ff<=r_exception_pc_e;
                r_exception_addr_e_m_ff<=r_exception_addr_e;
            end
            else
            begin
                r_exception_code_e_m_ff<=`NO_E;
                r_exception_pc_e_m_ff<=0;
                r_exception_addr_e_m_ff<=0;
            end
        end


    end

    always@(*)
    begin

        r_exception_code_f = w_exception_code_f;
        r_exception_pc_f = w_pc_out_f;

        r_exception_code_e = w_exception_code_e;
        r_exception_pc_e = w_pc_e;
        r_exception_addr_e = w_alu_out_e;

    end




    Exception_Signals_Handler Exception_Signals_Handler_Inst(
        .i_reset_permission(r_reset_permission),
        .i_trap_permission(r_trap_permission),
        .i_pc_f(w_pc_out_f),
        .i_opcode_f(w_instr_f[6:0]),
        .i_res_src_e(w_result_src_e),
        .i_reg_write_e(w_reg_write_e),
        .i_rd_e(w_rd_e),
        .i_alu_out_e(w_alu_out_e),
        .i_mem_write_e(w_mem_write_e),
        .i_ecall_e(w_ecall_e),
        .i_ms_12b_f(w_instr_f[31:20]),
        .o_exception_code_f(w_exception_code_f),
        .o_exception_code_e(w_exception_code_e)
    );


    // IF ------------------------------------------------------------


    PC PC_Inst(.i_clk(i_clk),
               .i_clk_en(i_clk_en),
               .i_wr_en(i_pc_wr_en_h),
               .i_exception_f_stall(w_pc_trap_sel_f),
               .i_rst(i_rst),
               .i_di(w_pc_in_f),
               .o_do(w_pc_out_f));

    assign w_pc_trap_sel_f = (w_exception_code_f!=`NO_E)?1'b1:1'b0;

    assign w_pc_p4_f = w_pc_out_f + 32'd4;

   

    assign w_pc_in_f = 
    (i_rst)?`RESET_LO:
    (w_mret_e)?(w_mret_target_pc_e):
    (w_pc_trap_sel_f || w_pc_trap_sel_e)?`TRAP_LO:
    (w_pc_src_e == 2'b00)?w_pc_p4_f: // pcp4;
    (w_pc_src_e == 2'b01)?w_pc_target_branch_or_jal_e: // imm // beq && jal
    (w_pc_src_e == 2'b10)?w_alu_out_e:32'b0; // rs1+imm


    wire [31:0] w_instr_f;
    Mem_Instr Mem_Instr_Inst(.i_rst(i_rst),
                             .i_adr(w_pc_out_f),
                             .o_instr(w_instr_f));


    // ~IF ------------------------------------------------------------

    

    IF_ID IF_ID_Inst(.i_clk(i_clk),
                     .i_rst(i_rst),
                     .i_clk_en(i_clk_en),
                     .i_if_id_stall(i_if_id_stall_h),
                     .i_if_id_flush(i_if_id_flush_h),
                     .i_instr_f(w_instr_f),
                     .i_pc_p4_f(w_pc_p4_f),
                     .i_pc_f(w_pc_out_f),
                     .i_if_id_flush_exception_m(w_if_id_flush_exception_m),
                     .i_exception_f_stall(w_pc_trap_sel_f),


                     .i_exception_code_f(w_exception_code_f),

                     .o_instr_d(w_instr_d),
                     .o_pc_p4_d(w_pc_p4_d),
                     .o_pc_d(w_pc_d));

    // ID ------------------------------------------------------------

    assign o_opcode_d = w_instr_d[6:0]; 
    assign o_f3_d = w_instr_d[14:12];
    assign o_f7_b6_d = w_instr_d[30];
    assign o_imm_d = w_instr_d[31:20];


    Reg_File Reg_File_Inst(.i_clk(i_clk),
                           .i_clk_enable(i_clk_en),
                           .i_rst(i_rst),
                           .i_csr_reg_write(w_csr_reg_write_w),
                           .i_reg_write(w_reg_write_w),
                           .i_rd_addr_1(w_instr_d[19:15]),
                           .i_rd_addr_2(w_instr_d[24:20]),
                           .i_wr_addr(w_rd_w),
                           .i_wr_data(w_result_w),
                           .o_rd_data_1(w_regs_do1_d),
                           .o_rd_data_2(w_regs_do2_d));

    M_CSR_Reg_File M_CSR_Reg_File_Inst(.i_clk(i_clk),
                                       .i_rst(i_rst),
                                       .i_clk_en(i_clk_en),
                                       .i_opcode_d(w_instr_d[6:0]),
                                       .i_csr_write_addr(w_csr_rd_w),
                                       .i_csr_read_addr(w_instr_d[31:20]),
                                       .i_csr_write_enable(w_csr_reg_write_w),
                                       .i_exception_code_f_d_ff(r_exception_code_f_d_ff),
                                       .i_exception_pc_f_d_ff(r_exception_pc_f_d_ff),
                                       .i_exception_code_e_m_ff(r_exception_code_e_m_ff),
                                       .i_exception_pc_e_m_ff(r_exception_pc_e_m_ff),
                                       .i_exception_addr_e_m_ff(r_exception_addr_e_m_ff),
                                       .i_csr_data(w_new_csr_w),
                                       .i_mret_e(w_mret_e),
                                       .o_csr_data(w_csr_read_data_d),
                                       .o_mepc(w_mepc_d));


    assign w_csr_unit_rs1_data_d = (i_fw_normal_into_csr_d == 2'b01)?w_alu_out_e:
                                   (i_fw_normal_into_csr_d == 2'b10)?w_alu_out_m:
                                   (i_fw_normal_into_csr_d == 2'b11)?w_result_w:
                                   (i_fw_csr_csr_reg_d == 2'b01)?w_old_csr_e:
                                   (i_fw_csr_csr_reg_d == 2'b10)?w_old_csr_m:
                                   (i_fw_csr_csr_reg_d == 2'b11)?w_old_csr_w: w_regs_do1_d;

    assign w_csr_unit_csr_data_d = (i_fw_csr_csr_csr_d == 2'b01)?w_new_csr_e:
                                   (i_fw_csr_csr_csr_d == 2'b10)?w_new_csr_m:
                                   (i_fw_csr_csr_csr_d == 2'b11)?w_new_csr_w: w_csr_read_data_d;

    CSR_Behavior_Unit CSR_Behavior_Unit_Inst(.i_opcode_d(w_instr_d[6:0]),
                                             .i_f3_d(w_instr_d[14:12]),
                                             .i_rd_d(w_instr_d[11:7]),
                                             .i_rs1_d(w_instr_d[19:15]),
                                             .i_rs1_data(w_csr_unit_rs1_data_d),
                                             .i_csr_d(w_csr_unit_csr_data_d),
                                             .i_imm_d(w_instr_d[31:20]),

                                             .o_csr_reg_write_d(w_csr_reg_write_d), // to wb
                                             .o_new_csr_d(w_new_csr_d), // to wb
                                             .o_old_csr_d(w_old_csr_d), // to wb
                                             .o_csr_rd_d(w_csr_rd_d), // to wb
                                             .o_ecall_d(w_ecall_d), // to ex
                                             .o_mret_d(w_mret_d)); // to ex

    Imm_32 Imm_32_Inst(.i_imm_ctl(i_imm_src_d),
                       .i_instr_bits(w_instr_d[31:7]),
                       .o_extended_imm(w_imm_32b_d));

    assign o_rs1_d = w_instr_d[19:15];
    assign o_rs2_d = w_instr_d[24:20];

    // ~ID ------------------------------------------------------------



    assign w_haz_do1_d = (i_fw_a_d == 1'b0)?w_regs_do1_d:w_result_w;
    assign w_haz_do2_d = (i_fw_b_d == 1'b0)?w_regs_do2_d:w_result_w;
    ID_EX ID_EX_Inst(.i_clk(i_clk),
                     .i_rst(i_rst),
                     .i_clk_en(i_clk_en),
                     .i_id_ex_flush(i_id_ex_flush_h),
                     
                     .i_rs1_d(w_instr_d[19:15]),
                     .i_rs2_d(w_instr_d[24:20]),
                     .i_rd_d(w_instr_d[11:7]),
                     .i_pc_p4_d(w_pc_p4_d),
                     .i_imm32_d(w_imm_32b_d),
                     .i_regs_do1_d(w_haz_do1_d),
                     .i_regs_do2_d(w_haz_do2_d),

                     .i_csr_reg_write_d(w_csr_reg_write_d),
                     .i_new_csr_d(w_new_csr_d),
                     .i_old_csr_d(w_old_csr_d),
                     .i_csr_rd_d(w_csr_rd_d),
                     .i_ecall_d(w_ecall_d),
                     .i_mret_d(w_mret_d),
                        
                     .i_reg_wr_d(i_reg_write_d),
                     .i_result_src_d(i_result_src_d),
                     .i_mem_write_d(i_mem_write_d),
                     .i_jmp_d(i_jmp_d),
                     .i_branch_d(i_branch_d),
                     .i_alu_ctl_d(i_alu_ctl_d),
                     .i_alu_src_d(i_alu_src_d),
                     .i_opcode_d(w_instr_d[6:0]),
                     .i_id_ex_flush_exception_m(w_id_ex_flush_exception_m),
                     .i_pc_d(w_pc_d),
                     .i_mepc_d(w_mepc_d),
                     .i_f3_d(w_instr_d[14:12]),
                     .i_imm_12b_d(w_instr_d[31:20]),


                     .o_pc_e(w_pc_e),
                     .o_rs1_e(w_rs1_e),
                     .o_rs2_e(w_rs2_e),
                     .o_rd_e(w_rd_e),
                     .o_pc_p4_e(w_pc_p4_e),
                     .o_imm32_e(w_imm_32b_e),
                     .o_regs_do1_e(w_regs_do1_e),
                     .o_regs_do2_e(w_regs_do2_e),
                     .o_mepc_e(w_mepc_e),

                     .o_csr_reg_write_e(w_csr_reg_write_e),
                     .o_new_csr_e(w_new_csr_e),
                     .o_old_csr_e(w_old_csr_e),
                     .o_csr_rd_e(w_csr_rd_e),
                     .o_ecall_e(w_ecall_e),
                     .o_mret_e(w_mret_e),
                     .o_f3_e(w_f3_e),
                     .o_imm_12b_e(w_imm_12b_e),

                     .o_reg_wr_e(w_reg_write_e),
                     .o_result_src_e(w_result_src_e),
                     .o_mem_write_e(w_mem_write_e),
                     .o_jmp_e(w_jmp_e),
                     .o_branch_e(w_branch_e),
                     .o_alu_ctl_e(w_alu_ctl_e),
                     .o_alu_src_e(w_alu_src_e),
                     .o_opcode_e(w_opcode_e));

    // EX ------------------------------------------------------------

    assign o_res_src_b0_e = w_result_src_e[0];
    assign o_pc_src_e = w_pc_src_e;
    assign w_pc_target_branch_or_jal_e = w_pc_e + w_imm_32b_e;

    assign o_rs1_e = w_rs1_e;
    assign o_rs2_e = w_rs2_e;
    assign o_rd_e = w_rd_e;
    assign o_jmp_e = w_jmp_e;

    assign o_opcode_e = w_opcode_e;
    assign o_mret_e = w_mret_e;
    assign o_f3_e = w_f3_e;
    assign o_imm_e = w_imm_12b_e;

    assign w_mret_target_pc_e = (i_fw_mret_e == 2'b01)?w_new_csr_m:
                                (i_fw_mret_e == 2'b10)?w_new_csr_w: w_mepc_e;

    

    assign w_haz_rs1_e = (i_fw_csr_into_normal_a_e == 2'b01)?w_old_csr_m: // careful to prioritize the more urgent forward
                         (i_fw_a_e==2'b10)?w_alu_out_m:
                         (i_fw_csr_into_normal_a_e == 2'b10)?w_old_csr_w:
                         (i_fw_a_e==2'b01)?w_result_w:w_regs_do1_e;




    assign w_haz_rs2_e = (i_fw_csr_into_normal_b_e == 2'b01)?w_old_csr_m:
                         (i_fw_b_e==2'b10)?w_alu_out_m:
                         (i_fw_csr_into_normal_b_e == 2'b10)?w_old_csr_w:
                         (i_fw_b_e==2'b01)?w_result_w:w_regs_do2_e;


    assign w_alu_op_b_e = (w_alu_src_e==1'b0)?w_haz_rs2_e:w_imm_32b_e;


    assign w_pc_src_e =
    ((w_zero_e && w_branch_e) || (w_jmp_e && w_opcode_e == `OP_J_TYPE)) ? 2'b01:
    (w_jmp_e && w_opcode_e == `OP_I_TYPE_JALR)?2'b10:
    2'b00; 

    assign w_pc_trap_sel_e =  (^w_exception_code_e===1'bx)?1'b0:
                              (w_exception_code_e!=4'b1111)?1'b1:1'b0;


    ALU_Main ALU_Main_Inst(.i_op_a(w_haz_rs1_e),
                           .i_op_b(w_alu_op_b_e),
                           .i_alu_op(w_alu_ctl_e),
                           .o_zero(w_zero_e),
                           .o_alu_out(w_alu_out_e));

    // ~EX ------------------------------------------------------------

    EX_MEM EX_MEM_Inst(.i_clk(i_clk),
                       .i_rst(i_rst),
                       .i_clk_en(i_clk_en),
                       
                       .i_rd_e(w_rd_e),
                       .i_alu_out_e(w_alu_out_e),
                       .i_haz_b_e(w_haz_rs2_e),
                       .i_pc_p4_e(w_pc_p4_e),
                       
                       .i_reg_wr_e(w_reg_write_e),
                       .i_result_src_e(w_result_src_e),
                       .i_mem_write_e(w_mem_write_e),
                       .i_exception_code_e(w_exception_code_e),

                       .i_csr_reg_write_e(w_csr_reg_write_e),
                       .i_new_csr_e(w_new_csr_e),
                       .i_old_csr_e(w_old_csr_e),
                       .i_csr_rd_e(w_csr_rd_e),

                       .i_opcode_e(w_opcode_e),
                       .i_f3_e(w_f3_e),
                       .i_imm_12b_e(w_imm_12b_e),
                       
                       .o_if_id_flush_exception_m(w_if_id_flush_exception_m),
                       .o_id_ex_flush_exception_m(w_id_ex_flush_exception_m),
                       .o_rd_m(w_rd_m),
                       .o_alu_out_m(w_alu_out_m),
                       .o_haz_b_m(w_haz_b_m),
                       .o_pc_p4_m(w_pc_p4_m),
                       .o_reg_wr_m(w_reg_wr_m),
                       .o_result_src_m(w_result_src_m),
                       .o_mem_write_m(w_mem_write_m),

                       .o_opcode_m(w_opcode_m),
                       .o_f3_m(w_f3_m),
                       .o_imm_12b_m(w_imm_12b_m),

                       .o_csr_reg_write_m(w_csr_reg_write_m),
                       .o_new_csr_m(w_new_csr_m),
                       .o_old_csr_m(w_old_csr_m),
                       .o_csr_rd_m(w_csr_rd_m));

    // MEM ------------------------------------------------------------

    
  
    Mem_Calculation_Unit Mem_Calculation_Unit_Inst(.i_addr_m(w_alu_out_m),
                                                   .o_effective_addr_m(w_effective_addr_m),
                                                   .o_dm_en(w_dm_en_m));

    Mem_Data Mem_Data_Inst(.i_clk(i_clk),
                           .i_clk_enable(i_clk_en),
                           .i_rst(i_rst),
                           .i_mem_write(w_mem_write_m),
                           .i_mem_addr(w_effective_addr_m),
                           .i_mem_data(w_haz_b_m),
                           .o_mem_data(w_mem_out_m));

    assign o_rd_m = w_rd_m;
    assign o_opcode_m = w_opcode_m;
    assign o_f3_m = w_f3_m;
    assign o_imm_m = w_imm_12b_m;

    // ~MEM ------------------------------------------------------------

    MEM_WB MEM_WB_Inst(.i_clk(i_clk),
                       .i_rst(i_rst),
                       .i_clk_en(i_clk_en),
                       
                       .i_alu_out_m(w_alu_out_m),
                       .i_mem_out_m(w_mem_out_m),
                       .i_rd_m(w_rd_m),
                       .i_pc_p4_m(w_pc_p4_m),
                       .i_reg_wr_m(w_reg_wr_m),
                       .i_result_src_m(w_result_src_m),

                       .i_csr_reg_write_m(w_csr_reg_write_m),
                       .i_new_csr_m(w_new_csr_m),
                       .i_old_csr_m(w_old_csr_m),
                       .i_csr_rd_m(w_csr_rd_m),

                       .i_opcode_m(w_opcode_m),
                       .i_f3_m(w_f3_m),
                       .i_imm_12b_m(w_imm_12b_m),
                       
                       .o_alu_out_w(w_alu_out_w),
                       .o_mem_out_w(w_mem_out_w),
                       .o_rd_w(w_rd_w),
                       .o_pc_p4_w(w_pc_p4_w),
                       .o_reg_wr_w(w_reg_write_w),
                       .o_result_src_w(w_result_src_w),

                       .o_opcode_w(w_opcode_w),
                       .o_f3_w(w_f3_w),
                       .o_imm_12b_w(w_imm_12b_w),

                       .o_csr_reg_write_w(w_csr_reg_write_w),
                       .o_new_csr_w(w_new_csr_w),
                       .o_old_csr_w(w_old_csr_w),
                       .o_csr_rd_w(w_csr_rd_w));

    // w ------------------------------------------------------------


    assign w_result_w = 
    (!w_csr_reg_write_w)?
        ((w_result_src_w==2'b00)?w_alu_out_w:
        (w_result_src_w==2'b01)?w_mem_out_w:
        (w_result_src_w==2'b10)?w_pc_p4_w:32'b0):
    (w_csr_reg_write_w)?w_old_csr_w:32'b0;

    assign o_rd_w = w_rd_w;

    assign o_opcode_w = w_opcode_w;
    assign o_f3_w = w_f3_w;
    assign o_imm_w = w_imm_12b_w;

    // ~w ------------------------------------------------------------









endmodule