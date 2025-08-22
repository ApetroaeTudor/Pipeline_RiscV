`timescale 1ns / 1ns

module PC(
    input clk,
    input reset,
    input[31:0]di,
    input pcw,
    output reg[31:0]do
);

    always@(posedge clk or posedge reset)
    begin
        if(reset) do<=32'b0;
        else if(pcw) do<=di;
    end

endmodule