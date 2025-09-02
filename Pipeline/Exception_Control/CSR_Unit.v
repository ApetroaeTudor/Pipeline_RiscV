module CSR_Unit#(
    parameter [1:0] XLEN = `XLEN_64b,
    parameter [25:0] SUPPORTED_EXTENSIONS = `SUPPORTED_EXTENSIONS
)(
    input i_clk,
    input i_rst,
    input i_clk_en,

    input [11:0] i_csr_write_addr_w,
    input i_csr_write_enable_w,

    input [3:0] i_exception_code_f_d_ff,
    input [((1<<(XLEN+4))-1):0] i_exception_pc_f_d_ff,
    input [3:0] i_exception_code_e_m_ff,
    input [((1<<(XLEN+4))-1):0] i_exception_pc_e_m_ff,
    input [((1<<(XLEN+4))-1):0] i_exception_addr_e_m_ff,
    input i_mret_e,

    input  [(1<<(XLEN+4))-1:0] i_csr_data_w,
    input [1:0] i_current_privilege,



    input [31:0] i_instr_d,
    input [((1<<(XLEN+4))-1):0] i_rs1_data,

    output o_csr_reg_write_d, // writes both in csr and reg file
    output [((1<<(XLEN+4))-1):0] o_new_csr_masked_d, 
    output [((1<<(XLEN+4))-1):0] o_old_csr_masked_d,
    output [11:0] o_csr_rd_d,

    output o_ecall_d,
    output o_mret_d,
    output [(1<<(XLEN+4))-1:0] o_mepc,

    output [((1<<(XLEN+4))<<6)-1:0] o_concat_pmpaddr,
    output [511:0] o_concat_pmpcfg,

    output [1:0] o_UXL,

    output [1:0] o_new_priv
);

    wire [6:0] w_opcode_d = i_instr_d[6:0];
    wire [2:0] w_f3_d = i_instr_d[14:12];
    wire [4:0] w_rd_d = i_instr_d[11:7];
    wire [4:0] w_rs1_d = i_instr_d[19:15];
    wire [11:0] w_imm_d = i_instr_d[31:20];


    wire [((1<<(XLEN+4))-1):0] w_csr_d; // read from the instantiated regfile
    wire [((1<<(XLEN+4))-1):0] w_old_csr;
    wire [((1<<(XLEN+4))-1):0] w_new_csr;



    CSR_Behavior_Unit #(
                        .XLEN(XLEN)
                        )
                                    CSR_Behavior_Unit_Inst(
                                        .i_opcode_d(w_opcode_d),
                                        .i_f3_d(w_f3_d),
                                        .i_rd_d(w_rd_d),
                                        .i_rs1_d(w_rs1_d),
                                        .i_csr_d(w_csr_d),
                                        .i_imm_d(w_imm_d),
                                        .i_rs1_data(i_rs1_data),
                                        .o_csr_reg_write_d(o_csr_reg_write_d),
                                        .o_new_csr_d(w_new_csr),
                                        .o_old_csr_d(w_old_csr),
                                        .o_csr_rd_d(o_csr_rd_d),
                                        .o_ecall_d(o_ecall_d),
                                        .o_mret_d(o_mret_d)
                                    );

    CSR_Data_Masking_Unit #(
                            .XLEN(XLEN),
                            .SUPPORTED_EXTENSIONS(SUPPORTED_EXTENSIONS)
                            )
                            CSR_Data_Masking_Unit_Inst(
                                .i_new_csr(w_new_csr),
                                .i_old_csr(w_old_csr),
                                .i_csr_addr(w_imm_d),
                                .i_opcode_d(w_opcode_d),
                                .o_masked_new_csr_write(o_new_csr_masked_d),
                                .o_masked_old_csr_read(o_old_csr_masked_d)
                            );

    M_CSR_Reg_File #(
                     .XLEN(XLEN)
                     )
                    M_CSR_Reg_File_Inst(
                        .i_clk(i_clk),
                        .i_rst(i_rst),
                        .i_clk_en(i_clk_en),
                        .i_csr_write_addr(i_csr_write_addr_w),
                        .i_csr_read_addr(w_imm_d),
                        .i_csr_write_enable(i_csr_write_enable_w),
                        .i_exception_code_f_d_ff(i_exception_code_f_d_ff),
                        .i_exception_pc_f_d_ff(i_exception_pc_f_d_ff),
                        .i_exception_code_e_m_ff(i_exception_code_e_m_ff),
                        .i_exception_pc_e_m_ff(i_exception_pc_e_m_ff),
                        .i_exception_addr_e_m_ff(i_exception_addr_e_m_ff),
                        .i_mret_e(i_mret_e),
                        .i_current_privilege(i_current_privilege),
                        .i_csr_data(i_csr_data_w),
                        .o_csr_data(w_csr_d),
                        .o_mepc(o_mepc),
                        .o_concat_pmpaddr(o_concat_pmpaddr),
                        .o_concat_pmpcfg(o_concat_pmpcfg),
                        .o_UXL(o_UXL),
                        .o_new_priv(o_new_priv)
                    );


    




endmodule