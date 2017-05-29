.macro xscenstackprep size
	srbse	-(\size)(sp)
	srlmt	-1(sp)
.endm

.macro dopserv_memset
	add a4,a0,a2
	srbse a0
	srlmt -1(a4)
	srdlgm a0
	sbent
	xscenstackprep 48
	call memset
	sbxit
.endm

.macro dopserv_make_entry sym, reg
	lui	\reg,%hi(\sym)
	add \reg,\reg,%lo(\sym)
	srbse \reg
	srlmt %lo(\sym\()_len-1)(\reg)
.endm

.macro dopserv_strcmp_cmd2 CMD

	lui	a4,%hi(\CMD)
	add a4,a4,%lo(\CMD)
	srbse a4
	srlmt %lo(\CMD\()_len-1)(a4)
	srdlgm a4

	srdlg	a0  #this is a bit tricky: it's char *cmd returned by stdinread and we maybe would not like to keep it in this context in the next iteration, but cant srdlgm, because its not on top
	sbent
	srbse	-48(sp)
	srlmt	-1(sp)
	call	strcmp
	sbxit

.endm

.macro dopserv_strcmp_cmd

	lui	a4,%hi(cmdstrs)
	add a4,a4,%lo(cmdstrs)
	srbse a4
	srlmt %lo(cmdstrs_len-1)(a4)
	srdlgm a4

	srdlg	a0  #this is a bit tricky: it's char *cmd returned by stdinread and we maybe would not like to keep it in this context in the next iteration, but cant srdlgm, because its not on top
	sbent
	srbse	-48(sp)
	srlmt	-1(sp)
	call	strcmp
	sbxit

.endm

.macro dopserv_strcmp_cmd3

	lui	a4,%hi(cmdstrs)
	add a4,a4,%lo(cmdstrs)
	srbse a4
	srlmt %lo(cmdstrs_len-1)(a4)
	srdlgm a4

	srdlg	a0  #this is a bit tricky: it's char *cmd returned by stdinread and we maybe would not like to keep it in this context in the next iteration, but cant srdlgm, because its not on top
	sbent
	call	strcmp

.endm
