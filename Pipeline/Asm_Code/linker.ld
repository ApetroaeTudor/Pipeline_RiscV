ENTRY(_start)

MEMORY 
{ /* instr mem (ROM) - Total 1MB */
    TRAP_VEC   (rx) : ORIGIN = 0x00000000, LENGTH = 256K
    RESET_VEC  (rx) : ORIGIN = 0x00040000, LENGTH = 256K
    TEXT       (rx) : ORIGIN = 0x00080000, LENGTH = 256K

  /* data mem (RAM) - Total 1MB */
    GLOBAL_DATA (rwx) : ORIGIN = 0x00100000, LENGTH = 256K
    STACK       (rwx) : ORIGIN = 0x00140000, LENGTH = 256K
    CSR_STACK   (rwx) : ORIGIN = 0x00180000, LENGTH = 256K
    IO          (rwx) : ORIGIN = 0x001c0000, LENGTH = 256K
}

_txt_start = ORIGIN(TEXT);

_stack_top = ORIGIN(STACK) + LENGTH(STACK);
_csr_stack_top = ORIGIN(CSR_STACK) + LENGTH(CSR_STACK);

SECTIONS
{

    .trap_vector :
    {
        . = ALIGN(4);
        KEEP(*(.trap_vector))
    } > TRAP_VEC

    .reset_vector :
    {
        . = ALIGN(4);
        KEEP(*(.reset_vector))
    } > RESET_VEC

    .text_segm :
    {
        . = ALIGN(4);
        *(.text .text.*)
        *(.rodata .rodata.*)
    } > TEXT

    _sidata = LOADADDR(.text_segm) + SIZEOF(.text_segm); 



    /* initially flashed data is put into rom, and then in the reset vector copied into ram*/
    .data : AT (_sidata)
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data .data.*)
        _edata = .;
    } > GLOBAL_DATA

    .bss : AT(_sidata)
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss .bss.*)
        *(COMMON)
        _ebss = .;
    } > GLOBAL_DATA

    .io :
    {
        . = ALIGN(4);
        _sio = .;
    } > IO

        
    /DISCARD/ : { *(.comment) *(.note) }
}
