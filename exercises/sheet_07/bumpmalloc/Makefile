CC := clang
CFLAGS := -shared -fPIC \
		  -O3 -march=native \
		  -Wall -Wextra -Wpedantic -Werror -Wno-unused-parameter

bumpmalloc.so: bumpmalloc.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f bumpmalloc.so
