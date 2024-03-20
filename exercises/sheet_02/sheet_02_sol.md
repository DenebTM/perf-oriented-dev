---
title: "Exercise 01"
subtitle: "VU Performance-oriented Computing, Summer Semester 2024"
author: Calvin Hoy
date: 2024-03-12
geometry: margin=2.5cm
papersize: a4
header-includes:
   - \usepackage{longtable}
comment: PDF created using pandoc
---

# Outline/Preparation

## Test environment (LCC3)

Benchmarks were conducted on the LCC3 cluster only.

I loaded the `gcc/12.2.0-gcc-8.5.0-p4pe45v` module before building any of the
code.

I have attached the Slurm job scripts I used to run the benchmarks on LCC3's
compute nodes in the [`jobs/`](jobs) directory.

## Updated benchmark scripts

The [benchmark.sh](benchmark.sh) script from exercise 1 has been updated to, by
default, re-run the benchmark until a statistical error below 0.05 has been
reached. This may be configured by the user; see `--help`.

[bench\_small\_samples.sh](bench_small_samples.sh) has been amended to allow
optionally running either the CPU load generator (supplying the path to the
`tools` directory) or I/O load generator (supplying the path to the
[`ioloadgen/`](ioloadgen) directory. Furthermore, the maximum number of files
created for the `filegen` and `filesearch` benchmarks has been reduced to
10,000.

# I/O load generator

I chose to use C++, but using C file 

The generator works by creating a working file of a certain size (8 GiB by
default, configurable via an environment variable) and writing data to it.

The program can be run in two primary modes: `--sequential` and `--random`. In
sequential mode, the working file is repeatedly overwritten start-to-finish in 1
MiB chunks, which primarily exercises the disk's sequential write performance.
In random mode, the file will instead have random 512-byte sections , which is
constrained primarily by the rate at which the disk can complete individiual I/O
operations. In either mode, each block is flushed to disk immediately, in order
to minimize the impact of write caching.

By default, the program will write as fast as the disk allows, essentially
creating a 100% I/O load. It can be limited to a specified write rate (either in
B/s or IOPS, depending on the mode) with `--limit <rate>`.

The program has a third mode, `--calib`, which can be used to measure disk
performance. In this program, sequential and random tests are run for 10 seconds
each, keeping track of the achieved output, then display the results in Bytes
per second (B/s) and I/O Operations per second (IOPS) respectively.

On my personal laptop, I measured around 2.6 GiB/s for sequential write and
160,000 IOPS for random write.

You may find the code in [`ioloadgen/ioloadgen.cpp`](ioloadgen/ioloadgen.cpp).
See `--help` for additional information.

# Benchmark results

All figures for mean and variance given in the following section were obtained
by re-running the benchmark until a statistical error below 0.05 or reached or a
maximum number of runs (30) was reached. Unless otherwise specified, runtime is
specified in seconds and memory use in kilobytes.

Raw (JSON) output from each of the tests as performed on LCC3 can be found in
[`results/`](results) directories.

All benchmarks were rerun for this exercise.

## CPU load generator

I chose to measure the impact of the CPU load generator provided in the `tools`
directory, executed using (a modified version of) the
`exec_with_workstation_heavy.sh` script, on the CPU-limited programs provided in
`small-samples`.

## `delannoy`

\begin{center}
\begin{longtable}{|l|r r r r|r r r r|}
    \hline
    & \multicolumn{4}{c|}{\textbf{Mean}} & \multicolumn{4}{c|}{\textbf{Variance}} \\
    N & wall & user & system & mem & wall & user & system & mem \\
    \hline
    \endhead

    \hline
    \endfoot

    1  & 0.000   & 0.000   & 0.000  & 1327.2 & 0.000 & 0.000 & 0.000 & 43.2     \\
    2  & 0.000   & 0.000   & 0.000  & 1349.6 & 0.000 & 0.000 & 0.000 & 1332.8   \\
    3  & 0.000   & 0.000   & 0.000  & 1349.6 & 0.000 & 0.000 & 0.000 & 1252.8   \\
    4  & 0.000   & 0.000   & 0.000  & 1369.6 & 0.000 & 0.000 & 0.000 & 372.8    \\
    5  & 0.000   & 0.000   & 0.000  & 1353.6 & 0.000 & 0.000 & 0.000 & 812.8    \\
    6  & 0.000   & 0.000   & 0.000  & 1364.0 & 0.000 & 0.000 & 0.000 & 704.0    \\
    7  & 0.000   & 0.000   & 0.000  & 1364.8 & 0.000 & 0.000 & 0.000 & 411.2    \\
    8  & 0.000   & 0.000   & 0.000  & 1368.8 & 0.000 & 0.000 & 0.000 & 3067.2   \\
    9  & 0.010   & 0.004   & 0.000  & 1356.0 & 0.000 & 0.000 & 0.000 & 584.0    \\
    10 & 0.050   & 0.050   & 0.000  & 1382.4 & 0.000 & 0.000 & 0.000 & 556.8    \\
    11 & 0.306   & 0.304   & 0.000  & 1348.0 & 0.000 & 0.000 & 0.000 & 256.0    \\
    12 & 1.718   & 1.716   & 0.000  & 1351.2 & 0.000 & 0.000 & 0.000 & 507.2    \\
    13 & 9.660   & 9.646   & 0.000  & 1365.6 & 0.002 & 0.002 & 0.000 & 212.8    \\
    14 & 54.314  & 54.232  & 0.000  & 1361.6 & 0.064 & 0.067 & 0.000 & 964.8    \\
    15 & 306.040 & 305.578 & 0.008  & 1360.8 & 0.930 & 0.964 & 0.000 & 1323.2   \\
\end{longtable}
\end{center}

## `mmul`

\begin{center}
\begin{tabular}{|l|r r r r|}
    \hline
    & wall & user & system & mem \\
    \hline
    Mean     & 5.780 & 5.760 & 0.000 & 24568.8      \\
    Variance & 0.006 & 0.006 & 0.000 & 2219.2       \\
    \hline
\end{tabular}
\end{center}

## `nbody`

\begin{center}
\begin{tabular}{|l|r r r r|}
    \hline
    & wall & user & system & mem \\
    \hline
    Mean     & 4.764 & 4.758 & 0.000 & 1833.6   \\
    Variance & 0.000 & 0.000 & 0.000 & 2116.8   \\
    \hline
\end{tabular}
\end{center}

## `qap`

\begin{center}
\begin{tabular}{|l|r r r r|r r r r|}
    \hline
    & \multicolumn{4}{c|}{\textbf{Mean}} & \multicolumn{4}{c|}{\textbf{Variance}}       \\
    Input & wall & user & system & mem & wall & user & system & mem \\
    \hline
    chr10a.dat & 0.010   & 0.010   & 0.000 & 1484.0 & 0.000 & 0.000 & 0.000 & 512.0     \\
    chr12a.dat & 0.160   & 0.160   & 0.000 & 1507.2 & 0.000 & 0.000 & 0.000 & 259.2     \\
    chr12b.dat & 0.146   & 0.140   & 0.000 & 1490.4 & 0.000 & 0.000 & 0.000 & 220.8     \\
    chr12c.dat & 0.210   & 0.210   & 0.000 & 1479.2 & 0.000 & 0.000 & 0.000 & 1427.2    \\
    chr15a.dat & 15.442  & 15.412  & 0.000 & 1485.6 & 0.050 & 0.050 & 0.000 & 1764.8    \\
    chr15b.dat & 4.170   & 4.160   & 0.000 & 1512.0 & 0.000 & 0.000 & 0.000 & 632.0     \\
    chr15c.dat & 13.950  & 13.926  & 0.000 & 1495.2 & 0.000 & 0.000 & 0.000 & 395.2     \\
    chr18a.dat & 879.550 & 877.720 & 0.030 & 1492.0 & N/A   & N/A   & N/A   & N/A       \\
    \hline
\end{tabular}
\end{center}

## I/O load generator

I first measured disk performance in the `/tmp` directory on one of the worker
noddes, then ran the `filegen` and `filesearch` benchmarks once with no external
I/O load, then once each with an approximate 50%, and 90%, and 100% external load.

Due to time constraints, I chose only to run the disk benchmarks under an
external *random* I/O load.

## `filegen`

\begin{center}
\begin{tabular}{|l l l|r r r r|r r r r|}
    \hline
    &&& \multicolumn{4}{c|}{\textbf{Mean}} & \multicolumn{4}{c|}{\textbf{Variance}} \\
    dirs & files & file size & wall & user & system & mem & wall & user & system & mem \\
    \hline
    1      & 1      & 10 kB  & 0.000  & 0.000 & 0.000 & 3273.333  & 0.000 & 0.000 & 0.000 & 1669.333    \\
    1      & 1      & 100 kB & 0.000  & 0.000 & 0.000 & 3281.333  & 0.000 & 0.000 & 0.000 & 2181.333    \\
    1      & 1      & 1 MB   & 0.020  & 0.010 & 0.000 & 3281.333  & 0.000 & 0.000 & 0.000 & 1797.333    \\
    1      & 1      & 10 MB  & 0.150  & 0.140 & 0.007 & 11024.000 & 0.000 & 0.000 & 0.000 & 9904.000    \\
    1      & 1      & 100 MB & 1.510  & 1.447 & 0.053 & 98897.333 & 0.000 & 0.000 & 0.000 & 11797.333   \\
    1      & 1000   & 1 B    & 0.040  & 0.000 & 0.040 & 3268.000  & 0.000 & 0.000 & 0.000 & 1792.000    \\
    1      & 10000  & 1 B    & 0.930  & 0.033 & 0.383 & 3262.667  & 0.765 & 0.000 & 0.000 & 5141.333    \\
    1      & 100000 & 1 B    & 11.127 & 0.387 & 3.880 & 3276.000  & 0.778 & 0.000 & 0.000 & 2704.000    \\
    1000   & 1      & 1 B    & 0.060  & 0.000 & 0.050 & 3256.000  & 0.000 & 0.000 & 0.000 & 1776.000    \\
    10000  & 1      & 1 B    & 1.087  & 0.047 & 0.543 & 3264.000  & 0.450 & 0.000 & 0.000 & 112.000     \\
    100000 & 1      & 1 B    & 20.497 & 0.533 & 5.650 & 3277.333  & 0.305 & 0.001 & 0.001 & 2949.333    \\
    \hline
\end{tabular}
\end{center}

## `filesearch`

\begin{center}
\begin{tabular}{|l l|r r r r|r r r r|}
    \hline
    && \multicolumn{4}{c|}{\textbf{Mean}} & \multicolumn{4}{c|}{\textbf{Variance}} \\
    dirs & files & wall & user & system & mem & wall & user & system & mem \\
    \hline
    1       & 1000    & 0.000  & 0.000 & 0.000 & 1473.6 & 0.000    & 0.000 & 0.000 & 260.8  \\
    1       & 1000000 & 1.558  & 0.298 & 1.246 & 1384.8 & 0.008    & 0.000 & 0.009 & 5499.2 \\
    1000    & 1       & 0.002  & 0.000 & 0.000 & 1453.6 & 0.000    & 0.000 & 0.000 & 7956.8 \\
    1000    & 1000    & 1.506  & 0.308 & 1.188 & 1526.4 & 0.009    & 0.000 & 0.009 & 4044.8 \\
    1000000 & 1       & 41.626 & 1.604 & 6.502 & 1490.4 & 5771.857 & 0.010 & 1.662 & 1612.8 \\
    \hline
\end{tabular}
\end{center}
