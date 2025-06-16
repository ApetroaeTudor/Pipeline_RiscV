`timescale 1ns / 1ns

module ALU_pc_imm(
    input [31:0] imm32,
    input [31:0] pc,
    output reg [31:0] pc_imm
);
always @(*) begin
    pc_imm = pc + imm32; 
end
endmodule