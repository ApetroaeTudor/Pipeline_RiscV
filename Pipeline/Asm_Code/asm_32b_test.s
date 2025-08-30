
addi t1,x0,0x678 # if all tests go well, write 1011 in x31, if fail 1111 in x31
lui t1,0x12345 # 78 56 34 12
sw t1,0(x0)
lb t0,0(x0) # 0111 1000
addi t1, x0, 0x78
bne t0,t1,fail

lh t0,0(x0) # 5678
addi t1,x0,0x567
lui t1,0x8000 
bne t0,t1,fail

lw t0,0(x0)
addi t1,x0,0x678
lui t1,0x12345
bne t0,t1,fail


pass:
addi x31,x0,0xb

fail:
addi x31,x0,0xf