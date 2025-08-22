`include "Constants.vh"

module M_CSR_Reg_File( // this should always output mtvec and mepc
    input i_clk,
    input i_rst,
    input i_clk_en,
    input [6:0] i_opcode_d,
    input [11:0] i_csr_write_addr,
    input [11:0] i_csr_read_addr,
    input i_csr_write_enable,

    input [3:0] i_exception_code_f_d_ff,
    input [31:0] i_exception_pc_f_d_ff,

    input [3:0] i_exception_code_e_m_ff,
    input [31:0] i_exception_pc_e_m_ff,
    input [31:0] i_exception_addr_e_m_ff,
    input i_mret_e,
    


    input [31:0] i_csr_data,
    output [31:0] o_csr_data,
    output [31:0] o_mepc,
    output [31:0] o_mcause,
    output [31:0] o_mtval,

    output [31:0] o_mstatus_lower,
    output [31:0] o_mie,
    output [31:0] o_mtvec,
    output [31:0] o_mstatus_upper,
    output [31:0] o_mscratch

);
    wire [11:0] w_actual_read_addr; // machine csr registers are addressed 0x300+
    assign w_actual_read_addr = i_csr_read_addr-12'h300;

    wire [11:0] w_actual_write_addr;
    assign w_actual_write_addr = i_csr_write_addr-12'h300;

    reg [31:0] r_csr_regs [69:0];
    integer i;

    assign o_csr_data = 
    (i_opcode_d ==`OP_I_TYPE_CSR)?r_csr_regs[w_actual_read_addr]:
    32'b0;

    assign o_mstatus_lower = r_csr_regs[`mstatus_lower-12'h300];
    assign o_mie = r_csr_regs[`mie-12'h300];
    assign o_mtvec = r_csr_regs[`mtvec-12'h300];
    assign o_mstatus_upper = r_csr_regs[`mstatus_upper-12'h300];
    assign o_mscratch = r_csr_regs[`mscratch-12'h300];
    assign o_mepc = r_csr_regs[`mepc-12'h300];
    assign o_mcause = r_csr_regs[`mcause-12'h300];
    assign o_mtval = r_csr_regs[`mtval-12'h300];


    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            for(i=0 ; i<70; i = i+1)
            begin
                if     (i==  `mie   -12'h300) r_csr_regs[i] <=`mie_DEFAULT_VALUE; // bit 1 is machine software interrupt and bit 7 is machine external interrupt enable
                else if(i==`mtvec   -12'h300) r_csr_regs[i] <=32'b0; // trap vector base addr
                else if(i==`mscratch-12'h300) r_csr_regs[i] <=`CSR_STACK_HI &32'hffff_fffc;
                else r_csr_regs[i] = 32'b0;
            end
        end
        else if(i_clk_en)
        begin
            if(i_csr_write_enable)
            begin
                r_csr_regs[w_actual_write_addr]<=i_csr_data;
            end
            else if(i_exception_code_f_d_ff!=`NO_E)
            begin
                r_csr_regs[(`mepc-12'h300)] <= i_exception_pc_f_d_ff;
                r_csr_regs[`mie-12'h300] <=0;
                r_csr_regs[`mcause-12'h300][31] <=0;
                r_csr_regs[`mcause-12'h300][30:0]<=i_exception_code_f_d_ff;
                r_csr_regs[`mtval-12'h300]<=i_exception_pc_f_d_ff;
            end
            else if(i_exception_code_e_m_ff!=`NO_E)
            begin
                r_csr_regs[`mepc-12'h300] <= i_exception_pc_e_m_ff;
                r_csr_regs[`mie-12'h300] <=0;
                r_csr_regs[`mcause-12'h300][31] <=0;
                r_csr_regs[`mcause-12'h300][30:0]<=i_exception_code_e_m_ff;
                r_csr_regs[`mtval-12'h300]<=i_exception_addr_e_m_ff;
            end
            else if(i_mret_e!=0)
            begin
                r_csr_regs[`mie-12'h300] <=`mie_DEFAULT_VALUE;
            end
        end
    end
    

endmodule