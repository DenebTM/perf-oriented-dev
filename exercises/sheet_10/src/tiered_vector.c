#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "array_like.h"

#define min(x, y) ((x < y) ? x : y)

#ifndef TREE_DEPTH
#define TREE_DEPTH 3 // minimum 1
#endif
#ifndef NODE_SIZE
#define NODE_SIZE 16
#endif

#define TYPE int

// leaf nodes hold data
// internal nodes hold pointers to child nodes
union node_data {
  struct node *node;
  TYPE data;
};

struct node {
  int capacity;
  int offset;
  int size;
  bool is_leaf;
  union node_data elements[NODE_SIZE];
};

struct node root;

void init_helper(struct node *v, int depth) {
  v->capacity = NODE_SIZE;
  for (int i = 0; i < depth; i++) {
    v->capacity *= NODE_SIZE;
  }

  if (depth == 0) {
    v->is_leaf = true;
    return;
  }

  for (int i = 0; i < NODE_SIZE; i++) {
    v->elements[i].node = calloc(1, sizeof(struct node));
    init_helper(v->elements[i].node, depth - 1);
  }
}

void cleanup_helper(struct node *v) {
  if (v->is_leaf) {
    if (v != &root)
      free(v);

    return;
  }

  for (int i = 0; i < NODE_SIZE; i++) {
    cleanup_helper(v->elements[i].node);
  }
}

// INTERNAL functions
TYPE *access(struct node *v, int i) {
  if (v->is_leaf) {
    return &v->elements[(NODE_SIZE + i + v->offset) % NODE_SIZE].data;
  }

  int i_prime = (i + v->offset) % v->capacity;
  struct node *v_prime = v->elements[i_prime / NODE_SIZE].node;
  return access(v_prime, i_prime % v_prime->capacity);
}

TYPE update(struct node *v, int i, TYPE e) {
  TYPE old_e = *access(v, i);
  *access(v, i) = e;

  return old_e;
}

TYPE shift(struct node *v, TYPE e, int i, int m, int size_update) {
  if (v->is_leaf) {
    TYPE e_0 = v->elements[(NODE_SIZE + v->offset + i + m) % NODE_SIZE].data;
    for (int i = m - 1; i > 0; i--) {
      v->elements[(NODE_SIZE + v->offset + i + 1)] = v->elements[(NODE_SIZE + v->offset + i) % NODE_SIZE];
    }
    v->elements[(NODE_SIZE + v->offset + i) % NODE_SIZE].data = e;
    return e_0;
  }

  v->size += size_update;

  int i_l = (i + v->offset) % v->capacity;
  int i_r = (i_l + m) % v->capacity;

  struct node *c_l = v->elements[(NODE_SIZE + (i_l * NODE_SIZE / v->capacity)) % NODE_SIZE].node;
  struct node *c_r = v->elements[(NODE_SIZE + (i_r * NODE_SIZE / v->capacity)) % NODE_SIZE].node;

  // insert the new element
  TYPE e_l = shift(c_l, e, i_l, min(m, c_l->capacity - i_l), size_update);

  for (int i = 1; i < m - 1; i++) {
    struct node *c_i = v->elements[(NODE_SIZE + ((i_l + i) * NODE_SIZE / v->capacity)) % NODE_SIZE].node;
    TYPE e_i = update(c_i, c_i->size - 1, e_l);
    c_i->offset = ((c_i->offset - 1) + c_i->capacity) % c_i->capacity;
    e_l = e_i;
  }

  // put back the element that was moved to make room for the new one
  return shift(c_r, e_l, 0, i_r % c_r->capacity, 0);
}

// PUBLIC functions
void init() { init_helper(&root, TREE_DEPTH - 1); }

void cleanup() { cleanup_helper(&root); }

TYPE read(int index) { return *access(&root, index); }

void write(int index, TYPE data) { update(&root, index, data); }

void insert(int index, int data) { shift(&root, data, index, root.size - index - 1, 1); }

void del(int index) {
  shift(&root, 0, 0, index, -1);
  root.offset = (root.offset + 1) % root.capacity;
}
