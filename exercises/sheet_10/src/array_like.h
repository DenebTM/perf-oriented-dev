#ifndef _ARRAY_LIKE_H
#define _ARRAY_LIKE_H

void init();
void cleanup();

void insert(int index, int data);
void del(int index);
int read(int index);
void write(int index, int data);

#endif
