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

    input i_bad_addr_f,
    input i_bad_addr_load_e,
    input i_bad_addr_store_e,

    output [3:0] o_exception_code_f, 
    output [3:0] o_exception_code_e
);

localparam PMPCFG_LEN = 8;
localparam PMPADDR_LEN = (1<<(XLEN+4));

wire [PMPADDR_LEN-1:0] w_pmpcfg_regs  [63:0];
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


wire w_store_addr_misaligned_4b = (i_mem_write_e) &&
                                  (!i_store_byte_e && !i_store_half_e) &&
                                  (i_alu_out_e[1:0]!=2'b00);

wire w_store_addr_misaligned_2b = (i_mem_write_e) &&
                                  (!i_store_byte_e && i_store_half_e) &&
                                  (i_alu_out_e[0]);





assign o_exception_code_f = (w_fetch_misaligned)?`E_FETCH_ADDR_MISALIGNED:
                            (w_illegal_opcode || w_illegal_csr_instr || i_bad_addr_f)?`E_ILLEGAL_INSTR:
                            (i_current_privilege!=`MACHINE && r_final_pmp_exc_f == `E_ILLEGAL_INSTR)?`E_ILLEGAL_INSTR:
                            `NO_E;

assign o_exception_code_e = (w_load_addr_misaligned_2b | w_load_addr_misaligned_4b)?`E_LOAD_ADDR_MISALIGNED:
                            ( (i_current_privilege!=`MACHINE && r_final_pmp_exc_e == `E_LOAD_ACCESS_FAULT) || i_bad_addr_load_e)?`E_LOAD_ACCESS_FAULT:
                            (w_store_addr_misaligned_2b | w_store_addr_misaligned_4b)?`E_STORE_ADDR_MISALIGNED:
                            ( (i_current_privilege!=`MACHINE && r_final_pmp_exc_e == `E_STORE_ACCESS_FAULT)|| i_bad_addr_store_e)?`E_STORE_ACCESS_FAULT:
                            (i_ecall_e)?`E_ECALL:
                            `NO_E;




wire [31:0] w_pmpaddr_0 = w_pmpaddr_regs[0]<<2;
wire [31:0] w_pmpaddr_1 = w_pmpaddr_regs[1]<<2;
wire [31:0] w_pmpaddr_2 = w_pmpaddr_regs[2]<<2;
wire [31:0] w_pmpaddr_3 = w_pmpaddr_regs[3]<<2;


wire [7:0] w_pmpcfg_0 = w_pmpcfg_regs[0];
wire [7:0] w_pmpcfg_1 = w_pmpcfg_regs[1];
wire [7:0] w_pmpcfg_2 = w_pmpcfg_regs[2];
wire [7:0] w_pmpcfg_3 = w_pmpcfg_regs[3];

wire w_pc_in_txt = i_pc_f >=w_pmpaddr_1 && i_pc_f<w_pmpaddr_2; //current is 2
wire [1:0] w_a_in_txt = w_pmpcfg_2[4:3]; 
wire w_x_in_txt = w_pmpcfg_2[2];




integer j;
integer k;
reg r_r;
reg r_w;
reg r_x;
reg [1:0] r_A;


localparam TOR = 2'b01;
localparam NA4 = 2'b10;
localparam NAPOT = 2'b11;
reg [((1<<(XLEN+4))-1):0] r_addr_cpy = 0;
wire w_addr_cpy_lsb = r_addr_cpy[0];
reg [7:0] r_sz =0;

reg [4:0] r_pmp_exception_f = {1'b0,`NO_E};
reg [4:0] r_pmp_exception_e = {1'b0,`NO_E};

reg r_any_match_f = 1'b0;
reg [3:0] r_final_pmp_exc_f = `NO_E;
reg r_any_match_e = 1'b1;
reg [3:0] r_final_pmp_exc_e = `NO_E;



always@(*)
begin
  r_any_match_f = 1'b0;
  r_any_match_e = 1'b0;

  r_final_pmp_exc_e = `NO_E;
  r_final_pmp_exc_f = `NO_E;

  if(i_current_privilege!=`MACHINE)
  begin
    for( j = 0; j<=ENABLED_PMP_REGISTERS ; j = j+1)
    begin
        r_A = w_pmpcfg_regs[j][4:3];
        r_r = w_pmpcfg_regs[j][0];
        r_w = w_pmpcfg_regs[j][1];
        r_x = w_pmpcfg_regs[j][2];
        casex(r_A)
        TOR:begin
              r_pmp_exception_f = tor(i_pc_f,1'b1,r_r,r_w,r_x,1'bx,1'bx,w_pmpaddr_regs[j],(j==0) ? {XLEN{1'b0}} : w_pmpaddr_regs[j-1]);
              r_pmp_exception_e = tor(i_alu_out_e,1'b0,r_r,r_w,r_x,i_res_src_b0_e,i_mem_write_e,w_pmpaddr_regs[j],(j==0) ? {XLEN{1'b0}} : w_pmpaddr_regs[j-1]);

        end
        NA4:begin
           
        end
        NAPOT:begin

        end
        default:begin
            r_pmp_exception_f[4] = 1'b0;
            r_pmp_exception_e[4] = 1'b0;
            r_pmp_exception_e[3:0] = (i_res_src_b0_e)?`E_LOAD_ACCESS_FAULT:
                                      (i_mem_write_e)?`E_STORE_ACCESS_FAULT:`E_ILLEGAL_INSTR;

            r_pmp_exception_f[3:0] = `E_ILLEGAL_INSTR;
        end
        endcase

        if(r_pmp_exception_f[4] && !r_any_match_f)
        begin
          r_any_match_f = 1'b1;
          r_final_pmp_exc_f = r_pmp_exception_f[3:0];
        end

        if(r_pmp_exception_e[3] && !r_any_match_e)
        begin
          r_any_match_e = 1'b1;
          r_final_pmp_exc_e = r_pmp_exception_e[3:0];
        end

    end

    if(!r_any_match_f)
    begin
      r_final_pmp_exc_f = `E_ILLEGAL_INSTR;
    end
    if(!r_any_match_e)
    begin
      r_final_pmp_exc_e = `E_ILLEGAL_INSTR;
    end

  end
  else
  begin
    r_pmp_exception_f = r_pmp_exception_f;
    r_pmp_exception_e = r_pmp_exception_e;
  end 

end



function [4:0] tor;
  input [((1<<(XLEN+4))-1):0] i_addr_to_check;
  input i_f_or_e; // 1  is f, 0 is e;
  input i_r;
  input i_w;
  input i_x;
  input i_lw;
  input i_sw;
  

  input [((1<<(XLEN+4))-1):0] i_pmpaddr_current;
  input [((1<<(XLEN+4))-1):0] i_pmpaddr_prev;


  begin
    if(i_f_or_e) // fetch
    begin
      if((i_addr_to_check >= (i_pmpaddr_prev<<2)) && (i_addr_to_check<(i_pmpaddr_current<<2)))
      begin
        tor[4] = 1'b1;
        tor[3:0] = (i_x)?`NO_E:`E_ILLEGAL_INSTR;
      end
      else
      begin
        tor[4] = 1'b0;
        tor[3:0] = `NO_E;
      end
    end
    else // ex
    begin
      if((i_addr_to_check >= (i_pmpaddr_prev<<2)) && (i_addr_to_check<(i_pmpaddr_current<<2)))
      begin
          tor[4] = 1'b1;
          casex({i_lw,i_sw})
          2'b01: // store needs w
          begin
            tor[3:0] = (i_w)?`NO_E:`E_STORE_ACCESS_FAULT; 
          end
          2'b10: // loads needs r
          begin
            tor[3:0] = (i_r)?`NO_E:`E_LOAD_ACCESS_FAULT;
          end
          default: begin
            tor[3:0] = `NO_E;
          end
          endcase
      end
      else
      begin
        tor[4] = 1'b0;
        tor[3:0] = `NO_E;
      end
      
    end

  end
endfunction



function [4:0] na4; // msb is 1 if addr match was found, 0 if not
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
      if(!i_x) na4[3:0] = `E_ILLEGAL_INSTR;
    end
    else if (i_res_src_b0_e && ( i_alu_out_e >= (i_pmpaddr_current<<2) && (i_alu_out_e<((i_pmpaddr_current<<2)+4)) ) )  
    begin
      if(!i_r) na4[3:0] = `E_LOAD_ACCESS_FAULT;
    end
    else if(i_mem_write_e && ( i_alu_out_e >= (i_pmpaddr_current<<2) && (i_alu_out_e<((i_pmpaddr_current<<2)+4)) ) )
    begin
      if(!i_w) na4[3:0] = `E_STORE_ACCESS_FAULT; 
    end
    else
    begin 
      na4[3:0] = `NO_E;
    end
  end

endfunction


function [4:0] napot;
  input [((1<<(XLEN+4))-1):0] i_pc_f;
  input [((1<<(XLEN+4))-1):0] i_alu_out_e;
  input i_r;
  input i_w;
  input i_x;
  input i_res_src_b0_e;
  input i_mem_write_e;

  input [((1<<(XLEN+4))-1):0] i_pmpaddr_current_no_trail;
  input [7:0] i_nr_of_trailing_ones;

  begin
    if(i_pc_f >= (i_pmpaddr_current_no_trail<<2) && (i_pc_f < ( (i_pmpaddr_current_no_trail << 2) + (1<<(i_nr_of_trailing_ones+3)))) )
    begin
        if(!i_x) napot[3:0] = `E_ILLEGAL_INSTR;
    end
    else if(i_res_src_b0_e &&   (i_alu_out_e >= (i_pmpaddr_current_no_trail<<2) && (i_alu_out_e < ( (i_pmpaddr_current_no_trail << 2) + (1<<(i_nr_of_trailing_ones+3)))))  )
    begin
        if(!i_r) napot[3:0] = `E_LOAD_ACCESS_FAULT;
    end
    else if(i_mem_write_e &&    (i_alu_out_e >= (i_pmpaddr_current_no_trail<<2) && (i_alu_out_e < ( (i_pmpaddr_current_no_trail << 2) + (1<<(i_nr_of_trailing_ones+3))))) )
    begin
        if(!i_w) napot[3:0] = `E_STORE_ACCESS_FAULT;
    end
    else 
    begin
      napot[3:0] = `NO_E;
    end
  end

endfunction



endmodule