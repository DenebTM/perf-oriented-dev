#!/usr/bin/env bash

set -e

results_dir="$1"
data_file="plot_mmul.dat"
data_file_base="$(basename ${data_file%.*})"

# print header
wall_min=
wall_max=
TI_min_wall=
TK_min_wall=
TI=1

rm "$data_file"
while [ "$TI" -le 2048 ]; do
    TK=1
    while [ "$TK" -le 2048 ]; do
        wall="$(cat -- "$results_dir/TI=${TI}_TK=${TK}.json" | jq -r ".mean.wall")"
        >>"$data_file" echo "$TI $TK $wall"
        
        if [ -z "$wall_max" ] || (( $(echo "$wall > $wall_max" | bc -l) )); then
            wall_max=$wall
        fi
        if [ -z "$wall_min" ] || (( $(echo "$wall < $wall_min" | bc -l) )); then
            wall_min=$wall
            TI_min_wall=$TI
            TK_min_wall=$TK
        fi
        
        TK=$((TK * 2))
    done
    >>"$data_file" echo
    TI=$((TI * 2))
done

gnuplot mmul.plt -e "
    set arrow 1
        from $TI_min_wall,$TK_min_wall,$wall_min
        to $TI_min_wall,$TK_min_wall,$wall_max
        front nohead lc rgb 'red';
    
    set label 1 \"min: $wall_min\" at $TI_min_wall,$TK_min_wall,$wall_max front tc rgb 'red' center offset 0,0.5;

    set output '$data_file_base.pdf';
    splot '$data_file' with pm3d;
"

echo "Saved plot to $data_file_base.pdf"
