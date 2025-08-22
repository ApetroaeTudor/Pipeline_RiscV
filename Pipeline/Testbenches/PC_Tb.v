module PC_Tb;
reg t_r_clk;
reg t_r_clk_en;
reg t_r_wr_en;
reg t_r_rst;
reg [31:0] t_r_di;

wire [31:0] t_w_do;

PC PC_Inst(.i_clk(t_r_clk),
           .i_clk_en(t_r_clk_en),
           .i_wr_en(t_r_wr_en),
           .i_rst(t_r_rst),
           .i_di(t_r_di),
           .o_do(t_w_do));

always #5 t_r_clk = ~t_r_clk;

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,PC_Tb);
    t_r_clk=1'b0;
    t_r_clk_en=1'b0;
    t_r_rst=1'b0;
    t_r_di=32'd12;
    t_r_wr_en=1'b1;

    #10
    t_r_clk_en=1'b1;
    t_r_rst=1'b1;

    #10
    t_r_rst=1'b0;

    #100
    $finish;
end

endmodule