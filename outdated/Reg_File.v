`timescale 1ns / 1ns

module Reg_File(
    input clk,
    input reset,
    input[4:0] read_addr_1,
    input[4:0] read_addr_2,
    input[4:0] write_addr,
    input[31:0] write_data,
    input reg_write,

    output [31:0] data_out_1,
    output [31:0] data_out_2,


    output [31:0] x1_out,
    output [31:0] x2_out,
    output [31:0] x3_out,
    output [31:0] x8_out
);

    reg[31:0] registers[31:0];

    assign data_out_1 = (read_addr_1==5'b0)?32'b0:registers[read_addr_1];
    assign data_out_2 = (read_addr_2==5'b0)?32'b0:registers[read_addr_2];
    integer i;

    always@(posedge clk)
    begin

        if(reset) 
        begin 
            for(i = 0; i < 32; i = i + 1)
            begin
                registers[i]<=32'b0;
            end
        end
        else if(reg_write && write_addr!=5'b0) registers[write_addr] <= write_data;

    end


    assign x1_out = registers[1];
    assign x2_out = registers[2];
    assign x3_out = registers[3];
    assign x8_out = registers[8];

endmodule