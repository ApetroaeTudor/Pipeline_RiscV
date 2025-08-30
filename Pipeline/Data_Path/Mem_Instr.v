`include "Constants.vh"

module Mem_Instr #(
    parameter [1:0]XLEN = `XLEN_64b
)(
    input i_rst,
    input [((1<<(XLEN+4))-1):0] i_adr,
    output [31:0] o_instr
);
    // memories should be smaller, and then the generated addresses should be converted to physical ones, by
    // a mem controller


    reg [7:0] r_mem_instr [(1<<20)-1:0]; // 2^20 -1 

    
    assign {o_instr[`byte_3] , o_instr[`byte_2] , o_instr[`byte_1] , o_instr[`byte_0]} = 
           {r_mem_instr[i_adr+3] , r_mem_instr[i_adr+2] , r_mem_instr[i_adr+1] , r_mem_instr[i_adr]};


    reg [31:0] temp_mem [(1<<20)-1:0];
    integer i;

    wire [31:0] w_40 = r_mem_instr[32'h0004_0000];
    wire [31:0] w_44 = r_mem_instr[32'h0004_0004];


    `ifdef DEBUG
          initial begin

           
            for(i=0;i<(1<<20);i=i+1)
            begin
                r_mem_instr[i]=0;
                temp_mem[i]=0;
            end

            if(XLEN == `XLEN_32b) $readmemh("./Mem_Files/instr_32b_simple.mem",temp_mem);
            else $readmemh("./Mem_Files/instructions_64b.mem",temp_mem);

            for(i=0; i< (1<<18); i = i+1)
            begin
                r_mem_instr[ i*4 + 3 ] = temp_mem[i][31:24];
                r_mem_instr[ i*4 + 2 ] = temp_mem[i][23:16];
                r_mem_instr[ i*4 + 1 ] = temp_mem[i][15:8];
                r_mem_instr[ i*4 + 0 ] = temp_mem[i][7:0];
            end
        end
    `else

        initial begin
            $readmemh("./Asm_Code/startup.hex",temp_mem);
            for(i=0; i< (1<<18); i = i+1)
            begin
                r_mem_instr[ i*4 + 0 ] = 0;
                r_mem_instr[ i*4 + 1 ] = 0;
                r_mem_instr[ i*4 + 2 ] = 0;
                r_mem_instr[ i*4 + 3 ] = 0;
            end
            for(i=0; i< (1<<18); i = i+1)
            begin
                r_mem_instr[ i*4 + 0 ] = temp_mem[i][31:24];
                r_mem_instr[ i*4 + 1 ] = temp_mem[i][23:16];
                r_mem_instr[ i*4 + 2 ] = temp_mem[i][15:8];
                r_mem_instr[ i*4 + 3 ] = temp_mem[i][7:0];
            end
        end
    `endif

endmodule