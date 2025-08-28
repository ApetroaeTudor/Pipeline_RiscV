`include "Constants.vh"

module Mem_Instr #(
    parameter [1:0]XLEN = `XLEN_64b
)(
    input i_rst,
    input [((1<<(XLEN+4))-1):0] i_adr,
    output [31:0] o_instr
);

    reg [7:0] r_mem_instr [(1<<20)-1:0]; // 2^20 -1 

    
    assign {o_instr[`byte_3] , o_instr[`byte_2] , o_instr[`byte_1] , o_instr[`byte_0]} = 
           {r_mem_instr[i_adr+3] , r_mem_instr[i_adr+2] , r_mem_instr[i_adr+1] , r_mem_instr[i_adr]};


    integer i;

    `ifdef DEBUG
          initial begin
            for(i=0;i<(1<<20)-1;i=i+1)
            begin
                r_mem_instr[i]=0;
            end
            $readmemh("./Mem_Files/TRAP_VECTOR_TEST.mem",r_mem_instr);
        end
    `else
        reg [31:0] temp_mem [(1<<20)-1:0];

        initial begin
            $readmemh("./Asm_Code/startup.hex",temp_mem);
            for(i=0; i< (1<<20)-1; i = i+1)
            begin
                r_mem_instr[ i*4 + 0 ] = 0;
                r_mem_instr[ i*4 + 1 ] = 0;
                r_mem_instr[ i*4 + 2 ] = 0;
                r_mem_instr[ i*4 + 3 ] = 0;
            end
            for(i=0; i< (1<<20)-1; i = i+1)
            begin
                r_mem_instr[ i*4 + 0 ] = temp_mem[i][31:24];
                r_mem_instr[ i*4 + 1 ] = temp_mem[i][23:16];
                r_mem_instr[ i*4 + 2 ] = temp_mem[i][15:8];
                r_mem_instr[ i*4 + 3 ] = temp_mem[i][7:0];
            end
        end
    `endif

endmodule