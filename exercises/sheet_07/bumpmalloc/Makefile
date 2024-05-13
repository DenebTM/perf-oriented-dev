CFLAGS := -shared -fPIC -O3 -Wall -Wextra -Wpedantic -Werror

bumpmalloc.so: bumpmalloc.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f bumpmalloc.so
