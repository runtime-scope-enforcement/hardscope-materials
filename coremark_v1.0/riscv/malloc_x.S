;#define HEAP_TOTAL (1000)

portable_malloc:
.global portable_malloc
  srbse -32(sp)
  srlmt -1(sp)
  add sp,sp,-32
  sw  ra,28(sp)
  sw  a0,24(sp)
#"real" malloc will do this on its own because it uses static
#;  lui t1,%hi(static_memblk)
#;  addi t1,t1,%lo(static_memblk)
##  srbse t1
#:  addi t1,t1,HEAP_TOTAL
#;  srlmt t1
#;  srdlgm t1
  sbent
  jal portable_malloc_1
  lw  ra,28(sp)
  lw  t1,24(sp)
  add t1,t1,a0
  srsub a0,-1(t1)
  srdlgm  a0
  add sp,sp,32
  sbxit
  jr  ra

