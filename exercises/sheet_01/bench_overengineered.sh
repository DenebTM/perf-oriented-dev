#!/usr/bin/env bash

# make C-c kill the whole script
quit() { exit 130; }
trap quit SIGINT
trap quit SIGTERM

# benchmark script (must be in same directory as this script)
bench="$PWD"/benchmark.sh

# where to cd before running program
workdir=/tmp

# programs to run
progs=(delannoy filegen filesearch mmul nbody qap)

# where the sample programs are located (required)
small_samples_path="$1"
if [[ -z "$small_samples_path" ]]; then
    echo "Usage: $0 <path/to/small_samples> [<path/to/save/results>]"
    exit 1
fi
small_samples_path="$(realpath $small_samples_path)"

# where results JSON files should be stored (optional)
results_path="results"
if [[ ! -z "$2" ]]; then
    results_path="$2"
fi
results_path="$(realpath $results_path)"

# comma-separated lists of space-separated parameter sets to use for each program
progs_params=(
    # delannoy
    "$(seq -s',' 1 12),"
    # filegen
    "1000 1 1 1,10000 1 1 1,100000 1 1 1,1000000 1 1 1,1 1000 1 1,1 10000 1 1,1 100000 1 1,1 1000000 1 1,1 1 10000 10000,1 1 100000 100000,1 1 1000000 1000000,1 1 10000000 10000000,1 1 100000000 100000000,"
    # filesearch
    ",,,,,"
    # mmul
    ""
    # nbody
    ""
    # qap
)

function mkcd { mkdir $1 && cd $1; }

# commands to run before each benchmark
# (one per set of parameters)
progs_prepare=(
    # delannoy
    ""
    # filegen
    ""
    # filesearch
    "mkcd $$_r1; $small_samples_path/build/filegen 1 100 1 10000,mkcd $$_r2; $small_samples_path/build/filegen 1 10000 1 10000,mkcd $$_r3; $small_samples_path/build/filegen 100 1 1 10000,mkcd $$_r4; $small_samples_path/build/filegen 100 100 1 10000,mkcd $$_r5; $small_samples_path/build/filegen 10000 1 1 10000,"
    # mmul
    ""
    # nbody
    ""
    # qap
    ""
)

# commands to run before each benchmark
# (shared between all parameter sets)
progs_cleanup=(
    # delannoy
    ""
    # filegen
    "rm -rf generated/"
    # filesearch
    "cd ..; rm -rf $$_r*"
    # mmul
    ""
    # nbody
    ""
    # qap
    ""
)

# build everything
(
    cd "$small_samples_path"
    mkdir -p build && cd build
    cmake ..
    make -j$(nproc)
    echo
)

for ((i=0; i < ${#progs[@]}; i++)); do
    prog="${progs[i]}"

    echo
    echo "Program: $prog"

    parlists="${progs_params[i]}"
    IFS=',' read -ra parlists <<< "$parlists"

    prepares="${progs_prepare[i]}"
    IFS=',' read -ra prepares <<< "$prepares"

    cleanup="${progs_cleanup[i]}"
    echo "$cleanup"

    mkdir -p "$results_path"/"$prog"
    for ((j=0; j < ${#parlists[@]}; j++)); do (
        parlist="${parlists[j]}"
        prepare="${prepares[j]}"

        echo "Preparing..."
        cd "$workdir"
        eval $prepare

        $bench -q -o "$results_path"/"$prog"/"$parlist".json -- \
            "$small_samples_path"/build/"$prog" $parlist

        eval $cleanup
    ); done

    echo
done
