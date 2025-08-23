`include "Constants.vh"
module Pipeline_Tb;
reg t_r_clk;
reg t_r_rst;
reg t_r_btn_enable_d_s_o;

always #5 t_r_clk = ~t_r_clk;

Pipeline DUT(.i_clk(t_r_clk),
             .i_rst(t_r_rst),
             .i_btn_enable_d_s_o(t_r_btn_enable_d_s_o));

`define dmem DUT.Data_Path_Inst.Mem_Data_Inst.r_mem_data
`define regs DUT.Data_Path_Inst.Reg_File_Inst.r_registers

`define test_reg 5

initial
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Pipeline_Tb);
    $monitor("mem[3]=%h; mem[2]=%h; mem[1]=%h; mem[0]=%h;",`dmem[3],`dmem[2],`dmem[1],`dmem[0]);

    $monitor("regs[%0d][3]=%h, regs[%0d][2]=%h, regs[%0d][1]=%h, regs[%0d][0]=%h",
    `test_reg,`regs[`test_reg][`byte_3],
    `test_reg,`regs[`test_reg][`byte_2],
    `test_reg,`regs[`test_reg][`byte_1],
    `test_reg,`regs[`test_reg][`byte_0]);



    t_r_clk=1'b1;
    t_r_rst=1'b1;
    t_r_btn_enable_d_s_o=1'b0;

    #10
    t_r_btn_enable_d_s_o=1'b1;
    t_r_rst=1'b0;
    #3
    t_r_btn_enable_d_s_o=1'b0;

    #1000
    $finish;    

end

endmodule