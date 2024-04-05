---
title: "Exercise 03"
subtitle: "VU Performance-oriented Computing, Summer Semester 2024"
author: Calvin Hoy
date: 2024-04-03
geometry: margin=2.5cm
papersize: a4
header-includes:
   - \usepackage{longtable}
comment: PDF created using pandoc
---

# A) Traditional profiling

## Preparation

In order to use `gprof`, `gcc` must be instructed using the flag `-pg` to
generate profile information upon running the compiled program, stored in a file
named `gmon.out`. To this end, I added `-DCMAKE_C_FLAGS=-pg` to the `cmake`
command line.

I also added `-DCMAKE_BUILD_TYPE=RelWithDebInfo`, since profiling an unoptimised
build is counterproductive.

# B) Hybrid trace profiling

# Test table please ignore

\begin{center}
\begin{longtable}{|l|l l|r r r r|r r r r|}
    \hline
    I/O load &&& \multicolumn{4}{c|}{\textbf{Mean}} & \multicolumn{4}{c|}{\textbf{Variance}} \\
             & dirs & files & wall & user & system & mem & wall & user & system & mem \\
    \hline
    \hline
    \endhead

    \hline
    \endfoot

    - & 1 & 100 & 0.000 & 0.000 & 0.000 & 1458.667 & 0.000 & 0.000 & 0.000 & 3621.333 \\
    - & 1 & 10000 & 0.010 & 0.000 & 0.010 & 1409.333 & 0.000 & 0.000 & 0.000 & 5477.333 \\
    - & 100 & 1 & 0.000 & 0.000 & 0.000 & 1416.000 & 0.000 & 0.000 & 0.000 & 624.000 \\
    - & 100 & 100 & 0.010 & 0.000 & 0.010 & 1440.000 & 0.000 & 0.000 & 0.000 & 448.000 \\
    - & 10000 & 1 & 0.080 & 0.013 & 0.063 & 1556.000 & 0.000 & 0.000 & 0.000 & 48.000 \\
    - & 10000 & 1 & 0.080 & 0.010 & 0.067 & 1489.333 & 0.000 & 0.000 & 0.000 & 4181.333 \\

    10 MiB/s & 1 & 100 & 0.000 & 0.000 & 0.000 & 1457.333 & 0.000 & 0.000 & 0.000 & 5541.333 \\
    10 MiB/s & 1 & 10000 & 0.010 & 0.000 & 0.010 & 1454.667 & 0.000 & 0.000 & 0.000 & 2021.333 \\
    10 MiB/s & 100 & 1 & 0.000 & 0.000 & 0.000 & 1436.000 & 0.000 & 0.000 & 0.000 & 336.000 \\
    10 MiB/s & 100 & 100 & 0.010 & 0.000 & 0.010 & 1445.333 & 0.000 & 0.000 & 0.000 & 741.333 \\
    10 MiB/s & 10000 & 1 & 0.083 & 0.010 & 0.067 & 1536.000 & 0.000 & 0.000 & 0.000 & 2032.000 \\

    50 MiB/s & 1 & 100 & 0.000 & 0.000 & 0.000 & 1466.667 & 0.000 & 0.000 & 0.000 & 4501.333 \\
    50 MiB/s & 1 & 10000 & 0.010 & 0.000 & 0.010 & 1486.667 & 0.000 & 0.000 & 0.000 & 4037.333 \\
    50 MiB/s & 100 & 1 & 0.000 & 0.000 & 0.000 & 1453.333 & 0.000 & 0.000 & 0.000 & 5957.333 \\
    50 MiB/s & 100 & 100 & 0.010 & 0.000 & 0.010 & 1438.667 & 0.000 & 0.000 & 0.000 & 341.333 \\
    50 MiB/s & 10000 & 1 & 0.080 & 0.010 & 0.067 & 1428.000 & 0.000 & 0.000 & 0.000 & 768.000 \\
    
    100 MiB/s & 1 & 100 & 0.000 & 0.000 & 0.000 & 1420.000 & 0.000 & 0.000 & 0.000 & 15424.000 \\
    100 MiB/s & 1 & 10000 & 0.010 & 0.000 & 0.010 & 1365.333 & 0.000 & 0.000 & 0.000 & 6165.333 \\
    100 MiB/s & 100 & 1 & 0.000 & 0.000 & 0.000 & 1458.667 & 0.000 & 0.000 & 0.000 & 485.333 \\
    100 MiB/s & 100 & 100 & 0.010 & 0.000 & 0.010 & 1490.667 & 0.000 & 0.000 & 0.000 & 1605.333 \\
    100 MiB/s & 10000 & 1 & 0.080 & 0.010 & 0.067 & 1465.333 & 0.000 & 0.000 & 0.000 & 917.333 \\
\end{longtable}
\end{center}
