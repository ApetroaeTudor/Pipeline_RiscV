`timescale 1ns / 1ns

module Imm_32(
    input[31:0] instruction,
    output[31:0] imm32
);

    assign imm32 = (instruction[6:0] == 7'b0000011)?{ {20{instruction[31]}}, instruction[31:20]}: // lw
                   (instruction[6:0] == 7'b1100011)?{ {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}: // beq
                   (instruction[6:0] == 7'b1101111)?{ {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 }: // jal
                   (instruction[6:0] == 7'b1100111)?{ {20{instruction[31]}}, instruction[31:20]}: // jalr
                   (instruction[6:0] == 7'b0100011)?{ {20{instruction[31]}}, instruction[31:25], instruction[11:7]}: // sw
                   32'b0; // r sau nedefinit
    
endmodule