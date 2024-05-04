// #pragma GCC optimize("unroll-loops")

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define BS_MIN 1024
#define BS_MAX 32 * 1024 * 1024

#define SAMPLE_COUNT 100
#define INDIRECTION_COUNT 10000

// clang-format off
#define RPT_10(a)   a; \
                    a; \
                    a; \
                    a; \
                    a; \
                    a; \
                    a; \
                    a; \
                    a; \
                    a

#define RPT_100(a)  RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a); \
                    RPT_10(a)

#define RPT_1000(a) RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a); \
                    RPT_100(a)
// clang-format on

struct node {
  struct node *next;
  intptr_t used;

  // pad node to cacheline size
  char padding[64 - sizeof(struct node *) - sizeof(intptr_t)];
};

// int strides[15];
// int strides[] = {1110,  139022, -20398, -2002, 160000,
//                  -5620, 1998,   -2880,  99878, -87400};

long long nodes_count;
struct node *nodes;

long long mymalloc_offset = 0;
int mymalloc_stride_idx = 0;

void mymalloc_clear() {
  mymalloc_offset = 0;
  mymalloc_stride_idx = 0;

  // for (int i = 0; i < sizeof(strides) / sizeof(*strides); i++) {
  //   strides[i] = rand() / (RAND_MAX / nodes_count);
  //   //printf("%f\n", (float)strides[i] / nodes_count);
  // }

  memset(nodes, 0, nodes_count * sizeof(struct node));
}

// allocate space for `count` instances of `struct node`
void mymalloc_init(long long count) {
  nodes_count = count;
  nodes = malloc(nodes_count * sizeof(struct node));

  mymalloc_clear();
}
void mymalloc_destroy() {
  free(nodes);
  nodes = NULL;
}

struct node *mymalloc() {
  // find next free node to the right if this one is already used
  int attempts = 0;
  while (nodes[mymalloc_offset].used == 0xdeadbeef) {
    mymalloc_offset = (mymalloc_offset + 1) % nodes_count;

    attempts++;
    if (attempts > nodes_count) {
      return NULL;
    }
  }

  // mark this node as in-use
  struct node *ptr = nodes + mymalloc_offset;
  ptr->used = 0xdeadbeef;

  // calculate the offset to be used next time
  // long long next_offset =
  //     (mymalloc_offset + strides[mymalloc_stride_idx]) % nodes_count;
  // if (next_offset < 0)
  //   next_offset += nodes_count;
  long long next_offset = rand() % nodes_count;

  // mymalloc_stride_idx =
  //     (mymalloc_stride_idx + 1) % (sizeof(strides) / sizeof(*strides));

  // return allocated node
  mymalloc_offset = next_offset;
  return ptr;
}

struct node *init_nodes() {
  struct node *start = mymalloc();

  struct node *node = start;
  for (int i = 0; i < INDIRECTION_COUNT; i++) {
    struct node *next = mymalloc();

    // all nodes allocated
    if (!next) {
      node->next = start;
      break;
    }

    node->next = next;
    node = next;
  }

  return start;
}

__attribute__((used)) struct node *followed;
void follow_chain(struct node *start) {
  followed = start;
  for (int i = 0; i < INDIRECTION_COUNT / 100; i++) {
    RPT_100(followed = followed->next);
  }
}

int main(int argc, char **argv) {
  char *src = malloc(sizeof(char) * BS_MAX);

  for (uint64_t block_size_base = BS_MIN; block_size_base <= BS_MAX;
       block_size_base *= 2) {

    for (uint64_t block_size = block_size_base;
         block_size < 2 * block_size_base && block_size <= BS_MAX;
         block_size += block_size_base / 64) {

      __suseconds_t total = 0;

      mymalloc_init(block_size / sizeof(struct node));
      struct node *start = init_nodes();

      for (int i = 0; i < SAMPLE_COUNT; i++) {
        // mymalloc_clear();
        // struct node *node = init_nodes();
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

      mymalloc_destroy();

      printf("%lu\t%lf\n", block_size,
             (double)total / SAMPLE_COUNT / INDIRECTION_COUNT);
      fflush(stdout);
    }
  }

  free(src);
  return EXIT_SUCCESS;
}
