`include "riscv_defines.vh"

module SoC_TOP#(
    parameter [1:0]                 XLEN = `XLEN_64b,
    parameter [25:0]                SUPPORTED_EXTENSIONS = `SUPPORTED_EXTENSIONS,
    parameter                       ENABLED_PMP_REGISTERS = 12,

    parameter [((1<<(XLEN+4))-1):0] INSTR_ROM_START = `TRAP_LO,
    parameter [((1<<(XLEN+4))-1):0] INSTR_ROM_END = `TEXT_HI,
    parameter [((1<<(XLEN+4))-1):0] DATA_ROM_START = `ROM_DATA_LO,
    parameter [((1<<(XLEN+4))-1):0] DATA_ROM_END = `ROM_DATA_HI,
    parameter [((1<<(XLEN+4))-1):0] DATA_RAM_START = `GLOBAL_LO,
    parameter [((1<<(XLEN+4))-1):0] DATA_RAM_END = `M_STACK_HI,
    parameter [((1<<(XLEN+4))-1):0] IO_START = `IO_LO,
    parameter [((1<<(XLEN+4))-1):0] IO_END = `IO_HI



)(
    input i_clk,
    input i_rst,
    input i_btn_enable_d_s_o
);

    localparam DATA_UNIT = 8;

    reg r_clk_en = 1'b0;

    always@(posedge i_clk)
    begin
        if(i_btn_enable_d_s_o)
        r_clk_en<=~r_clk_en;
    end

    wire                       w_bad_addr_f;
    wire [31:0]                w_instr_f;
    wire [((1<<(XLEN+4))-1):0] w_fetch_addr_f;
    wire [((1<<(XLEN+4))-1):0] w_fetch_addr_translated_f;
    wire [((1<<(XLEN+4))-1):0] w_fetch_addr_selected_f;




    wire                       w_sw_e; 
    wire                       w_lw_e; 
    wire                       w_bad_addr_load_e;
    wire                       w_bad_addr_store_e;
    wire [((1<<(XLEN+4))-1):0] w_mem_addr_e; 
    wire [((1<<(XLEN+4))-1):0] w_mem_data_e; 
    wire                       w_store_byte_e; 
    wire                       w_store_half_e; 
    wire [((1<<(XLEN+4))-1):0] w_translated_addr_e; 

    wire                       w_sw_m; 
    wire [((1<<(XLEN+4))-1):0] w_mem_data_m; 
    wire                       w_store_byte_m; 
    wire                       w_store_half_m; 
    wire [((1<<(XLEN+4))-1):0] w_mem_addr_m;
    wire [((1<<(XLEN+4))-1):0] w_mem_data_rom_out_m;
    wire [((1<<(XLEN+4))-1):0] w_mem_data_ram_out_m;

    wire [((1<<(XLEN+4))-1):0] w_mem_data_selected_m;
    wire w_data_rom_en_m;
    wire w_data_ram_en_m;




    wire w_instr_rom_en;
    wire w_data_rom_en;
    wire w_data_ram_en;
    wire w_io_en;


    Core #(
                .XLEN(XLEN),
                .SUPPORTED_EXTENSIONS(SUPPORTED_EXTENSIONS),
                .ENABLED_PMP_REGISTERS(ENABLED_PMP_REGISTERS)
              )
              Core_Inst(
                            .i_clk(i_clk),
                            .i_rst(i_rst),
                            .i_btn_enable_d_s_o(i_btn_enable_d_s_o),
                            .i_clk_en(r_clk_en),
                            
                            //for mem rom/ram  
                            .o_mem_addr_e(w_mem_addr_e),
                            .o_mem_data_e(w_mem_data_e),
                            .o_store_byte_e(w_store_byte_e),
                            .o_store_half_e(w_store_half_e),
                            //from mem rom/ram
                            .i_mem_data_m(w_mem_data_selected_m), 

                            //from instr rom
                            .i_instr_f(w_instr_f), 

                            //for mem mapper
                            .o_fetch_addr_f(w_fetch_addr_f),
                            .o_lw_e(w_lw_e),
                            .o_sw_e(w_sw_e),
                            //from mem_mapper
                            .i_bad_addr_f(w_bad_addr_f),
                            .i_bad_addr_load_e(w_bad_addr_load_e),
                            .i_bad_addr_store_e(w_bad_addr_store_e)
                           );


   
    Mem_Mapper_Unit #(
                        .XLEN(XLEN),
                        .INSTR_ROM_START(INSTR_ROM_START),
                        .INSTR_ROM_END(INSTR_ROM_END),
                        .DATA_ROM_START(DATA_ROM_START),
                        .DATA_ROM_END(DATA_ROM_END),
                        .DATA_RAM_START(DATA_RAM_START),
                        .DATA_RAM_END(DATA_RAM_END),
                        .IO_START(IO_START),
                        .IO_END(IO_END)
                     )
                     Mem_Mapper_Unit_Inst(
                                          .i_fetch_addr(w_fetch_addr_f),
                                          .i_alu_out_e(w_mem_addr_e),
                                          .i_lw_e(w_lw_e),
                                          .i_sw_e(w_sw_e),

                                          .o_instr_rom_en(w_instr_rom_en),
                                          .o_data_rom_en(w_data_rom_en),
                                          .o_data_ram_en(w_data_ram_en),
                                          .o_io_en(w_io_en),
                                          .o_fetch_translated_addr(w_fetch_addr_translated_f),
                                          .o_ex_translated_addr(w_translated_addr_e),
                                          .o_bad_addr_f(w_bad_addr_f),
                                          .o_bad_addr_load_e(w_bad_addr_load_e),
                                          .o_bad_addr_store_e(w_bad_addr_store_e)
                                         );

    // i need to pipe the enable signals to read/write in memory stage

    SoC_Pipe_Reg #(
                    .XLEN(XLEN)
                  )
                  SoC_Pipe_Reg_Inst(
                                        .i_clk(i_clk),
                                        .i_clk_en(r_clk_en),
                                        .i_rst(i_rst),

                                        .i_sw_e(w_sw_e),
                                        .i_mem_data_e(w_mem_data_e),
                                        .i_mem_addr_e(w_translated_addr_e),
                                        .i_store_byte_e(w_store_byte_e),
                                        .i_store_half_e(w_store_half_e),
                                        .i_data_rom_en_e(w_data_rom_en),
                                        .i_data_ram_en_e(w_data_ram_en),
                                        

                                        .o_sw_m(w_sw_m),
                                        .o_mem_data_m(w_mem_data_m),
                                        .o_mem_addr_m(w_mem_addr_m),
                                        .o_store_byte_m(w_store_byte_m),
                                        .o_store_half_m(w_store_half_m),
                                        .o_data_rom_en_m(w_data_rom_en_m),
                                        .o_data_ram_en_m(w_data_ram_en_m)
                                   );




    Mem_Instr_ROM #(
                        .XLEN(XLEN),
                        .WIDTH(DATA_UNIT),
                        .DEPTH(`TEXT_HI+1)
                   )
                   Mem_Instr_ROM_Inst(
                                        .i_rst(i_rst),
                                        .i_adr(w_instr_rom_en?w_fetch_addr_selected_f:0),
                                        .o_instr(w_instr_f)
                                     );

    Mem_Data_ROM #(
                    .XLEN(XLEN),
                    .WIDTH(DATA_UNIT),
                    .DEPTH(`ROM_DATA_HI-`ROM_DATA_LO+1)
                  )
                  Mem_Data_ROM_Inst(
                                        .i_rst(i_rst),
                                        .i_mem_addr(w_data_rom_en_m?w_mem_addr_m:0),
                                        .o_mem_data(w_mem_data_rom_out_m)
                                   );

    Mem_Data_RAM #(
                        .XLEN(XLEN),
                        .WIDTH(DATA_UNIT),
                        .DEPTH(`M_STACK_HI-`GLOBAL_LO+1)
                  )
                  Mem_Data_RAM_Inst(
                                        .i_clk(i_clk),
                                        .i_clk_en(r_clk_en),
                                        .i_rst(i_rst),

                                        .i_mem_write(w_sw_m),
                                        .i_mem_addr(w_data_ram_en_m?w_mem_addr_m:0),
                                        .i_mem_data(w_mem_data_m),
                                        .i_store_byte(w_store_byte_m),
                                        .i_store_half(w_store_half_m),


                                        .o_mem_data(w_mem_data_ram_out_m)
                                   );

    


    assign w_mem_data_selected_m = (w_data_rom_en_m & ~w_data_ram_en)?w_mem_data_rom_out_m:
                                   (w_data_ram_en_m & ~w_data_rom_en)?w_mem_data_ram_out_m:0;


    assign w_fetch_addr_selected_f = (w_instr_rom_en)?w_fetch_addr_translated_f:0;
endmodule