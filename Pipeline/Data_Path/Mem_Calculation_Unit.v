`include "Constants.vh"
module Mem_Calculation_Unit#(
    parameter [1:0] XLEN = `XLEN_64b
)(
    input [((1<<(XLEN+4))-1):0] i_addr_m,
    output [((1<<(XLEN+4))-1):0] o_effective_addr_m,
    output o_dm_en
);


assign o_dm_en = i_addr_m[20];


assign o_effective_addr_m = (o_dm_en)?
    { {((1<<(XLEN+4))-20){1'b0}} ,i_addr_m[19:0]}:i_addr_m;

endmodule