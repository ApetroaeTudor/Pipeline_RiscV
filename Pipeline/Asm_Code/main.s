	.file	"main.c"
	.option nopic
	.attribute arch, "rv32i2p1_zicsr2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	sum
	.type	sum, @function
sum:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	sw	a1,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	add	a5,a4,a5
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	sum, .-sum
	.globl	x
	.section	.srodata,"a"
	.align	2
	.type	x, @object
	.size	x, 4
x:
	.word	5
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a1,3
	li	a0,2
	call	sum
	sw	a0,-20(s0)
	li	a5,16777216
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	li	a5,5
	bne	a4,a5,.L4
	lw	a5,-24(s0)
	li	a4,1
	sw	a4,0(a5)
	j	.L5
.L4:
	lw	a5,-24(s0)
	li	a4,2
	sw	a4,0(a5)
.L5:
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (g1b306039a) 15.1.0"
	.section	.note.GNU-stack,"",@progbits
