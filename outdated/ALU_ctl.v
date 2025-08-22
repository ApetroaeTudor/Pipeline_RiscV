`timescale 1ns / 1ns

module ALU_ctl(
    input[1:0] alu_op,
    input f7_bit,
    input[2:0] f3,
    output reg[1:0] alu_signal
);
    // 00 - add -> 00
    // 01 - sub -> 01
    // 10 - add -> 00
    //    - sub -> 01
    //    - or  -> 10
    //    - and -> 11
    always@(*)
    begin
        if( alu_op == 2'b00 ) alu_signal = 2'b00;
        else if( alu_op == 2'b01 ) alu_signal = 2'b01;
        else if( alu_op == 2'b10 )
        begin
            casex(f3)
                3'b000: 
                begin
                    if( f7_bit == 1'b1 ) alu_signal=2'b01;
                    else if( f7_bit == 1'b0 ) alu_signal = 2'b00;
                    else alu_signal = 2'bxx; 
                end
                3'b110: alu_signal = 2'b10;
                3'b111: alu_signal = 2'b11;
                default: alu_signal = 2'bxx;
            endcase
        end
        else alu_signal<=2'bxx;
    end
    

endmodule