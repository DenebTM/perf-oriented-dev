#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet07_preload_mimalloc
# Redirect output stream to this file
#SBATCH --output=output07_preload_mimalloc.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

basedir="/scratch/cb761236/perf-oriented-dev/exercises/sheet_07"
bench="$basedir/benchmark.sh"

set -e

module load cmake ninja llvm
mkdir -p "$basedir/preload"
cd "$basedir/preload"

# prepare mimalloc
if [ ! -d mimalloc ]; then
    git clone https://github.com/microsoft/mimalloc.git
fi
(
    cd mimalloc
    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -G Ninja ..
    ninja
)
_ld_preload="$basedir/preload/mimalloc/build/libmimalloc.so"

# prepare allscale_api source
if [ ! -d allscale_api ]; then
    git clone https://github.com/allscale/allscale_api.git
fi
mkdir -p allscale_api/build_preload_mimalloc
cd allscale_api/build_preload_mimalloc
cmake -DCMAKE_BUILD_TYPE=Release -G Ninja ../code

# run compile benchmark
results_filename="$basedir/preload/mimalloc.json"
"$bench" -o "$results_filename" -n 5 -p "ninja clean" -- \
    env LD_PRELOAD=$_ld_preload ninja
