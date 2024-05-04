#!/bin/bash

# gcc flags: -O3 -march=native

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet06_latency
# Redirect output stream to this file
#SBATCH --output=output06_latency.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

basedir="/scratch/cb761236/perf-oriented-dev"

module load gcc/12.2.0-gcc-8.5.0-p4pe45v

exe_name="latency"
cd "$basedir"/exercises/sheet_06
(
    cd latency/
    gcc -o "$exe_name" -O3 -march=native latency.c
)

results_filename="latency_LCC3.dat"
latency/"$exe_name" > /tmp/"$results_filename"
mv /tmp/"$results_filename" .
