	.include "xscen-macros.S"
	.file	"dopserv.c"
	.option nopic
	.comm	inbuf,8192,4
	.comm	message,4096,4
	.comm	serverstruct,12,4
	.local	msgout
	.comm	msgout,8192,4
	.section	.sdata,"aw",@progbits
	.align	2
	.type	inptr, @object
	.size	inptr, 4
inptr:
	.word	stdinbuf
	.text
	.align	2
	.globl	mygetchar
	.type	mygetchar, @function
mygetchar:
	xscenstackprep 16
	lui	a4,%hi(inptr)
	add a4,a4,%lo(inptr)
	srbse a4
	srlmt 3(a4)
	lw a4,0(a4)
	srbse a4
	srlmt a4

	add	sp,sp,-16
	sw	s0,12(sp)
	add	s0,sp,16
	lui	a5,%hi(inptr)
	lw	a5,%lo(inptr)(a5)
	add	a3,a5,1
	lui	a4,%hi(inptr)
	sw	a3,%lo(inptr)(a4)
	lbu	a5,0(a5)
	mv	a0,a5
	lw	s0,12(sp)
	add	sp,sp,16
	sbxit
	jr	ra
	.size	mygetchar, .-mygetchar
	.section	.rodata
	.align	2
.LC0:
	.string	"%s"
	.text
	.align	2
	.globl	stdinread
	.type	stdinread, @function
stdinread:
    srbse -16(sp)
    srlmt -1(sp)

	lui	a4,%hi(inptr)
	add a4,a4,%lo(inptr)
	srbse 0(a4)
	srlmt 3(a4)

	lui	a4,%hi(inbuf)
	add a4,a4,%lo(inbuf)

	srbse a4
	li a5,8191
	add a5,a5,a4
	srlmt a5

	add	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	add	s0,sp,16
	lui	a5,%hi(inptr)
	lw	a4,%lo(inptr)(a5)
	lui	a5,%hi(inbuf)
	add	a2,a5,%lo(inbuf)
	lui	a5,%hi(.LC0)
	add	a1,a5,%lo(.LC0)
	mv	a0,a4

	lui	a4,%hi(stdinbuf)
	add a4,a4,%lo(stdinbuf)

	srbse a4
	li a5,438
	add a5,a5,a4
	srlmt a5

	srdlgm	a0
	srbse	a1
	srlmt	3(a1)
	srdlgm	a1
	srdlg	a2

	sbent
	call	sscanf

	mv	a5,a0
	bnez	a5,.L4
	li	a5,0
	j	.L5
.L4:
	lui	a5,%hi(inptr)
	lw	s1,%lo(inptr)(a5)
	lui	a5,%hi(inbuf)
	add	a0,a5,%lo(inbuf)

	srdlg	a0
	sbent
	call	strlen

	mv	a5,a0
	add	a5,a5,1
	add	a4,s1,a5
	lui	a5,%hi(inptr)
	sw	a4,%lo(inptr)(a5)
	lui	a5,%hi(inbuf)
	add	a5,a5,%lo(inbuf)
.L5:
	mv	a0,a5
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	add	sp,sp,16
#NOTE: this should be returned, but the scope of main can't be kept clean if we do this
#	srdlg	a0
    sbxit
	jr	ra
	.size	stdinread, .-stdinread
	.comm	session,1032,4
	.globl	main_server
	.section	.sbss,"aw",@nobits
	.align	2
	.type	main_server, @object
	.size	main_server, 4
main_server:
	.zero	4
	.section	.rodata
	.align	2
.LC1:
	.string	"DOPserv"
	.align	2
cmdstrs:
.LC2:
	.string	"PUT"
	.align	2
.LC3:
	.string	"GET"
	.align	2
.LC4:
	.string	"CWD"
	.align	2
.LC6:
	.string	"PWD"
	.align	2
.LC7:
	.string	"QUIT"
	.set cmdstrs_len,.-cmdstrs
	.align	2
.LC5:
	.string	"220"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
    sbent
    srbse -64(sp)
    srlmt -1(sp)

	lui	t0,%hi(main_server)
	add t0,t0,%lo(main_server)
	srbse t0
	srlmt 3(t0)

	lui	t0,%hi(serverstruct)
	add t0,t0,%lo(serverstruct)
	srbse t0
	srlmt 11(t0)

	lui	t0,%hi(session)
	add	t0,t0,%lo(session)
	srbse t0
	srlmt 1023(t0)

	lui	t0,%hi(message)
	add	t0,t0,%lo(message)
	srbse t0
	li	t1,4095
	add	t1,t1,t0
	srlmt t1

	lui	t0,%hi(inbuf)
	add t0,t0,%lo(inbuf)
	srbse t0
	li t1,8191
	add t1,t1,t0
	srlmt t1

	add	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	add	s0,sp,64
	sw	a0,-52(s0)
	sw	a1,-56(s0)
	lui	a5,%hi(main_server)
	lui	a4,%hi(serverstruct)
	add	a4,a4,%lo(serverstruct)
	sw	a4,%lo(main_server)(a5)
	lui	a5,%hi(main_server)
	lw	a5,%lo(main_server)(a5)
	lui	a4,%hi(.LC1)
	add	a4,a4,%lo(.LC1)
	sw	a4,8(a5)
	li	a5,20
	sw	a5,-20(s0)
	j	.L7
.L13:
	lui	a5,%hi(.LC2)
	add	a1,a5,%lo(.LC2)
	lw	a0,-32(s0)

	dopserv_strcmp_cmd3
	nop

	mv	a5,a0
	bnez	a5,.L8
	sbent
	call	stdinread
	sw	a0,-36(s0)
	lui	a5,%hi(message)
	add	a5,a5,%lo(message)
	sw	a5,-24(s0)
.L9:
	sbent
	call	mygetchar
	mv	a5,a0
	sb	a5,-25(s0)
	lbu	a4,-25(s0)
	li	a5,10
	beq	a4,a5,.L9
.L10:
	lw	a5,-24(s0)
	add	a4,a5,1
	sw	a4,-24(s0)
	lbu	a4,-25(s0)
	sb	a4,0(a5)
	sbent
	call	mygetchar
	mv	a5,a0
	sb	a5,-25(s0)
	lbu	a5,-25(s0)
	bnez	a5,.L10
	lw	a5,-24(s0)
	sb	zero,0(a5)
	j	.L7
.L8:
	lui	a5,%hi(.LC3)
	add	a1,a5,%lo(.LC3)
	lw	a0,-32(s0)

	dopserv_strcmp_cmd3

	mv	a5,a0
	beqz	a5,.L7
	lui	a5,%hi(.LC4)
	add	a1,a5,%lo(.LC4)
	lw	a0,-32(s0)

	dopserv_strcmp_cmd3
	
	mv	a5,a0
	bnez	a5,.L11

	sbent
	call	stdinread
	sw	a0,-40(s0)
	li	a2,1023
	lw	a1,-40(s0)
	lui	a5,%hi(session)
	add	a0,a5,%lo(session)

	srdlg a0
	srdlg a1
	sbent
	call	sstrncpy

	lui	a5,%hi(.LC5)
	add	a0,a5,%lo(.LC5)
	srbse	a0
	srlmt	4(a0)
	srdlgm	a0

	sbent
	call	pr_display_file
	j	.L7
.L11:
	lui	a5,%hi(.LC6)
	add	a1,a5,%lo(.LC6)
	lw	a0,-32(s0)

	dopserv_strcmp_cmd3

	mv	a5,a0
	beqz	a5,.L7
	lui	a5,%hi(.LC7)
	add	a1,a5,%lo(.LC7)
	lw	a0,-32(s0)

	dopserv_strcmp_cmd3 

	mv	a5,a0
	beqz	a5,.L15
.L7:
	lw	a5,-20(s0)
	add	a4,a5,-1
	sw	a4,-20(s0)
	beqz	a5,.L12

    sbent
	call	stdinread
	sw	a0,-32(s0)
	lw	a5,-32(s0)
	bnez	a5,.L13
	j	.L12
.L15:
	nop
.L12:
	li	a5,0
	mv	a0,a5
	lw	ra,60(sp)
	lw	s0,56(sp)
	add	sp,sp,64
	sbxit
	jr	ra
	.size	main, .-main
	.section	.rodata
	.align	2
.LC8:
	.string	"(none)"
	.align	2
display_fmt:
.LC9:
	.string	"%V"
	.align	2
.LC10:
	.string	"%T"
	.align	2
.LC11:
	.string	"%C"
	.set display_fmt_len,.-display_fmt
	.text
	.align	2
	.globl	pr_display_file
	.type	pr_display_file, @function
pr_display_file:
	xscenstackprep 1088

	lui	t1,%hi(message)
	add	t1,t1,%lo(message)
	srbse	t1
	li	t0,4095
	add	t1,t0,t1
	srlmt	t1

	lui	t0,%hi(session)
	add	t0,t0,%lo(session)
	srbse t0
	srlmt 1023(t0)

	lui	t0,%hi(main_server)
	add t0,t0,%lo(main_server)
	srbse t0
	srlmt 3(t0)

	lui	t0,%hi(serverstruct)
	add t0,t0,%lo(serverstruct)
	srbse t0
	srlmt 11(t0)

	add	sp,sp,-1088
	sw	ra,1084(sp)
	sw	s0,1080(sp)
	add	s0,sp,1088
	sw	a0,-1076(s0)
	add	a5,s0,-1060
	li	a4,1024
	mv	a2,a4
	li	a1,0
	mv	a0,a5

	add	a4,a0,a2
	srbse	a0
	srlmt	-1(a4)
	srdlgm	a0
	sbent
	call	memset

	li	a5,1
	sb	a5,-21(s0)
	li	a0,0

	sbent
	call	pr_strtime

	sw	a0,-32(s0)
	sw	zero,-28(s0)
	j	.L17
.L23:
	lw	a5,-28(s0)
	add	a4,s0,-1060
	add	a4,a4,a5
	li	a2,1024
	lui	a5,%hi(message)
	add	a1,a5,%lo(message)
	mv	a0,a4

	srbse	-1060(s0)
	srlmt	(-1060+1023)(s0)
	srdlgm	-1060(s0)
	srdlg	a1
	sbent
	call	memcpy

	sb	zero,-37(s0)
	add	a5,s0,-1060
	mv	a0,a5

	srdlg	a0
	sbent
	call	strlen

	mv	a5,a0
	sw	a5,-20(s0)
	lw	a4,-28(s0)
	lw	a5,-20(s0)
	add	a5,a4,a5
	sw	a5,-28(s0)
	j	.L18
.L20:
	lw	a5,-20(s0)
	add	a5,a5,-1
	add	a4,s0,-16
	add	a5,a4,a5
	sb	zero,-1044(a5)
	lw	a5,-20(s0)
	add	a5,a5,-1
	sw	a5,-20(s0)
.L18:
	lw	a5,-20(s0)
	beqz	a5,.L19
	lw	a5,-20(s0)
	add	a5,a5,-1
	add	a4,s0,-16
	add	a5,a4,a5
	lbu	a4,-1044(a5)
	li	a5,13
	beq	a4,a5,.L20
	lw	a5,-20(s0)
	add	a5,a5,-1
	add	a4,s0,-16
	add	a5,a4,a5
	lbu	a4,-1044(a5)
	li	a5,10
	beq	a4,a5,.L20
.L19:
	lui	a5,%hi(session)
	lbu	a5,%lo(session)(a5)
	beqz	a5,.L21
	lui	a5,%hi(session)
	add	a2,a5,%lo(session)
	j	.L22
.L21:
	lui	a5,%hi(.LC8)
	add	a2,a5,%lo(.LC8)
.L22:
	dopserv_make_entry display_fmt,a4

	lui	a5,%hi(main_server)
	lw	a5,%lo(main_server)(a5)
	lw	a5,8(a5)
	add	a0,s0,-1060
	li	a7,0
	mv	a6,a5
	lui	a5,%hi(.LC9)
	add	a5,a5,%lo(.LC9)
	lw	a4,-32(s0)
	lui	a3,%hi(.LC10)
	add	a3,a3,%lo(.LC10)
	lui	a1,%hi(.LC11)
	add	a1,a1,%lo(.LC11)

#this string could be dynamically allocated and instrumentation would be different
	srbse	a6
	srlmt	7(a6)
	srdlgm	a6 #main_server name
	srdlg	a4 #mg_time
	srdlg	a2 #session
	srdlgm	a1 #substitution patterns
	srdlg	a0 #buf
	sbent
	call	sreplace

	sw	a0,-36(s0)
	add	a5,s0,-1060
	li	a2,1024
	lw	a1,-36(s0)
	mv	a0,a5

	srdlg	a0
	srdlg	a1
	sbent
	call	sstrncpy

	lbu	a5,-21(s0)
	beqz	a5,.L17
	sb	zero,-21(s0)
.L17:
	lui	a5,%hi(message)
	add	a0,a5,%lo(message)

	srbse	a0
	li	a5,4095
	add	a5,a5,a0
	srlmt	a5
	srdlgm	a0
	sbent
	call	strlen

	mv	a4,a0
	lw	a5,-28(s0)
	bgtu	a4,a5,.L23
	li	a5,0
	mv	a0,a5
	lw	ra,1084(sp)
	lw	s0,1080(sp)
	add	sp,sp,1088
	sbxit
	jr	ra
	.size	pr_display_file, .-pr_display_file
	.align	2
	.globl	sreplace
	.type	sreplace, @function
sreplace:
	xscenstackprep 1408
	add	sp,sp,-1408
	sw	ra,1372(sp)
	sw	s0,1368(sp)
	sw	s1,1364(sp)
	add	s0,sp,1376
#a small, separate SR for buffer
    srbse	-1360(s0)
	srlmt	-335(s0)
	sw	a0,-1364(s0)
	sw	a1,4(s0)
	sw	a2,8(s0)
	sw	a3,12(s0)
	sw	a4,16(s0)
	sw	a5,20(s0)
	sw	a6,24(s0)
	sw	a7,28(s0)
	lw	a5,-1364(s0)
	sw	a5,-20(s0)
	sw	zero,-36(s0)
	sw	zero,-40(s0)
	sw	zero,-60(s0)
	li	a5,1
	sw	a5,-48(s0)
	add	a5,s0,-1360
	li	a4,1024
	mv	a2,a4
	li	a1,0
	mv	a0,a5

	add	a4,a0,a2
	srbse	a0
	srlmt	-1(a4)
	srdlgm	a0
	sbent
	call	memset

	add	a5,s0,-1360
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	sb	zero,0(a5)
	add	a5,s0,-204
	li	a2,132
	li	a1,0
	mv	a0,a5

	add	a4,a0,a2
	srbse	a0
	srlmt	-1(a4)
	srdlgm	a0
	sbent
	call	memset

	add	a5,s0,-336
	li	a2,132
	li	a1,0
	mv	a0,a5

	add	a4,a0,a2
	srbse	a0
	srlmt	-1(a4)
	srdlgm	a0
	sbent
	call	memset

	lw	a0,-20(s0)

	srdlg	a0
	sbent
	call	strlen

	mv	a5,a0
	add	a5,a5,1
	sw	a5,-44(s0)
	add	a5,s0,32
	add	a5,a5,-28
	sw	a5,-72(s0)
	j	.L26
.L31:
	sw	zero,-52(s0)
	sw	zero,-56(s0)
	lw	a5,-72(s0)
	add	a4,a5,4
	sw	a4,-72(s0)
	lw	a5,0(a5)
	sw	a5,-68(s0)
	lw	a5,-68(s0)
	beqz	a5,.L45
	lw	a1,-64(s0)
	lw	a0,-1364(s0)

	srdlg	a0
	srdlg	a1
	sbent
	call	strstr

	sw	a0,-52(s0)
	j	.L29
.L30:
	lw	a5,-56(s0)
	add	a5,a5,1
	sw	a5,-56(s0)
	lw	a0,-64(s0)

	srdlg	a0
	sbent
	call	strlen

	mv	a4,a0
	lw	a5,-52(s0)
	add	a5,a5,a4
	sw	a5,-52(s0)
	lw	a1,-64(s0)
	lw	a0,-52(s0)

	srdlg	a0
	srdlg	a1
	sbent
	call	strstr

	sw	a0,-52(s0)
.L29:
	lw	a5,-52(s0)
	bnez	a5,.L30
	lw	a5,-56(s0)
	beqz	a5,.L26
	lw	a0,-68(s0)

	srdlg	a0
	sbent
	call	strlen

	mv	s1,a0
	lw	a0,-64(s0)

	srdlg	a0
	sbent
	call	strlen

	mv	a5,a0
	sub	a4,s1,a5
	lw	a5,-56(s0)
	mul	a5,a4,a5
	lw	a4,-44(s0)
	add	a5,a4,a5
	sw	a5,-44(s0)
	lw	a5,-40(s0)
	sll	a5,a5,2
	add	a4,s0,-16
	add	a5,a4,a5
	lw	a4,-64(s0)
	sw	a4,-188(a5)
	lw	a5,-40(s0)
	add	a4,a5,1
	sw	a4,-40(s0)
	sll	a5,a5,2
	add	a4,s0,-16
	add	a5,a4,a5
	lw	a4,-68(s0)
	sw	a4,-320(a5)
.L26:
	lw	a5,-72(s0)
	add	a4,a5,4
	sw	a4,-72(s0)
	lw	a5,0(a5)
	sw	a5,-64(s0)
	lw	a5,-64(s0)
	beqz	a5,.L28
	lw	a4,-40(s0)
	li	a5,130
	bleu	a4,a5,.L31
	j	.L28
.L45:
	nop
.L28:
	lw	a5,-36(s0)
	bnez	a5,.L33
	add	a5,s0,-1360
	sw	a5,-36(s0)
	lw	a5,-36(s0)
	sw	a5,-24(s0)
	sw	zero,-48(s0)
	li	a5,1024
	sw	a5,-44(s0)
	j	.L33
.L41:
	add	a5,s0,-204
	sw	a5,-28(s0)
	add	a5,s0,-336
	sw	a5,-32(s0)
	j	.L34
.L39:
	lw	a5,-28(s0)
	lw	a5,0(a5)
	mv	a0,a5

	nop
	srdlg	a0
	sbent
	call	strlen

	sw	a0,-40(s0)
	lw	a5,-32(s0)
	lw	a5,0(a5)
	mv	a0,a5

	srdlg	a0
	sbent
	call	strlen

	sw	a0,-60(s0)
	lw	a5,-28(s0)
	lw	a5,0(a5)
	lw	a2,-40(s0)
	mv	a1,a5
	lw	a0,-20(s0)

	srdlg	a0
	srdlg	a1
	sbent
	call	strncmp

	mv	a5,a0
	bnez	a5,.L35
	lw	a5,-32(s0)
	lw	s1,0(a5)
	lw	a0,-36(s0)

	srdlg	a0
	sbent
	call	strlen

	mv	a4,a0
	lw	a5,-44(s0)
	sub	a5,a5,a4
	mv	a2,a5
	mv	a1,s1
	lw	a0,-24(s0)

	srdlg	a0
	srdlg	a1
	sbent
	call	sstrncpy

	lw	a4,-24(s0)
	lw	a5,-60(s0)
	add	a5,a4,a5
	mv	a4,a5
	lw	a5,-36(s0)
	sub	a5,a4,a5
	add	a5,a5,1
	mv	a4,a5
	lw	a5,-44(s0)
	bleu	a4,a5,.L36
	lw	a5,-44(s0)
	add	a5,a5,-1
	lw	a4,-36(s0)
	add	a5,a4,a5
	sw	a5,-24(s0)
	j	.L37
.L36:
	lw	a4,-24(s0)
	lw	a5,-60(s0)
	add	a5,a4,a5
	sw	a5,-24(s0)
	lw	a4,-20(s0)
	lw	a5,-40(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
	j	.L38
.L35:
	lw	a5,-28(s0)
	add	a5,a5,4
	sw	a5,-28(s0)
	lw	a5,-32(s0)
	add	a5,a5,4
	sw	a5,-32(s0)
.L34:
	lw	a5,-28(s0)
	lw	a5,0(a5)
	bnez	a5,.L39
.L38:
	lw	a5,-28(s0)
	lw	a5,0(a5)
	bnez	a5,.L33
	lw	a4,-24(s0)
	lw	a5,-36(s0)
	sub	a5,a4,a5
	add	a5,a5,1
	mv	a4,a5
	lw	a5,-44(s0)
	bleu	a4,a5,.L40
	lw	a5,-44(s0)
	add	a5,a5,-1
	lw	a4,-36(s0)
	add	a5,a4,a5
	sw	a5,-24(s0)
.L40:
	lw	a5,-24(s0)
	add	a4,a5,1
	sw	a4,-24(s0)
	lw	a4,-20(s0)
	add	a3,a4,1
	sw	a3,-20(s0)
	lbu	a4,0(a4)
	sb	a4,0(a5)
.L33:
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	bnez	a5,.L41
.L37:
	lw	a5,-24(s0)
	sb	zero,0(a5)
	lw	a5,-48(s0)
	beqz	a5,.L42
	lw	a5,-36(s0)
	j	.L44
.L42:
	add	a5,s0,-1360
	mv	a1,a5
	lui	a5,%hi(msgout)
	add	a0,a5,%lo(msgout)

	srbse	a0
	li a5,8191
	add a5,a5,a0
	srlmt	a5

	srdlg	a0
	srdlg	a1
	sbent
	call	strcpy

	mv	a5,a0
.L44:
	mv	a0,a5
	lw	ra,1372(sp)
	lw	s0,1368(sp)
	lw	s1,1364(sp)
	add	sp,sp,1408
	srdlg	a0
	sbxit
	jr	ra
	.size	sreplace, .-sreplace
	.section	.rodata
	.align	2
mons:
.LC12:
	.string	"Jan"
	.align	2
.LC13:
	.string	"Feb"
	.align	2
.LC14:
	.string	"Mar"
	.align	2
.LC15:
	.string	"Apr"
	.align	2
.LC16:
	.string	"May"
	.align	2
.LC17:
	.string	"Jun"
	.align	2
.LC18:
	.string	"Jul"
	.align	2
.LC19:
	.string	"Aug"
	.align	2
.LC20:
	.string	"Sep"
	.align	2
.LC21:
	.string	"Oct"
	.align	2
.LC22:
	.string	"Nov"
	.align	2
.LC23:
	.string	"Dec"
	.set mons_len,.-mons
	.align	2
days:
.LC24:
	.string	"Sun"
	.align	2
.LC25:
	.string	"Mon"
	.align	2
.LC26:
	.string	"Tue"
	.align	2
.LC27:
	.string	"Wed"
	.align	2
.LC28:
	.string	"Thu"
	.align	2
.LC29:
	.string	"Fri"
	.align	2
.LC30:
	.string	"Sat"
	.set days_len,.-days
	.align	2
datefmt:
.LC31:
	.string	"%s %s %2d %02d:%02d:%02d %d"
	.set datefmt_len,.-datefmt
	.text
	.align	2
	.globl	pr_strtime
	.type	pr_strtime, @function
pr_strtime:
	xscenstackprep 128
	dopserv_make_entry days, a4
	dopserv_make_entry mons, a4
	lui	a4,%hi(buf.3089)
	add	a4,a4,%lo(buf.3089)
	srbse a4
	srlmt 29(a4)

	add	sp,sp,-128
	sw	ra,124(sp)
	sw	s0,120(sp)
	add	s0,sp,128
	sw	a0,-100(s0)
	lui	a5,%hi(.LC12)
	add	a5,a5,%lo(.LC12)
	sw	a5,-68(s0)
	lui	a5,%hi(.LC13)
	add	a5,a5,%lo(.LC13)
	sw	a5,-64(s0)
	lui	a5,%hi(.LC14)
	add	a5,a5,%lo(.LC14)
	sw	a5,-60(s0)
	lui	a5,%hi(.LC15)
	add	a5,a5,%lo(.LC15)
	sw	a5,-56(s0)
	lui	a5,%hi(.LC16)
	add	a5,a5,%lo(.LC16)
	sw	a5,-52(s0)
	lui	a5,%hi(.LC17)
	add	a5,a5,%lo(.LC17)
	sw	a5,-48(s0)
	lui	a5,%hi(.LC18)
	add	a5,a5,%lo(.LC18)
	sw	a5,-44(s0)
	lui	a5,%hi(.LC19)
	add	a5,a5,%lo(.LC19)
	sw	a5,-40(s0)
	lui	a5,%hi(.LC20)
	add	a5,a5,%lo(.LC20)
	sw	a5,-36(s0)
	lui	a5,%hi(.LC21)
	add	a5,a5,%lo(.LC21)
	sw	a5,-32(s0)
	lui	a5,%hi(.LC22)
	add	a5,a5,%lo(.LC22)
	sw	a5,-28(s0)
	lui	a5,%hi(.LC23)
	add	a5,a5,%lo(.LC23)
	sw	a5,-24(s0)
	lui	a5,%hi(.LC24)
	add	a5,a5,%lo(.LC24)
	sw	a5,-96(s0)
	lui	a5,%hi(.LC25)
	add	a5,a5,%lo(.LC25)
	sw	a5,-92(s0)
	lui	a5,%hi(.LC26)
	add	a5,a5,%lo(.LC26)
	sw	a5,-88(s0)
	lui	a5,%hi(.LC27)
	add	a5,a5,%lo(.LC27)
	sw	a5,-84(s0)
	lui	a5,%hi(.LC28)
	add	a5,a5,%lo(.LC28)
	sw	a5,-80(s0)
	lui	a5,%hi(.LC29)
	add	a5,a5,%lo(.LC29)
	sw	a5,-76(s0)
	lui	a5,%hi(.LC30)
	add	a5,a5,%lo(.LC30)
	sw	a5,-72(s0)
	li	a2,30
	li	a1,0
	lui	a5,%hi(buf.3089)
	add	a0,a5,%lo(buf.3089)

	add	a4,a0,a2
	srbse	a0
	srlmt	-1(a4)
	srdlgm	a0
	sbent
	call	memset

	add	a5,s0,-100
	mv	a0,a5

	srbse	a0
	srlmt	3(a0)
	srdlgm	a0

	sbent
	call	localtime

	sw	a0,-20(s0)
	lw	a5,-20(s0)
	beqz	a5,.L47
	lw	a5,-20(s0)
	lw	a5,24(a5)
	sll	a5,a5,2
	add	a4,s0,-16
	add	a5,a4,a5
	lw	a3,-80(a5)
	lw	a5,-20(s0)
	lw	a5,16(a5)
	sll	a5,a5,2
	add	a4,s0,-16
	add	a5,a4,a5
	lw	a2,-52(a5)
	lw	a5,-20(s0)
	lw	a1,12(a5)
	lw	a5,-20(s0)
	lw	a0,8(a5)
	lw	a5,-20(s0)
	lw	a6,4(a5)
	lw	a5,-20(s0)
	lw	a5,0(a5)
	lw	a4,-20(s0)
	lw	a4,20(a4)
	add	a4,a4,1900
	sw	a4,4(sp)
	sw	a5,0(sp)
	mv	a7,a6
	mv	a6,a0
	mv	a5,a1
	mv	a4,a2
	lui	a2,%hi(.LC31)
	add	a2,a2,%lo(.LC31)
	li	a1,30
	lui	a0,%hi(buf.3089)
	add	a0,a0,%lo(buf.3089)

	srdlg	a0
	srdlg	a3
	srdlg	a4
	
	srbse	a2
	srlmt	datefmt_len(a2)
	srdlg	a2

#va args
	srbse	sp
	srlmt	7(sp)
	srdlgm	sp

	sbent
	call	snprintf

	j	.L48
.L47:
	lui	a5,%hi(buf.3089)
	sb	zero,%lo(buf.3089)(a5)
.L48:
	lui	a5,%hi(buf.3089)
	add	a5,a5,%lo(buf.3089)
	sb	zero,29(a5)
	lui	a5,%hi(buf.3089)
	add	a5,a5,%lo(buf.3089)
	mv	a0,a5
	lw	ra,124(sp)
	lw	s0,120(sp)
	add	sp,sp,128

	srdlg	a0
	sbxit
	jr	ra
	.size	pr_strtime, .-pr_strtime
	.align	2
	.globl	sstrncpy
	.type	sstrncpy, @function
sstrncpy:
	xscenstackprep 32
	add	sp,sp,-32
	sw	s0,28(sp)
	sw	s1,24(sp)
	add	s0,sp,32
	sw	a0,-20(s0)
	sw	a1,-24(s0)
	sw	a2,-28(s0)
	lw	s1,-20(s0)
	lw	a5,-20(s0)
	bnez	a5,.L51
	li	a5,0
	j	.L52
.L51:
	lw	a5,-24(s0)
	beqz	a5,.L53
	lw	a5,-24(s0)
	lbu	a5,0(a5)
	beqz	a5,.L53
	j	.L54
.L55:
	mv	a4,s1
	add	s1,a4,1
	lw	a5,-24(s0)
	add	a3,a5,1
	sw	a3,-24(s0)
	lbu	a5,0(a5)
	sb	a5,0(a4)
	lw	a5,-28(s0)
	add	a5,a5,-1
	sw	a5,-28(s0)
.L54:
	lw	a5,-24(s0)
	lbu	a5,0(a5)
	beqz	a5,.L53
	lw	a4,-28(s0)
	li	a5,1
	bgtu	a4,a5,.L55
.L53:
	sb	zero,0(s1)
	lw	a5,-20(s0)
.L52:
	mv	a0,a5
	lw	s0,28(sp)
	lw	s1,24(sp)
	add	sp,sp,32
    sbxit
	jr	ra
	.size	sstrncpy, .-sstrncpy
	.local	buf.3089
	.comm	buf.3089,30,4
	.ident	"GCC: (GNU) 6.1.0"
