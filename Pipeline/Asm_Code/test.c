// Test SLLI
//li    t0, 1
//slli  t1, t0, 3      
//li    t2, 8
//beq t1,t2,8
//jalr x0,0(t5)
00100293 
00329313 
00800393 
00730463
000f0067

// Test SLTI
//li    t0, 5
//slti  t1, t0, 10     
//li    t2, 1
//beq t1,t2,8
//jalr x0,0(t5)
00500293
00a2a313
00100393
00730463
000f0067

// Test SLTIU
//li    t0, -1
//sltiu t1, t0, 1      
//li    t2, 0
//beq t1,t2,8
//jalr x0,0(t5)
fff00293
0012b313
00000393
00730463
000f0067

// Test XORI
//li    t0, 0xF0
//xori  t1, t0, 0x0F   
//li    t2, 0xFF
//beq t1,t2,8
//jalr x0,0(t5)
0f000293
00f2c313
0ff00393
00730463
000f0067

// Test SRLI
//li    t0, 0x80
//srli  t1, t0, 7     
//li    t2, 1
//beq t1,t2,8
//jalr x0,0(t5)
08000293
0072d313
00100393
00730463
000f0067

// Test SRAI
//li    t0, -128
//srai  t1, t0, 7      
//li    t2, -1
//beq t1,t2,8
//jalr x0,0(t5)
f8000293
4072d313
fff00393
00730463
000f0067

// Test ORI
//li    t0, 0x10
//ori   t1, t0, 0x01  
//li    t2, 0x11
//beq t1,t2,8
//jalr x0,0(t5)
01000293
0012e313
01100393
00730463
000f0067
    
// Test ANDI
//li    t0, 0xF3
//andi  t1, t0, 0xF0   
//li    t2, 0xF0
//beq t1,t2,8
//jalr x0,0(t5)
0f300293
0f02f313
0f000393
00730463
000f0067

// Test AUIPC
//auipc t1, 0          
//addi  t2, t1, 8
//auipc t3, 0
//beq t2,t3,8
//jalr x0,0(t5)
00000317
00830393
00000e17
01c38463
000f0067


// Test SLT
//li    t0, 5
//li    t1, 10
//slt   t2, t0, t1     
//li    t3, 1
//beq t2,t3,8
//jalr x0,0(t5)
00500293
00a00313
0062a3b3
00100e13
01c38463
000f0067

// Test SLTU
//li    t0, -1         
//li    t1, 1
//sltu  t2, t0, t1     
//li    t3, 0
//beq t2,t3,8
//jalr x0,0(t5)
fff00293
00100313
0062b3b3
00000e13
01c38463
000f0067

// Test XOR
//li    t0, 0xAA
//li    t1, 0xFF
//xor   t2, t0, t1     
//li    t3, 0x55
//beq t2,t3,8
//jalr x0,0(t5)
0aa00293
0ff00313
0062c3b3
05500e13
01c38463
000f0067

// Test SRL
//li    t0, 0x80000000
//li    t1, 31
//srl   t2, t0, t1    
//li    t3, 1
//beq t2,t3,8
//jalr x0,0(t5)
0010029b
01f29293
01f00313
0062d3b3
00100e13
01c38463
000f0067

// Test SRA
//li    t0, -2147483648   
//li    t1, 31
//sra   t2, t0, t1       
//li    t3, -1
//beq t2,t3,8
//jalr x0,0(t5)
800002b7
01f00313
4062d3b3
fff00e13
01c38463
000f0067

// Test AND
//li    t0, 0xF0
//li    t1, 0xCC
//and   t2, t0, t1        
//li    t3, 0xC0
//beq t2,t3,8
//jalr x0,0(t5)
0f000293
0cc00313
0062f3b3
0c000e13
01c38463
000f0067


// Test BEQ
//li    t0, 123
//li    t1, 123
//beq   t0, t1, 8
//jalr x0,0(t5)
07b00293
07b00313
00628463
000f0067

// Test BNE
//li    t0, 123
//li    t1, 456
//bne   t0, t1, 8
//jalr x0,0(t5)
07b00293
1c800313
00629463
000f0067

// Test BLT
//li    t0, -1
//li    t1, 0
//blt   t0, t1, 8
//jalr x0,0(t5)
fff00293
00000313
0062c463
000f0067


// Test BGE
//li    t0, 5
//li    t1, -5
//bge   t0, t1, 8
//jalr x0,0(t5)
00500293
ffb00313
0062d463
000f0067

// Test BLTU
//li    t0, 1
//li    t1, -1           
//bltu  t0, t1, 8
//jalr x0,0(t5)
00100293
fff00313
0062e463
000f0067

// Test BGEU
//li    t0, -1           
//li    t1, 1
//bgeu  t0, t1, 8
//jalr x0,0(t5)
fff00293
00100313
0062f463
000f0067