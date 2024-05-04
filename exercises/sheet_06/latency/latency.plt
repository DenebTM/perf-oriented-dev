set yrange [0:*]
set xrange [1024:*]
set logscale x 2

set xtics 1024,2 \
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
    "64M" 2**26, \
    "128M" 2**27, \
    "256M" 2**28 \
  ) \
  rotate by 45 right nomirror
set mxtics 8

set ytics 5 nomirror
set mytics 5

set terminal pdf
set output "latency.pdf"

set xlabel "Block size"
set ylabel "Latency [ns]"
set grid

plot 'latency.dat' using 1:2 with lines notitle
