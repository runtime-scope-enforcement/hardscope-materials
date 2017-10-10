CC=riscv32-unknown-elf-gcc -Xassembler '-march=rv32ixscen'
OBJDUMP=riscv32-unknown-elf-objdump
RISCV_GCC_BARE_LNK_OPTS=-ffreestanding -nostartfiles
RISCV_GCC_OPTS=
RISCV_LIBGCC_FILE=bare/libgcc.a
demobin=dopserv.noio.bare dopserv.noio.bare.attack dopserv.noio.bare.wlibc.xscen dopserv.noio.bare.wlibc.xscen.attack

.PHONY: all clean demo

all: dopserv dopserv.noio.*

demo: $(demobin)

clean:
	rm -f dopserv bare/crt.o bare/syscalls.o bare/syscalls.xscen.o bare/libc.xscen.o dopserv.noio.bare.o $(demobin)

dopserv.noio.bare.wlibc.xscen.attack: bare/crt.o bare/syscalls.xscen.o bare/bare.ld dopserv.noio.bare.wlibc.xscen.S dopserv_noio_attack.c bare/libc.xscen.o xscen-macros.S
	$(CC) -Tbare/bare.ld $(RISCV_GCC_BARE_LNK_OPTS) -static -nostdlib -Lbare -o $@ dopserv.noio.bare.wlibc.xscen.S bare/syscalls.xscen.o $(RISCV_LIBGCC_FILE) dopserv_noio_attack.c bare/libc.xscen.o

dopserv.noio.bare.wlibc.xscen: bare/crt.o bare/syscalls.xscen.o bare/bare.ld dopserv.noio.bare.wlibc.xscen.S dopserv_noio.c bare/libc.xscen.o xscen-macros.S
	$(CC) -Tbare/bare.ld $(RISCV_GCC_BARE_LNK_OPTS) -static -nostdlib -Lbare -o $@ dopserv.noio.bare.wlibc.xscen.S bare/syscalls.xscen.o $(RISCV_LIBGCC_FILE) dopserv_noio.c bare/libc.xscen.o

dopserv.noio.bare.attack: bare/crt.o bare/syscalls.o bare/bare.ld dopserv.noio.bare.o dopserv_noio_attack.c bare/libc.c
	$(CC) -Tbare/bare.ld $(RISCV_GCC_BARE_LNK_OPTS) -static -nostdlib -Lbare -o $@ dopserv.noio.bare.o bare/syscalls.o $(RISCV_LIBGCC_FILE) dopserv_noio_attack.c bare/libc.c

dopserv.noio.bare: bare/crt.o bare/syscalls.o bare/bare.ld dopserv.noio.bare.o dopserv_noio.c bare/libc.c
	$(CC) -Tbare/bare.ld $(RISCV_GCC_BARE_LNK_OPTS) -static -nostdlib -Lbare -o $@ dopserv.noio.bare.o bare/syscalls.o $(RISCV_LIBGCC_FILE) dopserv_noio.c bare/libc.c

bare/syscalls.S: bare/syscalls.c
	$(CC) -DBARE -static -fno-stack-protector $(RISCV_GCC_OPTS) -S -o $@ $<

bare/syscalls.xscen.o: bare/syscalls.xscen.S xscen-macros.S
	$(CC) -DBARE -static -fno-stack-protector $(RISCV_GCC_OPTS) -c -o $@ $<

bare/libc.xscen.o: bare/libc.xscen.S xscen-macros.S
	$(CC) -DBARE -static -fno-stack-protector $(RISCV_GCC_OPTS) -c -o $@ $<

dopserv.noio.bare.o: dopserv.c
	$(CC) -DBARE -static -fno-stack-protector $(RISCV_GCC_OPTS) -c -o $@ $<

bare/crt.o: bare/crt.S
	$(CC) -static $(RISCV_GCC_OPTS) -Wall -c -o $@ $<

bare/syscalls.o: bare/syscalls.c
	$(CC) -static $(RISCV_GCC_OPTS) -Wall -c -o $@ $<
	
dopserv: dopserv.c dopserv.h
	$(CC) -Wall -fno-stack-protector -o $@ -Wl,--section-start=.data=01ff0000 dopserv.c

dopserv_noio_attack.c: exploit.py
	echo 'char stdinbuf[] = {' >$@
	./$^ | xxd -i >>$@
	echo -n ',' >>$@
	echo QUIT | xxd -i >>$@
	echo '};' >>$@

insns.log: dopserv.noio.bare.wlibc.xscen
	spike ./dopserv.noio.bare.wlibc.xscen 2>/dev/null | grep -E 'sbent|sbxit|srbse|srlmt|srdlg|srdlgm .*pc=' | awk 'NF==2 {print $$0} NF==3 {print $$1,$$3}' >insns.log

insns.stat: insns.log
	sort insns.log | uniq -c |sort -n >insns.stat

code.stats: dopserv.c dopserv_noio.c dopserv.h bare/libc.c bare/syscalls.libfuns.c
	cloc dopserv.c dopserv_noio.c dopserv.h bare/libc.c bare/syscalls.libfuns.c >code.stats
	cflow dopserv.c dopserv_noio.c dopserv.h bare/libc.c bare/syscalls.c >>code.stats
