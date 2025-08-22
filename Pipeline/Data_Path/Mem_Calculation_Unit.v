module Mem_Calculation_Unit(
    input [31:0] i_addr_m,
    output [31:0] o_effective_addr_m,
    output o_dm_en
);


assign o_dm_en = i_addr_m[20];


assign o_effective_addr_m = (o_dm_en)?
    {i_addr_m[31:20]&12'b0,i_addr_m[19:0]}:i_addr_m;

endmodule