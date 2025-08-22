module Mem_Data(
    input i_clk,
    input i_clk_enable,
    input i_rst,
    input i_mem_write,
    input [31:0] i_mem_addr,
    input [31:0] i_mem_data,
    output [31:0] o_mem_data

);

    reg [7:0] r_mem_data [(1<<20)-1:0];

    assign {o_mem_data[7:0] , o_mem_data[15:8] , o_mem_data[23:16] , o_mem_data[31:24] } = 
           {r_mem_data[i_mem_addr] , r_mem_data[i_mem_addr+1] , r_mem_data[i_mem_addr+2] , r_mem_data[i_mem_addr+3]};

    
    integer i;
    initial
    begin
        for(i=0;i<(1<<20)-1;i=i+1)
        begin
            r_mem_data[i]=8'h00;
        end
        $readmemh("./Mem_Files/MEM_AREAS_TEST.mem",r_mem_data);
    end

    always@(posedge i_clk)
    begin
        if(i_rst)
        begin
            // data mem

        end
        else if(i_clk_enable)
        begin
            if(i_mem_write)
            begin
                r_mem_data[i_mem_addr] <= i_mem_data[7:0];
                r_mem_data[i_mem_addr+1] <= i_mem_data[15:8];
                r_mem_data[i_mem_addr+2] <= i_mem_data[23:16];
                r_mem_data[i_mem_addr+3] <= i_mem_data[31:24];
            end
        end

    end

endmodule