module Mem_Instr(
    input i_rst,
    input [31:0] i_adr,
    output [31:0] o_instr
);

    reg [7:0] r_mem_instr [(1<<20)-1:0]; // 2^20 -1 

    reg [31:0] r_instr_out;
    assign {o_instr[31:24] , o_instr[23:16] , o_instr[15:8] , o_instr[7:0]} = 
           {r_mem_instr[i_adr+3] , r_mem_instr[i_adr+2] , r_mem_instr[i_adr+1] , r_mem_instr[i_adr]};


    reg [31:0] temp_mem [(1<<18)-1:0];

    integer i;
    initial begin
        $readmemh("./Asm_Code/startup.hex",temp_mem);
        for(i=0; i< (1<<18)-1; i = i+1)
        begin
            r_mem_instr[ i*4 + 0 ] = temp_mem[i][31:24];
            r_mem_instr[ i*4 + 1 ] = temp_mem[i][23:16];
            r_mem_instr[ i*4 + 2 ] = temp_mem[i][15:8];
            r_mem_instr[ i*4 + 3 ] = temp_mem[i][7:0];
        end
    end


endmodule