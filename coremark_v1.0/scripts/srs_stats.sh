#!/bin/bash

grep STACK | sort | uniq -c | sort -k 3n
