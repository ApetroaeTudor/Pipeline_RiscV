`timescale 1ns / 1ns

module ALU_pc_inc(
    input[31:0] pc,
    output[31:0] pc_incremented
);
    assign pc_incremented = pc+4;

endmodule