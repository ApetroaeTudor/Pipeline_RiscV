module Mem_Calculation_Unit_Tb;
reg [31:0] t_r_addr;
wire [31:0] t_w_effective_addr;

wire t_w_tv_en;
wire t_w_rv_en;
wire t_w_txt_en;

wire t_w_glb_en;
wire t_w_stk_en;
wire t_w_io_en;

Mem_Calculation_Unit DUT(.i_addr_m(t_r_addr),
                         .o_effective_addr_m(t_w_effective_addr),
                         .o_tv_en(t_w_tv_en),
                         .o_rv_en(t_w_rv_en),
                         .o_txt_en(t_w_txt_en),
                         .o_glb_en(t_w_glb_en),
                         .o_stk_en(t_w_stk_en),
                         .o_io_en(t_w_io_en));

initial
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Mem_Calculation_Unit_Tb);
    t_r_addr=32'h0000_0000;

    #10
    t_r_addr=32'h0004_0000;
    #10
    t_r_addr=32'h0007_ffff;

    #10
    t_r_addr=32'h0008_0000;
    #10
    t_r_addr=32'h0008_0004;
    #10
    t_r_addr=32'h000b_ffff;

    #10
    t_r_addr=32'h0010_0000;
    #10
    t_r_addr=32'h0013_ffff;

    #10
    t_r_addr=32'h0014_0000;
    #10
    t_r_addr=32'h0017_ffff;

    #10
    t_r_addr=32'h0018_0000;
    #10
    t_r_addr=32'h0018_0010;
    #10
    t_r_addr=32'h001c_0011;
    #10
    t_r_addr=32'h001f_ffff;
    #100
    $finish;

end



endmodule