`include "riscv_defines.vh"
module Mem_Instr_ROM#(
    parameter [1:0] XLEN = `XLEN_64b,
    parameter WIDTH = 8,
    parameter DEPTH = `TEXT_HI + 1
)(
    input i_rst,
    input [((1<<(XLEN+4))-1):0] i_adr,
    output [31:0] o_instr
);

    localparam LOAD_FILE = (XLEN==`XLEN_32b)?"./Mem_Files/instructions_32b.mem":"./Mem_Files/instructions_64b.mem";
    reg [WIDTH-1:0] r_mem_instr [DEPTH-1:0];

    assign {o_instr[`byte_3] , o_instr[`byte_2] , o_instr[`byte_1] , o_instr[`byte_0]} = 
           {r_mem_instr[i_adr+3] , r_mem_instr[i_adr+2] , r_mem_instr[i_adr+1] , r_mem_instr[i_adr]};

    
    reg [31:0] temp_mem [DEPTH-1:0];

    integer i;
        

    `ifdef DEBUG
          initial begin
            for(i=0;i<DEPTH;i = i+1)
            begin
                r_mem_instr[i] = 0;
                temp_mem[i] = 0;
            end

            if(XLEN == `XLEN_64b) $readmemh("./Mem_Files/instructions_64b.mem",temp_mem);
            else $readmemh("./Mem_Files/instructions_32b.mem",temp_mem);


            for(i=0; i< DEPTH<<2; i = i+1)
            begin
                r_mem_instr[ i*4 + 3 ] = temp_mem[i][31:24];
                r_mem_instr[ i*4 + 2 ] = temp_mem[i][23:16];
                r_mem_instr[ i*4 + 1 ] = temp_mem[i][15:8];
                r_mem_instr[ i*4 + 0 ] = temp_mem[i][7:0];
            end
        end
    `else 

        initial begin
            for(i=0;i<DEPTH;i = i+1)
            begin
                r_mem_instr[i] = 0;
                temp_mem[i] = 0;
            end
            $readmemh("./Asm_Code/startup.hex",temp_mem);
            for(i=0; i< DEPTH<<2; i = i+1)
            begin
                r_mem_instr[ i*4 + 0 ] = temp_mem[i][31:24];
                r_mem_instr[ i*4 + 1 ] = temp_mem[i][23:16];
                r_mem_instr[ i*4 + 2 ] = temp_mem[i][15:8];
                r_mem_instr[ i*4 + 3 ] = temp_mem[i][7:0];
            end
        end
    `endif

endmodule