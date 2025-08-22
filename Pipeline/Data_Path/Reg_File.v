module Reg_File(
    input i_clk,
    input i_clk_enable,
    input i_rst,
    input i_reg_write,
    input i_csr_reg_write,

    input [4:0] i_rd_addr_1,
    input [4:0] i_rd_addr_2,
    input [4:0] i_wr_addr,

    input [31:0] i_wr_data,
    
    output [31:0] o_rd_data_1,
    output [31:0] o_rd_data_2,

    output [31:0] o_x0_debug,
    output [31:0] o_x1_debug,
    output [31:0] o_x2_debug,
    output [31:0] o_x3_debug,
    output [31:0] o_x4_debug,
    output [31:0] o_x5_debug,
    output [31:0] o_x6_debug,
    output [31:0] o_x7_debug,
    output [31:0] o_x8_debug,
    output [31:0] o_x9_debug

);




    reg [31:0] r_registers [31:0];

    assign o_x0_debug = r_registers[0];
    assign o_x1_debug = r_registers[1];
    assign o_x2_debug = r_registers[2];
    assign o_x3_debug = r_registers[3];
    assign o_x4_debug = r_registers[4];
    assign o_x5_debug = r_registers[5];
    assign o_x6_debug = r_registers[6];
    assign o_x7_debug = r_registers[7];
    assign o_x8_debug = r_registers[8];
    assign o_x9_debug = r_registers[9];


    assign o_rd_data_1 = r_registers[i_rd_addr_1];
    assign o_rd_data_2 = r_registers[i_rd_addr_2];

    integer i;
    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            for(i=0;i<32;i=i+1)
            begin
                r_registers[i]<=32'b0;
            end
        end
        else if(i_clk_enable)
        begin
            if(i_reg_write || i_csr_reg_write)
            begin
                if(i_wr_addr!=0) 
                r_registers[i_wr_addr] <= i_wr_data;
            end
        end
    end

endmodule