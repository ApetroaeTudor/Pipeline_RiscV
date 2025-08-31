`include "Constants.vh"

module M_CSR_Reg_File#(
    parameter [1:0] XLEN = `XLEN_64b
)( // this should always output mtvec and mepc
    input i_clk,
    input i_rst,
    input i_clk_en,
    input [11:0] i_csr_write_addr,  
    input [11:0] i_csr_read_addr,
    input i_csr_write_enable,

    input [3:0] i_exception_code_f_d_ff,
    input [((1<<(XLEN+4))-1):0] i_exception_pc_f_d_ff,

    input [3:0] i_exception_code_e_m_ff,
    input [((1<<(XLEN+4))-1):0] i_exception_pc_e_m_ff,
    input [((1<<(XLEN+4))-1):0] i_exception_addr_e_m_ff,
    input i_mret_e,
    


    input  [(1<<(XLEN+4))-1:0] i_csr_data,
    output [(1<<(XLEN+4))-1:0] o_csr_data,

    output [(1<<(XLEN+4))-1:0] o_mepc,

    output [1:0] o_UXL

);

    integer i;
    
    reg [(1<<(XLEN+4))-1:0] r_pmpaddr[63:0];

    reg [31:0] r_mvendorid;
    reg [(1<<(XLEN+4))-1:0] r_marchid;
    reg [(1<<(XLEN+4))-1:0] r_mimpid;
    reg [(1<<(XLEN+4))-1:0] r_mhartid;
    reg [(1<<(XLEN+4))-1:0] r_mconfigptr;

    reg [(1<<(XLEN+4))-1:0] r_mstatus;
    reg [(1<<(XLEN+4))-1:0] r_misa;
    reg [(1<<(XLEN+4))-1:0] r_medeleg;
    reg [(1<<(XLEN+4))-1:0] r_mideleg;
    reg [(1<<(XLEN+4))-1:0] r_mie;


    reg [(1<<(XLEN+4))-1:0] r_mtvec;
    reg [(1<<(XLEN+4))-1:0] r_mcounteren;
    reg [31:0] r_mstatush;
    reg [(1<<(XLEN+4))-1:0] r_mscratch;
    reg [(1<<(XLEN+4))-1:0] r_mepc;

    reg [(1<<(XLEN+4))-1:0] r_mcause;
    reg [(1<<(XLEN+4))-1:0] r_mtval;
    reg [(1<<(XLEN+4))-1:0] r_mip;
    reg [(1<<(XLEN+4))-1:0] r_mtinst;
    reg [(1<<(XLEN+4))-1:0] r_mtval2;


    reg [(1<<(XLEN+4))-1:0] r_menvcfg;
    reg [31:0] r_menvcfgh;
    reg [(1<<(XLEN+4))-1:0] r_mseccfg;
    reg [31:0] r_mseccfgh;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg0;

    reg [(1<<(XLEN+4))-1:0] r_pmpcfg1;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg2;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg3;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg4;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg5;


    reg [(1<<(XLEN+4))-1:0] r_pmpcfg6;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg7;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg8;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg9;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg10;

    reg [(1<<(XLEN+4))-1:0] r_pmpcfg11;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg12;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg13;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg14;
    reg [(1<<(XLEN+4))-1:0] r_pmpcfg15;

    reg [(1<<(XLEN+4))-1:0] r_o_csr_data;
    assign o_csr_data = r_o_csr_data;
    assign o_mepc = r_mepc;



    always@(*)
    begin

            casex(i_csr_read_addr)
            `REG_MVENDORID_ADDR:   r_o_csr_data = $unsigned(r_mvendorid); //d
            `REG_MARCHID_ADDR:     r_o_csr_data = r_marchid; //d
            `REG_MIMPID_ADDR:      r_o_csr_data = r_mimpid; //d
            `REG_MHARTID_ADDR:     r_o_csr_data = r_mhartid; //d
            `REG_MCONFIGPTR_ADDR:  r_o_csr_data = r_mconfigptr; //d
            `REG_MSTATUS_ADDR:     r_o_csr_data = r_mstatus; //d
            `REG_MISA_ADDR:        r_o_csr_data = r_misa;
            `REG_MEDELEG_ADDR:     r_o_csr_data = r_medeleg; //d - for s mode
            `REG_MIDELEG_ADDR:     r_o_csr_data = r_mideleg; //d - for s mode
            `REG_MIE_ADDR:         r_o_csr_data = r_mie; //d - for interrupts (to be implemented later)
            `REG_MTVEC_ADDR:       r_o_csr_data = r_mtvec;//d
            `REG_MCOUNTEREN_ADDR:  r_o_csr_data = r_mcounteren; //d - to be implemented later
            `REG_MSTATUSH_ADDR:    r_o_csr_data = r_mstatush;//d
            `REG_MSCRATCH_ADDR:    r_o_csr_data = r_mscratch; //d
            `REG_MEPC_ADDR:        r_o_csr_data = r_mepc; //d
            `REG_MCAUSE_ADDR:      r_o_csr_data = r_mcause;//d
            `REG_MTVAL_ADDR:       r_o_csr_data = r_mtval; //d
            `REG_MIP_ADDR:         r_o_csr_data = r_mip; //d - for interrupts (to be implemented later)
            `REG_MTINST_ADDR:      r_o_csr_data = r_mtinst; //d
            `REG_MTVAL2_ADDR:      r_o_csr_data = r_mtval2; //d
            `REG_MENVCFG_ADDR:     r_o_csr_data = r_menvcfg; //d (not implemented yet)
            `REG_MENVCFGH_ADDR:    r_o_csr_data = r_menvcfg;//
            `REG_MSECCFG_ADDR:     r_o_csr_data = r_mseccfg; // d - (not implemented)
            `REG_MSECCFGH_ADDR:    r_o_csr_data = r_mseccfg;//d
            `REG_PMPCFG0_ADDR:     r_o_csr_data = r_pmpcfg0;
            `REG_PMPCFG1_ADDR:     r_o_csr_data = r_pmpcfg1;
            `REG_PMPCFG2_ADDR:     r_o_csr_data = r_pmpcfg2;
            `REG_PMPCFG3_ADDR:     r_o_csr_data = r_pmpcfg3;
            `REG_PMPCFG4_ADDR:     r_o_csr_data = r_pmpcfg4;
            `REG_PMPCFG5_ADDR:     r_o_csr_data = r_pmpcfg5;
            `REG_PMPCFG6_ADDR:     r_o_csr_data = r_pmpcfg6;
            `REG_PMPCFG7_ADDR:     r_o_csr_data = r_pmpcfg7;
            `REG_PMPCFG8_ADDR:     r_o_csr_data = r_pmpcfg8;
            `REG_PMPCFG9_ADDR:     r_o_csr_data = r_pmpcfg9;
            `REG_PMPCFG10_ADDR:    r_o_csr_data = r_pmpcfg10;
            `REG_PMPCFG11_ADDR:    r_o_csr_data = r_pmpcfg11;
            `REG_PMPCFG12_ADDR:    r_o_csr_data = r_pmpcfg12;
            `REG_PMPCFG13_ADDR:    r_o_csr_data = r_pmpcfg13;
            `REG_PMPCFG14_ADDR:    r_o_csr_data = r_pmpcfg14;
            `REG_PMPCFG15_ADDR:    r_o_csr_data = r_pmpcfg15;
            default: begin
                if(i_csr_read_addr >= `REG_PMPADDR_BASE_ADDR && i_csr_read_addr <=`REG_PMPADDR_END_ADDR)
                begin
                    r_o_csr_data = r_pmpaddr[i_csr_read_addr - `REG_PMPADDR_BASE_ADDR];
                end
                else r_o_csr_data = 0;
            end
            endcase

    end

    assign o_UXL = (XLEN == `XLEN_64b)?r_mstatus[33:32]:XLEN;


    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            r_mvendorid   <= 0;
            r_marchid     <= 0;
            r_mimpid      <= 0;
            r_mhartid     <= 0; // main and only hart, ID<=0
            r_mconfigptr  <= 0;

            r_mstatus     <= 0;
            r_misa        <= 0;
            r_medeleg     <= 0;
            r_mideleg     <= 0;
            r_mie         <= 0;


            r_mtvec       <= 0;
            r_mcounteren  <= 0;
            r_mstatush    <= 0;
            r_mscratch    <= 0;
            r_mepc        <= 0;

            r_mcause      <= 0;
            r_mtval       <= 0;
            r_mip         <= 0;
            r_mtinst      <= 0;
            r_mtval2      <= 0;


            r_menvcfg     <= 0;
            r_menvcfgh    <= 0;
            r_mseccfg     <= 0;
            r_mseccfgh    <= 0;
            r_pmpcfg0     <= 0;

            r_pmpcfg1     <= 0;
            r_pmpcfg2     <= 0;
            r_pmpcfg3     <= 0;
            r_pmpcfg4     <= 0;
            r_pmpcfg5     <= 0;

            r_pmpcfg6     <= 0;
            r_pmpcfg7     <= 0;
            r_pmpcfg8     <= 0;
            r_pmpcfg9     <= 0;
            r_pmpcfg10    <= 0;

            r_pmpcfg11    <= 0;
            r_pmpcfg12    <= 0;
            r_pmpcfg13    <= 0;
            r_pmpcfg14    <= 0;
            r_pmpcfg15    <= 0;

            for(i = 0 ; i < 64; i = i + 1) r_pmpaddr[i] = 0;

        end
        else if(i_clk_en)
        begin
            if(i_csr_write_enable)
            begin

                casex(i_csr_write_addr)
                    `REG_MVENDORID_ADDR:   r_mvendorid           <= r_mvendorid;
                    `REG_MARCHID_ADDR:     r_marchid             <= r_marchid;
                    `REG_MIMPID_ADDR:      r_mimpid              <= r_mimpid;
                    `REG_MHARTID_ADDR:     r_mhartid             <= r_mhartid;
                    `REG_MCONFIGPTR_ADDR:  r_mconfigptr          <= r_mconfigptr;
                    `REG_MSTATUS_ADDR:     r_mstatus             <= i_csr_data;
                    `REG_MISA_ADDR:        r_misa                <= i_csr_data;
                    `REG_MEDELEG_ADDR:     r_medeleg             <= i_csr_data;
                    `REG_MIDELEG_ADDR:     r_mideleg             <= i_csr_data;
                    `REG_MIE_ADDR:         r_mie                 <= i_csr_data;
                    `REG_MTVEC_ADDR:       r_mtvec               <= i_csr_data;
                    `REG_MCOUNTEREN_ADDR:  r_mcounteren          <= i_csr_data;
                    `REG_MSTATUSH_ADDR:    r_mstatush            <= i_csr_data;
                    `REG_MSCRATCH_ADDR:    r_mscratch            <= i_csr_data;
                    `REG_MEPC_ADDR:        r_mepc                <= i_csr_data;
                    `REG_MCAUSE_ADDR:      r_mcause              <= i_csr_data;
                    `REG_MTVAL_ADDR:       r_mtval               <= i_csr_data;
                    `REG_MIP_ADDR:         r_mip                 <= i_csr_data;
                    `REG_MTINST_ADDR:      r_mtinst              <= i_csr_data;
                    `REG_MTVAL2_ADDR:      r_mtval2              <= i_csr_data;
                    `REG_MENVCFG_ADDR:     r_menvcfg             <= i_csr_data;
                    `REG_MENVCFGH_ADDR:    r_menvcfgh            <= i_csr_data;
                    `REG_MSECCFG_ADDR:     r_mseccfg             <= i_csr_data;
                    `REG_MSECCFGH_ADDR:    r_mseccfgh            <= i_csr_data;
                    `REG_PMPCFG0_ADDR:     r_pmpcfg0             <= i_csr_data;
                    `REG_PMPCFG1_ADDR:     r_pmpcfg1             <= i_csr_data;
                    `REG_PMPCFG2_ADDR:     r_pmpcfg2             <= i_csr_data;
                    `REG_PMPCFG3_ADDR:     r_pmpcfg3             <= i_csr_data;
                    `REG_PMPCFG4_ADDR:     r_pmpcfg4             <= i_csr_data;
                    `REG_PMPCFG5_ADDR:     r_pmpcfg5             <= i_csr_data;
                    `REG_PMPCFG6_ADDR:     r_pmpcfg6             <= i_csr_data;
                    `REG_PMPCFG7_ADDR:     r_pmpcfg7             <= i_csr_data;
                    `REG_PMPCFG8_ADDR:     r_pmpcfg8             <= i_csr_data;
                    `REG_PMPCFG9_ADDR:     r_pmpcfg9             <= i_csr_data;
                    `REG_PMPCFG10_ADDR:    r_pmpcfg10            <= i_csr_data;
                    `REG_PMPCFG11_ADDR:    r_pmpcfg11            <= i_csr_data;
                    `REG_PMPCFG12_ADDR:    r_pmpcfg12            <= i_csr_data;
                    `REG_PMPCFG13_ADDR:    r_pmpcfg13            <= i_csr_data;
                    `REG_PMPCFG14_ADDR:    r_pmpcfg14            <= i_csr_data;
                    `REG_PMPCFG15_ADDR:    r_pmpcfg15            <= i_csr_data;
                    default: begin
                    if(i_csr_write_addr >= `REG_PMPADDR_BASE_ADDR && i_csr_write_addr <=`REG_PMPADDR_END_ADDR)
                    begin
                        r_pmpaddr[i_csr_write_addr - `REG_PMPADDR_BASE_ADDR]<=i_csr_data;
                    end
                end
                endcase
            
            end
        end
    end

    // warl - software can write anythig, but reading is always to a legal value (default case)
    // wpri - can be written, read is 0














    // always@(posedge i_clk)
    // begin
    //     if(i_rst)
    //     begin
    //         for(i=0 ; i<`CSR_CNT; i = i+1)
    //         begin
    //             if     (i==  `mie   -12'h300) r_csr_regs[i] <= $signed(`mie_DEFAULT_VALUE); // bit 1 is machine software interrupt and bit 7 is machine external interrupt enable
    //             else if(i==`mtvec   -12'h300) r_csr_regs[i] <={(1<<(XLEN+4)){1'b0}}; // trap vector base addr
    //             else if(i==`mscratch-12'h300) r_csr_regs[i] <= $signed(`M_STACK_HI &32'hffff_fffc);
    //             else if(i==`mstatus -12'h300) begin
    //                 if(XLEN == `XLEN_64b)
    //                 begin
    //                     r_csr_regs[i] <= {
    //                                       1'b0, // b63         SD state dirty
    //                                       25'b0,// b[62:38]    WPRI
    //                                       1'b0 ,// b37         MBE machine big endian
    //                                       1'b0 ,// b36         SBE supervisor big endian
    //                                       XLEN, // b[35:34]    SXL supervisor xlen (defaults to xlen)
    //                                       XLEN, // b[33:32]    UXL user xlen (defaults to xlen)
    //                                       9'b0, // b[31:23]    wpri
    //                                       1'b0, // b22         TSR trap sret
    //                                       1'b0, // b21         TW timeout wait
    //                                       1'b0, // b20         TVM trap virtual mem
    //                                       1'b0, // b19         MXR make executable readable
    //                                       1'b0, // b18         SUM supervisor user memory access
    //                                       1'b0, // b17         MPRV machine privilege
    //                                       2'b00,// b[16:15]    XS extension state
    //                                       2'b00,// b[14:13]    FS floating point status
    //                                       2'b00,// b[12:11]    MPP machine previous privilege - 00 = User, 11 = Machine, 01 = Supervisor (not implemented), 10 = Hypervisor (not implemented)
    //                                       2'b00,// b[10:9]     VS vector status
    //                                       1'b1, // b8          SPP supervisor previous privilege - 1 =  Machine, 0 = User
    //                                       1'b1, // b7          MPIE machine previous interrupt enable, restored on mret
    //                                       1'b0, // b6          UBE user big endian
    //                                       1'b1, // b5          SPIE supervisor previous interrupt enable
    //                                       1'b0, // b4          wpri
    //                                       1'b0, // b3          MIE machine interrupt enable
    //                                       1'b0, // b2          wpri
    //                                       1'b0, // b1          SIE supervisor interrupt enable
    //                                       1'b0  // b0          wpri
    //                     };
    //                     r_csr_regs[`mstatush-12'h300] <=  r_csr_regs[i][63:32];
    //                 end
    //                 else 
    //                 begin
    //                     r_csr_regs[i] <= {
    //                                       1'b0, // b31         SD
    //                                       8'b0, // b[30:23]    wpri
    //                                       1'b0, // b22         TSR trap sret
    //                                       1'b0, // b21         TW timeout wait
    //                                       1'b0, // b20         TVM trap virtual mem
    //                                       1'b0, // b19         MXR make executable readable
    //                                       1'b0, // b18         SUM supervisor user memory access
    //                                       1'b0, // b17         MPRV machine privilege
    //                                       2'b00,// b[16:15]    XS extension state
    //                                       2'b00,// b[14:13]    FS floating point status
    //                                       2'b00,// b[12:11]    MPP machine previous privilege - 00 = User, 11 = Machine, 01 = Supervisor (not implemented), 10 = Hypervisor (not implemented)
    //                                       2'b00,// b[10:9]     VS vector status
    //                                       1'b1, // b8          SPP supervisor previous privilege - 1 =  Machine, 0 = User
    //                                       1'b1, // b7          MPIE machine previous interrupt enable, restored on mret
    //                                       1'b0, // b6          UBE user big endian
    //                                       1'b1, // b5          SPIE supervisor previous interrupt enable
    //                                       1'b0, // b4          wpri
    //                                       1'b0, // b3          MIE machine interrupt enable
    //                                       1'b0, // b2          wpri
    //                                       1'b0, // b1          SIE supervisor interrupt enable
    //                                       1'b0  // b0          wpri
    //                     };
    //                     r_csr_regs[`mstatush-12'h300] <=  {
    //                                                     26'b0, // b[31:6]   wpri
    //                                                     1'b0,  // b5        MBE machine big endian
    //                                                     1'b0,  // b4        SBE supervisor big endian
    //                                                     4'b0  // b[3:0]    wpri
    //                     };   
    //                 end
    //             end
    //             else r_csr_regs[i] = {(1<<(XLEN+4)){1'b0}};
    //         end
    //     end
    //     else if(i_clk_en)
    //     begin
    //         if(i_csr_write_enable)
    //         begin
    //             casex(w_actual_read_addr)
    //             (`mstatus-12'h300): begin       
    //                 r_csr_regs[`mstatus-12'h300] <= i_csr_data;
    //                 if(XLEN == `XLEN_64b) // write in mstatus in 64b
    //                 begin
    //                     r_csr_regs[`mstatush-12'h300] <=  $signed(i_csr_data[63:32]);
    //                 end
    //             end
    //             (`mstatush-12'h300): begin
    //                 r_csr_regs[`mstatush-12'h300] <= $signed(i_csr_data[31:0]);
    //                 if(XLEN == `XLEN_64b) // write in mstatush in 64b
    //                 begin
    //                     r_csr_regs[`mstatus-12'h300][63:32] <= i_csr_data[31:0]; 
    //                 end
                        
    //             end
    //             default: begin
    //                 r_csr_regs[w_actual_write_addr]<=$signed(i_csr_data);
    //             end
    //             endcase
    //         end
    //         else if(i_exception_code_f_d_ff!=`NO_E)
    //         begin
    //             r_csr_regs[(`mepc-12'h300)] <= i_exception_pc_f_d_ff;
    //             r_csr_regs[`mie-12'h300] <=0;
    //             r_csr_regs[`mcause-12'h300][31] <=0;
    //             r_csr_regs[`mcause-12'h300][30:0]<=i_exception_code_f_d_ff;
    //             r_csr_regs[`mtval-12'h300]<=i_exception_pc_f_d_ff;
    //         end
    //         else if(i_exception_code_e_m_ff!=`NO_E)
    //         begin
    //             r_csr_regs[`mepc-12'h300] <= i_exception_pc_e_m_ff;
    //             r_csr_regs[`mie-12'h300] <=0;
    //             r_csr_regs[`mcause-12'h300][31] <=0;
    //             r_csr_regs[`mcause-12'h300][30:0]<=i_exception_code_e_m_ff;
    //             r_csr_regs[`mtval-12'h300]<=i_exception_addr_e_m_ff;
    //         end
    //         else if(i_mret_e!=0)
    //         begin
    //             r_csr_regs[`mie-12'h300] <=`mie_DEFAULT_VALUE;
    //         end
    //     end
    // end
    

endmodule


// // csr regs to implement:
// 0xF11-0xF15(5 x xlen) - initalize on reset all to 0, cant be written
// mvendorid, marchid, mimpid, mhartid, mconfigptr

// (8 x xlen) - reset vector 
// 0x300 = mstatus
// 0x301 = misa
// 0x302 = medeleg
// 0x303 = mideleg
// 0x304 = mie
// 0x305 = mtvec
// 0x306 = mcounteren
// 0x310 = mstatush 

// (7 x xlen) - on exception/interrupt
// 0x340 = mscratch
// 0x341 = mepc
// 0x342 = mcause
// 0x343 = mtval
// 0x344 = mip
// 0x34A = mtinst (?)
// 0x34B = mtval2 (?)

// (4 x xlen) - init to 0 in reset
// 0x30A = mecnvcfg
// 0x31A = menvcfgh
// 0x747 = mseccfg 
// 0x757 = mseccfgh

// (16 x xlen) - init in code, all initialized in code
// 0x3A0-0x3AF
// pmpcfg0 - pmpcfg15
// if on 32b -> pmpcfg0-15 are initialized
// if on 64b -> pmpcfg0,2,4,..,14 are initialized

// (64 x xlen) - init in code
// 0x3B0-0x3EF
// pmpaddr0 - pmpaddr63



