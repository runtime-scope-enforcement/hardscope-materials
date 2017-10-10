#!/bin/bash

TESTDIR=tests
PLUGIN=$PWD/scen.so
set -ue

testname=$1
shift

[ -e "${TESTDIR}/${testname}.c" ] || ! echo file does not exist  || exit 1

make scen.so
mkdir -p ${TESTDIR}/${testname}
cd ${TESTDIR}/${testname}
riscv32-unknown-elf-gcc $* -mxscen -da -fdump-tree-all -S -fplugin=${PLUGIN} -o ${testname}.s ${OLDPWD}/${TESTDIR}/${testname}.c
cd -
make -B ${TESTDIR}/${testname}.o
