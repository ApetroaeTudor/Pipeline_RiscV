module Pipeline_Tb;
reg t_r_clk;
reg t_r_rst;
reg t_r_btn_enable_d_s_o;

always #5 t_r_clk = ~t_r_clk;

Pipeline DUT(.i_clk(t_r_clk),
             .i_rst(t_r_rst),
             .i_btn_enable_d_s_o(t_r_btn_enable_d_s_o));

initial
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Pipeline_Tb);
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