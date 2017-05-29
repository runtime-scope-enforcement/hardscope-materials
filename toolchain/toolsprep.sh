#!/bin/bash

set -ue

apply_patch() {
  repodir=$1
  patch=$PWD/$2
  cd $repodir
  git apply $patch
  cd $OLDPWD
}

patches=patches
commit=cd78e37f72cfc2a452a0c11744586084fbae1dcd
riscvtools=riscv-tools
git clone https://github.com/riscv/riscv-tools.git $riscvtools
cd $riscvtools
git checkout $commit
git submodule update --init --recursive
cd $OLDPWD

apply_patch $riscvtools/riscv-isa-sim $patches/riscv-isa-sim.patch
apply_patch $riscvtools/riscv-gnu-toolchain/riscv-binutils-gdb $patches/riscv-binutils-gdb.patch
