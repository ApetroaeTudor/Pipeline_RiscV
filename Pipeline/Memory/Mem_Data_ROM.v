`include "riscv_defines.vh"
module Mem_Data_ROM#(
    parameter [1:0] XLEN = `XLEN_64b,
    parameter WIDTH = 8,
    parameter DEPTH = `ROM_DATA_HI-`ROM_DATA_LO+1
)(
    input i_rst,
    input [((1<<(XLEN+4))-1):0] i_mem_addr,
    output [((1<<(XLEN+4))-1):0] o_mem_data
);
    localparam LOAD_FILE = "./Mem_Files/rom_data.mem";

    reg [WIDTH-1:0] r_mem_data [DEPTH-1:0];

    assign o_mem_data = (XLEN==`XLEN_64b)?{ r_mem_data[i_mem_addr+7]  ,  r_mem_data[i_mem_addr+6],  r_mem_data[i_mem_addr+5],  r_mem_data[i_mem_addr+4],
                                            r_mem_data[i_mem_addr+3],  r_mem_data[i_mem_addr+2],  r_mem_data[i_mem_addr+1],  r_mem_data[i_mem_addr+0]}:

                                          { r_mem_data[i_mem_addr+3]  ,  r_mem_data[i_mem_addr+2],  r_mem_data[i_mem_addr+1],  r_mem_data[i_mem_addr+0]};


    integer i;
    initial
    begin
        for(i=0;i<DEPTH;i=i+1)
        begin
            r_mem_data[i] = 0;
        end
        $readmemh(LOAD_FILE,r_mem_data);
    end

endmodule