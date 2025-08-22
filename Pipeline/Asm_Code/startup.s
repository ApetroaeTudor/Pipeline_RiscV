
.section .reset_vector, "ax"
.globl _start

_start:
    lui x2,%hi(_stack_top)
    addi x2,x2,%lo(_stack_top)
    lui x3,0x00120
    lui x5, %hi(_txt_start)
    addi x5, x5,%lo(_txt_start)
    jalr x0,0(x5)

.section .trap_vector, "ax"
.global trap_handler

trap_handler:

    csrrs t0,mscratch,x0
    addi t0,t0,-16
    sw t1, 0(t0)
    sw t2, 4(t0)
    sw a7, 8(t0)
    sw a0, 12(t0)

    csrrs t1,mcause,x0  # in t1 i put mcause without changing mcause
    addi t2,x0,0 

    beq t1,t2, fetch_addr_mis #-> 0
    addi t2,t2,2
    beq t1,t2, illegal_instr #-> 2
    addi t2,t2,1
    beq t1,t2, sp_out_of_range #-> 3
    addi t2,t2,1
    beq t1,t2, load_addr_mis #-> 4
    addi t2,t2,1
    beq t1,t2, load_access_fault #-> 5
    addi t2,t2,1
    beq t1,t2, store_addr_mis #-> 6
    addi t2,t2,1
    beq t1,t2, store_addr_fault #-> 7
    addi t2,t2,1
    beq t1,t2, ecall #-> 8

done:

    lw t1, 0(t0)
    lw t2, 4(t0)
    lw a7, 8(t0)
    lw a0, 12(t0)
    addi t0,t0,16
    csrrw t0,mscratch,t0
    mret

exit:
    jal x0, exit

fetch_addr_mis:
    jal x0,exit

illegal_instr:
    jal x0,exit

sp_out_of_range:
    jal x0,exit

load_addr_mis:
    jal x0,exit

load_access_fault:
    jal x0,exit

store_addr_mis:
    jal x0,exit

store_addr_fault:
    jal x0,exit

ecall:
    csrrw t2,mepc,t2
    addi t2,t2,4
    csrrw t2,mepc,t2

    addi t2,x0,0
    beq a7,t2, exit
    addi t2,t2,1
    beq a7,t2, uart

ecall_end:

    jal x0,done

uart:
    # in a0 i have the print data, and i want to keep the lower 8bits
    andi a0,a0,0xff
    

    beq t2,t2,ecall_end

.section .text_segm, "ax"
.global txt

txt:
    addi a7,x0,0
    addi a0,x0,0
    ecall
    addi x0,x0,0
    addi x0,x0,0


