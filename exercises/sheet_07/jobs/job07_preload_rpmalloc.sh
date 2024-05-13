#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet07_preload_rpmalloc
# Redirect output stream to this file
#SBATCH --output=output07_preload_rpmalloc.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

basedir="/scratch/cb761236/perf-oriented-dev/exercises/sheet_07"
bench="$basedir/benchmark.sh"

set -e

module load $(module avail -t | grep -E '^(cmake|ninja|llvm)')
mkdir -p "$basedir/preload"
cd "$basedir/preload"

# prepare rpmalloc
if [ ! -d rpmalloc ]; then
    git clone https://github.com/mjansson/rpmalloc.git
fi
(
    cd rpmalloc
    module load $(module avail -t | grep '^python/3.10')
    ./configure.py
    sed -i 's/-W /-W -Wno-unknown-warning-option/g' build.ninja
    ninja
)
_ld_preload="$basedir/preload/rpmalloc/bin/linux/release/x86-64/librpmalloc.so"

# prepare allscale_api source
if [ ! -d allscale_api ]; then
    git clone https://github.com/allscale/allscale_api.git
fi
mkdir -p allscale_api/build_preload_rpmalloc
cd allscale_api/build_preload_rpmalloc
cmake -DCMAKE_BUILD_TYPE=Release -G Ninja ../code

# run compile benchmark
results_filename="$basedir/preload/rpmalloc.json"
"$bench" -o "$results_filename" -n 5 -- \
    bash -c "ninja clean; LD_PRELOAD=$_ld_preload ninja"
