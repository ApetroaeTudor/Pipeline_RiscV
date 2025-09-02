`include "riscv_defines.vh"
module Mem_Data_RAM#(
    parameter [1:0] XLEN = `XLEN_64b,
    parameter WIDTH = 8,
    parameter DEPTH = `STACK_HI - `GLOBAL_LO + 1 
)(
    input i_clk,
    input i_clk_en,
    input i_rst,

    input i_mem_write,
    input [((1<<(XLEN+4))-1):0] i_mem_addr,
    input [((1<<(XLEN+4))-1):0] i_mem_data,
    input i_store_byte,
    input i_store_half,


    output [((1<<(XLEN+4))-1):0] o_mem_data

   
);

    localparam LOAD_FILE = "./Mem_Files/ram_data.mem";

    reg [WIDTH-1:0] r_mem_data [DEPTH-1:0];
    assign o_mem_data = (XLEN==`XLEN_64b)?{ r_mem_data[i_mem_addr+7]  ,  r_mem_data[i_mem_addr+6],  r_mem_data[i_mem_addr+5],  r_mem_data[i_mem_addr+4],
                                            r_mem_data[i_mem_addr+3],  r_mem_data[i_mem_addr+2],  r_mem_data[i_mem_addr+1],  r_mem_data[i_mem_addr+0]}:

                                          { r_mem_data[i_mem_addr+3]  ,  r_mem_data[i_mem_addr+2],  r_mem_data[i_mem_addr+1],  r_mem_data[i_mem_addr+0]};



    integer i;
    initial
    begin
        for(i=0;i<DEPTH-1;i=i+1)
        begin
            r_mem_data[i]=8'h00;
        end
        $readmemh(LOAD_FILE,r_mem_data); // in the final version the ram should be empty
    end
    

    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            for(i=0;i<DEPTH-1;i=i+1)
            begin
                r_mem_data[i]=8'h00;
            end
        end
        else if(i_clk_en)
        begin
            if(i_mem_write)
            begin
                if(i_store_byte) begin
                    r_mem_data[i_mem_addr] <= i_mem_data[`byte_0];
                end
                else if(!i_store_byte && i_store_half) begin
                    r_mem_data[i_mem_addr] <= i_mem_data[`byte_0];
                    r_mem_data[i_mem_addr+1] <= i_mem_data[`byte_1];
                end
                else begin
                    r_mem_data[i_mem_addr] <= i_mem_data[`byte_0];
                    r_mem_data[i_mem_addr+1] <= i_mem_data[`byte_1];
                    r_mem_data[i_mem_addr+2] <= i_mem_data[`byte_2];
                    r_mem_data[i_mem_addr+3] <= i_mem_data[`byte_3];
                end
                
                
                
            end
        end

    end


endmodule