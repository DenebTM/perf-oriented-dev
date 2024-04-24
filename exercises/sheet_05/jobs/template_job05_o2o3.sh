#!/bin/bash

# gcc flags: -O2 $TESTFLAG

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet05_o2o3_$TESTFLAG
# Redirect output stream to this file
#SBATCH --output=output05_o2o3_$TESTFLAG.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive
# More than 1 core
#SBATCH --cpus-per-task=8

basedir=/scratch/cb761236/perf-oriented-dev

module load gcc/12.2.0-gcc-8.5.0-p4pe45v
module load cmake/3.24.3-gcc-8.5.0-svdlhox

cd $basedir/exercises/sheet_05
(
    cd test_cases
    mkdir -p -- "build_$TESTFLAG" && cd -- "build_$TESTFLAG"
    cmake -DCMAKE_C_FLAGS="-O2 $TESTFLAG" ..
    make -j$(nproc)
)

progs=(
    "mmul"
    "nbody"
    "qap test_cases/qap/chr15c.dat"
    "delannoy 13"
    "npb_bt_w"
    "ssca2 15"
)

for prog in "${progs[@]}"; do
    outfilename="$TESTFLAG.json"
    if [ "$outfilename" == ".json" ]; then
        outfilename="none.json"
    fi
    prog_args=($prog)
    outdir=results/${prog_args[0]}
    mkdir -p "$outdir"
    ./benchmark.sh -n 10 -o "$outdir"/"$TESTFLAG".json -- \
        test_cases/"build_$TESTFLAG"/$prog
done
