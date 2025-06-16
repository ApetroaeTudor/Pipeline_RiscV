`timescale 1ns / 1ns

module Control(
    input[6:0] opcode,
    input[2:0] f3,
    input[6:0] f7,

    //wb
    output reg_write,
    output[1:0] mem_reg_pc,

    //mem
    output mem_read,
    output mem_write,
    output branch,
    output jl,
    output jlr,

    //ex
    output alu_src,
    output[1:0] alu_op
);

    //r types, lw, jal, jalr
    assign reg_write = (opcode == 7'b0110011) || // r
                    (opcode == 7'b0000011) || // lw
                    (opcode == 7'b1100111) || // jalr
                    (opcode == 7'b1101111); // jal
    //r types - 00, lw - 01, jal jalr - 10
    assign mem_reg_pc = (opcode == 7'b0110011)?2'b00:
                        (opcode == 7'b0000011)?2'b01:
                        ( opcode == 7'b1100111 ||
                          opcode == 7'b1101111 )?2'b10: 2'bxx;


    assign mem_read = (opcode == 7'b0000011); // lw
    assign mem_write = (opcode == 7'b0100011); // sw
    assign branch = (opcode == 7'b1100011); // beq
    assign jl = (opcode == 7'b1101111); // jal
    assign jlr = (opcode == 7'b1100111); // jalr

    assign alu_src = (opcode == 7'b0100011) || // sw
                     (opcode == 7'b0000011) || // lw
                     (opcode == 7'b1100111 ); // jalr
    assign alu_op = (opcode == 7'b0110011)?2'b10: // r
                    (opcode == 7'b1100011)?2'b01: // beq
                    (opcode == 7'b1101111)?2'bxx: 2'b00; // jal sau restul

endmodule