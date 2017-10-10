#!/bin/bash

set -u

makeabin() {
  RUN=$1
  MEM=$2
  ITER=$3
  PULPINO=$4
  XSCEN=$5

  make=make
  make="${make} PORT_DIR=riscv"
  make="${make} ITERATIONS=${ITER}"

  binname=coremark
  if [ $PULPINO -ne 0 ]; then
    binname=${binname}-pulpino
    make="${make} PULPINO=1"
  else
    binname=${binname}-riscvpk
  fi
  if [ $XSCEN -ne 0 ]; then
    binname=${binname}-xscen
    make="${make} XSCEN=1"
  fi
  binname=${binname}-${RUN,,.*}x${ITER}
  binname=${binname}.bin

  xcflags="XCFLAGS="
  xcflags="${xcflags}-D${RUN^^*}_RUN=1 "
  xcflags="${xcflags}-DMEM_METHOD=MEM_${MEM^^*} "
  #xcflags=${xcflags}

  ${make} "${xcflags}" coremark.bin &>/dev/null
  if [ $? -ne 0 ]; then
    echo make failed for build $binname $* >&2
    return 1
  fi
  mv coremark.bin build/${binname}
  riscv-disas.sh build/${binname} >build/${binname}.disas

  echo build/${binname}
}

bins1() {
  mem=static
  for it in 1 100; do
    for x in 0 1; do
      makeabin profile $mem $it 1 $x
      makeabin performance $mem $it 1 $x
      makeabin validation $mem $it 1 $x
    done
  done
}

binnames=$(bins1)
for binname in ${binnames}; do
  spike-pulp --xscen=1 ${binname} 1>${binname}.stdout 2>${binname}.stderr
  if [ $? -ne 0 ]; then
    echo spike run failed $binname
  else
    echo spike run ok: $binname 
  fi

  [[ ${binname} =~ x1\.bin ]] || continue
  spike-pulp --xscen=2 ${binname} 1>${binname}.stdout-dbg 2>${binname}.stderr-dbg
  if [ $? -ne 0 ]; then
    echo spike debug run failed $binname
  else
    echo spike debug run ok: $binname 
  fi
done

#PORT_DIR
#RISCV
#PULPINO
#XSCEN
#MEM_METHOD
#PROFILE_RUN
#PERFORMANCE_RUN
#VALIDATION_RUN
