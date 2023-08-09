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


%.table.2bpp: dep = $(shell tools/tablegfx --list-dependencies $*.tablegfx)
%.table.2bpp %.table.gbpal %.table.tilemap %.table.attrmap %.table.queued-tiledata: %.tablegfx tools/tablegfx $$(dep)
	tools/tablegfx \
		--attr-map $*.table.attrmap \
		--tilemap $*.table.tilemap \
		--queued-tiledata $*.table.queued-tiledata \
		--palette $*.table.gbpal \
		--output $*.table.2bpp \
		$*.tablegfx
	rgbgfx -r16 \
		--output $*.table.2bpp \
		$*.table.2bpp.png

%.2bpp: %.png
	rgbgfx -o $@ $<

%.1bpp: %.png
	rgbgfx -d1 -o $@ $<

%.pcm: %.wav
	tools/pcm -o $@ $<
