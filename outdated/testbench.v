`timescale 1ns / 1ns


module testbench;
    reg clk;
    reg reset;

    wire[31:0] pc_out;
    wire[31:0] x1_out;
    wire[31:0] x2_out;
    wire[31:0] x3_out;
    wire[31:0] x8_out;
    wire[31:0] mem_addr_12_test;


    always #5
    begin
        clk=~clk;
    end

    TOP DUT(.clk(clk),
            .reset(reset),
            .pc_out(pc_out),
            .x1_out(x1_out),
            .x2_out(x2_out),
            .x3_out(x3_out),
            .x8_out(x8_out),
            .mem_addr_12_test(mem_addr_12_test));

    initial
    begin
        $dumpfile("waveform.vcd");
        $dumpvars(0,testbench);
        #0
        

        clk=1'b0;
        reset=1'b1;

        #10
        reset=1'b0;

        #1000

        #1000


        #1000
        $finish;
    end


endmodule