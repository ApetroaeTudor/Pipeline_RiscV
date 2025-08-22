`include "Constants.vh"
module CSR_Behavior_Unit(
    input [6:0] i_opcode_d,
    input [2:0] i_f3_d,
    input [4:0] i_rd_d,
    input [4:0] i_rs1_d, // this is taken from the instruction encoding

    input [31:0] i_csr_d,
    input [11:0] i_imm_d,
    input [31:0] i_rs1_data,

    output o_csr_reg_write_d, // writes both in csr and reg file
    output [31:0] o_new_csr_d, // this will be taken from the imm field of the csr instr
    output [31:0] o_old_csr_d, // this will be written in the normal rd deduced from the i type instr 
    output [11:0] o_csr_rd_d, // imm in csr instr is csr addr in csr reg file
    //new csr goes in csr, old csr goes in regfile

    output o_ecall_d,
    output o_mret_d

); // is in decode 
// needs opcode to tell if its csr instr
// needs f3 
// needs imm number, NOT extended, 12 bits is enough


reg r_csr_reg_write_d = 0;
assign o_csr_reg_write_d = r_csr_reg_write_d;

reg [31:0] r_new_csr_d = 0;
assign o_new_csr_d = r_new_csr_d;

reg [31:0] r_old_csr_d = 0;
assign o_old_csr_d = r_old_csr_d;

reg [11:0] r_csr_rd_d = 0;
assign o_csr_rd_d = r_csr_rd_d;

reg r_ecall_d = 0;
assign o_ecall_d = r_ecall_d; // ecall signal is pipelined through to ex
// if ecall_e is asserted, then the ecall exception signal is set
// from here the pc will move to trap vector

reg r_mret_d = 0;
assign o_mret_d = r_mret_d; // mret signal is pipelined through to ex
// if mret_e is asserted, then the next pc is from mepc


// csr_rd_d is sent through the pipeline to WB
// new csr and old csr are sent through the pipeline to WB
// old csr is written into rd_w - reg file
// new csr is written into csr_rd_w

// csr_reg_write_w acts as a permission for both the reg file and the csr reg file
// in the normal reg file i also pass in csr_reg_write_w and trap_permission
        // both csr reg write and trap permissions must be asserted



always@(*)
begin
    if(i_opcode_d == `OP_I_TYPE_CSR)
    begin
        casex(i_f3_d)
        `CSR_CONTROL_F3: begin
            if(i_imm_d==12'd0 && (i_rs1_d==0) && (i_rd_d==0) ) begin // ecall
                r_csr_reg_write_d=0;
                r_new_csr_d=0;
                r_old_csr_d=0;
                r_csr_rd_d=0;
                r_ecall_d=1;
                r_mret_d=0;
            end
            else if( (i_imm_d==12'd770) && (i_rs1_d==0) && (i_rd_d==0) ) begin // mret
                r_csr_reg_write_d=0;
                r_new_csr_d=0;
                r_old_csr_d=0;
                r_csr_rd_d=0;
                r_ecall_d=0;
                r_mret_d=1;
            end
            else begin
                r_csr_reg_write_d=0;
                r_new_csr_d=0;
                r_old_csr_d=0;
                r_csr_rd_d=0;
                r_ecall_d=0;
                r_mret_d=0;
            end
        end
        `CSR_CSRRW_F3: begin
            r_csr_reg_write_d=1'b1;
            r_new_csr_d=i_rs1_data;
            r_old_csr_d=i_csr_d;
            r_csr_rd_d=i_imm_d;
            r_ecall_d=0;
            r_mret_d=0;
        end
        `CSR_CSRRS_F3: begin
            r_csr_reg_write_d=1'b1;
            r_new_csr_d=i_csr_d|i_rs1_data;
            r_old_csr_d=i_csr_d;
            r_csr_rd_d=i_imm_d;
            r_ecall_d=0;
            r_mret_d=0;
        end
        `CSR_CSRRC_F3: begin
            r_csr_reg_write_d=1'b1;
            r_new_csr_d = ((~i_rs1_data) &(i_csr_d));
            r_old_csr_d = i_csr_d;
            r_csr_rd_d = i_imm_d;
            r_ecall_d=0;
            r_mret_d=0;
        end
        default: begin
            r_csr_reg_write_d=0;
            r_new_csr_d=0;
            r_old_csr_d=0;
            r_csr_rd_d=0;
            r_ecall_d=0;
            r_mret_d=0;
        end
        endcase 
    end
    else
    begin
        r_csr_reg_write_d=0;
        r_new_csr_d=0;
        r_old_csr_d=0;
        r_csr_rd_d=0;
        r_ecall_d=0;
        r_mret_d=0;
    end
end

// instructions:
//1. ecall
//2. mcall
//3. csrrw rd,csr,rs1; rd<= csr; csr<=rs1
//4. csrrs rd,csr,rs1; rd<=csr; csr = csr | rs1;
//5. csrrc rd,csr,rs1; rd<=csr; csr = csr ~& rs1;
// 3+4+5 reg_write_exc_d = 1; csr_write_exc_d = 1, else 0



endmodule