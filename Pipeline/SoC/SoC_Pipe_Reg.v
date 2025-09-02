module SoC_Pipe_Reg#(
    parameter [1:0] XLEN = `XLEN_64b
)(
    input i_clk,
    input i_clk_en,
    input i_rst,

    input i_sw_e,
    input [((1<<(XLEN+4))-1):0] i_mem_data_e,
    input [((1<<(XLEN+4))-1):0] i_mem_addr_e,
    input i_store_byte_e,
    input i_store_half_e,


    output o_sw_m,
    output [((1<<(XLEN+4))-1):0] o_mem_data_m,
    output [((1<<(XLEN+4))-1):0] o_mem_addr_m,
    output o_store_byte_m,
    output o_store_half_m
);

    reg r_sw_m;
    assign o_sw_m = r_sw_m;

    reg [((1<<(XLEN+4))-1):0] r_mem_data_m;
    assign o_mem_data_m = r_mem_data_m;

    reg [((1<<(XLEN+4))-1):0] r_mem_addr_m;
    assign o_mem_addr_m = r_mem_addr_m;

    reg r_store_byte_m;
    assign o_store_byte_m = r_store_byte_m;

    reg r_store_half_m;
    assign o_store_half_m = r_store_half_m;

    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            r_sw_m <=0;
            r_mem_data_m<=0;
            r_mem_addr_m<=0;
            r_store_byte_m<=0;
            r_store_half_m<=0;
        end
        else if(i_clk_en)
        begin
            r_sw_m <=i_sw_e;
            r_mem_data_m<=i_mem_data_e;
            r_mem_addr_m<=i_mem_addr_e;
            r_store_byte_m<=i_store_byte_e;
            r_store_half_m<=i_store_half_e;
        end
    end
    

endmodule