`timescale 1ns / 1ns

module Instruction_Memory(
    input clk,
    input reset,
    input[31:0] addr,
    output reg[31:0] instruction
);

    reg[7:0]i_mem[1023:0];

    initial
    begin
        // addr0:
        // lw x1,0(x0)
        // lw x2,4(x0)
        // lw x3,8(x0)
        // sub x2,x2,x3
        // add x2,x2,x1
        // beq x2,x1,48 -> x2,x1,28
        // jal x8,96 -> x8,72
        // beq x2,x0,48 -> x2,x0,20
        
        // addr48:
        // or x2,x2,x1
        // and x2,x3,x2

        // addr96:
        // sub x2,x2,x3
        // sub x2,x2,x3
        // sw x1,12(x0)
        // jalr x8,x8,0

        i_mem[3] =8'h00 ; i_mem[2] =8'h00 ; i_mem[1] =8'h20 ; i_mem[0] =8'h83 ; // lw x1,0(x0)
        i_mem[7] =8'h00 ; i_mem[6] =8'h40 ; i_mem[5] =8'h21 ; i_mem[4] =8'h03 ;// lw x2,4(x0)
        i_mem[11] =8'h00 ; i_mem[10] =8'h80 ; i_mem[9] =8'h21 ; i_mem[8] =8'h83 ;// lw x3,8(x0)
        i_mem[15] =8'h40 ; i_mem[14] =8'h31 ; i_mem[13] =8'h01 ; i_mem[12] =8'h33 ;// sub x2,x2,x3
        i_mem[19] =8'h00 ; i_mem[18] =8'h11 ; i_mem[17] =8'h01 ; i_mem[16] =8'h33 ;// add x2,x2,x1
        i_mem[23] =8'h00 ; i_mem[22] =8'h11 ; i_mem[21] =8'h0d ; i_mem[20] =8'h63 ; // beq x2,x1,48 -> x2,x1,28
        i_mem[27] =8'h04 ; i_mem[26] =8'h80 ; i_mem[25] =8'h04 ; i_mem[24] =8'h6f ; // jal x8,96 -> x8,72
        i_mem[31] =8'h00 ; i_mem[30] =8'h01 ; i_mem[29] =8'h0a ; i_mem[28] =8'h63 ;// beq x2,x0,48 -> x2,x0,20

        i_mem[51] =8'h00 ; i_mem[50] =8'h11 ; i_mem[49] =8'h61 ; i_mem[48] =8'h33 ;// or x2,x2,x1
        i_mem[55] =8'h00 ; i_mem[54] =8'h21 ; i_mem[53] =8'hf1 ; i_mem[52] =8'h33 ;// and x2,x3,x2

        i_mem[99] =8'h40 ; i_mem[98] =8'h31 ; i_mem[97] =8'h01 ; i_mem[96] =8'h33 ; // sub x2,x2,x3
        i_mem[103] =8'h30 ; i_mem[102] =8'h31 ; i_mem[101] =8'h01 ; i_mem[100] =8'h33 ;// sub x2,x2,x3
        i_mem[107] =8'h00 ; i_mem[106] =8'h10 ; i_mem[105] =8'h26 ; i_mem[104] =8'h23 ;// sw x1,12(x0)
        i_mem[111] =8'h00 ; i_mem[110] =8'h04 ; i_mem[109] =8'h04 ; i_mem[108] =8'h67 ;// jalr x8,x8,0

    end


    always@(*)
    begin
        if(reset) instruction<=32'b0;
        else instruction<={i_mem[addr+3],i_mem[addr+2],i_mem[addr+1],i_mem[addr]};
    end



endmodule