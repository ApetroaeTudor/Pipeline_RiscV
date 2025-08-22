// risc-v opcodes implemented
  `define OP_R_TYPE 7'b011_0011
  `define OP_I_TYPE_LW 7'b000_0011
  `define OP_I_TYPE_ADDI 7'b001_0011
  `define OP_I_TYPE_JALR 7'b110_0111
  `define OP_S_TYPE 7'b010_0011
  `define OP_J_TYPE 7'b110_1111
  `define OP_B_TYPE_BEQ 7'b110_0011
  `define OP_U_TYPE 7'b011_0111
  `define OP_I_TYPE_CSR 7'b111_0011
  `define OP_NOP 7'b000_0000


// mapped mem addresses 
// instr mem
  `define TRAP_LO 32'h0000_0000
  `define TRAP_HI 32'h0003_ffff
  `define RESET_LO 32'h0004_0000
  `define RESET_HI 32'h0007_fff
  `define TEXT_LO 32'h0008_0000
  `define TEXT_HI 32'h000b_ffff
// data mem
  `define GLOBAL_LO 32'h0010_0000
  `define GLOBAL_HI 32'h0013_ffff

  `define STACK_LO 32'h0014_0000
  `define STACK_HI 32'h0017_ffff

  `define CSR_STACK_LO 32'h0018_0000
  `define CSR_STACK_HI 32'h001b_ffff

  `define IO_LO 32'h001c_0000
  `define IO_HI 32'h001f_ffff

  `define TV_EN !addr_f[20] && !addr_f[19] && !addr_f[18]
  `define RV_EN !addr_f[20] && !addr_f[19] && addr_f[18]
  `define TXT_EN !addr_f[20] && addr_f[19] && !addr_f[18]

  `define GLB_EN addr_m[20] && !addr_m[19] && !addr_m[18]
  `define STK_EN addr_m[20] && !addr_m[19] && addr_m[18]
  `define CSR_STK_EN addr_m[20] && addr_m[19] && !addr_m[18]
  `define IO_EN addr_m[20] && addr_m[19] && addr_m[18]


  

// alu control
  `define ALU_OP_ADD 2'b00
  `define ALU_OP_SUB 2'b01
  `define ALU_OP_SPECIAL 2'b10
  `define ALU_OP_U_TYPE 2'b11

  `define ALU_CTL_ADD 3'b000
  `define ALU_CTL_SUB 3'b001
  `define ALU_CTL_SLT 3'b101
  `define ALU_CTL_OR 3'b011
  `define ALU_CTL_AND 3'b010
  `define ALU_CTL_U_EXTENSION 3'b110

// imm ctl
  `define IMM_I_TYPE 3'b000
  `define IMM_S_TYPE 3'b001
  `define IMM_B_TYPE 3'b010
  `define IMM_J_TYPE 3'b011
  `define IMM_U_TYPE 3'b100

// exception codes

  `define E_FETCH_ADDR_MISALIGNED 4'b0000
  `define E_ILLEGAL_INSTR 4'b0010 // detected in fetch

  `define E_SP_OUT_OF_RANGE 4'b0011
  `define E_LOAD_ADDR_MISALIGNED 4'b0100
  `define E_LOAD_ACCESS_FAULT 4'b0101
  `define E_STORE_ADDR_MISALIGNED 4'b0110
  `define E_STORE_ADDR_FAULT 4'b0111 // detected in execute

  `define E_ECALL 4'b1000 
  `define NO_E 4'b1111


  `define CSR_CONTROL_F3 3'b000
  `define CSR_CSRRW_F3 3'b001
  `define CSR_CSRRS_F3 3'b010
  `define CSR_CSRRC_F3 3'b011

  `define CSR_IMM_ECALL  12'd0
  `define CSR_IMM_MRET  12'd770 // rs1 and rd must also be 0;

// csr machine registers
  `define mstatus_lower 12'h300
  `define mie 12'h304
  `define mtvec 12'h305
  `define mstatus_upper 12'h310
  `define mscratch 12'h340
  `define mepc 12'h341
  `define mcause 12'h342
  `define mtval 12'h343

  `define mie_DEFAULT_VALUE 32'b0000_0000_0000_0000_0000_0000_1000_0010

// registers
  `define zero 5'b000_00 //x0
  `define ra 5'b000_01 //x1
  `define sp 5'b000_10 //x2
  `define gp 5'b000_11 //x3
  `define tp 5'b001_00 //x4
  `define t0 5'b001_01 //x5
  `define t1 5'b001_10 //x6
  `define t2 5'b001_11 //x7
  `define s0 5'b010_00 //x8
  `define s1 5'b010_01 //x9
  `define a0 5'b011_10 //x10
  `define a1 5'b010_11 //x11
  `define a2 5'b011_00 //x12
  `define a3 5'b011_01 //x13
  `define a4 5'b011_10 //x14
  `define a5 5'b011_11 //x15
  `define a6 5'b100_00 //x16
  `define a7 5'b100_01 //x17
  `define s2 5'b100_10 //x18
  `define s3 5'b100_11 //x19
  `define s4 5'b101_00 //x20
  `define s5 5'b101_01 //x21
  `define s6 5'b101_10 //x22
  `define s7 5'b101_11 //x23
  `define s8 5'b110_00 //x24
  `define s9 5'b110_01 //x25
  `define s10 5'b110_10 //x26
  `define s11 5'b110_11 //x27
  `define t3 5'b111_00 //x28
  `define t4 5'b111_01 //x29
  `define t5 5'b111_10 //x30
  `define t6 5'b111_11 //x31








