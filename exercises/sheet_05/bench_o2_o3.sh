#!/usr/bin/env bash

bench="./benchmark.sh"

run_benchmark() {
    
}

progs=(
    ""
)

opts=(
    "-fgcse-after-reload"
    "-fipa-cp-clone"
    "-floop-interchange"
    "-floop-unroll-and-jam"
    "-fpeel-loops"
    "-fpredictive-commoning"
    "-fsplit-loops"
    "-fsplit-paths"
    "-ftree-loop-distribution"
    "-ftree-partial-pre"
    "-funroll-completely-grow-size"
    "-funswitch-loops"
    "-fvect-cost-model=dynamic"
    "-fversion-loops-for-strides"
)

for opt in "${opts[@]}"; do
    
done
