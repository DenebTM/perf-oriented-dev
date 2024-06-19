// compiling: gcc -o benchmark_arr array_like.c benchmark.c
// compiling: gcc -o benchmark_ll linked_list.c benchmark.c
#include <stdio.h>
#include <stdlib.h>

#include "array_like.h"

#define LENGTH 1000

int get_random_max(int max) { return rand() % max; }

int main(int argc, char *argv[]) {
  if (argc < 5) {
    printf("Usage: %s <N_RUNS> <R_W_P> <I_D_P> <Sequential>\n", argv[0]);
    return 1;
  }
  int N_RUNS = atoi(argv[1]);
  int R_W_P = atoi(argv[2]);
  int I_D_P = atoi(argv[3]);
  int SEQUENTIAL = atoi(argv[4]);

  init();

  // set up initial data
  for (int i = 0; i < LENGTH; i++) {
    insert(i, rand());
  }

  // precompute random access indices
  // outside of if so overhead is more similar for sequential and random access
  int rand_indices[2 * N_RUNS * (R_W_P + I_D_P)];
  for (int i = 0; i < 2 * N_RUNS * (R_W_P + I_D_P); i++) {
    rand_indices[i] = get_random_max(LENGTH);
  }

  int count = 0;
  if (SEQUENTIAL == 0) {
    for (int n = 0; n < N_RUNS; n++) {
      for (int i_d = 0; i_d < I_D_P; i_d++) {
        insert(rand_indices[count], rand());
        count++;
        del(rand_indices[count]);
        count++;
      }
      for (int r_w = 0; r_w < R_W_P; r_w++) {
        read(rand_indices[count]);
        count++;
        write(rand_indices[count], rand());
        count++;
      }
    }
  } else {
    for (int n = 0; n < N_RUNS; n++) {
      for (int i_d = 0; i_d < I_D_P; i_d++) {
        insert(count % LENGTH, rand());
        count++;
        del(count % LENGTH);
        count++;
      }
      for (int r_w = 0; r_w < R_W_P; r_w++) {
        read(count % LENGTH);
        count++;
        write(count % LENGTH, rand());
        count++;
      }
    }
  }

  cleanup();

  return 0;
}
