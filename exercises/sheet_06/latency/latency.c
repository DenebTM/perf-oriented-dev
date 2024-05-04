#pragma GCC optimize("unroll-loops")

#include <stdbool.h>
#include <stdint.h>
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

void shuffle(int *array, size_t n) {
  if (n > 1) {
    size_t i;
    for (i = n - 1; i > 0; i--) {
      size_t j = (unsigned int)(drand48() * (i + 1));
      int t = array[j];
      array[j] = array[i];
      array[i] = t;
    }
  }
}

struct node {
  struct node *next;
  bool used;

  // pad to cacheline size
  char padding[64 - sizeof(struct node *) - sizeof(bool)];
};

long long nodes_count;
struct node *nodes;
long long nextnode_offset = 0;

/**
 * create a new node at a random offset in the `nodes` array
 */
struct node *create_node() {

  // find next free node to the right if this one is already used
  for (int attempts = 0; nodes[nextnode_offset].used; attempts++) {
    if (attempts > nodes_count) {
      return NULL;
    }
    nextnode_offset = (nextnode_offset + 1) % nodes_count;
  }

  // mark this node as in-use
  struct node *ptr = nodes + nextnode_offset;
  ptr->used = true;

  // calculate the offset to be used for the next block
  long long next_offset = rand() % nodes_count;

  // return allocated node
  nextnode_offset = next_offset;
  return ptr;
}

/**
 * allocate space for `count` instances of `struct node`,
 * reset initial offset to 0
 */
struct node *nodes_init(long long count) {

  nodes_count = count;
  nodes = calloc(nodes_count, sizeof(struct node));

  nextnode_offset = 0;

  int *indices = malloc(count * sizeof(int));
  indices[count - 1] = 0;
  for (int i = 0; i < count - 1; i++) {
    indices[i] = i + 1;
  }
  shuffle(indices, count - 1);

  struct node *start = create_node();

  struct node *node = start;
  for (int i = 0; i < INDIRECTION_COUNT; i++) {

    // all available nodes allocated
    if (i + 1 >= count) {
      node->next = start;
      break;
    } else {
      node->next = nodes + indices[i];
      node = node->next;
    }
  }

  free(indices);
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

int main(int argc, char **argv) {
  char *src = malloc(sizeof(char) * BS_MAX);

  // at each block size increment of 2
  for (uint64_t block_size_base = BS_MIN; block_size_base <= BS_MAX;
       block_size_base *= 2) {

    int block_size_incr = block_size_base / 64 < sizeof(struct node)
                              ? sizeof(struct node)
                              : block_size_base / 64;

    // ...
    for (uint64_t block_size = block_size_base;
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

        int64_t sample_time = tv_end.tv_nsec - tv_start.tv_nsec;
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
