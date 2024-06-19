#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva

# Name your job to be able to identify it later
#SBATCH --job-name benchmark_ex10

# Redirect output stream to this file
#SBATCH --output=benchmark.log

# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

/bin/hostname
# run script
/bin/time ./benchmark_ll 10000 1 99 0
/bin/time ./benchmark_ll 10000 10 90 0
/bin/time ./benchmark_ll 10000 50 50 0
/bin/time ./benchmark_ll 10000 90 10 0
/bin/time ./benchmark_ll 10000 99 1 0

/bin/time ./benchmark_ll 10000 1 99 1
/bin/time ./benchmark_ll 10000 10 90 1
/bin/time ./benchmark_ll 10000 50 50 1
/bin/time ./benchmark_ll 10000 90 10 1
/bin/time ./benchmark_ll 10000 99 1 1

/bin/time ./benchmark_arr 10000 1 99 0
/bin/time ./benchmark_arr 10000 10 90 0
/bin/time ./benchmark_arr 10000 50 50 0
/bin/time ./benchmark_arr 10000 90 10 0
/bin/time ./benchmark_arr 10000 99 1 0

/bin/time ./benchmark_arr 10000 1 99 1
/bin/time ./benchmark_arr 10000 10 90 1
/bin/time ./benchmark_arr 10000 50 50 1
/bin/time ./benchmark_arr 10000 90 10 1
/bin/time ./benchmark_arr 10000 99 1 1