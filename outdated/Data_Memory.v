`timescale 1ns / 1ns

module Data_Memory(
    input clk,
    input reset,

    input mem_read,
    input mem_write,

    input [31:0] addr,
    input [31:0] data_to_write,

    output reg[31:0] data_out,

    output[31:0] mem_addr_12
);

    assign mem_addr_12 = {data_memory[15],data_memory[14],data_memory[13],data_memory[12]};
    reg[7:0] data_memory[1023:0];

    initial 
    begin
        data_memory[3] = 8'h00 ; data_memory[2] = 8'h00 ; data_memory[1] = 8'h00 ; data_memory[0] = 8'h01 ;
        data_memory[7] = 8'h00 ; data_memory[6] = 8'h00 ; data_memory[5] = 8'h00 ; data_memory[4] = 8'h05 ;
        data_memory[11] = 8'h00 ; data_memory[10] = 8'h00 ; data_memory[9] = 8'h00 ; data_memory[8] = 8'h02 ;
    end

    always@(posedge clk)
    begin
        if(reset) data_out<=32'b0;
        else if(mem_read) data_out <= {data_memory[addr+3],data_memory[addr+2],data_memory[addr+1],data_memory[addr]};
        else if(mem_write)
        begin
	        data_memory[addr+3] 	<= data_to_write[31:24];
	        data_memory[addr+2] 	<= data_to_write[23:16];
	        data_memory[addr+1] 	<= data_to_write[15:8];
	        data_memory[addr+0] 	<= data_to_write[7:0];	
        end
        
    end

endmodule