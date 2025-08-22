module Hazard_Unit_Tb;
reg [4:0] t_r_rs1_d;
reg [4:0] t_r_rs2_d;
reg [4:0] t_r_rs1_e;
reg [4:0] t_r_rs2_e;

reg [4:0] t_r_rd_e;
reg [4:0] t_r_rd_m;
reg [4:0] t_r_rd_wb;
reg t_r_res_src_b0_e;
reg [1:0] t_r_pc_src_e;

wire [1:0] t_w_fw_a_e;
wire [1:0] t_w_fw_b_e;
wire t_w_fw_a_d;
wire t_w_fw_b_d;

wire t_w_if_id_flush;
wire t_w_if_id_stall;
wire t_w_id_ex_flush;
wire t_w_pc_stall;

Hazard_Unit DUT(.i_rs1_d(t_r_rs1_d),
                .i_rs2_d(t_r_rs2_d),
                .i_rs1_e(t_r_rs1_e),
                .i_rs2_e(t_r_rs2_e),
                .i_rd_e(t_r_rd_e),
                .i_rd_m(t_r_rd_m),
                .i_rd_wb(t_r_rd_wb),
                .i_res_src_b0_e(t_r_res_src_b0_e),
                .i_pc_src_e(t_r_pc_src_e),
                .o_fw_a_e(t_w_fw_a_e),
                .o_fw_b_e(t_w_fw_b_e),
                .o_fw_a_d(t_w_fw_a_d),
                .o_fw_b_d(t_w_fw_b_d),
                .o_if_id_flush(t_w_if_id_flush),
                .o_if_id_stall(t_w_if_id_stall),
                .o_id_ex_flush(t_w_id_ex_flush),
                .o_pc_stall(t_w_pc_stall));


initial
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Hazard_Unit_Tb);

    #10;
    #10
    t_r_rs1_e=4'd5;
    t_r_rd_m=4'd5;
    //fwae  should be 10

    #10
    t_r_rs1_e=4'd0;
    //fwae should be 00

    #10
    t_r_rs2_e=4'd5;
    //fwbe should be 10

    #10
    t_r_rd_e=4'd5;
    // fwae and fwbe should be still 10

    #10
    t_r_rd_m=4'd5;
    // fwae and fwbe should be 01

    #10
    t_r_rs1_d=4'd5;
    t_r_rs2_d=4'd5;
    t_r_rd_wb=4'd5;
    // fwad and fwbd should be 1

    #10
    t_r_rs1_d=4'd2;
    t_r_rd_e=4'd2;
    // stall lw should be 0

    #10
    t_r_res_src_b0_e=1'b1;
    // stall lw should be 1, together with stall pc, stall ifid, flush ex

    #10
    t_r_res_src_b0_e=1'b0;
    t_r_pc_src_e = 2'b01; // branch taken, flushD and flushE
end
endmodule