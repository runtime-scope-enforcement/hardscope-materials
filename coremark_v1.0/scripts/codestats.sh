#!/bin/bash

files=riscv/core_portme.[ch]" "core_*.c" "coremark.h

cloc $files
cflow $files
