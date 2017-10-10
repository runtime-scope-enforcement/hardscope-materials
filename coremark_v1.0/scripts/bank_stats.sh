#!/bin/bash

grep BANK[AB] | sort -u -k 2n | awk 'NR==1{min=$2} {max=$2} END {print "MAX:",max;print "MIN:",min}'
