#pragma GCC optimize("unroll-loops")

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define BS_MIN 512                // 512 B
#define BS_MAX 64 * 1024 * 1024   // 64 MiB
#define SAMPLE_COUNT 5            // number of test passes per block size
#define INDIRECTION_COUNT 1000000 // divided by 100 and rounded down

// clang-format off
#define RPT_10(a)   a;a;a;a;a;a;a;a;a;a
#define RPT_100(a)  RPT_10(a);RPT_10(a);RPT_10(a);RPT_10(a);RPT_10(a);\
                    RPT_10(a);RPT_10(a);RPT_10(a);RPT_10(a);RPT_10(a)
// clang-format on

// source: https://stackoverflow.com/a/10072899
void shuffle(int *array, size_t n) {
  if (n > 1) {
    for (size_t i = n - 1; i > 0; i--) {
      size_t j = (size_t)(drand48() * (i + 1));
      int t = array[j];
      array[j] = array[i];
      array[i] = t;
    }
  }
}

struct node {
  struct node *next;

  // pad to cacheline length
  char padding[64 - sizeof(struct node *)];
};

long long nodes_count;
struct node *nodes;

/**
 * allocate space for `count` instances of `struct node`,
 * then link them in a random order
 */
struct node *nodes_init(size_t count) {

  nodes_count = count;
  nodes = calloc(nodes_count, sizeof(struct node));

  static int indices[BS_MAX / sizeof(struct node)];
  indices[count - 1] = 0;
  for (size_t i = 0; i < count - 1; i++) {
    indices[i] = i + 1;
  }
  shuffle(indices, count - 1);

  struct node *start = nodes;

  struct node *node = start;
  for (size_t i = 0; i < INDIRECTION_COUNT && i < count; i++) {
    node->next = nodes + indices[i];
    node = node->next;
  }

  return start;
}

void nodes_destroy() {
  free(nodes);
  nodes = NULL;
}

__attribute__((used)) // prevent GCC from optimizing out the test
struct node *followed;

/**
 * follow `start`'s `next` pointer `floor(INDIRECTION_COUNT / 100) *
 * 100` times
 */
void follow_chain(struct node *start) {
  followed = start;
  for (int i = 0; i < INDIRECTION_COUNT / 100; i++) {
    RPT_100(followed = followed->next);
  }
}

int main() {
  char *src = malloc(sizeof(char) * BS_MAX);

  // for each block size range n <= B < 2*n ...
  for (size_t block_size_base = BS_MIN; block_size_base <= BS_MAX;
       block_size_base *= 2) {

    int block_size_incr = block_size_base / 64 < sizeof(struct node)
                              ? sizeof(struct node)
                              : block_size_base / 64;

    // ... test 64 equally spaced block sizes
    for (size_t block_size = block_size_base;
         block_size < 2 * block_size_base && block_size <= BS_MAX;
         block_size += block_size_incr) {

      __suseconds_t total = 0;

      // create `nodes` array of current block size
      struct node *start = nodes_init(block_size / sizeof(struct node));

      for (int i = 0; i < SAMPLE_COUNT; i++) {
        struct node *node = start;

        struct timespec tv_start;
        clock_gettime(CLOCK_REALTIME, &tv_start);

        follow_chain(node);

        struct timespec tv_end;
        clock_gettime(CLOCK_REALTIME, &tv_end);

        __suseconds_t sample_time = tv_end.tv_nsec - tv_start.tv_nsec;
        if (sample_time < 0) {
          sample_time += 1000000000;
        }
        total += sample_time;
      }

      nodes_destroy();

      printf("%lu\t%lf\n", block_size,
             (double)total / SAMPLE_COUNT / INDIRECTION_COUNT);
      fflush(stdout);
    }
  }

  free(src);
  return EXIT_SUCCESS;
}
