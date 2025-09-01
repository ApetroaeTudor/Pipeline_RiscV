`include "riscv_defines.vh"

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

    output [((1<<(XLEN+4))<<6)-1:0] o_concat_pmpaddr,
    output [511:0] o_concat_pmpcfg,

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



    // reg [(1<<(XLEN+4))<<6:0] r_concat_pmpaddr; // 64/32 x 64
    // assign o_concat_pmpaddr = r_concat_pmpaddr;


    reg [511:0] r_concat_pmpcfg; // for each pmpaddr there is a pmpconfig byte
    assign o_concat_pmpcfg = r_concat_pmpcfg;


    genvar j; // system verilog 

    generate
        for (j=0;j<64;j=j+1)
        begin
            assign o_concat_pmpaddr[((j+1)*(1<<(XLEN+4))-1):j*(1<<(XLEN+4))] = r_pmpaddr[j];
        end
    endgenerate

    always@(*)
    begin

            if(XLEN == `XLEN_64b)
            begin
                r_concat_pmpcfg[`byte_0]  = r_pmpcfg0[`byte_0];  // this is very poorly done
                r_concat_pmpcfg[`byte_1]  = r_pmpcfg0[`byte_1];
                r_concat_pmpcfg[`byte_2]  = r_pmpcfg0[`byte_2];
                r_concat_pmpcfg[`byte_3]  = r_pmpcfg0[`byte_3];

                r_concat_pmpcfg[`byte_4]  = r_pmpcfg0[`byte_4];
                r_concat_pmpcfg[`byte_5]  = r_pmpcfg0[`byte_5];
                r_concat_pmpcfg[`byte_6]  = r_pmpcfg0[`byte_6];
                r_concat_pmpcfg[`byte_7]  = r_pmpcfg0[`byte_7];


                r_concat_pmpcfg[`byte_8]  = r_pmpcfg2[`byte_0];
                r_concat_pmpcfg[`byte_9]  = r_pmpcfg2[`byte_1];
                r_concat_pmpcfg[`byte_10] = r_pmpcfg2[`byte_2];
                r_concat_pmpcfg[`byte_11] = r_pmpcfg2[`byte_3];

                r_concat_pmpcfg[`byte_12] = r_pmpcfg2[`byte_4];
                r_concat_pmpcfg[`byte_13] = r_pmpcfg2[`byte_5];
                r_concat_pmpcfg[`byte_14] = r_pmpcfg2[`byte_6];
                r_concat_pmpcfg[`byte_15] = r_pmpcfg2[`byte_7];



                r_concat_pmpcfg[`byte_16] = r_pmpcfg4[`byte_0];
                r_concat_pmpcfg[`byte_17] = r_pmpcfg4[`byte_1];
                r_concat_pmpcfg[`byte_18] = r_pmpcfg4[`byte_2];
                r_concat_pmpcfg[`byte_19] = r_pmpcfg4[`byte_3];

                r_concat_pmpcfg[`byte_20] = r_pmpcfg4[`byte_4];
                r_concat_pmpcfg[`byte_21] = r_pmpcfg4[`byte_5];
                r_concat_pmpcfg[`byte_22] = r_pmpcfg4[`byte_6];
                r_concat_pmpcfg[`byte_23] = r_pmpcfg4[`byte_7];


                r_concat_pmpcfg[`byte_24] = r_pmpcfg6[`byte_0];
                r_concat_pmpcfg[`byte_25] = r_pmpcfg6[`byte_1];
                r_concat_pmpcfg[`byte_26] = r_pmpcfg6[`byte_2];
                r_concat_pmpcfg[`byte_27] = r_pmpcfg6[`byte_3];

                r_concat_pmpcfg[`byte_28] = r_pmpcfg6[`byte_4];
                r_concat_pmpcfg[`byte_29] = r_pmpcfg6[`byte_5];
                r_concat_pmpcfg[`byte_30] = r_pmpcfg6[`byte_6];
                r_concat_pmpcfg[`byte_31] = r_pmpcfg6[`byte_7];




                r_concat_pmpcfg[`byte_32] = r_pmpcfg8[`byte_0];
                r_concat_pmpcfg[`byte_33] = r_pmpcfg8[`byte_1];
                r_concat_pmpcfg[`byte_34] = r_pmpcfg8[`byte_2];
                r_concat_pmpcfg[`byte_35] = r_pmpcfg8[`byte_3];

                r_concat_pmpcfg[`byte_36] = r_pmpcfg8[`byte_4];
                r_concat_pmpcfg[`byte_37] = r_pmpcfg8[`byte_5];
                r_concat_pmpcfg[`byte_38] = r_pmpcfg8[`byte_6];
                r_concat_pmpcfg[`byte_39] = r_pmpcfg8[`byte_7];


                r_concat_pmpcfg[`byte_40] = r_pmpcfg10[`byte_0];
                r_concat_pmpcfg[`byte_41] = r_pmpcfg10[`byte_1];
                r_concat_pmpcfg[`byte_42] = r_pmpcfg10[`byte_2];
                r_concat_pmpcfg[`byte_43] = r_pmpcfg10[`byte_3];

                r_concat_pmpcfg[`byte_44] = r_pmpcfg10[`byte_4];
                r_concat_pmpcfg[`byte_45] = r_pmpcfg10[`byte_5];
                r_concat_pmpcfg[`byte_46] = r_pmpcfg10[`byte_6];
                r_concat_pmpcfg[`byte_47] = r_pmpcfg10[`byte_7];



                r_concat_pmpcfg[`byte_48] = r_pmpcfg12[`byte_0];
                r_concat_pmpcfg[`byte_49] = r_pmpcfg12[`byte_1];
                r_concat_pmpcfg[`byte_50] = r_pmpcfg12[`byte_2];
                r_concat_pmpcfg[`byte_51] = r_pmpcfg12[`byte_3];

                r_concat_pmpcfg[`byte_52] = r_pmpcfg12[`byte_4];
                r_concat_pmpcfg[`byte_53] = r_pmpcfg12[`byte_5];
                r_concat_pmpcfg[`byte_54] = r_pmpcfg12[`byte_6];
                r_concat_pmpcfg[`byte_55] = r_pmpcfg12[`byte_7];


                r_concat_pmpcfg[`byte_56] = r_pmpcfg14[`byte_0];
                r_concat_pmpcfg[`byte_57] = r_pmpcfg14[`byte_1];
                r_concat_pmpcfg[`byte_58] = r_pmpcfg14[`byte_2];
                r_concat_pmpcfg[`byte_59] = r_pmpcfg14[`byte_3];

                r_concat_pmpcfg[`byte_60] = r_pmpcfg14[`byte_4];
                r_concat_pmpcfg[`byte_61] = r_pmpcfg14[`byte_5];
                r_concat_pmpcfg[`byte_62] = r_pmpcfg14[`byte_6];
                r_concat_pmpcfg[`byte_63] = r_pmpcfg14[`byte_7];
                
            end
            else
            begin
                r_concat_pmpcfg[`byte_0]  = r_pmpcfg0[`byte_0];
                r_concat_pmpcfg[`byte_1]  = r_pmpcfg0[`byte_1];
                r_concat_pmpcfg[`byte_2]  = r_pmpcfg0[`byte_2];
                r_concat_pmpcfg[`byte_3]  = r_pmpcfg0[`byte_3];

                r_concat_pmpcfg[`byte_4]  = r_pmpcfg1[`byte_0];
                r_concat_pmpcfg[`byte_5]  = r_pmpcfg1[`byte_1];
                r_concat_pmpcfg[`byte_6]  = r_pmpcfg1[`byte_2];
                r_concat_pmpcfg[`byte_7]  = r_pmpcfg1[`byte_3];


                r_concat_pmpcfg[`byte_8]  = r_pmpcfg2[`byte_0];
                r_concat_pmpcfg[`byte_9]  = r_pmpcfg2[`byte_1];
                r_concat_pmpcfg[`byte_10] = r_pmpcfg2[`byte_2];
                r_concat_pmpcfg[`byte_11] = r_pmpcfg2[`byte_3];

                r_concat_pmpcfg[`byte_12] = r_pmpcfg3[`byte_0];
                r_concat_pmpcfg[`byte_13] = r_pmpcfg3[`byte_1];
                r_concat_pmpcfg[`byte_14] = r_pmpcfg3[`byte_2];
                r_concat_pmpcfg[`byte_15] = r_pmpcfg3[`byte_3];



                r_concat_pmpcfg[`byte_16] = r_pmpcfg4[`byte_0];
                r_concat_pmpcfg[`byte_17] = r_pmpcfg4[`byte_1];
                r_concat_pmpcfg[`byte_18] = r_pmpcfg4[`byte_2];
                r_concat_pmpcfg[`byte_19] = r_pmpcfg4[`byte_3];

                r_concat_pmpcfg[`byte_20] = r_pmpcfg5[`byte_0];
                r_concat_pmpcfg[`byte_21] = r_pmpcfg5[`byte_1];
                r_concat_pmpcfg[`byte_22] = r_pmpcfg5[`byte_2];
                r_concat_pmpcfg[`byte_23] = r_pmpcfg5[`byte_3];


                r_concat_pmpcfg[`byte_24] = r_pmpcfg6[`byte_0];
                r_concat_pmpcfg[`byte_25] = r_pmpcfg6[`byte_1];
                r_concat_pmpcfg[`byte_26] = r_pmpcfg6[`byte_2];
                r_concat_pmpcfg[`byte_27] = r_pmpcfg6[`byte_3];

                r_concat_pmpcfg[`byte_28] = r_pmpcfg7[`byte_0];
                r_concat_pmpcfg[`byte_29] = r_pmpcfg7[`byte_1];
                r_concat_pmpcfg[`byte_30] = r_pmpcfg7[`byte_2];
                r_concat_pmpcfg[`byte_31] = r_pmpcfg7[`byte_3];




                r_concat_pmpcfg[`byte_32] = r_pmpcfg8[`byte_0];
                r_concat_pmpcfg[`byte_33] = r_pmpcfg8[`byte_1];
                r_concat_pmpcfg[`byte_34] = r_pmpcfg8[`byte_2];
                r_concat_pmpcfg[`byte_35] = r_pmpcfg8[`byte_3];

                r_concat_pmpcfg[`byte_36] = r_pmpcfg9[`byte_0];
                r_concat_pmpcfg[`byte_37] = r_pmpcfg9[`byte_1];
                r_concat_pmpcfg[`byte_38] = r_pmpcfg9[`byte_2];
                r_concat_pmpcfg[`byte_39] = r_pmpcfg9[`byte_3];


                r_concat_pmpcfg[`byte_40] = r_pmpcfg10[`byte_0];
                r_concat_pmpcfg[`byte_41] = r_pmpcfg10[`byte_1];
                r_concat_pmpcfg[`byte_42] = r_pmpcfg10[`byte_2];
                r_concat_pmpcfg[`byte_43] = r_pmpcfg10[`byte_3];

                r_concat_pmpcfg[`byte_44] = r_pmpcfg11[`byte_0];
                r_concat_pmpcfg[`byte_45] = r_pmpcfg11[`byte_1];
                r_concat_pmpcfg[`byte_46] = r_pmpcfg11[`byte_2];
                r_concat_pmpcfg[`byte_47] = r_pmpcfg11[`byte_3];



                r_concat_pmpcfg[`byte_48] = r_pmpcfg12[`byte_0];
                r_concat_pmpcfg[`byte_49] = r_pmpcfg12[`byte_1];
                r_concat_pmpcfg[`byte_50] = r_pmpcfg12[`byte_2];
                r_concat_pmpcfg[`byte_51] = r_pmpcfg12[`byte_3];

                r_concat_pmpcfg[`byte_52] = r_pmpcfg13[`byte_0];
                r_concat_pmpcfg[`byte_53] = r_pmpcfg13[`byte_1];
                r_concat_pmpcfg[`byte_54] = r_pmpcfg13[`byte_2];
                r_concat_pmpcfg[`byte_55] = r_pmpcfg13[`byte_3];


                r_concat_pmpcfg[`byte_56] = r_pmpcfg14[`byte_0];
                r_concat_pmpcfg[`byte_57] = r_pmpcfg14[`byte_1];
                r_concat_pmpcfg[`byte_58] = r_pmpcfg14[`byte_2];
                r_concat_pmpcfg[`byte_59] = r_pmpcfg14[`byte_3];

                r_concat_pmpcfg[`byte_60] = r_pmpcfg15[`byte_0];
                r_concat_pmpcfg[`byte_61] = r_pmpcfg15[`byte_1];
                r_concat_pmpcfg[`byte_62] = r_pmpcfg15[`byte_2];
                r_concat_pmpcfg[`byte_63] = r_pmpcfg15[`byte_3];
            end

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

            for(i = 0 ; i < 64; i = i + 1) 
            begin
                r_pmpaddr[i] = 0;
            end

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

