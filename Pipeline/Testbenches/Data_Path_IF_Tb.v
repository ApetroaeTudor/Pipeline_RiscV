module Data_Path_IF_Tb;
reg t_r_clk;
reg t_r_rst;
reg t_r_clk_en;

reg t_r_pc_wr_en_h;
reg t_r_if_id_flush_h;
reg t_r_if_id_stall_h;

wire [6:0] t_w_opcode_d;
wire [2:0] t_w_f3_d;
wire t_w_f7_b6_d;

always #5 t_r_clk = ~t_r_clk;

Data_Path DUT(.i_clk(t_r_clk),
              .i_rst(t_r_rst),
              .i_clk_en(t_r_clk_en),
              .i_pc_wr_en_h(t_r_pc_wr_en_h),
              .i_if_id_flush_h(t_r_if_id_flush_h),
              .i_if_id_stall_h(t_r_if_id_stall_h),
              .i_pc_src_e(2'b00),
              .i_reg_write_d(1'b0),
              .i_result_src_d(2'b0),
              .i_mem_write_d(1'b0),
              .i_jmp_d(1'b0),
              .i_branch_d(1'b0),
              .i_alu_ctl_d(3'b0),
              .i_alu_src_d(1'b0),
              .i_imm_src_d(2'b0),
              .o_opcode_d(t_w_opcode_d),
              .o_f3_d(t_w_f3_d),
              .o_f7_b6_d(t_w_f7_b6_d));


initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Data_Path_IF_Tb);
    t_r_clk = 1'b0;
    t_r_rst = 1'b0;
    t_r_clk_en = 1'b0;
    t_r_pc_wr_en_h=1'b1;

    #10
    t_r_clk_en=1'b1;

    #10
    t_r_rst=1'b1;
    #10
    t_r_rst=1'b0;

    #10
    t_r_if_id_flush_h=1'b1;

    #10
    t_r_if_id_flush_h=1'b0;
    t_r_if_id_stall_h=1'b1;


    #1000
    $finish;
end
endmodule