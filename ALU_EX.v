`timescale 1ns / 1ns

module ALU_EX(
    input[31:0] op_a,
    input[31:0] op_b,
    input[1:0] alu_signal,
    

    output reg[31:0] alu_out,
    output zero
);

    // 00 - add -> 00
    // 01 - sub -> 01
    // 10 - add -> 00
    //    - sub -> 01
    //    - or  -> 10
    //    - and -> 11

    always@(*)
    begin
        casex(alu_signal)
            2'b00: alu_out = op_a+op_b;
            2'b01: alu_out = op_a - op_b;
            2'b10: alu_out = op_a | op_b;
            2'b11: alu_out = op_a & op_b;
        endcase
    end

    assign zero = (alu_out == 32'b0);



endmodule