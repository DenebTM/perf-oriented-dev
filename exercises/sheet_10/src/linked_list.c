#include <stdio.h>
#include <stdlib.h>

#include "array_like.h"

struct node {
  int data;
  struct node *next;
};
struct node *head = NULL;

void insert(int index, int data) {
  struct node *new_node = malloc(sizeof(struct node));
  new_node->data = data;
  new_node->next = NULL;

  if (index == 0) {
    new_node->next = head;
    head = new_node;
    return;
  }

  struct node *temp = head;
  for (int i = 0; i < index - 1; i++) {
    temp = temp->next;
  }

  new_node->next = temp->next;
  temp->next = new_node;
}

void del(int index) {
  struct node *temp = head;

  if (index == 0) {
    head = temp->next;
    free(temp);
    return;
  }

  for (int i = 0; i < index - 1; i++) {
    temp = temp->next;
  }

  struct node *new_next = temp->next->next;
  free(temp->next);
  temp->next = new_next;
}

int read(int index) {
  struct node *temp = head;
  for (int i = 0; i < index; i++) {
    temp = temp->next;
  }

  return temp->data;
}

void write(int index, int data) {
  struct node *temp = head;
  for (int i = 0; i < index; i++) {
    temp = temp->next;
  }

  temp->data = data;
}
