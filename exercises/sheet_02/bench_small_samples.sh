#!/usr/bin/env bash

# make C-c kill the whole script
quit() { exit 130; }
trap quit SIGINT
trap quit SIGTERM

function mkcd { mkdir -p $1 && cd $1; }

function print_usage {
    echo "Usage: $0 [--loadgen <path/to/tools>] <path/to/small_samples> <path/to/workdir> <list of programs...>"
    exit 1
}

# benchmark script + arguments (must be in same directory as this script)
#bench="$PWD/benchmark.sh -q"
bench="$PWD/benchmark.sh"

# where results JSON files will be stored
results_path=$(realpath "results/")

# whether or not to run `loadgen` in the background
tools_path=""
bench_wrapper=""
if [[ "$1" == "--loadgen" ]]; then
    tools_path="$(realpath "$2")"
    bench_wrapper="$PWD/exec_with_workstation_heavy.sh $tools_path"
    results_path_append="_loadgen"
    shift 2
fi

# where the sample programs are located (from cmdline)
small_samples_path="$1"
[[ -z "$small_samples_path" ]] && print_usage
small_samples_path="$(realpath "$small_samples_path")"

# where to cd before running program
workdir="$2"
[[ -z "$workdir" ]] && print_usage
if [[ ! -d "$workdir" ]]; then
    if [[ -e "$workdir" ]]; then
        echo "$workdir is not a directory"
        exit 2
    fi
    mkdir -p "$workdir"
fi

# which benchmarks to run (from cmdline)
benchmarks="${@:3}"
[[ -z "${benchmarks[@]}" ]] && print_usage

# run benchmark until statistical error does not exceed this value
bench_max_err=0.05
# maximum benchmark passes before giving up on reaching error bound (0 => inf)
bench_max_runs=30


# (re-)build everything
(
    cd "$small_samples_path"
    mkcd build/
    cmake ..
    make -j$(nproc) $benchmarks
    echo

    if [[ ! -z "$tools_path" ]]; then
        cd "$tools_path"
        mkcd build/
        cmake ..
        make -j$(nproc) loadgen
    fi
)


# benchmark delannoy
prog=delannoy
case "$benchmarks" in *$prog*)
    parlists=($(seq 1 15))

    mkdir -p "$results_path"/"$prog""$results_path_append"
    for parlist in "${parlists[@]}"; do (
        $bench -o "$results_path"/"$prog""$results_path_append"/"$parlist".json \
            -n "$bench_max_runs" -e "$bench_max_err" -- \
            $bench_wrapper \
            "$small_samples_path"/build/"$prog" $parlist
    ); done
esac

# benchmark filegen
prog=filegen
case "$benchmarks" in *$prog*)
    parlists=(
        "1000 1 1 1"
        "10000 1 1 1"
        "1 1000 1 1"
        "1 10000 1 1"
        "1 1 10000 10000"
        "1 1 100000 100000"
        "1 1 1000000 1000000"
        "1 1 10000000 10000000"
        "1 1 100000000 100000000"
    )

    mkdir -p "$results_path"/"$prog""$results_path_append"
    for parlist in "${parlists[@]}"; do (
        cd $workdir
        rm -rf generated/

        $bench -o "$results_path"/"$prog""$results_path_append"/"$parlist".json \
            -n "$bench_max_runs" -e "$bench_max_err" -- \
            $bench_wrapper \
            "$small_samples_path"/build/"$prog" $parlist

        rm -rf generated/
    ); done
esac


# benchmark filesearch
prog=filesearch
case "$benchmarks" in *$prog*)
    prepare_parlists=(
        "1 100 1 1000"
        "1 10000 1 1000"
        "100 1 1 1000"
        "100 100 1 10000"
        "10000 1 1 10000"
        "10000 1 1 1"
    )

    mkdir -p "$results_path"/"$prog""$results_path_append"
    for parlist in "${prepare_parlists[@]}"; do (
        cd $workdir

        echo "Preparing files ($parlist)..."
        rm -rf generated/
        "$small_samples_path"/build/filegen $parlist
        cd generated/

        $bench -o "$results_path"/"$prog""$results_path_append"/"$parlist".json \
            -n "$bench_max_runs" -e "$bench_max_err" -- \
            $bench_wrapper \
            "$small_samples_path"/build/"$prog"

        rm -rf generated/
    ); done
esac


# benchmark mmul
prog=mmul
case "$benchmarks" in *$prog*)
    mkdir -p "$results_path"/"$prog""$results_path_append"

    $bench -o "$results_path"/"$prog""$results_path_append"/"$prog".json \
        -n "$bench_max_runs" -e "$bench_max_err" -- \
        $bench_wrapper \
        "$small_samples_path"/build/"$prog"
esac


# benchmark nbody
prog=nbody
case "$benchmarks" in *$prog*)
    mkdir -p "$results_path"/"$prog""$results_path_append"

    $bench -o "$results_path"/"$prog""$results_path_append"/"$prog".json \
        -n "$bench_max_runs" -e "$bench_max_err" -- \
        $bench_wrapper \
        "$small_samples_path"/build/"$prog"
esac


# benchmark qap
prog=qap
case "$benchmarks" in *$prog*) (
    cd "$small_samples_path"/"$prog"/
    parlists=(
        "problems/chr10a.dat"
        "problems/chr12a.dat"
        "problems/chr12b.dat"
        "problems/chr12c.dat"
        "problems/chr15a.dat"
        "problems/chr15b.dat"
        "problems/chr15c.dat"
    )

    mkdir -p "$results_path"/"$prog""$results_path_append"
    for parlist in "${parlists[@]}"; do (
        json_filename="$(basename "${parlist%%.dat}").json"

        $bench -o "$results_path"/"$prog""$results_path_append"/"$json_filename" \
            -n "$bench_max_runs" -e "$bench_max_err" -- \
            $bench_wrapper \
            "$small_samples_path"/build/"$prog" $parlist
    ); done
); esac
