#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet01_qap
# Redirect output stream to this file
#SBATCH --output=output01_qap.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

basedir=/scratch/cb761236
tmpdir=$basedir/tmp

module load gcc/12.2.0-gcc-8.5.0-p4pe45v

mkdir -p $tmpdir
cd $basedir/perf-oriented-dev/exercises/sheet_01 &&
$basedir/perf-oriented-dev/exercises/sheet_01/bench_small_samples.sh \
	$basedir/perf-oriented-dev/small_samples \
	$tmpdir \
	qap
