# passed parameter is the .s file name without extension

riscv64-unknown-elf-as -march=rv32i_zicsr -mabi=ilp32 -o ./Asm_Code/$1.o ./Asm_Code/$1.s
riscv64-unknown-elf-gcc -march=rv32i_zicsr -mabi=ilp32 -nostdlib -T ./Asm_Code/linker.ld ./Asm_Code/$1.o -o ./Asm_Code/$1.elf
riscv64-unknown-elf-objcopy -O binary ./Asm_Code/$1.elf ./Asm_Code/$1.bin
riscv64-unknown-elf-objcopy -O binary ./Asm_Code/$1.elf ./Asm_Code/$1.bin
xxd -p -c 4 ./Asm_Code/$1.bin > ./Asm_Code/$1.hex


rm ./Asm_Code/$1.o ./Asm_Code/$1.elf ./Asm_Code/$1.bin
