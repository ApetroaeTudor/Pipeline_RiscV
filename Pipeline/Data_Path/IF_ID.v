module IF_ID(
    input i_clk,
    input i_rst,
    input i_clk_en,


    input i_if_id_flush_exception_m, // signal emitted by ex_mem reg after a valid exception was entered
    input i_if_id_stall,
    input i_if_id_flush,
    input i_exception_f_stall,

    input [31:0] i_instr_f,
    input [31:0] i_pc_p4_f,
    input [31:0] i_pc_f,
    input [3:0] i_exception_code_f,

    output [31:0] o_pc_d,
    output [31:0] o_instr_d,
    output [31:0] o_pc_p4_d

);

    wire w_if_id_final_flush;
    assign w_if_id_final_flush = i_if_id_flush || (w_exception_code_f_d!=`NO_E) || i_if_id_flush_exception_m;


    wire w_if_id_final_stall;
    assign w_if_id_final_stall = i_exception_f_stall || i_if_id_stall;

    reg [31:0] r_pc_d;
    assign o_pc_d = r_pc_d;
    reg [31:0] r_instr;
    assign o_instr_d = r_instr;
    reg [31:0] r_pc_p4;
    assign o_pc_p4_d = r_pc_p4;

    reg [3:0] r_exception_code_f_d;
    wire [3:0] w_exception_code_f_d;
    assign w_exception_code_f_d = r_exception_code_f_d;

    always@(posedge i_clk)
    begin
        if(i_rst||w_if_id_final_flush)
        begin // if the exception code for a fetch exception then flush
            r_instr<=0;
            r_pc_p4<=0;
            r_pc_d<=0;
            r_exception_code_f_d<=`NO_E;
        end
        else
        begin
            if(i_clk_en && !w_if_id_final_stall)
            begin
                r_instr<=i_instr_f;
                r_pc_p4<=i_pc_p4_f;
                r_pc_d<=i_pc_f;
                r_exception_code_f_d<=i_exception_code_f;
            end
        end
    end


endmodule