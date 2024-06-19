#!/usr/bin/env bash

# Run this script on the head node, don't sbatch it!

opts=(
    "-fgcse-after-reload"
    "-fipa-cp-clone"
    "-floop-interchange"
    "-floop-unroll-and-jam"
    "-fpeel-loops"
    "-fpredictive-commoning"
    "-fsplit-loops"
    "-fsplit-paths"
    "-ftree-loop-distribution"
    "-ftree-partial-pre"
    "-funswitch-loops"
    "-fvect-cost-model=dynamic"
    "-fversion-loops-for-strides"
)

# create and batch job scripts
tmp_jobdir="/tmp/${USER}_jobs_o2o3"
mkdir -p "$tmp_jobdir"
for opt in "${opts[@]}"; do
    export TESTFLAG="$opt"
    envsubst '$TESTFLAG' < template_lua_o2o3.sh > "$tmp_jobdir/$opt.sh"

    sbatch "$tmp_jobdir/$opt.sh"
done

echo -n "Waiting for jobs"
while squeue -u $USER | grep -v JOBID >/dev/null; do
    sleep 1
    echo -n .
done

echo -e "\nAll jobs done."

