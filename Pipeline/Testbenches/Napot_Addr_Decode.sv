`include "riscv_defines.vh"

module Napot_Addr_Decode;


localparam XLEN = `XLEN_32b;

reg [31:0] r_pc_f = 32'h0000_0FFF;
reg [31:0] r_addr_cpy = 0;
reg r_addr_cpy_lsb = r_addr_cpy[0];
reg [31:0] r_sz = 0;

reg [31:0] r_addr_start = 0;
reg [31:0] r_addr_end = 0;

integer k;

initial begin
    r_addr_cpy = r_pc_f;
    for( k = 0 ; k < 32; k = k + 1)
    begin
        r_addr_cpy_lsb = r_addr_cpy[0];
        if(r_addr_cpy_lsb) 
        begin
             r_sz = r_sz+1;
        end
        r_addr_cpy = r_addr_cpy >>1;
    end
    r_sz = 1<<(r_sz+3);

    r_addr_start = (r_pc_f<<2) & ~(r_sz-1);
    r_addr_end = r_addr_start + r_sz;

    $display("Start Addr = %h; End Addr = %h; Size = %d", r_addr_start,r_addr_end,r_sz);

end


endmodule