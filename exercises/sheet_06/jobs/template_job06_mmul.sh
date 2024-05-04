#!/bin/bash

# gcc flags: ${GCC_FLAGS}

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet06_mmul_TI=${TI}_TK=${TK}
# Redirect output stream to this file
#SBATCH --output=output06_mmul_TI=${TI}_TK=${TK}.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

basedir="/scratch/cb761236/perf-oriented-dev"

module load gcc/12.2.0-gcc-8.5.0-p4pe45v

exe_name="mmul_TI=${TI}_TK=${TK}"
cd "$basedir"/exercises/sheet_06
(
    cd mmul_tiled/
    gcc -o "$exe_name" ${GCC_FLAGS} -DTI=${TI} -DTK=${TK} mmul.c
)

results_dir="mmul_tiled/results/"
results_filename="TI=${TI}_TK=${TK}.json"

mkdir -p "$results_dir"
./benchmark.sh -n 5 -e -0.1 -o "$results_dir"/"$results_filename" -- \
    mmul_tiled/"$exe_name"
