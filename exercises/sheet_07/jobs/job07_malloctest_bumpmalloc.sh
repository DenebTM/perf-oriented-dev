#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet07_malloctest_bumpmalloc
# Redirect output stream to this file
#SBATCH --output=output07_malloctest_bumpmalloc.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

basedir="/scratch/cb761236/perf-oriented-dev"
bench="$basedir/exercises/sheet_07/benchmark.sh"

set -e

module load $(module avail -t | grep -E '^llvm')
cd "$basedir/exercises/sheet_07/bumpmalloc"

# prepare bumpmalloc
if [ ! -f bumpmalloc.so ]; then
  make bumpmalloc.so
fi
_ld_preload="$PWD/bumpmalloc.so"

# prepare malloctest
(
    cd "$basedir/tools/malloctest"
    if [ ! -f malloctest ]; then
        clang -o malloctest -O3 -march=native malloctest.c 
    fi
)

exe="$basedir/tools/malloctest/malloctest"

# run malloctest benchmark
results_filename="$basedir/bumpmalloc/malloctest_bumpmalloc.json"
"$bench" -o "$results_filename" -n 5 -- \
    env LD_PRELOAD="$_ld_preload" \
    "$exe" 1 500 1000000 10 1000
