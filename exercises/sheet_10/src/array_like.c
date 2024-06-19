#include "array_like.h"

#define SIZE 1000

int arr[SIZE];
int length = 0;

void insert(int index, int data) {
  for (int i = length - 1; i >= index; i--) {
    arr[i + 1] = arr[i];
  }
  arr[index] = data;
  length++;
}

void del(int index) {
  for (int i = index; i < length - 1; i++) {
    arr[i] = arr[i + 1];
  }
  length--;
}

int read(int index) { return arr[index]; }

void write(int index, int data) { arr[index] = data; }
