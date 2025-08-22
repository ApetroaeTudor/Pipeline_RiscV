module Control_Path_Tb;
reg [6:0] t_r_opcode;
reg [2:0] t_r_f3;
reg t_r_f7_b6;
reg t_r_zero;

wire [1:0] t_w_result_src;
wire [1:0] t_w_pc_src;
wire t_w_mem_write;
wire t_w_reg_write;
wire [2:0] t_w_alu_ctl;
wire t_w_alu_src;
wire [1:0] t_w_imm_src;

Control_Path Control_Path_Inst(.i_opcode(t_r_opcode),
                               .i_f3(t_r_f3),
                               .i_f7_b6(t_r_f7_b6),
                               .i_zero(t_r_zero),
                               .o_result_src(t_w_result_src),
                               .o_pc_src(t_w_pc_src),
                               .o_mem_write(t_w_mem_write),
                               .o_reg_write(t_w_reg_write),
                               .o_alu_ctl(t_w_alu_ctl),
                               .o_alu_src(t_w_alu_src),
                               .o_imm_src(t_w_imm_src));


initial
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Control_Path_Tb);
    t_r_opcode = 7'b011_0011; // r type
    t_r_f3 = 3'b010; // slt

    #10
    t_r_f3 = 3'b110; // or

    #10
    t_r_f3 = 3'b111;

    #10
    t_r_f3 = 3'b000;
    t_r_f7_b6 = 1'b0; //add

    #10
    t_r_f7_b6 = 1'b1; // sub


    #10
    t_r_opcode = 7'b000_0011; // lw

    #10
    t_r_opcode = 7'b001_0011; // addi

    #10
    t_r_opcode = 7'b110_0111; // jalr

    #10
    t_r_opcode = 7'b010_0011; // sw

    #10
    t_r_opcode = 7'b110_1111; // jal

    #10
    t_r_opcode = 7'b110_0011; // beq
    t_r_zero = 1'b0; // branch not taken

    #10
    t_r_zero = 1'b1; // branch taken

    #100
    $finish;
end

endmodule