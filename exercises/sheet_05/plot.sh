#!/usr/bin/env bash

set -e

results_dir="$1"
cd "$results_dir"

( for file in *.json; do
    level="${file%%.json}"
    cat -- "$file" | jq -r "[\"$level\", .mean[]] | join(\" \")"
done ) > plot.dat

gnuplot <<EOF
set terminal png size 852,480
set output "plot.png"
set key outside
set style data histograms
set style fill solid 1.0 border lt -1

set xtics nomirror
set xtics format " "
set y2range [0:*]
set y2tics
set ytics nomirror

plot "plot.dat" using 2:xtic(1) linecolor 1 title "wall", \
    "" using 3:xtic(1) linecolor 2 title "user", \
    "" using 4:xtic(1) linecolor 3 title "sys", \
    "" using 5:xtic(1) linecolor 4 title "mem" axes x1y2
EOF

rm plot.dat

echo "Saved plot to $results_dir/plot.png"
