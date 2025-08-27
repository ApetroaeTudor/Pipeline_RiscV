`include "Constants.vh"

module M_CSR_Reg_File#(
    parameter [1:0] XLEN = `XLEN_64b
)( // this should always output mtvec and mepc
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
    


    input  [(1<<(XLEN+4))-1:0] i_csr_data,
    output [(1<<(XLEN+4))-1:0] o_csr_data,
    output [(1<<(XLEN+4))-1:0] o_mepc,
    output [(1<<(XLEN+4))-1:0] o_mcause,
    output [(1<<(XLEN+4))-1:0] o_mtval,

    output [(1<<(XLEN+4))-1:0] o_mie,
    output [(1<<(XLEN+4))-1:0] o_mtvec,


    output [(1<<(XLEN+4))-1:0] o_mstatush,
    output [(1<<(XLEN+4))-1:0] o_mstatus,

    output [(1<<(XLEN+4))-1:0] o_mscratch,



    output [1:0] o_UXL

);
    wire [11:0] w_actual_read_addr; // machine csr registers are addressed 0x300+
    assign w_actual_read_addr = i_csr_read_addr-12'h300;

    wire [11:0] w_actual_write_addr;
    assign w_actual_write_addr = i_csr_write_addr-12'h300;



    reg [(1<<(XLEN+4))-1:0] r_csr_regs [69:0];



    integer i;

    assign o_csr_data = 
    (i_opcode_d ==`OP_I_TYPE_CSR)?r_csr_regs[w_actual_read_addr]:
    32'b0;

    assign o_mstatus = r_csr_regs[`mstatus-12'h300];
    assign o_mie = r_csr_regs[`mie-12'h300];
    assign o_mtvec = r_csr_regs[`mtvec-12'h300];

    assign o_mstatush = r_csr_regs[`mstatush-12'h300];
    assign o_mscratch = r_csr_regs[`mscratch-12'h300];
    assign o_mepc = r_csr_regs[`mepc-12'h300];
    assign o_mcause = r_csr_regs[`mcause-12'h300];
    assign o_mtval = r_csr_regs[`mtval-12'h300];


    reg [1:0] r_UXL;
    assign o_UXL = r_UXL;


    always@(*)
    begin
        casex(XLEN)
        `XLEN_64b: begin
            r_UXL = r_csr_regs[`mstatus-12'h300][33:32];
        end
        default: begin
            r_UXL = XLEN;
        end
        endcase
    end


    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            for(i=0 ; i<70; i = i+1)
            begin
                if     (i==  `mie   -12'h300) r_csr_regs[i] <= $signed(`mie_DEFAULT_VALUE); // bit 1 is machine software interrupt and bit 7 is machine external interrupt enable
                else if(i==`mtvec   -12'h300) r_csr_regs[i] <={(1<<(XLEN+4)){1'b0}}; // trap vector base addr
                else if(i==`mscratch-12'h300) r_csr_regs[i] <= $signed(`M_STACK_HI &32'hffff_fffc);
                else if(i==`mstatus -12'h300) begin
                    if(XLEN == `XLEN_64b)
                    begin
                        r_csr_regs[i] <= {
                                          1'b0, // b63         SD state dirty
                                          25'b0,// b[62:38]    WPRI
                                          1'b0 ,// b37         MBE machine big endian
                                          1'b0 ,// b36         SBE supervisor big endian
                                          XLEN, // b[35:34]    SXL supervisor xlen (defaults to xlen)
                                          XLEN, // b[33:32]    UXL user xlen (defaults to xlen)
                                          9'b0, // b[31:23]    wpri
                                          1'b0, // b22         TSR trap sret
                                          1'b0, // b21         TW timeout wait
                                          1'b0, // b20         TVM trap virtual mem
                                          1'b0, // b19         MXR make executable readable
                                          1'b0, // b18         SUM supervisor user memory access
                                          1'b0, // b17         MPRV machine privilege
                                          2'b00,// b[16:15]    XS extension state
                                          2'b00,// b[14:13]    FS floating point status
                                          2'b11,// b[12:11]    MPP machine previous privilege - 00 = User, 11 = Machine, 01 = Supervisor (not implemented), 10 = Hypervisor (not implemented)
                                          2'b00,// b[10:9]     VS vector status
                                          1'b1, // b8          SPP supervisor previous privilege - 1 =  Machine, 0 = User
                                          1'b1, // b7          MPIE machine previous interrupt enable, restored on mret
                                          1'b0, // b6          UBE user big endian
                                          1'b1, // b5          SPIE supervisor previous interrupt enable
                                          1'b0, // b4          wpri
                                          1'b0, // b3          MIE machine interrupt enable
                                          1'b0, // b2          wpri
                                          1'b0, // b1          SIE supervisor interrupt enable
                                          1'b0  // b0          wpri
                        };
                        r_csr_regs[`mstatush-12'h300] <=  r_csr_regs[i][63:32];
                    end
                    else 
                    begin
                        r_csr_regs[i] <= {
                                          1'b0, // b31         SD
                                          8'b0, // b[30:23]    wpri
                                          1'b0, // b22         TSR trap sret
                                          1'b0, // b21         TW timeout wait
                                          1'b0, // b20         TVM trap virtual mem
                                          1'b0, // b19         MXR make executable readable
                                          1'b0, // b18         SUM supervisor user memory access
                                          1'b0, // b17         MPRV machine privilege
                                          2'b00,// b[16:15]    XS extension state
                                          2'b00,// b[14:13]    FS floating point status
                                          2'b11,// b[12:11]    MPP machine previous privilege - 00 = User, 11 = Machine, 01 = Supervisor (not implemented), 10 = Hypervisor (not implemented)
                                          2'b00,// b[10:9]     VS vector status
                                          1'b1, // b8          SPP supervisor previous privilege - 1 =  Machine, 0 = User
                                          1'b1, // b7          MPIE machine previous interrupt enable, restored on mret
                                          1'b0, // b6          UBE user big endian
                                          1'b1, // b5          SPIE supervisor previous interrupt enable
                                          1'b0, // b4          wpri
                                          1'b0, // b3          MIE machine interrupt enable
                                          1'b0, // b2          wpri
                                          1'b0, // b1          SIE supervisor interrupt enable
                                          1'b0  // b0          wpri
                        };
                        r_csr_regs[`mstatush-12'h300] <=  {
                                                        26'b0, // b[31:6]   wpri
                                                        1'b0,  // b5        MBE machine big endian
                                                        1'b0,  // b4        SBE supervisor big endian
                                                        4'b0  // b[3:0]    wpri
                        };   
                    end
                end
                else r_csr_regs[i] = {(1<<(XLEN+4)){1'b0}};
            end
        end
        else if(i_clk_en)
        begin
            if(i_csr_write_enable)
            begin
                casex(w_actual_read_addr)
                (`mstatus-12'h300): begin       
                    r_csr_regs[`mstatus-12'h300] <= i_csr_data;
                    if(XLEN == `XLEN_64b) // write in mstatus in 64b
                    begin
                        r_csr_regs[`mstatush-12'h300] <=  $signed(i_csr_data[63:32]);
                    end
                end
                (`mstatush-12'h300): begin
                    r_csr_regs[`mstatush-12'h300] <= $signed(i_csr_data[31:0]);
                    if(XLEN == `XLEN_64b) // write in mstatush in 64b
                    begin
                        r_csr_regs[`mstatus-12'h300][63:32] <= i_csr_data[31:0]; 
                    end
                        
                end
                default: begin
                    r_csr_regs[w_actual_write_addr]<=$signed(i_csr_data);
                end
                endcase
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