module MEM_WB(
    input i_clk,
    input i_rst,
    input i_clk_en,

    input [31:0] i_alu_out_m,
    input [31:0] i_mem_out_m,
    input [4:0] i_rd_m,
    input [31:0] i_pc_p4_m,

    input i_reg_wr_m,
    input [1:0] i_result_src_m,

    input i_csr_reg_write_m,
    input [31:0] i_new_csr_m,
    input [31:0] i_old_csr_m,
    input [11:0] i_csr_rd_m,


    input [6:0] i_opcode_m,
    input [2:0] i_f3_m,
    input [11:0] i_imm_12b_m,

    output [31:0] o_alu_out_w,
    output [31:0] o_mem_out_w,
    output [4:0] o_rd_w,
    output [31:0] o_pc_p4_w,

    output o_csr_reg_write_w,
    output [31:0] o_new_csr_w,
    output [31:0] o_old_csr_w,
    output [11:0] o_csr_rd_w,

    output [6:0] o_opcode_w,
    output [2:0] o_f3_w,
    output [11:0] o_imm_12b_w,

    output o_reg_wr_w,
    output [1:0] o_result_src_w
);


    reg [6:0] r_opcode_m;
    assign o_opcode_w = r_opcode_m;

    reg [2:0] r_f3_m;
    assign o_f3_w = r_f3_m;

    reg [11:0] r_imm_12b_m;
    assign o_imm_12b_w = r_imm_12b_m;



    reg r_csr_reg_write_m;
    assign o_csr_reg_write_w = r_csr_reg_write_m;

    reg [31:0] r_new_csr_m;
    assign o_new_csr_w = r_new_csr_m;

    reg [31:0] r_old_csr_m;
    assign o_old_csr_w = r_old_csr_m;

    reg [11:0] r_csr_rd_m;
    assign o_csr_rd_w = r_csr_rd_m;


    reg [31:0] r_alu_out_m;
    assign o_alu_out_w = r_alu_out_m;

    reg [31:0] r_mem_out_m;
    assign o_mem_out_w = r_mem_out_m;

    reg [4:0] r_rd_m;
    assign o_rd_w = r_rd_m;

    reg [31:0] r_pc_p4_m;
    assign o_pc_p4_w = r_pc_p4_m;

    reg r_reg_wr_m;
    assign o_reg_wr_w = r_reg_wr_m;

    reg [1:0] r_result_src_m;
    assign o_result_src_w = r_result_src_m;

    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            r_alu_out_m<=0;
            r_mem_out_m<=0;
            r_rd_m<=0;
            r_pc_p4_m<=0;
            r_csr_reg_write_m<=0;

            r_reg_wr_m<=0;
            r_result_src_m<=0;

            r_opcode_m<=0;
            r_f3_m<=0;
            r_imm_12b_m<=0;

            r_old_csr_m<=0;
            r_new_csr_m<=0;
            r_csr_rd_m<=0;

        end
        else if(i_clk_en)
        begin
            r_alu_out_m<=i_alu_out_m;
            r_mem_out_m<=i_mem_out_m;
            r_rd_m<=i_rd_m;
            r_pc_p4_m<=i_pc_p4_m;
            r_csr_reg_write_m<=i_csr_reg_write_m;

            r_reg_wr_m<=i_reg_wr_m;
            r_result_src_m<=i_result_src_m;

            r_old_csr_m<=i_old_csr_m;
            r_new_csr_m<=i_new_csr_m;
            r_csr_rd_m<=i_csr_rd_m;

            r_opcode_m<=i_opcode_m;
            r_f3_m<=i_f3_m;
            r_imm_12b_m<=i_imm_12b_m;

        end
    end

endmodule