#!/bin/bash

cat <<EOF
  x
      number of context switches where last context switch happened x cycles ago
             number of context switches where x entries had to be moved to/from the cache
                       number of context switches where processor had to stall for x cycles
                              context switches where total stack entries was x
EOF

awk '/^ *[0-9]*: / && int($1) >= 0{
printf "%3d %7d %7d %7d %7d\n",$1+1,$2,$5,$6,$7
a+=$2
b+=$5
c+=$6*int($1)
}
END {printf "%3s %7d %7d %7d\n","tot",a,b,c}'
