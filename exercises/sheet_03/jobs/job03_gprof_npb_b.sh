#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet03_npb_bt_b
# Redirect output stream to this file
#SBATCH --output=output03_npb_bt_b
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

basedir=/scratch/cb761236/perf-oriented-dev
builddir="build_$$"

module load cmake/3.24.3-gcc-8.5.0-svdlhox
module load gcc/12.2.0-gcc-8.5.0-p4pe45v

cd $basedir/larger_samples/npb_bt
mkdir "$builddir"
cd "$builddir"
cmake -DCMAKE_C_FLAGS=-pg -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j$(nproc) npb_bt_b

./npb_bt_b
