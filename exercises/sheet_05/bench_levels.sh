#!/usr/bin/env bash

workdir="$(realpath .)"
bench="$(realpath ./benchmark.sh)"

# return 77 from subshell to kill script
set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

progs=(
    "mmul"
    "nbody"
    "qap $workdir/test_cases/qap/chr15c.dat"
    "delannoy 13"
    "npb_bt_w"
    "ssca2 15"
)

levels=("-O0" "-O1" "-O2" "-O3" "-Os" "-Ofast")

(
    cd test_cases
    for level in "${levels[@]}"; do (
        builddir="build_$level"
        mkdir -p "$builddir" && cd "$builddir" \
        || ( echo "Could not create or enter directory $builddir"; exit 77 )

        cmake -DCMAKE_C_FLAGS="$level" ..
        make -j$(nproc)

        for prog in "${progs[@]}"; do (
            prog_args=($prog)
            
            results_dir="$workdir/results/$prog_args"
            mkdir -p "$results_dir"
            "$bench" -n 10 -o "$results_dir/$level.json" -- ./${prog_args[*]}
        ); done
    ); done
)
