# Performance oriented computing sheet 10
Calvin Hoy (B), Luca Rahm (A), Jannis Voigt (C)
## A) Unrolled Linked Lists
TBD

## B) Tiered Arrays
TBD

## C) Extended Benchmarking
Adapted from Jannis Voigt sheet 9. Added option for sequential and random access patterns. The random indices are precomputed no matter which access pattern is chosen to avoid one sided overhead.

Benchmarks are run with `n_runs` = 10000 and different `r_w_p` / `i_d_p` configurations where the latter two always sum up to 100:

| r_w_p                    | 1 | 10 | 50 | 90 | 99 |
|-|-|-|-|-|-|
| **linked list seq [s]**  | 3.47 | 3.54 | 3.50 | 3.62 | 3.60 |
| **linked list ran [s]**  | 3.51 | 3.47 | 3.49 | 3.52 | 3.50 |
| **array like seq [s]**   | 3.00 | 2.79 | 1.75 | 0.44 | 0.09 |
| **array like ran [s]**   | 3.35 | 2.90 | 1.59 | 0.34 | 0.08 |
| **unrolled ll seq [s]**  |  |  |  |  |  |
| **unrolled ll ran [s]**  |  |  |  |  |  |
| **tiered arr seq [s]**   |  |  |  |  |  |
| **tiered arr ran [s]**   |  |  |  |  |  |