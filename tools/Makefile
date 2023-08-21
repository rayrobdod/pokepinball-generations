.PHONY: all clean

CC := gcc
CFLAGS := -std=c99 -Wall -Wextra

tools := \
	collision \
	gfx \
	pcm \
	scan_includes \
	tablegfx

all: $(tools)
	@:

clean:
	rm -f $(tools)

collision: collision.c
	$(CC) $(CFLAGS) -o $@ $< -lpng

tablegfx: tablegfx.c
	$(CC) $(CFLAGS) -o $@ $< -lpng

%: %.c
	$(CC) $(CFLAGS) -o $@ $<
