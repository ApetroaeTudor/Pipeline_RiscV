`include "riscv_defines.vh"
module PC#(
    parameter [1:0] XLEN = `XLEN_64b
)
(
    input i_clk,
    input i_clk_en,
    input i_wr_en,
    input i_rst,
    input [(1<<(XLEN+4))-1:0] i_di,

    input i_exception_f_stall,

    output [(1<<(XLEN+4))-1:0] o_do
);

    wire w_write_enable_final =  i_wr_en;
    reg [(1<<(XLEN+4))-1:0] r_pc = 0;
    assign o_do = r_pc;

    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            r_pc<=`RESET_LO;
        end
        else if(i_clk_en)
        begin
            if(w_write_enable_final)
            begin
                r_pc<=i_di;
            end
        end
    end
endmodule