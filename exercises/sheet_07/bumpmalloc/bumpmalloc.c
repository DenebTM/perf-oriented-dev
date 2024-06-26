#include <stdio.h>
#include <stdlib.h>

/**
 * worst case: all 1,000,000 allocations are maximum size (1000 B)
 *
 * assume subsequent iterations don't need to reuse any data from previous ones
 * (otherwise i'd need to reserve 500 GiB for this exercise)
 */
#ifndef ARENA_SIZE
#define ARENA_SIZE 1000 * 1000000
#endif

char arena[ARENA_SIZE];
size_t arena_ptr = 0;

void *malloc(size_t size) {
  if (size > ARENA_SIZE) {
    return NULL;
  }

  if (ARENA_SIZE - arena_ptr < size) {
    arena_ptr = 0;
  }

  void *ptr = arena + arena_ptr;
  arena_ptr += size;

  return ptr;
}

// dummy; needs to exist
void free(void *ptr) {}
