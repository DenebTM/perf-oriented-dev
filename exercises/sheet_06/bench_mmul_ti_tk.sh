#!/usr/bin/env bash

# create and batch job scripts
tmp_jobdir="/tmp/${USER}_jobs_mmul"
mkdir -p "$tmp_jobdir"

export GCC_FLAGS="-O3 -march=native"

TI=1

while [ "$TI" -le 2048 ]; do
    export TI
    
    TK=1
    while [ "$TK" -le 2048 ]; do
        export TK

        envsubst '${TI},${TK},${GCC_FLAGS}' < jobs/template_job06_mmul.sh > "$tmp_jobdir/TI=${TI}_TK=${TK}.sh"

        sbatch "$tmp_jobdir/TI=${TI}_TK=${TK}.sh"
        
        TK=$((TK * 2))
    done
    
    TI=$((TI * 2))
done

echo -n "Waiting for jobs"
while squeue -u $USER | grep -v JOBID >/dev/null; do
    sleep 1
    echo -n .
done

echo -e "\nAll jobs done."

