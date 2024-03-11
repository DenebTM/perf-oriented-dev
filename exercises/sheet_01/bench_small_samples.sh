#!/usr/bin/env bash

# make C-c kill the whole script
quit() { exit 130; }
trap quit SIGINT
trap quit SIGTERM

function mkcd { mkdir -p $1 && cd $1; }

function print_usage {
    echo "Usage: $0 <path/to/small_samples> <path/to/workdir> <list of programs...>"
    exit 1
}

# benchmark script (must be in same directory as this script)
bench="$PWD"/benchmark.sh

# where results JSON files will be stored
results_path=$(realpath "results/")

# where the sample programs are located (from cmdline)
small_samples_path="$1"
[[ -z "$small_samples_path" ]] && print_usage
small_samples_path="$(realpath $small_samples_path)"

# where to cd before running program
workdir="$2"
[[ -z "$workdir" ]] && print_usage

# which benchmarks to run (from cmdline)
benchmarks="${@:3}"
[[ -z "${benchmarks[@]}" ]] && print_usage


# build everything
(
    cd "$small_samples_path"
    mkcd build/
    cmake ..
    make -j$(nproc) $benchmarks
    echo
)


# benchmark delannoy
prog=delannoy
case "$benchmarks" in *$prog*)
    parlists=($(seq 1 15))

    mkdir -p "$results_path"/"$prog"
    for parlist in "${parlists[@]}"; do (
        $bench -q -o "$results_path"/"$prog"/"$parlist".json -- \
            "$small_samples_path"/build/"$prog" $parlist
    ); done
esac

# benchmark filegen
prog=filegen
case "$benchmarks" in *$prog*)
    parlists=(
        "1000 1 1 1"
        "10000 1 1 1"
        "100000 1 1 1"
        "1000000 1 1 1"
        "1 1000 1 1"
        "1 10000 1 1"
        "1 100000 1 1"
        "1 1000000 1 1"
        "1 1 10000 10000"
        "1 1 100000 100000"
        "1 1 1000000 1000000"
        "1 1 10000000 10000000"
        "1 1 100000000 100000000"
    )

    mkdir -p "$results_path"/"$prog"
    for parlist in "${parlists[@]}"; do (
        cd $workdir
        rm -rf generated/

        $bench -q -o "$results_path"/"$prog"/"$parlist".json -- \
            "$small_samples_path"/build/"$prog" $parlist

        rm -rf generated/
    ); done
esac


# benchmark filesearch
prog=filesearch
case "$benchmarks" in *$prog*)
    prepare_parlists=(
        "1 1000 1 10000"
        "1 1000000 1 10000"
        "1000 1 1 10000"
        "1000 1000 1 10000"
        "1000000 1 1 10000"
        "1000000 1 1 1"
    )

    mkdir -p "$results_path"/"$prog"
    for parlist in "${prepare_parlists[@]}"; do (
        cd $workdir

        echo "Preparing files ($parlist)..."
        rm -rf generated/
        "$small_samples_path"/build/filegen $parlist
        cd generated/

        $bench -q -o "$results_path"/"$prog"/"$parlist".json -- \
            "$small_samples_path"/build/"$prog"

        rm -rf generated/
    ); done
esac


# benchmark mmul
prog=mmul
case "$benchmarks" in *$prog*)
    mkdir -p "$results_path"/"$prog"

    $bench -q -o "$results_path"/"$prog"/"$prog".json -- \
        "$small_samples_path"/build/"$prog"
esac


# benchmark nbody
prog=nbody
case "$benchmarks" in *$prog*)
    mkdir -p "$results_path"/"$prog"

    $bench -q -o "$results_path"/"$prog"/"$prog".json -- \
        "$small_samples_path"/build/"$prog"
esac


# benchmark qap
prog=qap
case "$benchmarks" in *$prog*) (
    cd "$small_samples_path"/"$prog"/
    parlists=(
        "chr10a.dat"
        "chr12a.dat"
        "chr12b.dat"
        "chr12c.dat"
        "chr15a.dat"
        "chr15b.dat"
        "chr15c.dat"
    )

    mkdir -p "$results_path"/"$prog"
    for parlist in "${parlists[@]}"; do (
        json_filename="$(basename "${parlist%%.dat}").json"

        $bench -o "$results_path"/"$prog"/"$json_filename" -- \
            "$small_samples_path"/build/"$prog" $parlist
    ); done
); esac
