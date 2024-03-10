# Exercise 1

## A) Preparation

### Building

I created a new folder named `build` and ran `cmake ..` inside it to prepare the build environment.

I then ran `make -j$(nproc)` to compile the examples.

### `delanoy.c`

The code in `delannoy.c` performs a recursive computation which runs very fast for low values of `N`, but becomes exponentially slower.

I chose to test all values of N between 1 and 15 (inclusive). Extrapolating the runtime for N=15 led me to expect a runtime in the ballpark of 10 minutes for N=16, and one hour for N=17, which I deemed simply impractical.

#### Results

## B) Experiments

I did this first and used the script to obtain the results shown in part A).

See [benchmark.sh](benchmark.sh); run the script with `--help` for more information.
