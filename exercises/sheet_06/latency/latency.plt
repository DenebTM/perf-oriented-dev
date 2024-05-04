set xrange [512:2**26+1]
set logscale x 2
set xtics 512,2 \
  add ( \
    "128k" 2**17, \
    "256k" 2**18, \
    "512k" 2**19, \
    "1M" 2**20, \
    "2M" 2**21, \
    "4M" 2**22, \
    "8M" 2**23, \
    "16M" 2**24, \
    "32M" 2**25, \
    "64M" 2**26 \
  ) \
  rotate by 45 right nomirror
set mxtics 8

set yrange [0.5:*]
set logscale y 10
set ytics 1,10 nomirror
set mytics 10

set xlabel "Block size" offset 0,2
set ylabel "Memory latency [ns]"
set grid

set terminal pdf

# set output "latency.pdf"
# plot 'latency.dat' using 1:2 with lines notitle
