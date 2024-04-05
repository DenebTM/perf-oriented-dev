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

## Output of `gprof`

Calling `gprof <binary> [<gmon.out>]` without any other arguments prints the
flat profile and call graph. Consult the man page for additional information.

I chose to focus on the workload sizes `_w` and `_b` for closer examination.

Note: On LCC3, the module `binutils/2.37` must be loaded, as the version of
`gprof` available by default (<2.35) is not able to process the generated
profile information.

### Flat profile

For brevity, most functions taking less than 1 percent of execution time were
omitted from the following output.

**W:**

```
  %   cumulative   self              self     total           
 time   seconds   seconds    calls  ms/call  ms/call  name    
 31.92      0.60     0.60  6712596     0.00     0.00  binvcrhs
 17.82      0.94     0.34  6712596     0.00     0.00  matmul_sub
 13.03      1.18     0.25      201     1.22     2.94  y_solve
 11.70      1.40     0.22      201     1.09     2.82  x_solve
 11.17      1.61     0.21      201     1.04     2.77  z_solve
  8.51      1.77     0.16      202     0.79     0.79  compute_rhs
  3.46      1.84     0.07  6712596     0.00     0.00  matvec_sub
  1.06      1.86     0.02   291852     0.00     0.00  binvrhs
  1.06      1.88     0.02   291852     0.00     0.00  lhsinit
  0.00      1.88     0.00   221472     0.00     0.00  exact_solution
  0.00      1.88     0.00      201     0.00     0.00  add
[...]
```

The flat profile (captured on my local machine) shows that about 29 percent of
execution time is spent in the function `binvcrhs`. A further 15 percent is
spent in `matmul_sub`, and just under 14 percent each in `x`/`y`/`z_solve`.

**B:** 

```
  %   cumulative   self              self     total           
 time   seconds   seconds    calls  ms/call  ms/call  name    
 28.99     56.57    56.57 609030000     0.00     0.00  binvcrhs
 15.11     86.05    29.48 609030000     0.00     0.00  matmul_sub
 13.91    113.19    27.14      201   135.02   290.23  y_solve
 13.79    140.10    26.91      201   133.88   289.09  x_solve
 13.54    166.52    26.42      201   131.46   286.67  z_solve
  9.91    185.86    19.33      202    95.71    95.71  compute_rhs
  3.53    192.74     6.88 609030000     0.00     0.00  matvec_sub
  0.58    193.88     1.14      201     5.67     5.67  add
  0.18    194.24     0.36  6030000     0.00     0.00  binvrhs
  0.17    194.58     0.34 16980552     0.00     0.00  exact_solution
  0.15    194.88     0.30  6030000     0.00     0.00  lhsinit
[...]
```

For the larger workload size, we see that the number of calls to functions such
as `binvcrhs` and `matmul_sub` increases, while e.g. `add` is called equally as
often (but its execution time has increased from near-zero to 5.67 ms).

The distribution of time spent does not change for the busiest functions, though
e.g. only 0.15 percent of the execution time is spent in `lhsinit` (compared to
1.06 percent for the smaller workload size).

### Call graph

```
index % time    self  children    called     name
                                                 <spontaneous>
[1]    100.0    0.00  195.12                 main [1]
                0.00  193.30     201/201         adi [2]
                1.14    0.00     201/201         add [10]
                0.03    0.26       2/2           initialize [14]
                0.10    0.06       1/1           exact_rhs [15]
                0.00    0.14       1/1           verify [16]
                0.10    0.00       1/1           set_constants [17]
                0.00    0.00      22/22          timer_clear [19]
                0.00    0.00       1/1           timer_start [24]
                0.00    0.00       1/1           timer_stop [25]
                0.00    0.00       1/1           timer_read [23]
                0.00    0.00       1/1           print_results [21]
-----------------------------------------------
                0.00  193.30     201/201         main [1]
[2]     99.1    0.00  193.30     201         adi [2]
               27.14   31.20     201/201         y_solve [3]
               26.91   31.20     201/201         x_solve [4]
               26.42   31.20     201/201         z_solve [5]
               19.24    0.00     201/202         compute_rhs [8]
-----------------------------------------------
               27.14   31.20     201/201         adi [2]
[3]     29.9   27.14   31.20     201         y_solve [3]
               18.86    0.00 203010000/609030000     binvcrhs [6]
                9.83    0.00 203010000/609030000     matmul_sub [7]
                2.29    0.00 203010000/609030000     matvec_sub [9]
                0.12    0.00 2010000/6030000     binvrhs [11]
                0.10    0.00 2010000/6030000     lhsinit [13]
-----------------------------------------------
               26.91   31.20     201/201         adi [2]
[4]     29.8   26.91   31.20     201         x_solve [4]
               18.86    0.00 203010000/609030000     binvcrhs [6]
                9.83    0.00 203010000/609030000     matmul_sub [7]
                2.29    0.00 203010000/609030000     matvec_sub [9]
                0.12    0.00 2010000/6030000     binvrhs [11]
                0.10    0.00 2010000/6030000     lhsinit [13]
-----------------------------------------------
               26.42   31.20     201/201         adi [2]
[5]     29.5   26.42   31.20     201         z_solve [5]
               18.86    0.00 203010000/609030000     binvcrhs [6]
                9.83    0.00 203010000/609030000     matmul_sub [7]
                2.29    0.00 203010000/609030000     matvec_sub [9]
                0.12    0.00 2010000/6030000     binvrhs [11]
                0.10    0.00 2010000/6030000     lhsinit [13]
-----------------------------------------------
               18.86    0.00 203010000/609030000     x_solve [4]
               18.86    0.00 203010000/609030000     y_solve [3]
               18.86    0.00 203010000/609030000     z_solve [5]
[6]     29.0   56.57    0.00 609030000         binvcrhs [6]
-----------------------------------------------
[...]
```

The above (truncated) call graph reveals the following:

- The program spends almost all of its time in the function `adi`.
- `adi` calls `x`/`y`/`z_solve` as well as `compute_rhs` and has no
  computationally intensive code of its own.
- `x`/`y`/`z_solve` are *only* called from `adi`.
- `x`/`y`/`z_solve` all operate analogously to each other, are called the same
  number of times, and take up an equal share of execution time.
- `binvchrs` accounts for roughly 19 percent of the time spent in
  `x`/`y`/`z_solve`, and does not call out to any computationally intensive
  functions.

### Annotated source code

`gprof` may also be instructed to output source code with annotations --
printing an execution count beside each line with a function definition, as well
as a short summary showing which lines (functions) were executed most often.

I found this output to be not very useful, as it is essentially just a less
concise form of the flat profile.

### Comparing with LCC3

The only noteworthy difference I observed in the output of `gprof` on LCC3 is
that some or all profile information for the `main` function and other functions
called from within it appears to be missing.

```
Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total           
 time   seconds   seconds    calls  ms/call  ms/call  name    
 30.56     96.94    96.94 609030000     0.00     0.00  binvcrhs
 17.17    151.42    54.48 609030000     0.00     0.00  matmul_sub
 13.55    194.42    43.00      201   213.92   488.12  z_solve
 11.97    232.39    37.98      201   188.94   463.14  y_solve
 11.29    268.21    35.82      201   178.22   452.41  x_solve
 10.16    300.45    32.24      202   159.58   159.58  compute_rhs
  4.05    313.28    12.83 609030000     0.00     0.00  matvec_sub
  0.63    315.28     2.00                             add
  0.18    315.86     0.58  6030000     0.00     0.00  lhsinit
  0.16    316.37     0.51  6030000     0.00     0.00  binvrhs
  0.15    316.86     0.49 16980552     0.00     0.00  exact_solution
  0.06    317.05     0.19                             exact_rhs
  0.03    317.15     0.10                             set_constants
  0.03    317.24     0.09                             initialize
  0.01    317.26     0.02        1    20.00    50.63  error_norm
  0.00    317.27     0.01        1    10.00    10.00  rhs_norm
  0.00    317.27     0.00        2     0.00     0.00  wtime_


                          Call graph


granularity: each sample hit covers 2 byte(s) for 0.00% of 317.27 seconds

index % time    self  children    called     name
                                                 <spontaneous>
[1]     99.0    0.00  314.21                 adi [1]
               43.00   55.11     201/201         z_solve [2]
               37.98   55.11     201/201         y_solve [4]
               35.82   55.11     201/201         x_solve [5]
               32.08    0.00     201/202         compute_rhs [7]
-----------------------------------------------
[...]
```

By the call graph, it appears as though `adi` was called directly at the
program entry point. Optimization / inlining?

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
