`timescale 1ns / 1ns

module TOP(
    input clk,
    input reset,

    output[31:0] pc_out,
    output[31:0] x1_out,
    output[31:0] x2_out,
    output[31:0] x3_out,
    output[31:0] x8_out,
    output[31:0] mem_addr_12_test
    );



    //IF

    assign pc_out = t_if_pc_out;

    wire[1:0] t_if_pc_src;
    wire[31:0] t_if_pc_next;
    wire[31:0] t_if_pc_out;


    assign t_if_pc_next = (t_if_pc_src==2'b00)?t_if_inc_pc:
                          (t_if_pc_src==2'b01)?t_mem_alu_out:t_mem_pc_plus_imm;

    PC PC_inst(.clk(clk),
               .reset(reset),
               .di(t_if_pc_next),
               .pcw(t_id_pc_write_hazard),
               .do(t_if_pc_out));

    wire[31:0] t_if_inc_pc;

    ALU_pc_inc ALU_pc_inc_inst(.pc(t_if_pc_out),
                               .pc_incremented(t_if_inc_pc));
    

    wire[31:0] t_if_instr_out;
    Instruction_Memory Instruction_Memory_inst(.clk(clk),
                                               .reset(reset),
                                               .addr(t_if_pc_out),
                                               .instruction(t_if_instr_out));



  



    IF_ID IF_ID_inst(.clk(clk),
                     .reset(reset),
                     .flush(t_mem_control_flush),
                     .pc_inc(t_if_inc_pc),
                     .pc_original(t_if_pc_out),
                     .instr(t_if_instr_out),
                     .if_id_write(t_id_if_id_write_hazard),
                     .pc_inc_reg(t_id_pc_inc),
                     .pc_original_reg(t_id_pc_original),
                     .instr_reg(t_id_instr));

    wire[31:0] t_id_pc_inc;
    wire[31:0] t_id_pc_original;
    wire[31:0] t_id_instr;
    //ID

    





    Hazard_Detection_Unit Hazard_Detection_Unit_inst(.id_ex_mem_read(t_ex_mem_read),
                                                     .id_ex_rd(t_ex_mem_rd),
                                                     .if_id_rs1(t_id_instr[19:15]),
                                                     .if_id_rs2(t_id_instr[24:20]),
                                                     .if_id_write(t_id_if_id_write_hazard),
                                                     .id_ex_flush(t_id_ex_flush_hazard),
                                                     .pc_write(t_id_pc_write_hazard));


    wire t_id_if_id_write_hazard;
    wire t_id_ex_flush_hazard;
    wire t_id_pc_write_hazard;


    Reg_File Reg_File_inst(.clk(clk),
                           .reset(reset),
                           .read_addr_1(t_id_instr[19:15]),
                           .read_addr_2(t_id_instr[24:20]),
                           .write_addr(t_wb_final_rd),
                           .write_data(t_wb_data_to_reg),
                           .reg_write(t_wb_reg_write),
                           .data_out_1(t_id_rs1),
                           .data_out_2(t_id_rs2),
                           .x1_out(x1_out),
                           .x2_out(x2_out),
                           .x3_out(x3_out),
                           .x8_out(x8_out));

    wire[31:0]t_id_rs1;
    wire[31:0]t_id_rs2;

    Imm_32 Imm_32_inst(.instruction(t_id_instr),
                       .imm32(t_id_imm32));

    wire[31:0] t_id_imm32;

    
    Control Control_inst(.opcode(t_id_instr[6:0]),
                         .f3(t_id_instr[14:12]),
                         .f7(t_id_instr[31:25]),
                         .reg_write(t_id_reg_write_signal),
                         .mem_reg_pc(t_id_mem_reg_pc_signal),
                         .mem_read(t_id_mem_read_signal),
                         .mem_write(t_id_mem_write_signal),
                         .branch(t_id_branch_signal),
                         .jl(t_id_jl_signal),
                         .jlr(t_id_jlr_signal),
                         .alu_src(t_id_alu_src_signal),
                         .alu_op(t_id_alu_op_signal));

    wire t_id_reg_write_signal;
    wire[1:0] t_id_mem_reg_pc_signal;
    wire t_id_mem_read_signal;
    wire t_id_mem_write_signal;
    wire t_id_branch_signal;
    wire t_id_jl_signal;
    wire t_id_jlr_signal;
    wire t_id_alu_src_signal;
    wire[1:0] t_id_alu_op_signal;



    ID_EX ID_EX_inst(.clk(clk),
                     .reset(reset),
                     .flush(t_mem_control_flush),
                     .if_id_rs1(t_id_instr[19:15]),
                     .if_id_rs2(t_id_instr[24:20]),
                     .if_id_rd(t_id_instr[11:7]),
                     .reg_write(t_id_reg_write_signal & ~t_id_ex_flush_hazard),
                     .mem_reg_pc(t_id_ex_flush_hazard ? 2'b0 : t_id_mem_reg_pc_signal),
                     .mem_read(t_id_mem_read_signal & ~t_id_ex_flush_hazard),
                     .mem_write(t_id_mem_write_signal & ~t_id_ex_flush_hazard),
                     .branch(t_id_branch_signal & ~t_id_ex_flush_hazard),
                     .jl(t_id_jl_signal & ~t_id_ex_flush_hazard),
                     .jlr(t_id_jlr_signal & ~t_id_ex_flush_hazard),
                     .alu_src(t_id_alu_src_signal & ~t_id_ex_flush_hazard),
                     .alu_op(t_id_ex_flush_hazard ? 2'b0 : t_id_alu_op_signal),
                     .pc_inc(t_id_pc_inc),
                     .pc_original(t_id_pc_original),
                     .read_data_1(t_id_rs1),
                     .read_data_2(t_id_rs2),
                     .imm32(t_id_imm32),
                     .f7_bit(t_id_instr[30]),
                     .f3(t_id_instr[14:12]),
                     .if_id_rs1_reg(t_id_ex_rs1),
                     .if_id_rs2_reg(t_id_ex_rs2),
                     .if_id_rd_reg(t_ex_mem_rd),
                     .reg_write_reg(t_ex_reg_write),
                     .mem_reg_pc_reg(t_ex_mem_reg_pc),
                     .mem_read_reg(t_ex_mem_read),
                     .mem_write_reg(t_ex_mem_write),
                     .branch_reg(t_ex_branch),
                     .jl_reg(t_ex_jl),
                     .jlr_reg(t_ex_jlr),
                     .alu_src_reg(t_ex_alu_src),
                     .alu_op_reg(t_ex_alu_op),
                     .pc_inc_reg(t_ex_pc_inc),
                     .pc_original_reg(t_ex_pc_original),
                     .read_data_1_reg(t_ex_read_data_1),
                     .read_data_2_reg(t_ex_read_data_2),
                     .imm32_reg(t_ex_imm32),
                     .f7_bit_reg(t_ex_f7),
                     .f3_reg(t_ex_f3));


    //EX

    wire[4:0] t_id_ex_rs1;
    wire[4:0] t_id_ex_rs2;

    wire[31:0] t_ex_read_data_1;
    wire[31:0] t_ex_read_data_2;

    wire t_ex_f7;
    wire[2:0] t_ex_f3;
    wire[1:0] t_ex_alu_signal;

    wire[31:0] t_ex_pc_original;

    wire t_ex_reg_write;
    wire[1:0] t_ex_mem_reg_pc;
    
    wire t_ex_mem_read;
    wire t_ex_mem_write;
    wire t_ex_jl;
    wire t_ex_jlr;
    wire t_ex_branch;

    wire t_ex_alu_src;
    wire[1:0] t_ex_alu_op;

    wire[31:0] t_ex_pc_inc;
    wire[4:0] t_ex_mem_rd;
    wire[31:0] t_ex_imm32;


    wire[31:0] t_ex_alu_out;

    wire t_ex_zero;


    Forwarding_Unit Forwarding_Unit_inst(.id_ex_rs1(t_id_ex_rs1),
                                         .id_ex_rs2(t_id_ex_rs2),
                                         .ex_mem_rd(t_mem_wb_rd),
                                         .mem_wb_rd(t_wb_final_rd),
                                         .ex_mem_reg_write(t_mem_reg_write),
                                         .mem_wb_reg_write(t_wb_reg_write),
                                         .forward_a(t_ex_fw_a), // sel pt muxurile din fata la alu din EX
                                         .forward_b(t_ex_fw_b));


    wire[1:0] t_ex_fw_a;
    wire[1:0] t_ex_fw_b;


    ALU_pc_imm ALU_pc_imm_inst(.imm32(t_ex_imm32),
                               .pc(t_ex_pc_original),
                               .pc_imm(t_ex_pc_plus_imm));




    wire[31:0] t_ex_op_a_fw;
    //depinde de fw
    assign t_ex_op_a_fw = (t_ex_fw_a==2'b00)?t_ex_read_data_1:  //nu e hazard
                          (t_ex_fw_a==2'b01)?t_wb_data_to_reg:  //hazard mem
                          (t_ex_fw_a==2'b10)?t_mem_alu_out:32'b0 ;  //hazard ex
    
    wire[31:0] t_ex_op_b_fw;
    wire[31:0] t_ex_op_b;
   
   
    assign t_ex_op_b = (t_ex_fw_b==2'b00)?t_ex_read_data_2:
                          (t_ex_fw_b==2'b01)?t_wb_data_to_reg:
                          (t_ex_fw_b==2'b10)?t_mem_alu_out:32'b0;


    assign t_ex_op_b_fw = (t_ex_alu_src==1'b0)?t_ex_op_b:
                          (t_ex_alu_src==1'b1)?t_ex_imm32:32'b0;


    ALU_EX ALU_EX_inst(.op_a(t_ex_op_a_fw),
                       .op_b(t_ex_op_b_fw),
                       .alu_signal(t_ex_alu_signal),
                       .alu_out(t_ex_alu_out),
                       .zero(t_ex_zero));


    ALU_ctl ALU_ctl_inst(.alu_op(t_ex_alu_op),
                         .f7_bit(t_ex_f7),
                         .f3(t_ex_f3),
                         .alu_signal(t_ex_alu_signal));


    wire[31:0] t_ex_pc_plus_imm;


    
 


    EX_MEM EX_MEM_inst(.clk(clk),
                       .reset(reset),
                       .id_ex_rd(t_ex_mem_rd),
                       .reg_write(t_ex_reg_write),
                       .mem_reg_pc(t_ex_mem_reg_pc),
                       .mem_read(t_ex_mem_read),
                       .mem_write(t_ex_mem_write),
                       .jl(t_ex_jl),
                       .jlr(t_ex_jlr),
                       .branch(t_ex_branch),
                       .pc_inc(t_ex_pc_inc),
                       .pc_plus_imm(t_ex_pc_plus_imm),
                       .zero(t_ex_zero),
                       .alu_out(t_ex_alu_out),
                       .read_data_2(t_ex_op_b),
                       .id_ex_rd_reg(t_mem_wb_rd),
                       .reg_write_reg(t_mem_reg_write),
                       .mem_reg_pc_reg(t_mem_reg_pc),
                       .mem_read_reg(t_mem_mem_read),
                       .mem_write_reg(t_mem_mem_write),
                       .jl_reg(t_mem_jl),
                       .jlr_reg(t_mem_jlr),
                       .branch_reg(t_mem_branch),
                       .pc_inc_reg(t_mem_pc_inc),
                       .pc_plus_imm_reg(t_mem_pc_plus_imm),
                       .zero_reg(t_mem_zero),
                       .alu_out_reg(t_mem_alu_out),
                       .read_data_2_reg(t_mem_read_data_2));

    //MEM


    wire t_mem_control_flush = t_mem_jl || t_mem_jlr || (t_mem_branch && t_mem_zero);
    wire t_mem_reg_write;  
    wire[1:0] t_mem_reg_pc;
    wire t_mem_mem_read;
    wire t_mem_mem_write;

    wire[31:0] t_mem_read_data_2;


    wire[4:0] t_mem_wb_rd;

    wire[31:0] t_mem_pc_inc;


    wire t_mem_jl;
    wire t_mem_jlr;
    wire t_mem_zero;
    wire t_mem_branch;

    assign t_if_pc_src = (t_mem_jlr) ? 2'b01 :  
                     (t_mem_jl || (t_mem_branch && t_mem_zero)) ? 2'b10 : 
                     2'b00;  


    wire[31:0] t_mem_alu_out;
    wire[31:0] t_mem_pc_plus_imm;


    

    Data_Memory Data_Memory_inst(.clk(clk),
                                 .reset(reset),
                                 .mem_read(t_mem_mem_read),
                                 .mem_write(t_mem_mem_write),
                                 .addr(t_mem_alu_out),
                                 .data_to_write(t_mem_read_data_2),
                                 .data_out(t_mem_data_out),
                                 .mem_addr_12(mem_addr_12_test));

                            
    wire[31:0] t_mem_data_out;


    MEM_WB MEM_WB_inst(.clk(clk),
                       .reset(reset),
                       .ex_mem_rd(t_mem_wb_rd),
                       .reg_write(t_mem_reg_write),
                       .mem_reg_pc(t_mem_reg_pc),
                       .mem_data(t_mem_data_out),
                       .alu_out(t_mem_alu_out),
                       .pc_inc(t_mem_pc_inc),
                       .ex_mem_rd_reg(t_wb_final_rd),
                       .reg_write_reg(t_wb_reg_write),
                       .mem_reg_pc_reg(t_wb_mem_reg_pc),
                       .mem_data_reg(t_wb_mem_data),
                       .alu_out_reg(t_wb_alu_out),
                       .pc_inc_reg(t_wb_pc_inc));

    //WB


    wire[4:0] t_wb_final_rd;

    wire[1:0] t_wb_mem_reg_pc;
    wire t_wb_reg_write;

    wire[31:0] t_wb_mem_data;
    wire[31:0] t_wb_alu_out;
    wire[31:0] t_wb_pc_inc;

    wire[31:0] t_wb_data_to_reg;
    assign t_wb_data_to_reg = (t_wb_mem_reg_pc==2'b00)?t_wb_alu_out:
                              (t_wb_mem_reg_pc==2'b01)?t_wb_mem_data:
                              (t_wb_mem_reg_pc==2'b10)?t_wb_pc_inc:32'b0;

  


    


endmodule