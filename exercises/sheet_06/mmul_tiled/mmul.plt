set grid xtics ytics ztics vertical
unset key

set xlabel 'TI'
set ylabel 'TK'
set zlabel 'wall [s]' rotate parallel

set logscale xy 2
set xrange [1:2048]
set yrange [1:2048]
set zrange [0:*]

set xtics 2
set ytics 2
# set ztics 5

set xyplane at 0

set format x ''
set for [i=1:12] \
  label at first 2**(i-1),graph 0,graph 0 \
  sprintf('%d', 2**(i-1)) \
  offset -.5,-.25,0 \
  rotate by 40 right

set format y ''
set for [i=1:12] \
  label at graph 1,first 2**(i-1),graph 0 \
  sprintf('%d', 2**(i-1)) \
  offset .5,-.25,0 \
  rotate by -40 left

set terminal pdf
# set output 'plot_mmul.pdf'
# splot 'plot_mmul.dat' with pm3d
