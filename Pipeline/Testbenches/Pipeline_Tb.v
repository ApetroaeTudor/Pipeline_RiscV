`timescale 1ns / 1ns
`include "Constants.vh"
module Pipeline_Tb;
reg t_r_clk;
reg t_r_probe_clk;
reg t_r_rst;
reg t_r_btn_enable_d_s_o;
localparam XLEN = `XLEN_32b;
localparam SUPPORTED_EXTENSIONS = `SUPPORTED_EXTENSIONS;

reg t_r_assert_reg_final = 1'b1;
assert assert_reg_final_value(
                        .clk(t_r_clk),
                        .test(t_r_assert_reg_final)
                        );

Pipeline #(.XLEN(XLEN),
          .SUPPORTED_EXTENSIONS(SUPPORTED_EXTENSIONS)) 
              DUT(
             .i_clk(t_r_clk),
             .i_rst(t_r_rst),
             .i_btn_enable_d_s_o(t_r_btn_enable_d_s_o)
             );



always #5 t_r_clk = ~t_r_clk;
always #100 t_r_probe_clk = ~t_r_probe_clk;

`define dmem DUT.Data_Path_Inst.Mem_Data_Inst.r_mem_data
`define regs DUT.Data_Path_Inst.Reg_File_Inst.r_registers
`define csr_regs DUT.Data_Path_Inst.CSR_Unit_Inst.M_CSR_Reg_File_Inst
// `define csr_regs DUT.Data_Path_Inst.M_CSR_Reg_File_Inst

// `define test_reg 5
// `define csr_test_reg_1 `mstatus-12'h300
// `define csr_test_reg_2 `mstatush-12'h300


integer fd_reg_dump;
integer fd_mem_dump;
integer fd_csr_dump;

task dump_mem;
    input [(1<<(XLEN+4))-1:0] start_addr;
    input [(1<<(XLEN+4))-1:0] end_addr;
    integer i;
    begin
        $fdisplay(fd_mem_dump,"\n\nMEM AT TIME %0t: ",$time);
        for(i=start_addr;i<end_addr;i=i+4)
        begin
            $fdisplay(fd_mem_dump,"mem[%04h] = %h_%h_%h_%h",i,
            `dmem[i+3],
            `dmem[i+2],
            `dmem[i+1],
            `dmem[i]);
        end
    end

endtask

task dump_regs;
    integer i;
    begin
        $fdisplay(fd_reg_dump, "\n\nREGS AT TIME %0t: ",$time);
        for(i=0;i<`REG_CNT;i=i+1) begin
            if(XLEN == `XLEN_32b)
            begin
                $fdisplay(fd_reg_dump,"regs[%02d] = %h_%h_%h_%h",i,
                `regs[i][`byte_3],
                `regs[i][`byte_2],
                `regs[i][`byte_1],
                `regs[i][`byte_0]);
            end
            else
            begin
                $fdisplay(fd_reg_dump,"regs[%02d] = %h_%h_%h_%h_%h_%h_%h_%h",i,
                `regs[i][`byte_7],
                `regs[i][`byte_6],
                `regs[i][`byte_5],
                `regs[i][`byte_4],
                `regs[i][`byte_3],
                `regs[i][`byte_2],
                `regs[i][`byte_1],
                `regs[i][`byte_0]);
            end
        end
    end
endtask

task dump_csr_regs;
integer i;
    begin
        $fdisplay(fd_csr_dump, "\n\nCSR_REGS AT TIME %0t: ",$time);
        $fdisplay(fd_csr_dump, "mvendorid        = %h  %b", `csr_regs.r_mvendorid, `csr_regs.r_mvendorid);
        $fdisplay(fd_csr_dump, "marchid          = %h  %b", `csr_regs.r_marchid, `csr_regs.r_marchid);
        $fdisplay(fd_csr_dump, "mimpid           = %h  %b", `csr_regs.r_mimpid, `csr_regs.r_mimpid);
        $fdisplay(fd_csr_dump, "mhartid          = %h  %b", `csr_regs.r_mhartid, `csr_regs.r_mhartid);
        $fdisplay(fd_csr_dump, "mconfigptr       = %h  %b", `csr_regs.r_mconfigptr, `csr_regs.r_mconfigptr);

        $fdisplay(fd_csr_dump, "mstatus          = %h  %b", `csr_regs.r_mstatus, `csr_regs.r_mstatus);
        $fdisplay(fd_csr_dump, "misa             = %h  %b", `csr_regs.r_misa, `csr_regs.r_misa);
        $fdisplay(fd_csr_dump, "medeleg          = %h  %b", `csr_regs.r_medeleg, `csr_regs.r_medeleg);
        $fdisplay(fd_csr_dump, "mideleg          = %h  %b", `csr_regs.r_mideleg, `csr_regs.r_mideleg);
        $fdisplay(fd_csr_dump, "mie              = %h  %b", `csr_regs.r_mie, `csr_regs.r_mie);

        $fdisplay(fd_csr_dump, "mtvec            = %h  %b", `csr_regs.r_mtvec, `csr_regs.r_mtvec);
        $fdisplay(fd_csr_dump, "mcounteren       = %h  %b", `csr_regs.r_mcounteren, `csr_regs.r_mcounteren);
        $fdisplay(fd_csr_dump, "mstatush         = %h  %b", `csr_regs.r_mstatush, `csr_regs.r_mstatush);
        $fdisplay(fd_csr_dump, "mscratch         = %h  %b", `csr_regs.r_mscratch, `csr_regs.r_mscratch);
        $fdisplay(fd_csr_dump, "mepc             = %h  %b", `csr_regs.r_mepc, `csr_regs.r_mepc);

        $fdisplay(fd_csr_dump, "mcause           = %h  %b", `csr_regs.r_mcause, `csr_regs.r_mcause);
        $fdisplay(fd_csr_dump, "mtval            = %h  %b", `csr_regs.r_mtval, `csr_regs.r_mtval);
        $fdisplay(fd_csr_dump, "mip              = %h  %b", `csr_regs.r_mip, `csr_regs.r_mip);
        $fdisplay(fd_csr_dump, "mtinst           = %h  %b", `csr_regs.r_mtinst, `csr_regs.r_mtinst);
        $fdisplay(fd_csr_dump, "mtval2           = %h  %b", `csr_regs.r_mtval2, `csr_regs.r_mtval2);

        $fdisplay(fd_csr_dump, "menvcfg          = %h  %b", `csr_regs.r_menvcfg, `csr_regs.r_menvcfg);
        $fdisplay(fd_csr_dump, "menvcfgh         = %h  %b", `csr_regs.r_menvcfgh, `csr_regs.r_menvcfgh);
        $fdisplay(fd_csr_dump, "mseccfg          = %h  %b", `csr_regs.r_mseccfg, `csr_regs.r_mseccfg);
        $fdisplay(fd_csr_dump, "mseccfgh         = %h  %b", `csr_regs.r_mseccfgh, `csr_regs.r_mseccfgh);
        $fdisplay(fd_csr_dump, "pmpcfg0          = %h  %b", `csr_regs.r_pmpcfg0, `csr_regs.r_pmpcfg0);

        $fdisplay(fd_csr_dump, "pmpcfg1           = %h  %b", `csr_regs.r_pmpcfg1, `csr_regs.r_pmpcfg1);
        $fdisplay(fd_csr_dump, "pmpcfg2           = %h  %b", `csr_regs.r_pmpcfg2, `csr_regs.r_pmpcfg2);
        $fdisplay(fd_csr_dump, "pmpcfg3           = %h  %b", `csr_regs.r_pmpcfg3, `csr_regs.r_pmpcfg3);
        $fdisplay(fd_csr_dump, "pmpcfg4           = %h  %b", `csr_regs.r_pmpcfg4, `csr_regs.r_pmpcfg4);
        $fdisplay(fd_csr_dump, "pmpcfg5           = %h  %b", `csr_regs.r_pmpcfg5, `csr_regs.r_pmpcfg5);

        $fdisplay(fd_csr_dump, "pmpcfg6           = %h  %b", `csr_regs.r_pmpcfg6, `csr_regs.r_pmpcfg6);
        $fdisplay(fd_csr_dump, "pmpcfg7           = %h  %b", `csr_regs.r_pmpcfg7, `csr_regs.r_pmpcfg7);
        $fdisplay(fd_csr_dump, "pmpcfg8           = %h  %b", `csr_regs.r_pmpcfg8, `csr_regs.r_pmpcfg8);
        $fdisplay(fd_csr_dump, "pmpcfg9           = %h  %b", `csr_regs.r_pmpcfg9, `csr_regs.r_pmpcfg9);
        $fdisplay(fd_csr_dump, "pmpcfg10           = %h  %b", `csr_regs.r_pmpcfg10, `csr_regs.r_pmpcfg10);

        $fdisplay(fd_csr_dump, "pmpcfg11         = %h  %b", `csr_regs.r_pmpcfg11, `csr_regs.r_pmpcfg11);
        $fdisplay(fd_csr_dump, "pmpcfg12         = %h  %b", `csr_regs.r_pmpcfg12, `csr_regs.r_pmpcfg12);
        $fdisplay(fd_csr_dump, "pmpcfg13         = %h  %b", `csr_regs.r_pmpcfg13, `csr_regs.r_pmpcfg13);
        $fdisplay(fd_csr_dump, "pmpcfg14         = %h  %b", `csr_regs.r_pmpcfg14, `csr_regs.r_pmpcfg14);
        $fdisplay(fd_csr_dump, "pmpcfg15         = %h  %b", `csr_regs.r_pmpcfg15, `csr_regs.r_pmpcfg15);

        $fdisplay(fd_csr_dump, "\n");

        for( i = 0 ; i < 64 ; i = i + 1 )
        begin
            $fdisplay(fd_csr_dump,"pmpaddr[%0d]    = %h",i,`csr_regs.r_pmpaddr[i]);
        end

        

    end
endtask


always@(posedge t_r_probe_clk)
begin
    dump_regs();
    dump_csr_regs();
    dump_mem(`GLOBAL_LO - 32'h100000, `GLOBAL_LO+128 - 32'h100000);
end

initial
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Pipeline_Tb);

    fd_reg_dump = $fopen("./Dumps/reg_dumps.txt","w");
    if(fd_reg_dump == 0) $display("could not open reg dump file");

    fd_mem_dump = $fopen("./Dumps/mem_dumps.txt","w");
    if(fd_mem_dump == 0) $display("could not open mem dump file");

    fd_csr_dump = $fopen("./Dumps/csr_dumps.txt","w");
    if(fd_csr_dump == 0) $display("could not open csr dump file");

    t_r_clk=1'b1;
    t_r_probe_clk=1'b1;
    t_r_rst=1'b1;
    t_r_btn_enable_d_s_o=1'b0;

    #10
    t_r_btn_enable_d_s_o=1'b1;
    t_r_rst=1'b0;

    #3
    t_r_btn_enable_d_s_o=1'b0;


    #6990
    // t_r_assert_reg_final = (`regs[31] == 2);

    #7000
    $finish;
    $fclose(fd_reg_dump);  
    $fclose(fd_mem_dump);  
    $fclose(fd_csr_dump);

end

endmodule