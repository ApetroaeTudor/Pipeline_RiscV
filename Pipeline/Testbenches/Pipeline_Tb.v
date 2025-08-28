`include "Constants.vh"
module Pipeline_Tb;
reg t_r_clk;
reg t_r_probe_clk;
reg t_r_rst;
reg t_r_btn_enable_d_s_o;
localparam XLEN = `XLEN_32b;

Pipeline #(.XLEN(XLEN)) DUT(
             .i_clk(t_r_clk),
             .i_rst(t_r_rst),
             .i_btn_enable_d_s_o(t_r_btn_enable_d_s_o)
             );



always #5 t_r_clk = ~t_r_clk;
always #100 t_r_probe_clk = ~t_r_probe_clk;

`define dmem DUT.Data_Path_Inst.Mem_Data_Inst.r_mem_data
`define regs DUT.Data_Path_Inst.Reg_File_Inst.r_registers
`define csr_regs DUT.Data_Path_Inst.M_CSR_Reg_File_Inst.r_csr_regs

// `define test_reg 5
// `define csr_test_reg_1 `mstatus-12'h300
// `define csr_test_reg_2 `mstatush-12'h300


integer fd_reg_dump;
integer fd_mem_dump;

task dump_mem;
    input [(1<<(XLEN+4))-1:0] start_addr;
    input [(1<<(XLEN+4))-1:0] end_addr;
    integer i;
    begin
        $fdisplay(fd_mem_dump,"\n\nMEM AT TIME %0t: ",$time);
        for(i=start_addr;i<end_addr;i=i+4)
        begin
            $fdisplay(fd_mem_dump,"mem[%04h] = %h_%h_%h_%h",i,
            `dmem[i],
            `dmem[i+1],
            `dmem[i+2],
            `dmem[i+3]);
        end
    end

endtask

task dump_regs;
    integer i;
    begin
        $fdisplay(fd_reg_dump, "\n\nREGS AT TIME %0t: ",$time);
        for(i=0;i<32;i=i+1) begin
            if(XLEN == `XLEN_32b)
            begin
                $fdisplay(fd_reg_dump,"regs[%04h] = %h_%h_%h_%h",i,
                `regs[i][`byte_3],
                `regs[i][`byte_2],
                `regs[i][`byte_1],
                `regs[i][`byte_0]);
            end
            else
            begin
                $fdisplay(fd_reg_dump,"regs[%08h] = %h_%h_%h_%h_%h_%h_%h_%h",i,
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
        $fdisplay(fd_reg_dump, "\n\nCSR_REGS AT TIME %0t: ",$time);
        for(i=0;i<69;i=i+1) begin
            if(XLEN == `XLEN_32b)
            begin
                $fdisplay(fd_reg_dump,"csr_regs[%04h] = %h_%h_%h_%h",i,
                `csr_regs[i][`byte_3],
                `csr_regs[i][`byte_2],
                `csr_regs[i][`byte_1],
                `csr_regs[i][`byte_0]);
            end
            else
            begin
                $fdisplay(fd_reg_dump,"csr_regs[%08h] = %h_%h_%h_%h_%h_%h_%h_%h",i,
                `csr_regs[i][`byte_7],
                `csr_regs[i][`byte_6],
                `csr_regs[i][`byte_5],
                `csr_regs[i][`byte_4],
                `csr_regs[i][`byte_3],
                `csr_regs[i][`byte_2],
                `csr_regs[i][`byte_1],
                `csr_regs[i][`byte_0]);
            end
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

    fd_reg_dump = $fopen("./Others/reg_dumps.txt","w");
    if(fd_reg_dump == 0) $display("could not open reg dump file");

    fd_mem_dump = $fopen("./Others/mem_dumps.txt","w");
    if(fd_mem_dump == 0) $display("could not open mem dump file");


    t_r_clk=1'b1;
    t_r_probe_clk=1'b1;
    t_r_rst=1'b1;
    t_r_btn_enable_d_s_o=1'b0;

    #10
    t_r_btn_enable_d_s_o=1'b1;
    t_r_rst=1'b0;

    #3
    t_r_btn_enable_d_s_o=1'b0;

    #10000
    $finish;
    $fclose(fd_reg_dump);  
    $fclose(fd_mem_dump);  

end

endmodule