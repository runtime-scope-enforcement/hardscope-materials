#!/bin/bash

set -ue

heading() {
  d=$1
  shift
  echo $*
  echo $* | tr -c $d $d
  echo
}

heading2() {
  heading - $*
}

heading1() {
  heading = $*
}

benchnums() {
#depth of deepest call chain: 11
echo -n "depth of deepest call chain: "
${SCRIPTDIR}/srs_stats.sh <$out1 | tail -n1 | awk '{print $3}'

#number of SRS entries per frame (min, max): 23, 1
echo -n "number of SRS entries per frame (min, max): "
${SCRIPTDIR}/bank_stats.sh <$out1 | awk '/MAX/{max=$2} /MIN/{min=$2} END {print min", "max}'

#maximum number of SRS frames: 11
echo maximum number of SRS frames: $(${SCRIPTDIR}/srs_stats.sh <$out1 | tail -n1 | awk '{print $3}')

#maximum number of SRS entries in whole stack: 
echo -n "maximum number of SRS entries in whole stack: "
${SCRIPTDIR}/ctxswitchstats.sh <$out2 | awk '$5>0{max=$1} END{print max}'

#sbent: 250950
#sbxit: 250950
#srbse: 282810
#srlmt: 282810
#srdlg: 274552
#srdlgm: 130924
#srsub: 130924
for i in sbent sbxit srbse srlmt srdlg srdlgm srsub; do
  echo -n "$i: "
  ${SCRIPTDIR}/instr_stats.sh <$out2 | tr -d : | awk "/$i[: ]/ {print \$3}"
done
#total stall cycles: 77080
echo -n "total stall cycles: "
${SCRIPTDIR}/instr_stats.sh <$out2 | awk '/total stalling due to fast ctx switches: /{print $NF}'
#total instructions: 34890187
echo -n "total instructions: "
${SCRIPTDIR}/instr_stats.sh <$out2 | awk '/Cycles reported by CPU: /{print $NF}'
#total clock cycles: 35235467
echo -n "total clock cycles: "
${SCRIPTDIR}/instr_stats.sh <$out2 | awk '/total approximated cycles: /{print $NF}'
#total clock cycles in non-instrumented: 33280710 
echo -n "total clock cycles in non-instrumented: "
out2std=${out2/-xscen/}
${SCRIPTDIR}/instr_stats.sh <$out2std | awk '/Cycles reported by CPU: /{print $NF}'
}

bin=$1
out1=${bin}.stdout
out2=${bin}.stderr
SCRIPTDIR="$PWD/$(dirname $0)"

heading1 CONTEXT SWITCH STATISTICS
${SCRIPTDIR}/ctxswitchstats.sh <$out2
echo

heading1 SRS STATISTICS
${SCRIPTDIR}/srs_stats.sh <$out1
echo
heading1 BANK STATISTICS
${SCRIPTDIR}/bank_stats.sh <$out1
echo

heading1 CYCLE COUNT AND INSTRUCTION STATISTICS
heading2 xscen
${SCRIPTDIR}/instr_stats.sh <$out2
if grep -q sbent <$out1;then
  echo
  heading2 vanilla
  out2std=${out2/-xscen/}
  ${SCRIPTDIR}/instr_stats.sh <$out2std
fi

heading1 REPORT
benchnums
