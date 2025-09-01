`include "riscv_defines.vh"
module Mem_Data#(
    parameter [1:0] XLEN = `XLEN_64b
)(
    input i_clk,
    input i_clk_enable,
    input i_rst,
    input i_mem_write,
    input [((1<<(XLEN+4))-1):0] i_mem_addr,
    input [((1<<(XLEN+4))-1):0] i_mem_data,
    output [((1<<(XLEN+4))-1):0] o_mem_data,

    input i_store_byte,
    input i_store_half

);

    reg [7:0] r_mem_data [(1<<20)-1:0];


    assign o_mem_data = (XLEN==`XLEN_64b)?{ r_mem_data[i_mem_addr+7]  ,  r_mem_data[i_mem_addr+6],  r_mem_data[i_mem_addr+5],  r_mem_data[i_mem_addr+4],
                                            r_mem_data[i_mem_addr+3],  r_mem_data[i_mem_addr+2],  r_mem_data[i_mem_addr+1],  r_mem_data[i_mem_addr+0]}:

                                          { r_mem_data[i_mem_addr+3]  ,  r_mem_data[i_mem_addr+2],  r_mem_data[i_mem_addr+1],  r_mem_data[i_mem_addr+0]};

    
    integer i;
    initial
    begin
        for(i=0;i<(1<<20)-1;i=i+1)
        begin
            r_mem_data[i]=8'h00;
        end
        $readmemh("./Mem_Files/MEM_AREAS_TEST.mem",r_mem_data);
    end

    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            // data mem

        end
        else if(i_clk_enable)
        begin
            if(i_mem_write)
            begin
                if(i_store_byte) begin
                    r_mem_data[i_mem_addr] <= i_mem_data[7:0];
                end
                else if(!i_store_byte && i_store_half) begin
                    r_mem_data[i_mem_addr] <= i_mem_data[7:0];
                    r_mem_data[i_mem_addr+1] <= i_mem_data[15:8];
                end
                else begin
                    r_mem_data[i_mem_addr] <= i_mem_data[7:0];
                    r_mem_data[i_mem_addr+1] <= i_mem_data[15:8];
                    r_mem_data[i_mem_addr+2] <= i_mem_data[23:16];
                    r_mem_data[i_mem_addr+3] <= i_mem_data[31:24];
                end
                
                
                
            end
        end

    end

endmodule