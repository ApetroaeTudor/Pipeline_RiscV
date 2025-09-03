`include "riscv_defines.vh"
module Mem_Mapper_Unit#(
    parameter [1:0] XLEN = `XLEN_64b,
    parameter [((1<<(XLEN+4))-1):0] INSTR_ROM_START = `TRAP_LO,
    parameter [((1<<(XLEN+4))-1):0] INSTR_ROM_END = `TEXT_HI,
    parameter [((1<<(XLEN+4))-1):0] DATA_ROM_START = `ROM_DATA_LO,
    parameter [((1<<(XLEN+4))-1):0] DATA_ROM_END = `ROM_DATA_HI,
    parameter [((1<<(XLEN+4))-1):0] DATA_RAM_START = `GLOBAL_LO,
    parameter [((1<<(XLEN+4))-1):0] DATA_RAM_END = `M_STACK_HI,
    parameter [((1<<(XLEN+4))-1):0] IO_START = `IO_LO,
    parameter [((1<<(XLEN+4))-1):0] IO_END = `IO_HI
)(
    input [((1<<(XLEN+4))-1):0] i_fetch_addr,
    input [((1<<(XLEN+4))-1):0] i_alu_out_e,
    input i_lw_e,
    input i_sw_e,

    output o_instr_rom_en,
    output o_data_rom_en,
    output o_data_ram_en,
    output o_io_en,
    output [((1<<(XLEN+4))-1):0] o_fetch_translated_addr,
    output [((1<<(XLEN+4))-1):0] o_ex_translated_addr,
    output o_bad_addr_f,
    output o_bad_addr_load_e,
    output o_bad_addr_store_e
);


    wire w_fetch_addr_in_instr_rom = (INSTR_ROM_START<= i_fetch_addr) && (INSTR_ROM_END>= i_fetch_addr); //range is inclusive
    wire w_ex_addr_in_instr_rom = (INSTR_ROM_START<= i_alu_out_e) && (INSTR_ROM_END>= i_alu_out_e);
    wire w_ex_addr_in_data_rom = (DATA_ROM_START<=i_alu_out_e) && (DATA_ROM_END >=i_alu_out_e);
    wire w_ex_addr_in_data_ram = (DATA_RAM_START<=i_alu_out_e) && (DATA_RAM_END >=i_alu_out_e);
    wire w_ex_addr_in_io = (IO_START<=i_alu_out_e) && (IO_END >=i_alu_out_e);


    reg r_instr_rom_en;
    assign o_instr_rom_en = r_instr_rom_en;

    reg r_data_rom_en;
    assign o_data_rom_en = r_data_rom_en;

    reg r_data_ram_en;
    assign o_data_ram_en = r_data_ram_en;

    reg r_io_en;
    assign o_io_en = r_io_en;

    reg [((1<<(XLEN+4))-1):0] r_fetch_translated_addr;
    assign o_fetch_translated_addr = r_fetch_translated_addr;

    reg [((1<<(XLEN+4))-1):0] r_ex_translated_addr;
    assign o_ex_translated_addr = r_ex_translated_addr;


    reg r_bad_addr_f = 1'b0;
    assign o_bad_addr_f = r_bad_addr_f;

    reg r_bad_addr_load_e = 1'b0;
    assign o_bad_addr_load_e = r_bad_addr_load_e;

    reg r_bad_addr_store_e = 1'b0;
    assign o_bad_addr_store_e = r_bad_addr_store_e;


    always@(*)
    begin
        r_instr_rom_en=0;
        r_data_rom_en=0;
        r_data_ram_en=0;
        r_io_en=0;

        r_fetch_translated_addr = i_fetch_addr;
        r_ex_translated_addr = i_alu_out_e;
        
        if(w_fetch_addr_in_instr_rom)
        begin
            r_instr_rom_en = 1'b1;
        end

        if(w_ex_addr_in_data_rom)
        begin
            r_ex_translated_addr = i_alu_out_e - DATA_ROM_START;
            r_data_rom_en = 1'b1;
        end
        else if(w_ex_addr_in_data_ram)
        begin
            r_ex_translated_addr = i_alu_out_e - DATA_RAM_START;
            r_data_ram_en = 1'b1;
        end
        else if(w_ex_addr_in_io)
        begin
            r_ex_translated_addr = i_alu_out_e - IO_START;
            r_io_en = 1'b1;
        end
    end


 


    always@(*)
    begin
        r_bad_addr_f = 1'b0;
        r_bad_addr_load_e = 1'b0;
        r_bad_addr_store_e = 1'b0;

        if(!w_fetch_addr_in_instr_rom)
        begin
            r_bad_addr_f = 1'b1;
        end

        if(w_ex_addr_in_instr_rom)
        begin
            if(i_lw_e) // load in instr rom bad
            begin
                r_bad_addr_load_e = 1'b1;
            end
            if(i_sw_e) // store in instr rom bad
            begin
                r_bad_addr_store_e = 1'b1;
            end
        end
        else if(w_ex_addr_in_data_rom) // here only load words are permitted (reads, no execute, no write)
        begin
            if(i_sw_e) // store in data rom
            begin
                r_bad_addr_store_e = 1'b1;
            end
        end
        else if(w_ex_addr_in_data_ram) // rw
        begin
            if(i_lw_e)
            begin
                r_bad_addr_load_e = 1'b0;
            end
            if(i_sw_e)
            begin
                r_bad_addr_store_e = 1'b0;
            end
        end
        else if(w_ex_addr_in_io)
        begin
            if(i_lw_e)
            begin
                r_bad_addr_load_e = 1'b0;
            end
            if(i_sw_e)
            begin
                r_bad_addr_store_e = 1'b0;
            end
        end
        else
        begin
            if(i_lw_e)
            begin
                r_bad_addr_load_e = 1'b1;
            end
            if(i_sw_e)
            begin
                r_bad_addr_store_e = 1'b1;
            end
        end

    end

endmodule