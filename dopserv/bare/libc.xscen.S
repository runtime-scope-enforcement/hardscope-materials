	.include "xscen-macros.S"
	.file	"libc.c"
	.option nopic
	.comm	__time_tm,36,4
	.text
	.align	2
	.globl	sscanf
	.type	sscanf, @function
sscanf:
	xscenstackprep 48
	add	sp,sp,-48
	sw	s0,44(sp)
	add	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sw	zero,-20(s0)
.L3:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	sb	a5,-21(s0)
	lbu	a4,-21(s0)
	li	a5,32
	beq	a4,a5,.L2
	lbu	a4,-21(s0)
	li	a5,10
	beq	a4,a5,.L2
	lbu	a5,-21(s0)
	beqz	a5,.L2
	lw	a5,-20(s0)
	lw	a4,-44(s0)
	add	a5,a4,a5
	lbu	a4,-21(s0)
	sb	a4,0(a5)
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
	j	.L3
.L2:
	lw	a5,-20(s0)
	lw	a4,-44(s0)
	add	a5,a4,a5
	sb	zero,0(a5)
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	add	sp,sp,48
	sbxit
	jr	ra
	.size	sscanf, .-sscanf
	.align	2
	.globl	strstr
	.type	strstr, @function
strstr:
	xscenstackprep 48
	add	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	add	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a0,-40(s0)

	srdlg a0
	sbent
	call	strlen

	mv	a5,a0
	sw	a5,-24(s0)
	lw	a5,-36(s0)
	sw	a5,-20(s0)
.L8:
	lw	a5,-24(s0)
	mv	a2,a5
	lw	a1,-40(s0)
	lw	a0,-20(s0)

	srdlg a0
	srdlg a1
	sbent
	call	strncmp

	mv	a5,a0
	bnez	a5,.L6
	lw	a5,-20(s0)
	j	.L7
.L6:
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	bnez	a5,.L8
	li	a5,0
.L7:
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	add	sp,sp,48
	sbxit
	jr	ra
	.size	strstr, .-strstr
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	xscenstackprep 48
	add	sp,sp,-48
	sw	s0,44(sp)
	add	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sw	zero,-20(s0)
	j	.L10
.L15:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a4,0(a5)
	lw	a5,-20(s0)
	lw	a3,-40(s0)
	add	a5,a3,a5
	lbu	a5,0(a5)
	beq	a4,a5,.L11
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	mv	a3,a5
	lw	a5,-20(s0)
	lw	a4,-40(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	sub	a5,a3,a5
	j	.L12
.L11:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	bnez	a5,.L13
	lw	a5,-20(s0)
	lw	a4,-40(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	beqz	a5,.L16
.L13:
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
.L10:
	lw	a4,-20(s0)
	lw	a5,-44(s0)
	bltu	a4,a5,.L15
	j	.L14
.L16:
	nop
.L14:
	li	a5,0
.L12:
	mv	a0,a5
	lw	s0,44(sp)
	add	sp,sp,48
	sbxit
	jr	ra
	.size	strncmp, .-strncmp
	.globl	_vals
	.section	.rodata
	.align	2
	.type	_vals, @object
	.size	_vals, 16
_vals:
	.half	60
	.half	60
	.half	24
	.half	7
	.half	-29012
	.half	1461
	.half	365
	.half	0
	.set _vals_len, .-_vals
	.globl	_days
	.align	2
	.type	_days, @object
	.size	_days, 13
_days:
	.byte	31
	.byte	28
	.byte	31
	.byte	30
	.byte	31
	.byte	30
	.byte	31
	.byte	31
	.byte	30
	.byte	31
	.byte	30
	.byte	31
	.byte	29
	.set _days_len, .-_days
	.text
	.align	2
	.globl	_time_t2tm
	.type	_time_t2tm, @function
_time_t2tm:
	xscenstackprep 48
	dopserv_make_entry _vals, a4
	dopserv_make_entry _days, a4

	add	sp,sp,-48
	sw	s0,44(sp)
	sw	s1,40(sp)
	sw	s2,36(sp)
	add	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	lw	a5,-36(s0)
	lw	a5,0(a5)
	sw	a5,-20(s0)
	lw	s1,-44(s0)
	add	a5,s1,28
	sw	zero,0(a5)
	lui	a5,%hi(_vals)
	add	s2,a5,%lo(_vals)
.L22:
	lhu	a5,0(s2)
	sw	a5,-24(s0)
	lw	a4,-24(s0)
	li	a5,7
	bne	a4,a5,.L18
	lw	a5,-20(s0)
	add	a5,a5,4
	lhu	a4,0(s2)
	rem	a5,a5,a4
	sw	a5,-28(s0)
	add	a5,s2,2
	lhu	a5,0(a5)
	sll	a5,a5,2
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	add	a5,a5,1
	sw	a5,-24(s0)
	lw	a4,-40(s0)
	li	a5,135168
	add	a5,a5,-394
	add	a5,a4,a5
	lw	a4,-20(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
.L18:
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	div	a5,a4,a5
	sw	a5,-32(s0)
	lw	a4,-32(s0)
	lw	a5,-24(s0)
	mul	a5,a4,a5
	lw	a4,-20(s0)
	sub	a5,a4,a5
	sw	a5,-20(s0)
	lhu	a4,0(s2)
	li	a5,7
	bne	a4,a5,.L19
	lw	a5,-24(s0)
	add	a4,a5,-1
	lw	a5,-20(s0)
	bne	a4,a5,.L19
	lw	a5,-20(s0)
	add	a5,a5,-1
	sw	a5,-20(s0)
	add	a5,s1,16
	lw	a4,0(a5)
	add	a4,a4,1
	sw	a4,0(a5)
.L19:
	lw	a4,-24(s0)
	li	a5,60
	bgt	a4,a5,.L20
	mv	a5,s1
	add	s1,a5,4
	lw	a4,-20(s0)
	sw	a4,0(a5)
	lw	a5,-32(s0)
	sw	a5,-20(s0)
	j	.L21
.L20:
	mv	a5,s1
	add	s1,a5,4
	lw	a4,-32(s0)
	sw	a4,0(a5)
.L21:
	add	s2,s2,2
	lhu	a5,0(s2)
	bnez	a5,.L22
	add	a5,s1,-4
	lw	a4,0(a5)
	li	a5,4
	bne	a4,a5,.L23
	add	a5,s1,-4
	lw	a4,0(a5)
	add	a4,a4,-1
	sw	a4,0(a5)
	li	a5,365
	sw	a5,-20(s0)
.L23:
	lw	a4,0(s1)
	lw	a5,-20(s0)
	add	a5,a4,a5
	sw	a5,0(s1)
	add	s1,s1,-8
	add	a5,s1,-8
	lw	a5,0(a5)
	sll	a4,a5,2
	add	a5,s1,-4
	lw	a5,0(a5)
	add	a4,a4,a5
	mv	a5,a4
	sll	a5,a5,1
	add	a5,a5,a4
	sll	a5,a5,3
	add	a4,a5,a4
	lw	a5,0(s1)
	add	a5,a4,a5
	sll	a4,a5,2
	add	a5,s1,4
	lw	a5,0(a5)
	add	a5,a5,-299
	add	a5,a4,a5
	sw	a5,0(s1)
	add	a5,s1,4
	lw	a4,-28(s0)
	sw	a4,0(a5)
	lui	a5,%hi(_days)
	add	s2,a5,%lo(_days)
	lw	a5,0(s1)
	add	a5,a5,1900
	sw	a5,-28(s0)
	add	a5,s1,8
	lw	a5,0(a5)
	add	a5,a5,1
	sw	a5,-28(s0)
	add	s1,s1,-4
	sw	zero,0(s1)
	j	.L24
.L26:
	lbu	a5,0(s2)
	mv	a4,a5
	lw	a5,-28(s0)
	sub	a5,a5,a4
	sw	a5,-28(s0)
	lbu	a4,0(s2)
	li	a5,29
	bne	a4,a5,.L25
	add	s2,s2,-11
.L25:
	add	s2,s2,1
	lw	a5,0(s1)
	add	a5,a5,1
	sw	a5,0(s1)
.L24:
	lbu	a5,0(s2)
	mv	a4,a5
	lw	a5,-28(s0)
	blt	a4,a5,.L26
	add	a5,s1,-4
	lw	a4,-28(s0)
	sw	a4,0(a5)
	add	a5,s1,16
	sw	zero,0(a5)
	lw	a5,-44(s0)
	mv	a0,a5
	lw	s0,44(sp)
	lw	s1,40(sp)
	lw	s2,36(sp)
	add	sp,sp,48
	sbxit
	jr	ra
	.size	_time_t2tm, .-_time_t2tm
	.align	2
	.globl	localtime
	.type	localtime, @function
localtime:
	xscenstackprep 32
	.set __time_tm_len, 36
	dopserv_make_entry __time_tm, a4

	add	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	add	s0,sp,32
	sw	a0,-20(s0)
	lui	a5,%hi(__time_tm)
	add	ra,a5,%lo(__time_tm)
	mv	a2,ra
	li	a1,0
	lw	a0,-20(s0)

	srdlg	a0
	srdlg	a2
	sbent
	call	_time_t2tm

	mv	a5,a0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	add	sp,sp,32
    srdlg a0
	sbxit
	jr	ra
	.size	localtime, .-localtime
	.align	2
	.globl	snprintf
	.type	snprintf, @function
snprintf:
	xscenstackprep 112
	add	sp,sp,-112
	sw	ra,76(sp)
	sw	s0,72(sp)
	sw	s1,68(sp)
	add	s0,sp,80
	sw	a0,-68(s0)
	sw	a1,-72(s0)
	sw	a2,-76(s0)
	sw	a3,12(s0)
	sw	a4,16(s0)
	sw	a5,20(s0)
	sw	a6,24(s0)
	sw	a7,28(s0)
	lw	a4,-68(s0)
	lw	a5,-72(s0)
	add	a5,a4,a5
	sw	a5,-52(s0)
	add	a5,s0,32
	add	a5,a5,-20
	sw	a5,-56(s0)
	lw	a5,-76(s0)
	sw	a5,-20(s0)
	lw	a5,-68(s0)
	sw	a5,-24(s0)
	sb	zero,-25(s0)
	j	.L31
.L62:
	sb	zero,-25(s0)
	sw	zero,-32(s0)
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,37
	bne	a4,a5,.L32
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,48
	bne	a4,a5,.L33
	li	a5,48
	sb	a5,-25(s0)
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
	j	.L34
.L33:
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,48
	bleu	a4,a5,.L34
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,57
	bgtu	a4,a5,.L34
	li	a5,32
	sb	a5,-25(s0)
.L34:
	lbu	a5,-25(s0)
	beqz	a5,.L35
	j	.L36
.L37:
	lw	a4,-32(s0)
	mv	a5,a4
	sll	a5,a5,2
	add	a5,a5,a4
	sll	a5,a5,1
	mv	a4,a5
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	add	a5,a5,-48
	add	a5,a4,a5
	sw	a5,-32(s0)
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
.L36:
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,47
	bleu	a4,a5,.L35
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,57
	bleu	a4,a5,.L37
.L35:
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,115
	bne	a4,a5,.L38
	lw	a5,-56(s0)
	add	a4,a5,4
	sw	a4,-56(s0)
	lw	a5,0(a5)
	sw	a5,-36(s0)
	lw	a5,-36(s0)
	beqz	a5,.L64
	lw	s1,-32(s0)
	lw	a0,-36(s0)

    srdlg   a0
    sbent
	call	strlen
	mv	a5,a0
	sub	a5,s1,a5
	sw	a5,-32(s0)
	j	.L41
.L44:
	lw	a4,-24(s0)
	lw	a5,-52(s0)
	bgeu	a4,a5,.L65
	lw	a5,-24(s0)
	lbu	a4,-25(s0)
	sb	a4,0(a5)
	lw	a5,-24(s0)
	add	a5,a5,1
	sw	a5,-24(s0)
.L41:
	lw	a5,-32(s0)
	add	a4,a5,-1
	sw	a4,-32(s0)
	bgtz	a5,.L44
	j	.L45
.L48:
	lw	a4,-24(s0)
	lw	a5,-52(s0)
	bgeu	a4,a5,.L66
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	lw	a5,-24(s0)
	sb	a4,0(a5)
	lw	a5,-24(s0)
	add	a5,a5,1
	sw	a5,-24(s0)
	lw	a5,-36(s0)
	add	a5,a5,1
	sw	a5,-36(s0)
.L45:
	lw	a5,-36(s0)
	lbu	a5,0(a5)
	bnez	a5,.L48
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
	j	.L31
.L38:
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	li	a5,100
	bne	a4,a5,.L31
	lw	a5,-56(s0)
	add	a4,a5,4
	sw	a4,-56(s0)
	lw	a5,0(a5)
	sw	a5,-40(s0)
	li	a5,10
	sw	a5,-44(s0)
	sw	zero,-48(s0)
	li	a5,1
	sw	a5,-48(s0)
	j	.L50
.L51:
	lw	a5,-48(s0)
	add	a5,a5,1
	sw	a5,-48(s0)
	lw	a4,-44(s0)
	mv	a5,a4
	sll	a5,a5,2
	add	a5,a5,a4
	sll	a5,a5,1
	sw	a5,-44(s0)
.L50:
	lw	a4,-40(s0)
	lw	a5,-44(s0)
	bgt	a4,a5,.L51
	lw	a4,-32(s0)
	lw	a5,-48(s0)
	sub	a5,a4,a5
	sw	a5,-32(s0)
	j	.L52
.L55:
	lw	a4,-24(s0)
	lw	a5,-52(s0)
	bgeu	a4,a5,.L67
	lw	a5,-24(s0)
	lbu	a4,-25(s0)
	sb	a4,0(a5)
	lw	a5,-24(s0)
	add	a5,a5,1
	sw	a5,-24(s0)
.L52:
	lw	a5,-32(s0)
	add	a4,a5,-1
	sw	a4,-32(s0)
	bgtz	a5,.L55
	j	.L56
.L59:
	lw	a4,-44(s0)
	li	a5,10
	div	a5,a4,a5
	sw	a5,-44(s0)
	lw	a4,-24(s0)
	lw	a5,-52(s0)
	bgeu	a4,a5,.L68
	lw	a4,-40(s0)
	lw	a5,-44(s0)
	div	a5,a4,a5
	and	a5,a5,0xff
	add	a5,a5,48
	and	a4,a5,0xff
	lw	a5,-24(s0)
	sb	a4,0(a5)
	lw	a5,-24(s0)
	add	a5,a5,1
	sw	a5,-24(s0)
	lw	a4,-40(s0)
	lw	a5,-44(s0)
	rem	a5,a4,a5
	sw	a5,-40(s0)
.L56:
	lw	a5,-48(s0)
	add	a4,a5,-1
	sw	a4,-48(s0)
	bnez	a5,.L59
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
	j	.L31
.L32:
	lw	a4,-24(s0)
	lw	a5,-52(s0)
	bgeu	a4,a5,.L69
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	lw	a5,-24(s0)
	sb	a4,0(a5)
	lw	a5,-24(s0)
	add	a5,a5,1
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
.L31:
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	bnez	a5,.L62
	j	.L40
.L64:
	nop
	j	.L40
.L65:
	nop
	j	.L40
.L66:
	nop
	j	.L40
.L67:
	nop
	j	.L40
.L68:
	nop
	j	.L40
.L69:
	nop
.L40:
	lw	a5,-24(s0)
	sb	zero,0(a5)
	lw	a4,-24(s0)
	lw	a5,-68(s0)
	sub	a5,a4,a5
	mv	a0,a5
	lw	ra,76(sp)
	lw	s0,72(sp)
	lw	s1,68(sp)
	add	sp,sp,112
	sbxit
	jr	ra
	.size	snprintf, .-snprintf
	.ident	"GCC: (GNU) 6.1.0"
