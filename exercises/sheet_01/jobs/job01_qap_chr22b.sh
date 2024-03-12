#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet01_chr22b
# Redirect output stream to this file
#SBATCH --output=output01_chr22b.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1

basedir=/scratch/cb761236

module load gcc/12.2.0-gcc-8.5.0-p4pe45v

mkdir -p $basedir/perf-oriented-dev/small_samples/build
cd $basedir/perf-oriented-dev/small_samples/build
cmake ..
make qap

cd $basedir/perf-oriented-dev/exercises/sheet_01 &&
./benchmark.sh -n 1 -o results/qap/chr22b.json \
	$basedir/perf-oriented-dev/small_samples/build/qap $basedir/perf-oriented-dev/small_samples/qap/problems/chr22b.dat
