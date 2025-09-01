`include "riscv_defines.vh"
module Branch_Decision(
    input i_alu_out_lsb_e,
    input [2:0] i_f3_e,
    input i_branch_e,
    input i_zero_e,

    output o_branch_taken_e
);

    reg r_branch_taken_e;
    assign o_branch_taken_e = r_branch_taken_e;

    always@(*)
    begin
        if(i_branch_e)
        begin
            casex(i_f3_e)
                `BEQ_F3:begin
                    if(i_zero_e) r_branch_taken_e = 1'b1;
                    else r_branch_taken_e = 1'b0;
                end
                `BNE_F3:begin
                    if(!i_zero_e) r_branch_taken_e = 1'b1;
                    else r_branch_taken_e = 1'b0;
                end
                `BLT_F3,`BLTU_F3:begin
                    if(i_alu_out_lsb_e) r_branch_taken_e = 1'b1;
                    else r_branch_taken_e = 1'b0;
                end
                `BGE_F3,`BGEU_F3:begin
                    if(!i_alu_out_lsb_e) r_branch_taken_e = 1'b1;
                    else r_branch_taken_e = 1'b0; 
                end
                default:begin
                    r_branch_taken_e = 1'b0;
                end
            endcase
        end
        else
        begin
            r_branch_taken_e = 1'b0;
        end
    end

endmodule