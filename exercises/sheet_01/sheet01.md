# Exercise 1

## Building

I created a new folder named `build` and ran `cmake ..` inside it to prepare
the build environment.

I then ran `make -j$(nproc)` while still in the `build` directory to compile
the examples.

## Test environment

Benchmarks were run on both my personal computer as well as an LCC3 cluster
node. The former is described in the table below.

| Component             | Component description                    |
| --------------------- | ---------------------------------------- |
| CPU                   | Ryzen 9 5900X                            |
| Memory                | 32GB DDR4                                |
| Test disk model       | NVMe PCIe 3.0 SSD with DRAM cache        |
| Test disk file system | Btrfs (zstd-compressed)                  |

## Benchmark script [B) Experiments]

I first wrote these scripts, then used them to obtain the results described
below.

See [bench\_small\_samples.sh](bench_small_samples.sh) and
[benchmark.sh](benchmark.sh). The former script may be used to benchmark the
programs given in small-samples; it relies on the latter script to conduct the
tests using `/usr/bin/env time` and store the output in JSON format.

#### Usage of `bench_small_samples.sh`:

```
./bench_small-samples.sh <path/to/small_samples> <workdir> <list of programs...>
```

**path/to/small_samples**: must be pointed to the `small-samples` directory in
the Git repository.

**path/to/workdir**: working directory to be used by `filegen` and `filesearch`

**list of programs**: which programs to be benchmarked, e.g. `delannoy filegen
filesearch`

**Example usage:**

```bash
./bench_small_samples.sh ../../small-samples ~/tempdir filesearch nbody
```

## Programs and test results

All figures for mean and variance given in the following section were taken
over five runs of the program. For "wall", "user", "system", and "mem", the
columns with "(var)" show the variance, while the ones without "(var)" show the
mean result. Unless otherwise specified, the unit for time is seconds, and for
memory, kilobytes.

I saw no noteworthy patterns in memory use with any of the programs provided.

### `delannoy`

`delannoy.c` performs a recursive computation that scales exponentially with
one given parameter `N`. It runs very fast for low values thereof, but becomes
exponentially slower for larger values.

I chose to test all values of N between 1 and 15 (inclusive). Extrapolating the
runtime for N=15 led me to expect a runtime in the ballpark of 10 minutes for
N=16, and one hour for N=17, which I deemed simply impractical.

#### Results

**PC**:

| N   | wall    | user    | system | mem    | wall (var) | user (var) | system (var) | mem (var) |
| --- | ------- | ------- | ------ | ------ | ---------- | ---------- | ------------ | --------- |
| 1   | 0.000   | 0.000   | 0.000  | 1256.0 | 0.000      | 0.000      | 0.000        | 9144.0    |
| 2   | 0.000   | 0.000   | 0.000  | 1250.4 | 0.000      | 0.000      | 0.000        | 8068.8    |
| 3   | 0.000   | 0.000   | 0.000  | 1283.2 | 0.000      | 0.000      | 0.000        | 5379.2    |
| 4   | 0.000   | 0.000   | 0.000  | 1315.2 | 0.000      | 0.000      | 0.000        | 3.2       |
| 5   | 0.000   | 0.000   | 0.000  | 1217.6 | 0.000      | 0.000      | 0.000        | 8068.8    |
| 6   | 0.000   | 0.000   | 0.000  | 1281.6 | 0.000      | 0.000      | 0.000        | 5252.8    |
| 7   | 0.000   | 0.000   | 0.000  | 1288.8 | 0.000      | 0.000      | 0.000        | 5995.2    |
| 8   | 0.000   | 0.000   | 0.000  | 1217.6 | 0.000      | 0.000      | 0.000        | 8068.8    |
| 9   | 0.000   | 0.000   | 0.000  | 1249.6 | 0.000      | 0.000      | 0.000        | 7940.8    |
| 10  | 0.010   | 0.010   | 0.000  | 1321.6 | 0.000      | 0.000      | 0.000        | 156.8     |
| 11  | 0.098   | 0.096   | 0.000  | 1261.6 | 0.000      | 0.000      | 0.000        | 10140.8   |
| 12  | 0.562   | 0.558   | 0.000  | 1321.6 | 0.000      | 0.000      | 0.000        | 156.8     |
| 13  | 3.184   | 3.178   | 0.000  | 1249.6 | 0.002      | 0.002      | 0.000        | 7940.8    |
| 14  | 18.034  | 18.018  | 0.010  | 1314.4 | 0.091      | 0.087      | 0.000        | 4.8       |
| 15  | 102.066 | 101.920 | 0.128  | 1249.6 | 0.180      | 0.226      | 0.003        | 7940.8    |

**LCC3**:


### `filegen`

`filegen.c` creates a given number of directories, each containing the same
specified number of files with a pseudorandom size within a given range. Each
file contains pseudorandom content, generated at runtime.

The workload clearly scales with each parameter -- likely linearly, but with
different respective constant factors.

To see how each of the three main parameters -- number of directories, number
of files, and file size -- affect performance, I chose to test the following
sets thereof:

- 1,000 / 10,000 / 100,000 / 1,000,000 directories, 1 file, 1B

- 1 directory, 1,000 / 10,000 / 100,000 / 1,000,000 files, 1B

- 1 directory, 1 file, 10,000 / 100,000 / 1,000,000 / 10,000,000 / 100,000,000 B

I chose to keep the minimum and maximum file sizes the same, as having a
"random" component to this would only serve to make scaling less consistent.

Each benchmark run was conducted using the default seed of `1234`, and all
generated files were deleted in between runs.

#### Results

**PC**:

| dirs    | files   | file size [B] | wall  | user  | system | mem     | wall (var) | user (var) | system (var) | mem (var) |
| ------- | ------- | ------------- | ----- | ----- | ------ | ------- | ---------- | ---------- | ------------ | --------- |
| 1       | 1       | 10000         | 0.000 | 0.000 | 0.000  | 1508.0  | 0.000      | 0.000      | 0.000        | 0.0       |
| 1       | 1       | 1000000       | 0.000 | 0.000 | 0.000  | 1700.0  | 0.000      | 0.000      | 0.000        | 0.0       |
| 1       | 1       | 100000000     | 0.000 | 0.000 | 0.000  | 2320.0  | 0.000      | 0.000      | 0.000        | 22736.0   |
| 1       | 1       | 10000000000   | 0.060 | 0.046 | 0.004  | 11188.8 | 0.000      | 0.000      | 0.000        | 22387.2   |
| 1       | 1       | 1000000000000 | 0.662 | 0.520 | 0.072  | 99060.0 | 0.016      | 0.000      | 0.000        | 6296.0    |
| 1       | 1000    | 1             | 0     | 0.000 | 0.020  | 1404.0  | 0.000      | 0.000      | 0.000        | 24888.0   |
| 1       | 10000   | 1             | 2     | 0.010 | 0.238  | 1436.8  | 0.000      | 0.000      | 0.000        | 9603.2    |
| 1       | 100000  | 1             | 2     | 0.162 | 2.412  | 1398.4  | 0.017      | 0.000      | 0.019        | 10140.8   |
| 1       | 1000000 | 1             | 12    | 1.704 | 23.852 | 1397.6  | 3.689      | 0.047      | 0.748        | 10308.8   |
| 1000    | 1       | 1             | 4     | 0.000 | 0.024  | 1480.8  | 0.000      | 0.000      | 0.000        | 5995.2    |
| 10000   | 1       | 1             | 6     | 0.012 | 0.276  | 1397.6  | 0.003      | 0.000      | 0.003        | 26052.8   |
| 100000  | 1       | 1             | 2     | 0.202 | 2.750  | 1365.6  | 0.275      | 0.000      | 0.280        | 6532.8    |
| 1000000 | 1       | 1             | 22    | 2.062 | 28.372 | 1436.8  | 51.508     | 0.022      | 35.108       | 9603.2    |

The table above primarily shows four things:

- Each execution parameter *does* exhibit roughly linear scaling in one or
  multiple relevant performance metrics.
- While generation of file content impacts the time in user space as well as
  memory usage, creation of additional files and directories directly increases
  the time spent in kernel space.
- File/directory creation is much slower as compared with pseudorandom content
  generation -- certainly due to the overhead of context switching, inode
  allocation, etc.
- Directory creation is slower than file creation.

**LCC3**:

### `filesearch`

`filesearch.c` implements a recursive (depth-first), linear directory search,
outputting the name and size of the largest file found in the present working
directory tree.

This workload clearly scales with the total number of files in the directory
and random-access performance. `stat` is used to look up each file's size, thus
the actual size of the files should not matter for performance. The number of
directories should also have a sizeable impact on performance, as each
`readdir`/`closedir` adds a system call and thereby a context switch.

I used `filegen` to create the following test setups, each with files sized
between 1B and 10kB:

- 1 directory, 1,000 files
- 1 directory, 1,000,000 files
- 1,000 directories, 1 file each
- 1,000 directories, 1,000 files each
- 1,000,000 directories, 1 file each

#### Results

**PC**:

| dirs    | files   | min size [B] | max size [B] | wall  | user  | system | mem      | wall (var) | user (var) | system (var) | mem (var) |
| ------- | ------- | ------------ | ------------ | ----- | ----- | ------ | -------- | ---------- | ---------- | ------------ | --------- |
| 1       | 1000    | 1            | 10000        | 0.000 | 0.000 | 0.000  | 1403.200 | 0.000      | 0.000      | 0.000        | 9323.200  |
| 1       | 1000000 | 1            | 10000        | 1.608 | 0.260 | 1.348  | 1364.000 | 0.000      | 0.000      | 0.000        | 6736.000  |
| 1000    | 1       | 1            | 10000        | 0.000 | 0.000 | 0.000  | 1397.600 | 0.000      | 0.000      | 0.000        | 10308.800 |
| 1000    | 1000    | 1            | 10000        | 1.588 | 0.258 | 1.320  | 1436.800 | 0.000      | 0.000      | 0.000        | 9603.200  |
| 1000000 | 1       | 1            | 10000        | 9.664 | 1.608 | 7.226  | 1318.400 | 8.736      | 0.001      | 1.321        | 15996.800 |

**LCC3**:


### `mmul`

`mmul.c` performs matrix multiplication in a serial fashion. It takes no
command-line arguments, thus we have no means of scaling the workload without
alterin, `nbody`g the macro `S` determining the size of the matrices being multiplied.

### `nbody`

`nbody.c` models a particle physics simulation with a fixed number of particles
in a finite space over a fixed number of iterations. We again have no way of
changing the size of the workload without modifying the code; in this case, the
macros `N`, `M`, `L` and `SPACE_SIZE`.

#### Results

**PC**:

|          | wall [s] | user [s] | system [s] | mem [kB] |
| -------- | -------- | -------- | ---------- | -------- |
| mean     | 2.608    | 2.602    | 0.000      | 24681.6  |
| variance | 0.002    | 0.002    | 0.000      | 9444.800 |

**LCC3**:


### `nbody`

`nbody.c` models a particle physics simulation with a fixed number of particles
in a finite space over a fixed number of iterations. We again have no way of
changing the size of the workload without modifying the code; in this case, the
macros `N`, `M`, `L` and `SPACE_SIZE`.

#### Results

**PC**:

|          | wall [s] | user [s] | system [s] | mem [kB] |
| -------- | -------- | -------- | ---------- | -------- |
| mean     | 1.650    | 1.646    | 0.000      | 1744.8   |
| variance | 0.001    | 0.001    | 0.000      | 9835.2   |

**LCC3**:


### `qap`

`qap.c` implements a recursive algorithm solving the
[Quadratic Assignment Problem](https://en.wikipedia.org/wiki/Quadratic_assignment_problem).
The input is given via `.dat` files in the `problems/` directory. As the
problem at hand is NP-hard, we cannot determine an upper bound for the runtime
based on input size.

After observing a runtime of well over 1 hour for a problem size of 18, I chose
to only benchmark the input files up to a problem size of 15 on my PC. On LCC3,
I added one input with a problem size of 18, took just a single measurement
(rather than five), and let the job run overnight.

#### Results

**PC**:


**LCC3**:

