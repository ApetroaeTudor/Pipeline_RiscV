# RISC-V Pipeline 
The implementation of this 5 stage pipeline processing unit is based on the single-cycle variant. Here the execution of the instruction is divided in 5 distinct stages, each one taking exactly one clock cycle.<br>
**The 5 stages are:**<br>
-> Instruction Fetch (IF)<br>
-> Instruction Decode (ID)<br>
-> Instruction Execution (EX)<br>
-> Memory access (M)<br>
-> Write-Back (WB)<br>

**Supported Instructions:**<br>
-> R type: add,sub,or,and,slt,sltu<br>
-> I type: addi, lw, lb, lh, lbu, lhu, jalr<br>
-> J type: jal<br>
-> S type: sw, sh, sb<br>
-> B type: beq, bne, blt, bge, bltu, bgeu<br>
-> U type: lui, auipc<br>
-> I type zicsr: csrrw, csrrs, csrrc, csrrwi(WIP), csrrsi(WIP), csrrci(WIP)<br>

**Memory Size:**<br>
-> Harvard architecture<br>
-> 2MiB total<br>
-> 1MiB rom (instruction memory), 1MiB ram (data memory)<br>
-> Currently memory restrictions are hardware-imposed. To implement: Physical memory protection registers.<br>
-> Current memory regions: <br>

TRAP_LO 32'h0000_0000 <br>
TRAP_HI 32'h0003_ffff <br>

RESET_LO 32'h0004_0000 <br>
RESET_HI 32'h0007_ffff <br>

TEXT_LO 32'h0008_0000 <br>
TEXT_HI 32'h000b_ffff <br>

GLOBAL_LO 32'h0010_0000 <br>
GLOBAL_HI 32'h0013_ffff <br>

STACK_LO 32'h0014_0000 <br>
STACK_HI 32'h0017_ffff <br>

CSR_STACK_LO 32'h0018_0000 <br>
CSR_STACK_HI 32'h001b_ffff <br>

IO_LO 32'h001c_0000 <br>
IO_HI 32'h001f_ffff <br>


### Implementation Details
![Implementation diagram](./Pipeline/Others/Pipeline.png)
The 5 stage pipeline structure is defined by the 4 stage-dividing registers, which store relevant data between clock cycles. In the diagram presented here, the data path is represented with black, and the various control signals that define the execution of certain instructions is represented with blue.<br>
A benefit of the pipelined architecture is that multiple instructions are executed simultaneously. At the same time, hazards can occur, causing incorrect program execution. The Hazard Unit, based on information that is already present in the pipeline, can detect these occurances. <br> <br>
**Some relevant hazards are:** <br>
-> Data Hazards (Read after Write, register use immediately after lw):<br>
**Forward if:**<br>
    1. A source register in execute-stage is the same as the destination register in memory-stage/decode-stage. (non csr)<br>
    2. A source register in decode-stage is the same as the destination register in write-back-stage (non csr)<br>
    3. The instruction in memory-stage/write-back-stage is csr-type and a source register in execute-stage is the same as the destination register in mem/wb (csr followed by normal)<br>
    4. The instruction in decode is csr-type and the instruction in ex/mem/wb is not csr and the source register in ex/mem/wb is the same as the destination in ex/mem/wb (normal followed by csr)<br>
    5. The instruction in ex/mem/wb is csr and the instruction in decode is csr, and the imm field in decode is the same as the imm field in ex/mem/wb (csr followed by csr)<br>
    6. The instruction in em/mem/wb is csr and the instruction in decode is csr, and the source register in decode is the same as the destination in ex/mem/wb (csr followed by csr)<br>
   Extra forwards are needed for csr type instructions because they don't fully share the same path with regular rv32i instructions (Different register file and 2 register writes).<br>
**Stall if:**<br>
    1. The instruction in execute takes data from memory, and the destination register in execute is the same as the source register in decode. This stalls the IF_ID register and the PC, inserting a bubble for one clock cycle.<br>
    2. An exception is detected in the fetch stage: IF_ID stall, because the opcode of the faulting instruction has to be in decode in order to decide new permissions.<br>
**Flush if:**<br>
    1. A load bubble was introduced (Flush ID_EX to prevent invalid data from propagating).<br>
    2. Mret instruction is in execute stage (Flush IF_ID and ID_EX to prevent the instructions in fetch and decode from executing).<br>
    3. A branch is taken or a j type instruction is in execute (Flush IF_ID and ID_EX)<br>
    4. An exception is detected in fetch and is now in decode (Flush IF_ID to clear the instruction that entered in fetch).<br>
    5. An exception is detected in execute and is now in mem-stage (Flush ID_EX and IF_ID).<br> <br>
-> Control Hazards (Not knowing whether a conditional branch is taken or not)<br>

**Detected Exceptions:** <br>
-> Fetch address misaligned (code 0) <br>
-> Illegal instruction (code 2) <br>
-> Sp out of range (code 3) <br>
-> Load address misalligned (code 4) <br>
-> Load access fault (code 5) <br>
-> Store address fault (code 6) <br>
-> Ecall (code 7) <br>
    Ecall uses the data in register a7 in order to execute a syscall. (WIP) <br>

**Exception Handling:** <br>
Upon detecting an exception the PC is updated to the beginning of the Trap Vector (addr 0x00000000 in rom instruction mem). Used registers are stored on the csr stack, and depending on the exception code found in the mcause register the code branches to the correct handler. After handling the exception the program either exits (goes into an infinite loop with no instructions) or returns to the value found in mepc (using mret).<br> <br>
-> Special csr registers:
1. mstatus lower <br>
2. mie <br>
3. mtvec <br>
4. mstatus upper <br>
5. mscratch <br>
6. mepc <br>
7. mcause <br>
8. mtval <br>
   
-> Entering the trap vector: <br>
1. mepc <= current PC <br>
2. mie <= 0 (interrupts disabled in trap vector **Interrupts are WIP**) <br>
3. mcause <= exception code (bit 31 = 1 for interrupt, 0 for exception) <br>
4. mtval <= additional exception info <br>
   
-> Exiting the trap vector: <br>
1. PC <= mepc
2. mie <= default interrupt permissions<br>



### Testing
![Testing waveform](./Pipeline/Others/waveform_1.png)
The code used for testing is written into the startup.s asm file. The memory regions are defined in the linker script. <br>
The create_hex.sh script takes in as a parameter the name of the asm source (no .s extension), and generates the little endian hex dump file. (assembler -> linker -> objcopy -> hexdump) <br>
The run_one.sh script compiles the .v code into a .out intermediate simulation executable, which is then run by the vvp runtime to run the simulation.<br>
The code loaded into the Instruction Memory covers arithmetic, logical, branch and memory instructions. There are cases that trigger data hazards, control hazards, and exceptions.<br>
Testing was done using Icarus Verilog and Gtkwave in Visual Studio Code.<br>
