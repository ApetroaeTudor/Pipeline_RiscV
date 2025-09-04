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

wire [7:0] w_pmpcfg_regs  [63:0];
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
                            ((i_current_privilege!=`MACHINE && r_pmp_exception_f == `E_ILLEGAL_INSTR) ||
                             (i_current_privilege!=`MACHINE && r_pmp_exception_e == `E_ILLEGAL_INSTR))?`E_ILLEGAL_INSTR:
                            `NO_E;
                            

assign o_exception_code_e = (w_load_addr_misaligned_2b | w_load_addr_misaligned_4b)?`E_LOAD_ADDR_MISALIGNED:
                            ( (i_current_privilege!=`MACHINE && r_pmp_exception_e == `E_LOAD_ACCESS_FAULT) || i_bad_addr_load_e)?`E_LOAD_ACCESS_FAULT:
                            (w_store_addr_misaligned_2b | w_store_addr_misaligned_4b)?`E_STORE_ADDR_MISALIGNED:
                            ( (i_current_privilege!=`MACHINE && r_pmp_exception_e == `E_STORE_ACCESS_FAULT)|| i_bad_addr_store_e)?`E_STORE_ACCESS_FAULT:
                            (i_ecall_e)?`E_ECALL:
                            `NO_E;
                            



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
reg r_addr_cpy_lsb = r_addr_cpy[0];
reg [31:0] r_sz =0;


reg [3:0] r_pmp_exception_f = {1'b0,`NO_E};
reg [3:0] r_pmp_exception_e = {1'b0,`NO_E};

reg r_any_match_f = 1'b0;
reg r_any_match_e = 1'b0;

reg r_is_match = 1'b0;



always@(*)
begin
  
  r_any_match_f = 1'b0;
  r_any_match_e = 1'b0;

  r_pmp_exception_e = `NO_E;
  r_pmp_exception_f = `NO_E;
  r_is_match = 1'b0;

  if(i_current_privilege!=`MACHINE)
  begin
    for( j = 0; j<=ENABLED_PMP_REGISTERS ; j = j+1)
    begin
        r_A = w_pmpcfg_regs[j][4:3];
        r_r = w_pmpcfg_regs[j][0];
        r_w = w_pmpcfg_regs[j][1];
        r_x = w_pmpcfg_regs[j][2];
        r_addr_cpy = 0;
        r_addr_cpy_lsb = 0;
        r_sz = 0;
        casex(r_A)
        TOR:begin
             if(!r_any_match_f)
             begin
                r_is_match = (j==0)?(i_pc_f >= 0 && (i_pc_f<(w_pmpaddr_regs[j]<<2))):
                                    (i_pc_f >= (w_pmpaddr_regs[j-1]<<2)) && (i_pc_f<(w_pmpaddr_regs[j]<<2));
                      
                if(r_is_match)
                begin
                  r_any_match_f = 1'b1;
                  if(!r_x) r_pmp_exception_f = `E_ILLEGAL_INSTR;
                end
             end
             if(!r_any_match_e)
             begin
                r_is_match = (j==0)?(i_alu_out_e >= 0 && (i_alu_out_e<(w_pmpaddr_regs[j]<<2))):
                                    (i_alu_out_e >= (w_pmpaddr_regs[j-1]<<2)) && (i_alu_out_e<(w_pmpaddr_regs[j]<<2));
                if(r_is_match)
                begin
                  r_any_match_e = 1'b1;
                  if(i_res_src_b0_e)
                  begin
                    if(!r_r) r_pmp_exception_e = `E_LOAD_ACCESS_FAULT;
                  end
                  if(i_mem_write_e)
                  begin
                    if(!r_w) r_pmp_exception_e = `E_STORE_ACCESS_FAULT;
                  end
                end
                          
             end
        end
        NA4:begin
          if(!r_any_match_f)
          begin
            r_is_match = ((i_pc_f >=(w_pmpaddr_regs[j]<<2)) && (i_pc_f<((w_pmpaddr_regs[j]<<2)+4)));
            if(r_is_match)
            begin
              r_any_match_f = 1'b1;
              if(!r_x) r_pmp_exception_f = `E_ILLEGAL_INSTR;
            end
          end
          if(!r_any_match_e)
          begin
            r_is_match = ((i_alu_out_e >=(w_pmpaddr_regs[j]<<2)) && (i_alu_out_e<((w_pmpaddr_regs[j]<<2)+4)));
            if(r_is_match)
            begin
              r_any_match_e = 1'b1;
              if(i_res_src_b0_e)
              begin
                if(!r_r) r_pmp_exception_e = `E_LOAD_ACCESS_FAULT;
              end
              if(i_mem_write_e)
              begin
                if(!r_w) r_pmp_exception_e = `E_STORE_ACCESS_FAULT;
              end
            end
          end
           
        end
        NAPOT:begin
          r_addr_cpy = w_pmpaddr_regs[j];
          for( k=0 ; k < (1<<(XLEN+4)) ; k=k+1 )
          begin
            r_addr_cpy_lsb = r_addr_cpy[0];
            if(r_addr_cpy_lsb) r_sz = r_sz+1;
            r_addr_cpy = r_addr_cpy >>1;
          end
          r_sz = 1<<(r_sz+3);

          if(!r_any_match_f)
          begin
            r_is_match = ( (i_pc_f>=( (w_pmpaddr_regs[j]<<2) & ~(r_sz-1))) && (i_pc_f <(( (w_pmpaddr_regs[j]<<2) & ~(r_sz-1))+r_sz) ) );
            if(r_is_match)
            begin
              r_any_match_f = 1'b1;
              if(!r_x) r_pmp_exception_f = `E_ILLEGAL_INSTR;
            end
          end
          if(!r_any_match_e)
          begin
            r_is_match = ( (i_alu_out_e>=( (w_pmpaddr_regs[j]<<2) & ~(r_sz-1))) && (i_alu_out_e <(( (w_pmpaddr_regs[j]<<2) & ~(r_sz-1))+r_sz) ) );
            if(r_is_match)
            begin
              r_any_match_e = 1'b1;
              if(i_res_src_b0_e)
              begin
                if(!r_r) r_pmp_exception_e = `E_LOAD_ACCESS_FAULT;
              end
              if(i_mem_write_e)
              begin
                if(!r_w) r_pmp_exception_e = `E_STORE_ACCESS_FAULT;
              end
            end
          end


        end
        default:begin
            if(!r_any_match_f)
            begin
              r_pmp_exception_f = `E_ILLEGAL_INSTR;
            end
            if(!r_any_match_e)
            begin
              r_pmp_exception_e = (i_res_src_b0_e | i_mem_write_e)?`E_ILLEGAL_INSTR:`NO_E;
            end
        end
        endcase

        

    end

    if(!r_any_match_f)
    begin
      r_pmp_exception_f = `E_ILLEGAL_INSTR;
    end
    if(!r_any_match_e)
    begin
      r_pmp_exception_e = (i_res_src_b0_e | i_mem_write_e)?`E_ILLEGAL_INSTR:`NO_E;
    end

  end
  else
  begin
    r_pmp_exception_f = {1'b0,`NO_E};
    r_pmp_exception_e = {1'b0,`NO_E};
  end 

end


endmodule