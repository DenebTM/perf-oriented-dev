set grid vertical
unset key

set xlabel "TI"
set ylabel "TK"
set zlabel "wall [s]"

set logscale xy 2
set xrange [1:2048]
set yrange [1:2048]
set zrange [0:*]

set xtics 2
set ytics 2
# set ztics 5

set terminal pdf
# set output "plot_mmul.pdf"
# splot "plot_mmul.dat" with pm3d
