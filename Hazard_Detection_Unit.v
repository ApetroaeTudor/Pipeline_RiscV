`timescale 1ns / 1ns

module Hazard_Detection_Unit(
    input id_ex_mem_read,
    input [4:0] id_ex_rd,
    input [4:0] if_id_rs1,
    input [4:0] if_id_rs2,
    output reg if_id_write,
    output reg id_ex_flush,
    output reg pc_write
);

always @(*) begin
    if (id_ex_mem_read && (id_ex_rd != 0) && 
        ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
        if_id_write = 0;
        pc_write = 0;
        id_ex_flush = 1;
    end
    else begin
        if_id_write = 1;
        pc_write = 1;
        id_ex_flush = 0;
    end
end
endmodule