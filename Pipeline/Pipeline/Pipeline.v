module Pipeline(
    input i_clk,
    input i_rst,
    input i_btn_enable_d_s_o
);

    reg r_clk_en = 1'b0;

    always@(posedge i_clk)
    begin
        if(i_btn_enable_d_s_o)
        r_clk_en<=~r_clk_en;
    end



    wire w_fw_a_d;
    wire w_fw_b_d;
    wire [4:0] w_rs1_d;
    wire [4:0] w_rs2_d;
    wire [6:0] w_opcode_d;
    wire [2:0] w_f3_d;
    wire [11:0] w_imm_d;
    wire [1:0] w_fw_normal_into_csr_d;
    wire [1:0] w_fw_csr_csr_reg_d;
    wire [1:0] w_fw_csr_csr_csr_d;



    wire [1:0] w_fw_a_e;
    wire [1:0] w_fw_b_e;
    wire [4:0] w_rs1_e;
    wire [4:0] w_rs2_e;
    wire [4:0] w_rd_e;
    wire w_res_src_b0_e;
    wire [1:0] w_pc_src_e;
    wire w_jmp_e;
    wire [6:0] w_opcode_e;
    wire [2:0] w_f3_e;
    wire [11:0] w_imm_e;
    wire w_mret_e;
    wire [1:0] w_fw_csr_into_normal_a_e;
    wire [1:0] w_fw_csr_into_normal_b_e;
    wire [1:0] w_fw_mret_e;


    wire [4:0] w_rd_m;
    wire [6:0] w_opcode_m;
    wire [2:0] w_f3_m;
    wire [11:0] w_imm_m;



    wire [4:0] w_rd_w;
    wire [6:0] w_opcode_w;
    wire [2:0] w_f3_w;
    wire [11:0] w_imm_w;

    wire w_if_id_flush;
    wire w_if_id_stall;
    wire w_id_ex_flush;
    wire w_pc_stall;

 
  
   
    
  


    wire [1:0] w_result_src;
    wire w_branch;
    wire w_jmp_d;
    wire w_mem_write;
    wire w_reg_write;
    wire [2:0] w_alu_ctl;
    wire w_alu_src;
    wire [2:0] w_imm_src;

    wire w_f7_b6;

    Data_Path Data_Path_Inst(.i_clk(i_clk),
                             .i_rst(i_rst),
                             .i_clk_en(r_clk_en),
                             
                             .i_pc_wr_en_h(~w_pc_stall),
                             .i_if_id_flush_h(w_if_id_flush),
                             .i_if_id_stall_h(w_if_id_stall),
                             .i_id_ex_flush_h(w_id_ex_flush),
                             
                             .i_fw_a_e(w_fw_a_e),
                             .i_fw_b_e(w_fw_b_e),
                             .i_fw_a_d(w_fw_a_d),
                             .i_fw_b_d(w_fw_b_d),

                             .i_reg_write_d(w_reg_write),
                             .i_result_src_d(w_result_src),
                             .i_mem_write_d(w_mem_write),
                             .i_jmp_d(w_jmp_d),
                             .i_branch_d(w_branch),
                             .i_alu_ctl_d(w_alu_ctl),
                             .i_alu_src_d(w_alu_src),
                             .i_imm_src_d(w_imm_src),

                             .i_fw_csr_into_normal_a_e(w_fw_csr_into_normal_a_e),
                             .i_fw_csr_into_normal_b_e(w_fw_csr_into_normal_b_e),
                             .i_fw_normal_into_csr_d(w_fw_normal_into_csr_d),
                             .i_fw_csr_csr_reg_d(w_fw_csr_csr_reg_d),
                             .i_fw_csr_csr_csr_d(w_fw_csr_csr_csr_d),
                             .i_fw_mret_e(w_fw_mret_e),
                             
                             .o_jmp_e(w_jmp_e),
                             
                             .o_f7_b6_d(w_f7_b6),
                             
                             .o_rs1_d(w_rs1_d),
                             .o_rs2_d(w_rs2_d),
                             .o_rs1_e(w_rs1_e),
                             .o_rs2_e(w_rs2_e),
                             .o_rd_e(w_rd_e),
                             .o_rd_m(w_rd_m),
                             .o_rd_w(w_rd_w),


                             .o_opcode_d(w_opcode_d),
                             .o_f3_d(w_f3_d),
                             .o_imm_d(w_imm_d),

                             .o_opcode_e(w_opcode_e),
                             .o_f3_e(w_f3_e),
                             .o_imm_e(w_imm_e),
                             .o_mret_e(w_mret_e),

                             .o_opcode_m(w_opcode_m),
                             .o_f3_m(w_f3_m),
                             .o_imm_m(w_imm_m),

                             .o_opcode_w(w_opcode_w),
                             .o_f3_w(w_f3_w),
                             .o_imm_w(w_imm_w),


                             
                             .o_res_src_b0_e(w_res_src_b0_e),
                             .o_pc_src_e(w_pc_src_e));


    Control_Path Control_Path_Inst(.i_opcode(w_opcode_d),
                                   .i_f3(w_f3_d),
                                   .i_f7_b6(w_f7_b6),
                                   
                                   .o_result_src(w_result_src),
                                   .o_branch(w_branch),
                                   .o_jmp(w_jmp_d),
                                   .o_mem_write(w_mem_write),
                                   .o_reg_write(w_reg_write),
                                   .o_alu_ctl(w_alu_ctl),
                                   .o_alu_src(w_alu_src),
                                   .o_imm_src(w_imm_src));


    Hazard_Unit Hazard_Unit_Inst(.i_opcode_d(w_opcode_d),
                                 .i_f3_d(w_f3_d),
                                 .i_imm_d(w_imm_d),
                                 .i_opcode_e(w_opcode_e),
                                 .i_f3_e(w_f3_e),
                                 .i_mret_e(w_mret_e),
                                 .i_imm_e(w_imm_e),
                                 .i_opcode_m(w_opcode_m),
                                 .i_f3_m(w_f3_m),
                                 .i_imm_m(w_imm_m),
                                 .i_opcode_w(w_opcode_w),
                                 .i_f3_w(w_f3_w),
                                 .i_imm_w(w_imm_w),


                                 .i_rs1_d(w_rs1_d),
                                 .i_rs2_d(w_rs2_d),
                                 .i_rs1_e(w_rs1_e),
                                 .i_rs2_e(w_rs2_e),
                                 
                                 .i_rd_e(w_rd_e),
                                 .i_rd_m(w_rd_m),
                                 .i_rd_wb(w_rd_w),
                                 .i_res_src_b0_e(w_res_src_b0_e),
                                 .i_pc_src_e(w_pc_src_e),
                                 .i_jmp_e(w_jmp_e),
                                 
                                 .o_fw_a_e(w_fw_a_e),
                                 .o_fw_b_e(w_fw_b_e),
                                 .o_fw_a_d(w_fw_a_d),
                                 .o_fw_b_d(w_fw_b_d),

                                 .o_fw_csr_into_normal_a_e(w_fw_csr_into_normal_a_e),
                                 .o_fw_csr_into_normal_b_e(w_fw_csr_into_normal_b_e),
                                 .o_fw_normal_into_csr_d(w_fw_normal_into_csr_d),
                                 .o_fw_csr_csr_reg_d(w_fw_csr_csr_reg_d),
                                 .o_fw_csr_csr_csr_d(w_fw_csr_csr_csr_d),

                                 .o_fw_mret_e(w_fw_mret_e),
                                 
                                 .o_if_id_flush(w_if_id_flush),
                                 .o_if_id_stall(w_if_id_stall),
                                 .o_id_ex_flush(w_id_ex_flush),
                                 .o_pc_stall(w_pc_stall));


endmodule