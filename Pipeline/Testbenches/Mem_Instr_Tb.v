module Mem_Instr_Tb;
reg t_r_rst;
reg [31:0] t_r_adr;
wire [31:0] t_w_instr;

Mem_Instr DUT(.i_rst(t_r_rst),
              .i_adr(t_r_adr),
              .o_instr(t_w_instr));

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,Mem_Instr_Tb);
    t_r_rst = 1'b1;
    t_r_adr = 32'h0;

    #10
    t_r_rst = 1'b0;
    
    repeat(11)
    begin
        t_r_adr = t_r_adr + 32'd4;
        #10;
    end

    #10
    t_r_adr = 32'h30;

    #10
    t_r_adr = 32'h34;

    #10
    t_r_adr = 32'h38;

    #10
    t_r_adr = 32'h3c;

    #10
    t_r_adr = 32'h40;

    #10
    t_r_adr = 32'h60;

    #10
    t_r_adr = 32'h64;

    #100
    $finish;
end


endmodule