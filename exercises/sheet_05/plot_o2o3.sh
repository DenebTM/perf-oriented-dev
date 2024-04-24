#!/usr/bin/env bash

set -e

results_dir="$1"
cd "$results_dir"

for prog in delannoy mmul nbody npb_bt_w qap ssca2; do (
    # print header
    echo "opt $prog"
    for opt in \
            "none" \
            "-fgcse-after-reload" \
            "-fipa-cp-clone" \
            "-floop-interchange" \
            "-floop-unroll-and-jam" \
            "-fpeel-loops" \
            "-fpredictive-commoning" \
            "-fsplit-loops" \
            "-fsplit-paths" \
            "-ftree-loop-distribution" \
            "-ftree-partial-pre" \
            "-funswitch-loops" \
            "-fvect-cost-model=dynamic" \
            "-fversion-loops-for-strides"
    do
        echo -n "$opt "
        cat -- "$prog/$opt.json" | jq -r ".mean.wall"
    done ) > plot.dat
    
    gnuplot <<"    EOF"
        set terminal pdf
        set output "plot.pdf"
        set key autotitle columnhead noenhanced
        set style data histograms
        set style fill solid 1.0 border lt -1

        set xtics rotate by 45 right nomirror

        plot "< head -n1 plot.dat && tail -n14 plot.dat | sort -rnk2" using 2:xtic(1) linecolor 1
    EOF

    mv plot.pdf plot_$prog.pdf
    mv plot.dat plot_$prog.dat
    echo "Saved plot to $results_dir/plot_$prog.pdf"

done
