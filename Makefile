.PHONY: all tools clean tidy tpp

.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:

ROM := PinballGenerations.gbc
OBJS := main.o wram.o sram.o

ifeq (,$(shell which sha1sum))
SHA1 := shasum
else
SHA1 := sha1sum
endif

COMPILE_FLAGS :=

all: $(ROM)
tpp: COMPILE_FLAGS += -D _TPP
tpp: all

ifeq (,$(filter tools clean tidy,$(MAKECMDGOALS)))
Makefile: tools
endif

%.o: dep = $(shell tools/scan_includes $(@D)/$*.asm)
%.o: %.asm $$(dep)
	rgbasm $(COMPILE_FLAGS) -h -Wunmapped-char=0 -l -o $@ $<

$(ROM): $(OBJS) contents/contents.link
	rgblink -n $(ROM:.gbc=.sym) -m $(ROM:.gbc=.map) -l contents/contents.link -o $@ $(OBJS)
	rgbfix -jsvc -k 01 -l 0x33 -m 0x1e -p 0 -r 02 -t "POKEPINBALL" -i VPHE $@

tools:
	$(MAKE) -C tools

tidy:
	rm -f $(ROM) $(OBJS) $(ROM:.gbc=.sym) $(ROM:.gbc=.map)
	$(MAKE) -C tools clean

clean: tidy
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pcm' -o -iname '*.tilemap' -o -iname '*.attrmap' -o -iname '*.gbpal' \) -exec rm {} +

%.interleave.2bpp: %.interleave.png
	rgbgfx -o $@ $<
	tools/gfx --interleave --png $< -o $@ $@

gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.attrmap gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.tilemap gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.gbpal gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.2bpp: gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.png gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.pal
	rgbgfx -u -m -b128 \
		-c psp:gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.pal \
		-a gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.attrmap.tmp \
		-t gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.tilemap.tmp \
		-p gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.gbpal \
		-o gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.2bpp \
		gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.png
	tail --bytes=+513 <gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.attrmap.tmp >gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.attrmap
	tail --bytes=+513 <gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.tilemap.tmp >gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.tilemap
	truncate --size 4096 gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.2bpp
	rgbgfx -r16 \
		-o gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.2bpp \
		gfx/stage/ruby_bottom/ruby_bottom_gameboycolor_tiles.png
	rgbgfx  -r32 -b128 \
		-a gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.attrmap \
		-t gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.tilemap \
		-p gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.gbpal \
		-o gfx/stage/ruby_bottom/ruby_bottom_gameboycolor.2bpp \
		gfx/stage/ruby_bottom/ruby_bottom_gameboycolor_reversed.png

%.2bpp: %.png
	rgbgfx -o $@ $<

%.1bpp: %.png
	rgbgfx -d1 -o $@ $<

%.pcm: %.wav
	tools/pcm -o $@ $<
