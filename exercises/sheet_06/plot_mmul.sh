#!/usr/bin/env bash

set -e

results_dir="$1"

# print header
(
    TI=1
    while [ "$TI" -le 2048 ]; do
        TK=1
        while [ "$TK" -le 2048 ]; do
            echo "$TI $TK $(cat -- "$results_dir/TI=${TI}_TK=${TK}.json" | jq -r ".mean.wall")"
            TK=$((TK * 2))
        done
        TI=$((TI * 2))
    done
) > plot_mmul.dat

gnuplot <<EOF
    set terminal pdf
    set output "plot_mmul.pdf"
    set grid vertical
    unset key
    
    set xlabel "TI"
    set ylabel "TK"
    set zlabel "wall [s]"

    set dgrid3d
    set logscale xy 2
    set xrange [1:2048]
    set yrange [1:2048]
    set zrange [0:*]
    
    set xtics 2
    set ytics 2
    
#     set xtics 1,2,4,8,16,32,64,128,256,512,1024,2048
#     set ytics 1,2,4,8,16,32,64,128,256,512,1024,2048

    splot "plot_mmul.dat" with pm3d
EOF

echo "Saved plot to plot_mmul.pdf"
