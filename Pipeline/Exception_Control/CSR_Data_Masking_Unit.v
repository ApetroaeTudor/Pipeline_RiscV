`include "riscv_defines.vh"

module CSR_Data_Masking_Unit#(
    parameter [1:0] XLEN = `XLEN_64b,
    parameter [25:0] SUPPORTED_EXTENSIONS = `SUPPORTED_EXTENSIONS
)(
    input [((1<<(XLEN+4))-1):0] i_new_csr,
    input [((1<<(XLEN+4))-1):0] i_old_csr,
    input [11:0] i_csr_addr,
    input [6:0] i_opcode_d,

    output [((1<<(XLEN+4))-1):0] o_masked_new_csr_write,
    output [((1<<(XLEN+4))-1):0] o_masked_old_csr_read
);
    integer i;

    reg [63:0] r_pmpaddr_lock = 64'b0;
    reg [11:0] r_pmpcfg_current = 0;
    reg [11:0] r_pmpaddr_current = 0;

    reg [((1<<(XLEN+4))-1):0] r_o_masked_new_csr_write;
    assign o_masked_new_csr_write = r_o_masked_new_csr_write;

    reg [((1<<(XLEN+4))-1):0] r_o_masked_old_csr_read;
    assign o_masked_old_csr_read = r_o_masked_old_csr_read;


    //read
    always@(*)
    begin
        if(i_opcode_d == `OP_I_TYPE_CSR)
        begin
            casex(i_csr_addr)
            `REG_MISA_ADDR:
            begin
                r_o_masked_old_csr_read[(1<<(XLEN+4))-1:(1<<(XLEN+4))-2] = (i_old_csr[(1<<(XLEN+4))-1:(1<<(XLEN+4))-2]==2'b01)?2'b01: // 32b
                                                                (i_old_csr[(1<<(XLEN+4))-1:(1<<(XLEN+4))-2]==2'b10)?2'b10: //64b
                                                                2'b01; // defaults to 32b // warl
                r_o_masked_old_csr_read[(1<<(XLEN+4))-3:26] = 0;
                r_o_masked_old_csr_read[25:0] = i_old_csr[25:0] & SUPPORTED_EXTENSIONS;
            end

            `REG_MTVEC_ADDR:
            begin
                r_o_masked_old_csr_read[(1<<(XLEN+4))-1:2] = i_old_csr & { {((1<<(XLEN+4))-2){1'b1}},2'b0 };
                r_o_masked_old_csr_read[1:0] = (i_old_csr[1:0]==00)?2'b00:
                                    (i_old_csr[1:0]==01)?2'b01:2'b00; // defaults to base
            end

            `REG_MSTATUSH_ADDR:
            begin
                if(XLEN == `XLEN_32b) r_o_masked_old_csr_read = i_old_csr;
                else r_o_masked_old_csr_read = 0;
            end

            `REG_MCAUSE_ADDR: //d
            begin
                r_o_masked_old_csr_read[(1<<(XLEN+4))-2:0] = legalize_exception_code(i_old_csr[(1<<(XLEN+4))-2:0]);
            end   

            `REG_MENVCFGH_ADDR: //
            begin   
                if(XLEN == `XLEN_32b) r_o_masked_old_csr_read = i_old_csr;
                else r_o_masked_old_csr_read = 0;
            end

            `REG_MSECCFGH_ADDR: //d
            begin
                if(XLEN == `XLEN_32b) r_o_masked_old_csr_read = i_old_csr;
                else r_o_masked_old_csr_read = 0;
            end   

            default:
            r_o_masked_old_csr_read = i_old_csr;


            endcase
        end
        else r_o_masked_old_csr_read = 0;

    end

    //writes

    always@(*)
    begin
        if(i_opcode_d == `OP_I_TYPE_CSR)
        begin
            casex(i_csr_addr)
            `REG_MSTATUS_ADDR:
            begin
                if(XLEN == `XLEN_64b) r_o_masked_new_csr_write = {
                                                           i_new_csr[63],
                                                           i_old_csr[62:43],
                                                           i_new_csr[42:32],
                                                           i_old_csr[31:25],
                                                           i_new_csr[24:1],
                                                           i_old_csr[0]
                                                           }; // wpri
                        else r_o_masked_new_csr_write = {
                                           i_new_csr[31],
                                           i_old_csr[30:25],
                                           i_new_csr[24:1],
                                           i_old_csr[0]
                                         }; //wpri

            end

            `REG_MSTATUSH_ADDR:    
                    begin 
                       if(XLEN == `XLEN_64b) r_o_masked_new_csr_write = 0;
                       else r_o_masked_new_csr_write = {
                                           i_old_csr[31:11],
                                           i_new_csr[10:4],
                                           i_old_csr[3:0] 
                                          }; //wpri
                    end

            `REG_MENVCFGH_ADDR, `REG_MSECCFGH_ADDR:
                    begin 
                        if(XLEN == `XLEN_64b) r_o_masked_new_csr_write = 0;
                       else r_o_masked_new_csr_write = i_new_csr;
                    end

            `REG_PMPCFG0_ADDR,`REG_PMPCFG1_ADDR,`REG_PMPCFG2_ADDR,`REG_PMPCFG3_ADDR,`REG_PMPCFG4_ADDR,
            `REG_PMPCFG5_ADDR,`REG_PMPCFG6_ADDR,`REG_PMPCFG7_ADDR,`REG_PMPCFG8_ADDR,`REG_PMPCFG9_ADDR,
            `REG_PMPCFG10_ADDR,`REG_PMPCFG11_ADDR,`REG_PMPCFG12_ADDR,`REG_PMPCFG13_ADDR,`REG_PMPCFG14_ADDR,
            `REG_PMPCFG15_ADDR:
            begin
                if(XLEN == `XLEN_64b) 
                begin //8 configs per pmpcfg
                    r_pmpcfg_current = i_csr_addr - `REG_PMPCFG0_ADDR;
                        
                    r_pmpaddr_lock[r_pmpcfg_current*8+0] = (i_new_csr[7] ==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*8+1] = (i_new_csr[15]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*8+2] = (i_new_csr[23]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*8+3] = (i_new_csr[31]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*8+4] = (i_new_csr[39]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*8+5] = (i_new_csr[47]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*8+6] = (i_new_csr[55]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*8+7] = (i_new_csr[63]==1'b1)?1'b1:1'b0;


                    r_o_masked_new_csr_write[`byte_7] = (i_old_csr[63]==1'b0)?i_new_csr[`byte_7]:i_old_csr[`byte_7] ;
                    r_o_masked_new_csr_write[`byte_6] = (i_old_csr[55]==1'b0)?i_new_csr[`byte_6]:i_old_csr[`byte_6] ;
                    r_o_masked_new_csr_write[`byte_5] = (i_old_csr[47]==1'b0)?i_new_csr[`byte_5]:i_old_csr[`byte_5] ;
                    r_o_masked_new_csr_write[`byte_4] = (i_old_csr[39]==1'b0)?i_new_csr[`byte_4]:i_old_csr[`byte_4] ;
                    r_o_masked_new_csr_write[`byte_3] = (i_old_csr[31]==1'b0)?i_new_csr[`byte_3]:i_old_csr[`byte_3] ;
                    r_o_masked_new_csr_write[`byte_2] = (i_old_csr[23]==1'b0)?i_new_csr[`byte_2]:i_old_csr[`byte_2] ;
                    r_o_masked_new_csr_write[`byte_1] = (i_old_csr[15]==1'b0)?i_new_csr[`byte_1]:i_old_csr[`byte_1] ;
                    r_o_masked_new_csr_write[`byte_0] = (i_old_csr[7] ==1'b0)?i_new_csr[`byte_0]:i_old_csr[`byte_0] ;
                end
                else //8 configs per pmpcfg
                begin
                    r_pmpcfg_current = i_csr_addr - `REG_PMPCFG0_ADDR;

                    r_pmpaddr_lock[r_pmpcfg_current*4+0] = (i_new_csr[7] ==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*4+1] = (i_new_csr[15]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*4+2] = (i_new_csr[23]==1'b1)?1'b1:1'b0;
                    r_pmpaddr_lock[r_pmpcfg_current*4+3] = (i_new_csr[31]==1'b1)?1'b1:1'b0;

                    r_o_masked_new_csr_write[`byte_3] = (i_old_csr[31]==1'b0)?i_new_csr[`byte_3]:i_old_csr[`byte_3] ;
                    r_o_masked_new_csr_write[`byte_2] = (i_old_csr[23]==1'b0)?i_new_csr[`byte_2]:i_old_csr[`byte_2] ;
                    r_o_masked_new_csr_write[`byte_1] = (i_old_csr[15]==1'b0)?i_new_csr[`byte_1]:i_old_csr[`byte_1] ;
                    r_o_masked_new_csr_write[`byte_0] = (i_old_csr[7] ==1'b0)?i_new_csr[`byte_0]:i_old_csr[`byte_0] ; // if the locked bit is set then dont write data
                    // the locked bit is set for each pmp entry
                end
            end

            default:
            begin
                if(i_csr_addr >= `REG_PMPADDR_BASE_ADDR && i_csr_addr <=`REG_PMPADDR_END_ADDR)
                    begin
                        r_pmpaddr_current = i_csr_addr-`REG_PMPADDR_BASE_ADDR;
                        
                        r_o_masked_new_csr_write = (r_pmpaddr_lock[r_pmpaddr_current]==1'b0)?i_new_csr:i_old_csr;

                    end
                else r_o_masked_new_csr_write = i_new_csr;
            end



            endcase
        end
        else r_o_masked_new_csr_write = 0;
    end



    function [(1<<(XLEN+4))-2:0] legalize_exception_code;
    input [(1<<(XLEN+4))-2:0] value;
    begin
        casex(value)
        {{((1<<(XLEN+4))-6){1'b0}},`E_FETCH_ADDR_MISALIGNED },
        {{((1<<(XLEN+4))-6){1'b0}},`E_ILLEGAL_INSTR },
        {{((1<<(XLEN+4))-6){1'b0}},`E_LOAD_ADDR_MISALIGNED },
        {{((1<<(XLEN+4))-6){1'b0}},`E_LOAD_ACCESS_FAULT },
        {{((1<<(XLEN+4))-6){1'b0}},`E_STORE_ACCESS_FAULT },
        {{((1<<(XLEN+4))-6){1'b0}},`E_STORE_ADDR_MISALIGNED },
        {{((1<<(XLEN+4))-6){1'b0}},`E_ECALL }: legalize_exception_code = value;
        default: legalize_exception_code = 0;
        endcase
    end
    endfunction



endmodule