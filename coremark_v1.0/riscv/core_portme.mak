#File : core_portme.mak

#ITERATIONS = 100
# Flag : OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o
# Flag : CC
#	Use this flag to define compiler to use
CC = riscv32-unknown-elf-gcc
# Flag : CFLAGS
#	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
#PORT_CFLAGS = -O2
ifdef XSCEN
PORT_CFLAGS = -Xassembler -march=rv32ixscen -mxscen -mxscendbg -fplugin=../scen-plug/scen.so
else
PORT_CFLAGS = -Xassembler -march=rv32i
endif
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS) $(XLFLAGS) $(LFLAGS_END)"
CFLAGS = $(PORT_CFLAGS) -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"
#Flag : LFLAGS_END
#	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts). 
#	Note : On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
ifdef PULPINO
LFLAGS_END = -T$(PORT_DIR)/pulpino/pulpino.ld -static -nostdlib -I$(PORT_DIR)/pulpino
else
LFLAGS_END = 
endif
# Flag : PORT_SRCS
# 	Port specific source files can be added here
ifdef XSCEN
PORT_SRCS = $(PORT_DIR)/core_portme.c
#$(PORT_DIR)/malloc.c $(PORT_DIR)/malloc_x.S
else
PORT_SRCS = $(PORT_DIR)/core_portme.c
endif
ifdef PULPINO
PORT_SRCS += $(PORT_DIR)/pulpino/crt0-pulpino.S
endif
# Flag : LOAD
#	For a simple port, we assume self hosted compile and run, no load needed.

# Flag : RUN
#	For a simple port, we assume self hosted compile and run, simple invocation of the executable

#For native compilation and execution
LOAD = echo Loading done
RUN = 

OEXT = .o
ifdef PULPINO
EXE = .bin
else
EXE = .exe
endif

# Target : port_pre% and port_post%
# For the purpose of this simple port, no pre or post steps needed.

.PHONY : port_prebuild port_postbuild port_prerun port_postrun port_preload port_postload
port_pre% port_post% : 

# FLAG : OPATH
# Path to the output folder. Default - current folder.
OPATH = ./
MKDIR = mkdir -p

