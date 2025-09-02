module Mem_Mapper_Unit_Tb;

localparam [1:0] XLEN = `XLEN_32b;
localparam [((1<<(XLEN+4))-1):0] INSTR_ROM_START = `TRAP_LO;
localparam [((1<<(XLEN+4))-1):0] INSTR_ROM_END = `TEXT_HI;

localparam [((1<<(XLEN+4))-1):0] DATA_ROM_START = `ROM_DATA_LO;
localparam [((1<<(XLEN+4))-1):0] DATA_ROM_END = `ROM_DATA_HI;

localparam [((1<<(XLEN+4))-1):0] DATA_RAM_START = `GLOBAL_LO;
localparam [((1<<(XLEN+4))-1):0] DATA_RAM_END = `STACK_HI;

localparam [((1<<(XLEN+4))-1):0] IO_START = `IO_LO;
localparam [((1<<(XLEN+4))-1):0] IO_END = `IO_HI;


reg [((1<<(XLEN+4))-1):0] t_r_fetch_addr;
reg [((1<<(XLEN+4))-1):0] t_r_alu_out_e;
reg t_r_lw_e;
reg t_r_sw_e;



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
                                    .i_fetch_addr  (t_r_fetch_addr),
                                    .i_alu_out_e   (t_r_alu_out_e),
                                    .i_lw_e(t_r_lw_e),
                                    .i_sw_e (t_r_sw_e),
                                    
                                    .o_instr_rom_en(t_w_instr_rom_en),
                                    .o_data_rom_en(t_w_data_rom_en),
                                    .o_data_ram_en(t_w_data_ram_en),
                                    .o_io_en(t_w_io_en),
                                    .o_fetch_translated_addr(t_w_fetch_translated_addr),
                                    .o_ex_translated_addr(t_w_ex_translated_addr),
                                    .o_bad_addr_f(t_w_bad_addr_f),
                                    .o_bad_addr_load_e(t_w_bad_addr_load_e),
                                    .o_bad_addr_store_e(t_w_bad_addr_store_e)
                                );


reg t_r_instr_rom_en_expected;
reg t_r_data_rom_en_expected;
reg t_r_data_ram_en_expected;
reg t_r_io_en_expected;

reg [((1<<(XLEN+4))-1):0] t_r_fetch_translated_addr_expected;
reg [((1<<(XLEN+4))-1):0] t_r_ex_translated_addr_expected;

reg t_r_bad_addr_f_expected;
reg t_r_bad_addr_load_e_expected;
reg t_r_bad_addr_store_e_expected;



reg [((1<<(XLEN+4))-1):0] pc;
reg [((1<<(XLEN+4))-1):0] alu_out;
reg lw;
reg sw;


reg [2:0] lw_sw;      // 00 => lw=0, sw=0; etc
reg [2:0] alu_region; // 00 => instr rom, 01 => datarom; 10 => dataram; 11 =>io
reg [2:0] pc_region;  // the same

wire t_w_instr_rom_en;
wire t_w_data_rom_en;
wire t_w_data_ram_en;
wire t_w_io_en;
wire [((1<<(XLEN+4))-1):0] t_w_fetch_translated_addr;
wire [((1<<(XLEN+4))-1):0] t_w_ex_translated_addr;
wire t_w_bad_addr_f;
wire t_w_bad_addr_load_e;
wire t_w_bad_addr_store_e;


integer i;
initial
begin

for(i=0;i<100;i = i+1)
    begin
        for (pc_region = 0; pc_region < 4; pc_region = pc_region+1)
        begin
            casex(pc_region)
                2'b00: pc = INSTR_ROM_START + $urandom_range(0,INSTR_ROM_END);
                2'b01: pc = DATA_ROM_START + $urandom_range(0,DATA_ROM_END-DATA_ROM_START);
                2'b10: pc = DATA_RAM_START + $urandom_range(0,DATA_RAM_END-DATA_RAM_START);
                2'b11: pc = IO_START + $urandom_range(0,IO_END-IO_START);
                default: pc = INSTR_ROM_START + $urandom_range(0,INSTR_ROM_END);
            endcase


            for(alu_region = 0; alu_region < 4 ; alu_region = alu_region + 1)
            begin
                casex(alu_region)
                    2'b00: alu_out = INSTR_ROM_START + $urandom_range(0,INSTR_ROM_END);
                    2'b01: alu_out = DATA_ROM_START + $urandom_range(0,DATA_ROM_END-DATA_ROM_START);
                    2'b10: alu_out = DATA_RAM_START + $urandom_range(0,DATA_RAM_END-DATA_RAM_START);
                    2'b11: alu_out = IO_START + $urandom_range(0,IO_END-IO_START);
                    default: alu_out = INSTR_ROM_START + $urandom_range(0,INSTR_ROM_END);
                endcase




                for(lw_sw = 0; lw_sw < 4; lw_sw = lw_sw +1)
                begin

                    lw = lw_sw[0]; sw=lw_sw[1];

                    t_r_fetch_addr = pc;
                    t_r_alu_out_e = alu_out;
                    t_r_lw_e = lw;
                    t_r_sw_e = sw;

                    #10;

                    t_r_instr_rom_en_expected = (pc_region == 2'b00);
                    t_r_data_rom_en_expected = (alu_region == 2'b01);
                    t_r_data_ram_en_expected = (alu_region == 2'b10);
                    t_r_io_en_expected = (alu_region == 2'b11);

                    t_r_fetch_translated_addr_expected = t_r_fetch_addr;
                    t_r_ex_translated_addr_expected = (alu_region==2'b00)?(alu_out-INSTR_ROM_START):
                                                    (alu_region==2'b01)?(alu_out-DATA_ROM_START):
                                                    (alu_region==2'b10)?(alu_out-DATA_RAM_START):
                                                    (alu_region==2'b11)?(alu_out-IO_START):alu_out;

                    t_r_bad_addr_f_expected = !(pc_region == 2'b00);
                    t_r_bad_addr_load_e_expected = (alu_region==2'b00 && lw)?1'b1:
                                                (alu_region>3)?1'b1:1'b0;
                    t_r_bad_addr_store_e_expected = (alu_region==2'b00 && sw)?1'b1:
                                                    (alu_region==2'b01 && sw)?1'b1:
                                                    (alu_region>3)?1'b1:1'b0;


                    assert((t_r_instr_rom_en_expected == t_w_instr_rom_en) && 
                        (t_r_data_rom_en_expected == t_w_data_rom_en) &&
                        (t_r_data_ram_en_expected == t_w_data_ram_en) &&
                        (t_r_io_en_expected == t_w_io_en) &&
                        (t_r_fetch_translated_addr_expected == t_w_fetch_translated_addr) &&
                        (t_r_ex_translated_addr_expected == t_w_ex_translated_addr) &&
                        (t_r_bad_addr_f_expected == t_w_bad_addr_f) &&
                        (t_r_bad_addr_load_e_expected == t_w_bad_addr_load_e) &&
                        (t_r_bad_addr_store_e_expected == t_w_bad_addr_store_e)
                        )  else
                        $display("\nAssertion failed with the data:\nfetch_addr = %h, alu_out = %h, lw = %h, sw = %h\nEXPECTED  : instr_rom_en= %d, data_rom_en=%d, data_ram_en=%d, io_en=%d, fetch_trans=%h, ex_trans=%h, bad_addr_f=%d, bad_addr_load_e=%d, bad_addr_store=%d\nWHAT I GOT: instr_rom_en= %d, data_rom_en=%d, data_ram_en=%d, io_en=%d, fetch_trans=%h, ex_trans=%h, bad_addr_f=%d, bad_addr_load_e=%d, bad_addr_store=%d",
                                pc,alu_out,lw,sw,
                                t_r_instr_rom_en_expected, t_r_data_rom_en_expected,t_r_data_ram_en_expected,t_r_io_en_expected,t_r_fetch_translated_addr_expected,t_r_ex_translated_addr_expected,t_r_bad_addr_f_expected,t_r_bad_addr_load_e_expected,t_r_bad_addr_store_e_expected,
                                t_w_instr_rom_en,t_w_data_rom_en,t_w_data_ram_en,t_w_io_en,t_w_fetch_translated_addr,t_w_ex_translated_addr,t_w_bad_addr_f,t_w_bad_addr_load_e,t_w_bad_addr_store_e); 

                end
            end

        end
    end
#10
$finish;


end

endmodule