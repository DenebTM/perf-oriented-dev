#!/bin/bash

# Execute job in the partition "lva" unless you have special requirements.
#SBATCH --partition=lva
# Name your job to be able to identify it later
#SBATCH --job-name sheet12_lua_-Ofast
# Redirect output stream to this file
#SBATCH --output=output12_lua_-Ofast.log
# Maximum number of tasks (=processes) to start in total
#SBATCH --ntasks=1
# Maximum number of tasks (=processes) to start per node
#SBATCH --ntasks-per-node=1
# Enforce exclusive node allocation, do not share with other jobs
#SBATCH --exclusive

set -e

scratchdir="/scratch/${USER}"
basedir="$scratchdir/sheet12_lua_Ofast_$$"
nruns=10

cd "$scratchdir"
[ ! -f lua-5.4.6.tar.gz ] && wget -c https://www.lua.org/ftp/lua-5.4.6.tar.gz
[ ! -f fib.lua ] && wget -c https://raw.githubusercontent.com/PeterTh/perf-oriented-dev/master/lua/fib.lua

mkdir -p "$basedir"
cd "$basedir"

(
    module load gcc
    tar xvf "$scratchdir/lua-5.4.6.tar.gz"
    cd lua-5.4.6/
    sed -i 's/CFLAGS= -O2/CFLAGS= -Ofast/' src/Makefile
    make -j$(nproc)
    cp src/lua "$basedir"
)

(
    echo 'func,time'
    for run in $(seq 1 $nruns); do
        >&2 echo "Run $run of $nruns"
        ./lua "$scratchdir/fib.lua" | awk '{ print $3 "," $5 }'
    done
) > results_raw.csv

funcs=($(awk -F ',' 'NR > 1 { print $1 }' results_raw.csv | sort | uniq))

echo -e "\nResults (see results.csv):"
(
    echo 'func,wall (mean)'
    for func in "${funcs[@]}"; do
        awk -F ',' "\$1 == \"$func\" { nr++; total += \$2 } END { print \"$func\" \",\" total/nr }" results_raw.csv
    done
) | tee results.csv
