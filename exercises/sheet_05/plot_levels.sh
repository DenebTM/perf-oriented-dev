#!/usr/bin/env bash

set -e

results_dir="$1"
cd "$results_dir"

for metric in wall user system mem; do (
    # print header
    echo -n "level "; for prog in */; do echo -n "${prog%%/} "; done; echo
    for level in -O0 -O1 -O2 -O3 -Ofast -Os; do
        echo -n "$level "
        for prog in */; do
            echo -n "$(cat -- "$prog/$level.json" | jq -r ".mean.$metric") "
        done
        echo
    done ) > plot.dat
    
    gnuplot <<"    EOF"
        set terminal pdf
        set output "plot.pdf"
        set key outside autotitle columnhead noenhanced
        set style data histograms
        set style fill solid 1.0 border lt -1
        
        set yrange [0:*]
        set xtics nomirror
        
        plot "plot.dat" using 2:xtic(1) linecolor 1, \
        "" using 3:xtic(1) linecolor 2, \
        "" using 4:xtic(1) linecolor 3, \
        "" using 5:xtic(1) linecolor 4, \
        "" using 6:xtic(1) linecolor 5, \
        "" using 7:xtic(1) linecolor 6
    EOF

    mv plot.pdf plot_$metric.pdf
    mv plot.dat plot_$metric.dat
    echo "Saved plot to $results_dir/plot_$metric.pdf"

done
