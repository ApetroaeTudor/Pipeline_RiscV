`include "riscv_defines.vh"
module Exception_Signals_Handler#(
  parameter [1:0] XLEN = `XLEN_64b,
  parameter ENABLED_PMP_REGISTERS = 12
)(
    input [((1<<(XLEN+4))-1):0] i_pc_f,  //
    input [6:0] i_opcode_f, //
    input [3:0] i_imm_ms_4b_f, //


    input i_res_src_b0_e, //1 = load

    input [((1<<(XLEN+4))-1):0] i_alu_out_e,
    input i_mem_write_e,

    input i_ecall_e,
    input i_store_byte_e,
    input i_store_half_e,
    input [2:0] i_f3_e,

    input [1:0] i_current_privilege,

    input [((1<<(XLEN+4))<<6)-1:0] i_concat_pmpaddr,
    input [511:0] i_concat_pmpcfg,

    output [3:0] o_exception_code_f, 
    output [3:0] o_exception_code_e
);

localparam PMPCFG_LEN = 8;
localparam PMPADDR_LEN = (1<<(XLEN+4));

wire [PMPADDR_LEN-1:0]   w_pmpcfg_regs  [63:0];
wire [PMPADDR_LEN-1:0] w_pmpaddr_regs [63:0];





genvar i;
generate
  for( i = 0 ; i < 64 ; i = i+1)
  begin
    assign w_pmpcfg_regs[i] = i_concat_pmpcfg[((i+1)*PMPCFG_LEN)-1:i*PMPCFG_LEN];
    assign w_pmpaddr_regs[i]= i_concat_pmpaddr[((i+1)*PMPADDR_LEN)-1:i*PMPADDR_LEN];
  end
endgenerate



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

wire w_load_addr_misaligned_4b = (i_res_src_b0_e==1'b1) &&
                                 (i_alu_out_e[1:0]!=2'b00) &&
                                 (i_f3_e!=`LB_F3 && i_f3_e!= `LH_F3 && i_f3_e!=`LBU_F3 && i_f3_e!=`LHU_F3);

wire w_load_addr_misaligned_2b = (i_res_src_b0_e==1'b1) &&
                                 (i_alu_out_e[0]!=0) &&
                                 (i_f3_e == `LH_F3 || i_f3_e == `LHU_F3);





function [3:0] na4;
  input [((1<<(XLEN+4))-1):0] i_pc_f;
  input [((1<<(XLEN+4))-1):0] i_alu_out_e;
  input i_r;
  input i_w;
  input i_x;
  input i_res_src_b0_e;
  input i_mem_write_e;

  input [((1<<(XLEN+4))-1):0] i_pmpaddr_current;

  begin
    if(i_pc_f >= (i_pmpaddr_current<<2) && (i_pc_f<((i_pmpaddr_current<<2)+4)) )
    begin
      if(!i_x) na4 = `E_ILLEGAL_INSTR;
    end
    else if (i_res_src_b0_e && ( i_alu_out_e >= (i_pmpaddr_current<<2) && (i_alu_out_e<((i_pmpaddr_current<<2)+4)) ) )  
    begin
      if(!i_r) na4 = `E_LOAD_ACCESS_FAULT;
    end
    else if(i_mem_write_e && ( i_alu_out_e >= (i_pmpaddr_current<<2) && (i_alu_out_e<((i_pmpaddr_current<<2)+4)) ) )
    begin
      if(!i_w) na4 = `E_STORE_ACCESS_FAULT; 
    end
    else na4 = `NO_E;
  end

endfunction


function [3:0] napot;
  input [((1<<(XLEN+4))-1):0] i_pc_f;
  input [((1<<(XLEN+4))-1):0] i_alu_out_e;
  input i_r;
  input i_w;
  input i_x;
  input i_res_src_b0_e;
  input i_mem_write_e;

  input [((1<<(XLEN+4))-1):0] i_pmpaddr_current_no_trail;
  input [31:0] i_nr_of_trailing_ones;

  begin
    if(i_pc_f >= (i_pmpaddr_current_no_trail<<2) && (i_pc_f < ( (i_pmpaddr_current_no_trail << 2) + (1<<(i_nr_of_trailing_ones+3)))) )
    begin
        if(!i_x) napot = `E_ILLEGAL_INSTR;
    end
    else if(i_res_src_b0_e &&   (i_alu_out_e >= (i_pmpaddr_current_no_trail<<2) && (i_alu_out_e < ( (i_pmpaddr_current_no_trail << 2) + (1<<(i_nr_of_trailing_ones+3)))))  )
    begin
        if(!i_r) napot = `E_LOAD_ACCESS_FAULT;
    end
    else if(i_mem_write_e &&    (i_alu_out_e >= (i_pmpaddr_current_no_trail<<2) && (i_alu_out_e < ( (i_pmpaddr_current_no_trail << 2) + (1<<(i_nr_of_trailing_ones+3))))) )
    begin
        if(!i_w) napot = `E_STORE_ACCESS_FAULT;
    end
    else napot = `NO_E;
  end

endfunction

function [3:0] tor;
  input [((1<<(XLEN+4))-1):0] i_pc_f;
  input [((1<<(XLEN+4))-1):0] i_alu_out_e;
  input i_r;
  input i_w;
  input i_x;
  input i_res_src_b0_e;
  input i_mem_write_e;
  

  input [((1<<(XLEN+4))-1):0] i_pmpaddr_current;
  input [((1<<(XLEN+4))-1):0] i_pmpaddr_prev;


  begin
    
    if((i_pc_f >= (i_pmpaddr_prev<<2)) && (i_pc_f<(i_pmpaddr_current<<2))) // fetch (execute)
    begin
      if(!i_x) tor = `E_ILLEGAL_INSTR;
    end
    else if(i_res_src_b0_e && (i_alu_out_e >=(i_pmpaddr_prev<<2)) && (i_alu_out_e<(i_pmpaddr_current<<2))) // load (read)
    begin
      if(!i_r) tor = `E_LOAD_ACCESS_FAULT;
    end
    else if(i_mem_write_e && (i_alu_out_e >=(i_pmpaddr_prev<<2)) && (i_alu_out_e<(i_pmpaddr_current<<2))) // store (write)
    begin
      if(!i_w) tor = `E_STORE_ACCESS_FAULT;
    end
    else tor = `NO_E;
  end
endfunction


endmodule