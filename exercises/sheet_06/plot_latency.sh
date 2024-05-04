#!/usr/bin/env bash

set -e

data_file="$1"
data_file_base="${data_file%.*}"

gnuplot 'latency.plt' -e \
  "set output 'plot_$data_file_base.pdf'; plot '$data_file' with lines notitle"

echo "Saved plot to plot_$data_file_base.pdf"
