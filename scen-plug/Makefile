.PHONY: clean

#disable some implicit rules
%.o : %.s
%.o : %.c

testdir=tests
plugin=./scen.so
RISCVCC=riscv32-unknown-elf-gcc
TESTS=$(notdir $(basename $(wildcard $(testdir)/test_*.c)))
GCC_HEADERS=$(RISCV)/lib/gcc/riscv32-unknown-elf/6.1.0/plugin/include/
RISCV_GCC_BARE_LNK_OPTS=-Tbare/bare.ld -static -nostdlib -Lbare
RISCV_GCC_PULPINO_LNK_OPTS=-Tbare/pulpino/pulpino.ld -static -nostdlib -Ibare/pulpino
PULPINO_MALLOC=bare/pulpino/malloc.c bare/pulpino/malloc_x.S

.PHONY: test_targets
test_targets:
	echo $(TESTS)
	echo $(wildcard $(testdir)/testhelp_*.[Scs])
	
.PHONY: tests
tests: $(addprefix $(testdir)/, $(addsuffix .o, $(TESTS)))

$(testdir)/test_%-pulpino.s: $(testdir)/test_%.c
	$(RISCVCC) -mxscen -fplugin=$(plugin) -Xassembler -march=rv32ixscen -S $(RISCV_GCC_PULPINO_LNK_OPTS) -o $@ $<

$(testdir)/test_%.disas: $(testdir)/test_%.bin
	riscv-disas.sh $< >$@

$(testdir)/test_%.trace: $(testdir)/test_%.bin
	spike-pulp --xscen=2 $< 2>/dev/null 1>$@
	spike-pulp --xscen=2 $< 2>>$@       1>/dev/null

$(testdir)/test_%-pulpino.bin: $(testdir)/test_%.c bare/pulpino/crt0-pulpino.S
	$(RISCVCC) -mxscen -fplugin=$(plugin) -Xassembler -march=rv32ixscen $(RISCV_GCC_PULPINO_LNK_OPTS) -o $@ $^ $(wildcard $(basename $(subst test_,testhelp_,$<)).[Scs])

$(testdir)/test_%.bin: $(testdir)/test_%.c
	$(RISCVCC) -mxscen -fplugin=$(plugin) -Xassembler -march=rv32imxscen $(RISCV_GCC_BARE_LNK_OPTS) -o $@ $< bare/syscalls.S -lgcc

$(testdir)/test_%.o: $(testdir)/test_%.s
	$(RISCVCC) -mxscen -fplugin=$(plugin) -Xassembler -march=rv32imxscen -o $@ $< $(wildcard $(basename $(subst test_,testhelp_,$<)).[Scs])

$(testdir)/test_%.s: $(testdir)/test_%.c
	$(RISCVCC) -mxscen -S -fplugin=$(plugin) -o $@ $<

scen.so: scen.o
	g++ -std=c++11 -ggdb -shared -o $@ $<

scen.o: scen.cpp scen.h
	g++ -std=c++11 -ggdb -fno-rtti -fPIC -Wall -I$(GCC_HEADERS) -c -o $@ $<

clean:
	rm -f tests/test_*/test_*.c.*r.*
	rm -f tests/test_*/test_*.c.*t.*
	rm -f tests/test_*/test_*.c.*i.*
	rm -f tests/test_*.s tests/test_*.o
