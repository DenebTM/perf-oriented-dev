#ifndef LINKED_LIST_H
#define LINKED_LIST_H

#include <stdio.h>
#include <stdlib.h>

// Define the struct node
struct node {
    int data;
    struct node *next;
};

// Function declarations
void insert(int position, int data);
void del(int position);
int read(int position);
void write(int position, int data);

#endif
