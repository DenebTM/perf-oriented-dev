#!/usr/bin/env bash

bench="./benchmark.sh"

run_benchmark() {
    
}

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
    "-funroll-completely-grow-size"
    "-funswitch-loops"
    "-fvect-cost-model=dynamic"
    "-fversion-loops-for-strides"
)

# create and batch job scripts
tmp_jobdir="/tmp/${USER}_jobs_o2o3"
mkdir -p "$tmp_jobdir"
for opt in "${opts[@]}"; do
    export TESTFLAG="$opt"
    envsubst '$TESTFLAG' < template_job05_o2o3.sh > "$tmp_jobdir/$opt.sh"

    sbatch "$tmp_jobdir/$opt.sh"
done

echo "Waiting for jobs"
while sq -u $USER | grep -v JOBID >/dev/null; do
    sleep 1
    echo -n .
done

echo -e "\nAll jobs done."

