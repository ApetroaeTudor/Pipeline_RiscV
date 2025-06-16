`timescale 1ns / 1ns

module Forwarding_Unit(
    input[4:0] id_ex_rs1,
    input[4:0] id_ex_rs2,
    input[4:0] ex_mem_rd,
    input[4:0] mem_wb_rd,

    input ex_mem_reg_write,
    input mem_wb_reg_write,

    //10 e hazard ex
    //01 e hazard mem
    //00 NU e hazard
    output reg[1:0] forward_a,
    output reg[1:0] forward_b
);

    always@(*)
    begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        
        if(ex_mem_reg_write &&
          ex_mem_rd!=5'b0 &&
          id_ex_rs1 == ex_mem_rd) forward_a =2'b10;
        else if(mem_wb_reg_write &&
                mem_wb_rd!=5'b0 &&
                !(ex_mem_reg_write &&
                  ex_mem_rd!=5'b0 &&
                  ex_mem_rd==id_ex_rs1)&&
                mem_wb_rd == id_ex_rs1) forward_a=2'b01;
        
        if( ex_mem_reg_write &&
            ex_mem_rd!=5'b0 &&
            id_ex_rs2 == ex_mem_rd ) forward_b=2'b10;
        else if( mem_wb_reg_write &&
                 mem_wb_rd!=5'b0 &&
                 !(ex_mem_reg_write &&
                   ex_mem_rd!=0 &&
                   ex_mem_rd == id_ex_rs2) &&
                 mem_wb_rd == id_ex_rs2  ) forward_b=2'b01;
    end

endmodule