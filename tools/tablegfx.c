/*
 * Generate the files that represent table graphics
 *
 * gbagfx is insufficient in this instance because
 * gbagfx can neither force certain tiles to a particular location
 * nor output which index certain tiles have been placed.
 * At least one of the two is required for dynamic portions of the stage background.
 */

#define EXTRACT_TILE_MAX_PALETTE (8)

#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE (200809L)
#include <ctype.h>
#include <endian.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <getopt.h>
#include <string.h>
#include <stdint.h>
#include <png.h>

#include "common.h"

static void usage(void) {
	fprintf(stderr, "Usage: tablegfx "
		"[--list-dependencies] "
		"[--attr-map file] "
		"[--tilemap file] "
		"[--queued-tiledata file] "
		"[--palette file] "
		"[--output0 file] "
		"[--output1 file] "
		"[-h] "
		"infile\n"
	);
}

/**
 * Modifes a nul-terminated string in-place to remove leading and terminating spaces and newlines.
 * Returns a pointer to the new string. The returned pointer is inside `str`.
 */
char *strstrip_inplace(char* str) {
	while (isspace(str[0])) {
		str++;
	}
	int len = strlen(str);
	while (isspace(str[len - 1])) {
		str[len - 1] = '\0';
		len = len - 1;
	}
	return str;
}

struct slice {
	unsigned int x;
	unsigned int y;
	unsigned int width_in_tiles;
	unsigned int height_in_tiles;
};

struct position {
	unsigned int x;
	unsigned int y;
};

/****** Options ******/

struct Options {
	int help;
	int list_dependencies;
	char *output_attrmap_filename;
	char *output_tilemap_filename;
	char *output_palette_filename;
	char *output_pixeldata0_filename;
	char *output_pixeldata1_filename;
	char *output_queuedtiledata_filename;
};

struct Options Options = {
};

void get_args(int argc, char *argv[]) {
	struct option long_options[] = {
		{"attr-map", required_argument, 0, 'a'},
		{"tilemap", required_argument, 0, 't'},
		{"palette", required_argument, 0, 'p'},
		{"output0", required_argument, 0, 'o'},
		{"output1", required_argument, 0, 'O'},
		{"queued-tiledata", required_argument, 0, 'q'},
		{"list-dependencies", no_argument, &Options.list_dependencies, 1},
		{"help", no_argument, 0, 'h'},
		{0}
	};
	for (int opt = 0; opt != -1;) {
		switch (opt = getopt_long(argc, argv, "h", long_options)) {
		case 'h':
			Options.help = true;
			break;
		case 'a':
			Options.output_attrmap_filename = optarg;
			break;
		case 't':
			Options.output_tilemap_filename = optarg;
			break;
		case 'o':
			Options.output_pixeldata0_filename = optarg;
			break;
		case 'O':
			Options.output_pixeldata1_filename = optarg;
			break;
		case 'p':
			Options.output_palette_filename = optarg;
			break;
		case 'q':
			Options.output_queuedtiledata_filename = optarg;
			break;
		case 0:
		case -1:
			break;
		default:
			usage();
			exit(1);
			break;
		}
	}
}

/****** Inputfile ******/

struct InputfileReserved {
	char* filename;
	unsigned int bank;
	unsigned int base_id;
	unsigned int length;
};

struct InputfileTiledataset {
	char* label;
	bool generate_header;
	char* function;

	struct position position;

	size_t frame_count;
	struct InputfileTiledatasetFrame *frame_values;
};

struct InputfileTiledatasetFrame {
	char* label;
	char* filename;
	bool horizontal_flip;
	bool ignore_tiles_with_palette_set;
	unsigned int ignore_tiles_with_palette;
	struct slice slice;
};

struct Inputfile {
	char* field_label;
	char* platform_label;
	char* palette_filename;

	/** the primary board graphics */
	struct {
		char* filename;
	} base;

	/** The reserved tiles  */
	size_t reserved_count;
	struct InputfileReserved *reserved_values;

	size_t tiledataset_count;
	struct InputfileTiledataset *tiledataset_values;
};

enum InputfileCurrentTable {
	INPUTFILE_TABLE_BASE,
	INPUTFILE_TABLE_RESERVED,
	INPUTFILE_TABLE_TILEDATASET,
	INPUTFILE_TABLE_TILEDATASET_FRAME,
	INPUTFILE_TABLE_ROOT
};

/**
 * Returns a newly-malloc'd pointer
 */
char *extract_toml_string_value(const char* input, const char* filename, size_t line) {
	char *retval;

	if ('\'' == input[0] && '\'' == input[strlen(input) - 1]) {
		retval = strdup(input + 1);
		retval[strlen(retval) - 1] = '\0';
		return retval;
	} else {
		fprintf(stderr, "%s:%zd:0: could not parse string value: %s\n", filename, line, input);
		exit(1);
	}
}

unsigned int extract_toml_uint_value(const char* input, const char* filename, size_t line) {
	unsigned int retval = 0;

	if ('+' == input[0]) {
		++input;
	}

	while ('\0' != input[0]) {
		if ('0' <= input[0] && input[0] <= '9') {
			retval *= 10;
			retval += input[0] - '0';
		} else {
			fprintf(stderr, "%s:%zd:0: could not parse integer value: %s\n", filename, line, input);
			exit(1);
		}

		++input;
	}

	return retval;
}

bool extract_toml_bool_value(const char* input, const char* filename, size_t line) {
	if (0 == strcmp("true", input)) {
		return true;
	} else if (0 == strcmp("false", input)) {
		return false;
	} else {
		fprintf(stderr, "%s:%zd:0: could not parse boolean value: %s\n", filename, line, input);
		exit(1);
	}
}

void close_tiledataset_frame_if_open(
		bool *dataset_is_open,
		struct InputfileTiledataset *dataset,
		bool *frame_is_open,
		struct InputfileTiledatasetFrame *frame) {
	if (*frame_is_open) {
		if (! *dataset_is_open) {
			fprintf(stderr, "assumption violated: tiledataset_frame open but tiledataset closed");
			exit(1);
		}

		dataset->frame_values = reallocarray(dataset->frame_values, dataset->frame_count + 1, sizeof(struct InputfileTiledatasetFrame));
		memcpy(dataset->frame_values + dataset->frame_count, frame, sizeof(struct InputfileTiledatasetFrame));
		dataset->frame_count = dataset->frame_count + 1;

		*frame_is_open = false;
		memset(frame, 0, sizeof(struct InputfileTiledatasetFrame));
	}
}

void close_tiledataset_if_open(
		struct Inputfile *inputfile,
		bool *dataset_is_open,
		struct InputfileTiledataset *dataset) {
	if (*dataset_is_open) {
		inputfile->tiledataset_values = reallocarray(inputfile->tiledataset_values, inputfile->tiledataset_count + 1, sizeof(struct InputfileTiledataset));
		memcpy(inputfile->tiledataset_values + inputfile->tiledataset_count, dataset, sizeof(struct InputfileTiledataset));
		inputfile->tiledataset_count = inputfile->tiledataset_count + 1;

		*dataset_is_open = false;
		memset(dataset, 0, sizeof(struct InputfileTiledataset));
	}
}

void close_reserved_if_open(
		struct Inputfile *inputfile,
		bool *dataset_is_open,
		struct InputfileReserved *dataset) {
	if (*dataset_is_open) {
		inputfile->reserved_values = reallocarray(inputfile->reserved_values, inputfile->reserved_count + 1, sizeof(struct InputfileReserved));
		memcpy(inputfile->reserved_values + inputfile->reserved_count, dataset, sizeof(struct InputfileReserved));
		inputfile->reserved_count = inputfile->reserved_count + 1;

		*dataset_is_open = false;
		memset(dataset, 0, sizeof(struct InputfileReserved));
	}
}

struct Inputfile parse_inputfile(char* filename) {
	FILE *file = fopen_verbose(filename, "r");
	if (!file) {
		exit(1);
	}

	size_t bufferc = 0;
	char* bufferv = NULL;
	ssize_t getlineretval = 0;
	enum InputfileCurrentTable current_table = INPUTFILE_TABLE_ROOT;
	size_t line = 0;

	struct Inputfile retval = {0};

	bool reserved_open = false;
	struct InputfileReserved retval_reserved = {0};
	bool tiledataset_open = false;
	bool tiledataset_frame_open = false;
	struct InputfileTiledataset retval_tiledataset = {0};
	struct InputfileTiledatasetFrame retval_tiledataset_frame = {0};

	getlineretval = getline(&bufferv, &bufferc, file);
	while (getlineretval >= 0) {
		if (0 == strcmp("\n", bufferv)) {
			// ignore empty lines
			++line;
			getlineretval = getline(&bufferv, &bufferc, file);
			continue;
		}
		if ('#' == bufferv[0]) {
			// ignore lines with only a comment
			++line;
			getlineretval = getline(&bufferv, &bufferc, file);
			continue;
		}

		if ('[' == bufferv[0] && ']' == bufferv[strlen(bufferv) - 2] && '\n' == bufferv[strlen(bufferv) - 1]) {
			// change table

			enum InputfileCurrentTable transition_to;
			if (0 == strcmp("[base]\n", bufferv)) {
				transition_to = INPUTFILE_TABLE_BASE;
			} else if (0 == strcmp("[[reserved]]\n", bufferv)) {
				transition_to = INPUTFILE_TABLE_RESERVED;
			} else if (0 == strcmp("[[tiledataset]]\n", bufferv)) {
				transition_to = INPUTFILE_TABLE_TILEDATASET;
			} else if (0 == strcmp("[[tiledataset.frame]]\n", bufferv)) {
				transition_to = INPUTFILE_TABLE_TILEDATASET_FRAME;
			} else {
				fprintf(stderr, "%s:%zd:0: unknown table: %s\n", filename, line, bufferv);
				exit(1);
			}

			close_reserved_if_open(
				&retval,
				&reserved_open,
				&retval_reserved
			);

			close_tiledataset_frame_if_open(
				&tiledataset_open,
				&retval_tiledataset,
				&tiledataset_frame_open,
				&retval_tiledataset_frame
			);

			if (transition_to != INPUTFILE_TABLE_TILEDATASET_FRAME) {
				close_tiledataset_if_open(
					&retval,
					&tiledataset_open,
					&retval_tiledataset
				);
			}

			switch (transition_to) {
			case INPUTFILE_TABLE_ROOT:
				break;
			case INPUTFILE_TABLE_BASE:
				break;
			case INPUTFILE_TABLE_RESERVED:
				reserved_open = true;
				break;
			case INPUTFILE_TABLE_TILEDATASET:
				tiledataset_open = true;
				break;
			case INPUTFILE_TABLE_TILEDATASET_FRAME:
				if (! tiledataset_open) {
					fprintf(stderr, "%s:%zd:0: cannot transition to [[tiledataset.frame]] exept from inside a [[tiledataset]]", filename, line);
					exit(1);
				}
				tiledataset_frame_open = true;

				break;
			}

			current_table = transition_to;

			++line;
			getlineretval = getline(&bufferv, &bufferc, file);
			continue;
		}

		char* separator = strchr(bufferv, '=');
		if (separator) {
			// key-value pair
			*separator = '\0';
			char* value = strstrip_inplace(separator + 1);
			char* key = strstrip_inplace(bufferv);

			switch (current_table) {
			case INPUTFILE_TABLE_ROOT:
				if (0 == strcmp("palette", key)) {
					retval.palette_filename = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("field", key)) {
					retval.field_label = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("platform", key)) {
					retval.platform_label = extract_toml_string_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in root table: %s\n", filename, line, key);
					exit(1);
				}
				break;

			case INPUTFILE_TABLE_BASE:
				if (0 == strcmp("filename", key)) {
					retval.base.filename = extract_toml_string_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in root table: %s\n", filename, line, key);
					exit(1);
				}
				break;

			case INPUTFILE_TABLE_RESERVED:
				if (0 == strcmp("filename", key)) {
					retval_reserved.filename = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("bank", key)) {
					retval_reserved.bank = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("base_id", key)) {
					retval_reserved.base_id = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("length", key)) {
					retval_reserved.length = extract_toml_uint_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in root table: %s\n", filename, line, key);
					exit(1);
				}
				break;

			case INPUTFILE_TABLE_TILEDATASET:
				if (0 == strcmp("label", key)) {
					retval_tiledataset.label = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("function", key)) {
					retval_tiledataset.function = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("generate_header", key)) {
					retval_tiledataset.generate_header = extract_toml_bool_value(value, filename, line);
				} else if (0 == strcmp("position.x", key)) {
					retval_tiledataset.position.x = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("position.y", key)) {
					retval_tiledataset.position.y = extract_toml_uint_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in [source] table: %s\n", filename, line, key);
					exit(1);
				}

				break;
			case INPUTFILE_TABLE_TILEDATASET_FRAME:
				if (0 == strcmp("label", key)) {
					retval_tiledataset_frame.label = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("filename", key)) {
					retval_tiledataset_frame.filename = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("ignore_tiles_with_palette", key)) {
					retval_tiledataset_frame.ignore_tiles_with_palette_set = true;
					retval_tiledataset_frame.ignore_tiles_with_palette = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("horizontal_flip", key)) {
					retval_tiledataset_frame.horizontal_flip = extract_toml_bool_value(value, filename, line);
				} else if (0 == strcmp("slice.x", key)) {
					retval_tiledataset_frame.slice.x = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("slice.y", key)) {
					retval_tiledataset_frame.slice.y = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("slice.width_in_tiles", key)) {
					retval_tiledataset_frame.slice.width_in_tiles = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("slice.height_in_tiles", key)) {
					retval_tiledataset_frame.slice.height_in_tiles = extract_toml_uint_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in [source.tiledata] table: %s\n", filename, line, key);
					exit(1);
				}

				break;
			default:
				fprintf(stderr, "%s:%zd:0: unknown current_table value", filename, line);
				exit(1);
			}

			++line;
			getlineretval = getline(&bufferv, &bufferc, file);
			continue;
		}

		fprintf(stderr, "%s:%zd:0: unknown line, %s", filename, line, bufferv);
		exit(1);
	}

	close_reserved_if_open(
		&retval,
		&reserved_open,
		&retval_reserved
	);

	close_tiledataset_frame_if_open(
		&tiledataset_open,
		&retval_tiledataset,
		&tiledataset_frame_open,
		&retval_tiledataset_frame
	);

	close_tiledataset_if_open(
		&retval,
		&tiledataset_open,
		&retval_tiledataset
	);

	free(bufferv);
	fclose(file);
	return retval;
}

/****** Palette ******/

typedef uint16_t color555_t;
typedef color555_t palette_t[4];
typedef palette_t palettes_t[8];

color555_t rgb24_to_rgb16(uint8_t red, uint8_t green, uint8_t blue) {
	return (
		(red >> 3 & 0x001F) |
		(green << 2 & 0x03E0) |
		(blue << 7 & 0x7C00)
	);
}

void parse_psp_palette(palettes_t* output, char* filename) {
	FILE *file = fopen_verbose(filename, "r");
	if (!file) {
		exit(1);
	}

	size_t bufferc = 0;
	char* bufferv = NULL;
	ssize_t getlineretval = 0;
	size_t line = 0;

	getlineretval = getline(&bufferv, &bufferc, file);
	if (getlineretval <= 0) {
		fprintf(stderr, "%s:%zd:0: psp palette too short\n", filename, line);
		exit(1);
	}
	if (0 != strcmp("JASC-PAL\r\n", bufferv)) {
		fprintf(stderr, "%s:%zd:0: psp palette magic number: %s\n", filename, line, bufferv);
		exit(1);
	}
	++line;
	getlineretval = getline(&bufferv, &bufferc, file);
	if (getlineretval <= 0) {
		fprintf(stderr, "%s:%zd:0: psp palette too short\n", filename, line);
		exit(1);
	}
	if (0 != strcmp("0100\r\n", bufferv)) {
		fprintf(stderr, "%s:%zd:0: psp palette magic number: %s\n", filename, line, bufferv);
		exit(1);
	}
	++line;
	getlineretval = getline(&bufferv, &bufferc, file);
	if (getlineretval <= 0) {
		fprintf(stderr, "%s:%zd:0: psp palette too short\n", filename, line);
		exit(1);
	}
	if (0 != strcmp("32\r\n", bufferv)) {
		fprintf(stderr, "%s:%zd:0: Only 32 palette entries supported\n", filename, line);
		exit(1);
	}
	for (int i = 0; i < 32; i++) {
		++line;
		getlineretval = getline(&bufferv, &bufferc, file);
		if (getlineretval <= 0) {
			fprintf(stderr, "%s:%zd:0: not enough palette entries\n", filename, line);
			exit(1);
		}

		uint8_t red, green, blue;
		sscanf(bufferv, "%hhu %hhu %hhu\r\n", &red, &green, &blue);

		(*output)[i / 4][i % 4] = rgb24_to_rgb16(red, green, blue);
	}

	free(bufferv);
	fclose(file);
	return;
}

/****** Tiles ******/

struct attrmap {
	unsigned priority;
	unsigned vertical_flip;
	unsigned horizontal_flip;
	unsigned bank;
	unsigned palette;
};
typedef uint8_t tilemap_t;

typedef uint8_t tiledata_t[16];
struct tile_bank_entry {
	bool used;
	tiledata_t data;
};
typedef struct tile_bank_entry tile_bank_t[256];


struct queued_tiledata_item {
	uint8_t count;
	uint8_t x;
	uint8_t y;
	uint8_t tiles[8];
};
struct queued_tiledata_list {
	char label[64]; // does not include the `TileData_` prefix
	char function[32];
	bool generate_header;
	uint8_t total_count;
	uint8_t parts_count;
	struct queued_tiledata_item parts[16];
};
struct queued_tiledata_list_list {
	size_t count;
	struct queued_tiledata_list *data;
};

struct tile_image {
	png_uint_32 width; // in tiles
	png_uint_32 height; // in tiles
	struct attrmap *attrs;
	tilemap_t *tiles;
	// the image data itself is stored in tile banks, separately from this struct
};

struct optional_attrmap {
	bool is_set;
	struct attrmap value;
};

/**
 * Returns the index of needle in haystack, or `-1` if needle is not in haystack
 */
ssize_t index_of_color(const color555_t *haystack, const color555_t needle, const size_t count) {
	size_t index = 0;
	while (index < count) {
		if (needle == haystack[index]) {
			return index;
		}
		index++;
	}
	return -1;
}

/**
 * Reverses the order of the bits in a byte
 */
uint8_t bitreverse(const uint8_t in) {
	return ((in & 0x01) << 7) |
		((in & 0x02) << 5) |
		((in & 0x04) << 3) |
		((in & 0x08) << 1) |
		((in & 0x10) >> 1) |
		((in & 0x20) >> 3) |
		((in & 0x40) >> 5) |
		((in & 0x80) >> 7);
}

void flip_inplace(tiledata_t *tiledata, const bool horizontal_flip) {
	if (horizontal_flip) {
		for (int j = 0; j < 16; j++) {
			(*tiledata)[j] = bitreverse((*tiledata)[j]);
		}
	}
}

/**
 * Finds the index of the palette (in palettes) used by the tile described by the other parameters
 */
int8_t palette_of_tile(
		const palettes_t palette,
		png_byte **row_pointers,
		const unsigned start_x,
		const unsigned start_y,
		const bool horizontal_flip,
		const unsigned image_width,
		const char* filename,
		const unsigned tilex,
		const unsigned tiley) {
	color555_t current_tile_color_v[EXTRACT_TILE_MAX_PALETTE];
	size_t current_tile_color_c;

	current_tile_color_c = 0;

	for (unsigned y = 0; y < 8; y++) {
	for (unsigned x = 0; x < 8; x++) {
		size_t pixel_x_in_image = (start_x + x);
		if (horizontal_flip) {
			pixel_x_in_image = image_width - 1 - pixel_x_in_image;
		}

		png_byte red = row_pointers[start_y + y][pixel_x_in_image * 3];
		png_byte green = row_pointers[start_y + y][pixel_x_in_image * 3 + 1];
		png_byte blue = row_pointers[start_y + y][pixel_x_in_image * 3 + 2];
		color555_t current_color = rgb24_to_rgb16(red, green, blue);

		unsigned i;
		for (i = 0; i < current_tile_color_c; i++) {
			if (current_color == current_tile_color_v[i]) {
				break;
			}
		}
		if (i == current_tile_color_c && current_tile_color_c < EXTRACT_TILE_MAX_PALETTE) {
			current_tile_color_v[current_tile_color_c] = current_color;
			++current_tile_color_c;
		}
	}
	}

	if (current_tile_color_c > 4) {
		fprintf(stderr, "%s: tile (%u:%u) has more than four colors", filename, tilex, tiley);
		return -1;
	}

	unsigned palette_index;
	for (palette_index = 0; palette_index < 8; ++palette_index) {
		const color555_t *current_palette = palette[palette_index];

		bool current_is_subset_of_checking = true;
		for (unsigned current_entry = 0; current_entry < current_tile_color_c; ++current_entry) {
			bool current_entry_is_in_checking = false;

			for (unsigned checking_entry = 0; checking_entry < 4; ++checking_entry) {
				if (current_palette[checking_entry] == current_tile_color_v[current_entry]) {
					current_entry_is_in_checking = true;
					break;
				}
			}

			current_is_subset_of_checking &= current_entry_is_in_checking;
		}

		if (current_is_subset_of_checking) {
			break;
		}
	}

	if (palette_index >= 8) {
		fprintf(stderr, "%s: tile (%u:%u) colors does not fit in provided palettes\n", filename, tilex, tiley);
		return -1;
	}
	return palette_index;
}

typedef void tile_bank_insert_fn(
		tile_bank_t *out_bank0,
		tile_bank_t *out_bank1,
		struct attrmap *out_attrs,
		tilemap_t *out_index,
		const unsigned tilex,
		const unsigned tiley,
		const unsigned tileid,
		const tiledata_t *tiledata,
		const char* filename,
		void *arg);

/**
 * Insert a tile into the pixel data position indicated by the `InputfileReserved` arg.
 *
 * Some tiles have a hard-coded meaning; such as the digits and other statusbar elements
 * at tiles $80 through $8F of the main boards; use this to place those tiles at the required position
 */
void tile_bank_insert_reserved(
		tile_bank_t *out_bank0,
		tile_bank_t *out_bank1,
		__attribute__((unused)) struct attrmap *out_attrs,
		tilemap_t *out_index,
		__attribute__((unused)) const unsigned tilex,
		__attribute__((unused)) const unsigned tiley,
		const unsigned tileid,
		__attribute__((unused)) const tiledata_t *tiledata,
		const char* filename,
		void *arg) {
	struct InputfileReserved *arg2 = (struct InputfileReserved*) arg;

	if (arg2->length != 0 && tileid > arg2->length) return;

	tile_bank_t *bank = (arg2->bank ? out_bank1 : out_bank0);
	size_t i = (arg2->base_id + tileid) & 0xFF;
	if ((*bank)[i].used) {
		fprintf(stderr, "%s: reserved tile %zd was already used\n", filename, i);
		return;
	}
	(*bank)[i].used = true;
	memcpy((*bank)[i].data, tiledata, 16);
	*out_index = i;
}

void tile_bank_insert_search_exact(
		tile_bank_t *out_bank0,
		tile_bank_t *out_bank1,
		struct attrmap *out_attrs,
		tilemap_t *out_index,
		__attribute__((unused)) const unsigned tilex,
		__attribute__((unused)) const unsigned tiley,
		__attribute__((unused)) const unsigned tileid,
		const tiledata_t *tiledata,
		__attribute__((unused)) const char* filename,
		void *arg) {
	bool *found = (bool *) arg;

	tile_bank_t *out_banks[] = {out_bank0, out_bank1};

	out_attrs->vertical_flip = 0;
	out_attrs->horizontal_flip = 0;

	for (size_t bank_i = 0; bank_i < 2; bank_i++) {
		tile_bank_t *out_bank = out_banks[bank_i];

		for (size_t tile_i = 0; tile_i < 256; tile_i++) {
			struct tile_bank_entry *out_tile = &((*out_bank)[tile_i]);

			if (! out_tile->used) {
				continue;
			}

			if (0 == memcmp(out_tile->data, *tiledata, 16)) {
				out_attrs->bank = bank_i;
				*out_index = tile_i;
				*found = true;
				return;
			}
		}
	}

	out_attrs->bank = 0;
	*out_index = 0;
	*found = false;
}

/**
 * Search for a tile, possibly finding mirrored tiles
 * `arg` is a `bool *`; will out whether a tile was found.
 */
void tile_bank_insert_search_mirrors(
		tile_bank_t *out_bank0,
		tile_bank_t *out_bank1,
		struct attrmap *out_attrs,
		tilemap_t *out_index,
		__attribute__((unused)) const unsigned tilex,
		__attribute__((unused)) const unsigned tiley,
		__attribute__((unused)) const unsigned tileid,
		const tiledata_t *tiledata,
		__attribute__((unused)) const char* filename,
		void *arg) {
	bool *found = (bool *) arg;

	tile_bank_t *out_banks[] = {out_bank0, out_bank1};

	for (size_t bank_i = 0; bank_i < 2; bank_i++) {
		tile_bank_t *out_bank = out_banks[bank_i];

		for (size_t tile_i = 0; tile_i < 256; tile_i++) {
			struct tile_bank_entry *out_tile = &((*out_bank)[tile_i]);

			if (! out_tile->used) {
				continue;
			}

			if (0 == memcmp(out_tile->data, *tiledata, 16)) {
				out_attrs->vertical_flip = 0;
				out_attrs->horizontal_flip = 0;
				out_attrs->bank = bank_i;
				*out_index = tile_i;
				*found = true;
				return;
			}

			bool horizontal_mirror_matches = true;
			for (int j = 0; j < 16; j++) {
				horizontal_mirror_matches &= (out_tile->data[j] == bitreverse((*tiledata)[j]));
			}
			if (horizontal_mirror_matches) {
				out_attrs->vertical_flip = 0;
				out_attrs->horizontal_flip = 1;
				out_attrs->bank = bank_i;
				*out_index = tile_i;
				*found = true;
				return;
			}

			// TODO: vertical mirror duplicates
		}
	}

	out_attrs->vertical_flip = 0;
	out_attrs->horizontal_flip = 0;
	out_attrs->bank = 0;
	*out_index = 0;
	*found = false;
}

void tile_bank_insert_base(
		tile_bank_t *out_bank0,
		tile_bank_t *out_bank1,
		struct attrmap *out_attrs,
		tilemap_t *out_index,
		__attribute__((unused)) const unsigned tilex,
		__attribute__((unused)) const unsigned tiley,
		__attribute__((unused)) const unsigned tileid,
		const tiledata_t *tiledata,
		const char* filename,
		void *arg) {
	struct optional_attrmap *decided_base_attrs = ((struct optional_attrmap *) arg);
	struct optional_attrmap *decided_attrs = &(decided_base_attrs[tileid]);

	tiledata_t tiledata2;
	memcpy(&tiledata2, tiledata, 16);

	tile_bank_t *bank = out_bank0;

	if (decided_attrs->is_set) {
		out_attrs->bank = decided_attrs->value.bank;
		out_attrs->horizontal_flip = decided_attrs->value.horizontal_flip;
		out_attrs->vertical_flip = decided_attrs->value.vertical_flip;

		bank = (decided_attrs->value.bank ? out_bank1 : out_bank0);

		flip_inplace(&tiledata2, decided_attrs->value.horizontal_flip);

		bool found;
		struct attrmap fake_attrs;
		tile_bank_insert_search_exact(
			bank,
			bank,
			&fake_attrs,
			out_index,
			tilex,
			tiley,
			tileid,
			&tiledata2,
			filename,
			&found);

		if (found) {return;}

	} else {
		bool found;
		tile_bank_insert_search_mirrors(
			out_bank0,
			out_bank1,
			out_attrs,
			out_index,
			tilex,
			tiley,
			tileid,
			&tiledata2,
			filename,
			&found);
		if (found) {return;}
	}

	// Assumes that neither bank will run out of space, and so there is no need to check the other
	size_t i = 128;
	while ((*bank)[i & 0xFF].used) {
		i++;

		if (i >= 128 + 256) {
			fprintf(stderr, "%s: too many unique tiles in images\n", filename);
			return;
		}

	}
	(*bank)[i & 0xFF].used = true;
	memcpy((*bank)[i & 0xFF].data, tiledata2, 16);

	*out_index = i & 0xFF;
}

void tile_bank_insert_tiledataset(
		tile_bank_t *out_bank0,
		tile_bank_t *out_bank1,
		struct attrmap *out_attrs,
		tilemap_t *out_index,
		const unsigned tilex,
		const unsigned tiley,
		__attribute__((unused)) const unsigned tileid,
		const tiledata_t *tiledata,
		const char* filename,
		void *arg) {
	struct optional_attrmap* base_attrmap = ((struct optional_attrmap**) arg)[0];
	struct position* position = ((struct position**) arg)[1];
	struct InputfileTiledatasetFrame *frame_instructions = ((struct InputfileTiledatasetFrame**) arg)[2];

	unsigned base_tileid = (tiley + position->y) * 0x20 + (tilex + position->x);

	if (frame_instructions->ignore_tiles_with_palette_set &&
			out_attrs->palette == frame_instructions->ignore_tiles_with_palette) {
		return;
	}

	if (! base_attrmap[base_tileid].is_set) {
		fprintf(stderr, "requires base_attrmap[%02X].is_set\n", base_tileid);
		return;
	}
	struct attrmap* base_attrs = &(base_attrmap[base_tileid].value);

	tiledata_t tiledata2;
	memcpy(&tiledata2, tiledata, 16);

	flip_inplace(&tiledata2, base_attrs->horizontal_flip);

	tile_bank_t *bank = (base_attrs->bank ? out_bank1 : out_bank0);

	bool found = false;
	tile_bank_insert_search_exact(
		bank,
		bank,
		out_attrs,
		out_index,
		tilex,
		tiley,
		tileid,
		&tiledata2,
		filename,
		&found);

	if (found) {
		*out_attrs = *base_attrs;
		return;
	}

	size_t i = 128;
	while ((*bank)[i & 0xFF].used) {
		i++;
		if (i >= 128 + 256) {
			fprintf(stderr, "%s: too many unique tiles in images\n", filename);
			return;
		}
	}
	(*bank)[i & 0xFF].used = true;
	memcpy((*bank)[i & 0xFF].data, tiledata2, 16);

	*out_attrs = *base_attrs;
	*out_index = i & 0xFF;
}

/**
 * @param palette the palettes to choose from
 * @param slice_of_input convert a portion of the image instead of the whole image
 * @param horizontal_flip flip the image horizontally before converting
 * @param check_mirror deduplicate tiles that are mirrors of each other
 * @param filename the name of the png-encoded image to convert
 */
struct tile_image extract_tiles(
		tile_bank_t *out_bank0,
		tile_bank_t *out_bank1,
		const palettes_t palette,
		const struct slice slice_of_input,
		const bool horizontal_flip,
		const char *filename,
		tile_bank_insert_fn *tile_bank_insert_fn,
		void *tile_bank_insert_arg) {

	if (! out_bank0 || ! out_bank1) {
		fputs("assumption violated: out_bank0 and out_bank1 required", stderr);
		exit(1);
	}

	png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (!png_ptr) {
		fputs("could not initialize libpng structs", stderr);
		exit(1);
	}
	png_infop info_ptr = png_create_info_struct(png_ptr);
	if (!info_ptr) {
		fputs("could not initialize libpng structs", stderr);
		exit(1);
	}
	png_infop end_info = png_create_info_struct(png_ptr);
	if (!end_info) {
		fputs("could not initialize libpng structs", stderr);
		exit(1);
	}

	FILE *file = fopen_verbose(filename, "rb");
	if (!file) {
		exit(1);
	}
	png_init_io(png_ptr, file);

	png_read_png(png_ptr, info_ptr,
			PNG_TRANSFORM_STRIP_16 |
			PNG_TRANSFORM_STRIP_ALPHA |
			PNG_TRANSFORM_PACKING |
			PNG_TRANSFORM_EXPAND |
			PNG_TRANSFORM_GRAY_TO_RGB,
			NULL);

	png_uint_32 image_width = png_get_image_width(png_ptr, info_ptr);
	if (image_width < slice_of_input.x) {
		fprintf(stderr, "image %s has slice.x is %u, but image width was only %u\n", filename, slice_of_input.x, image_width);
		exit(1);
	}
	image_width -= slice_of_input.x;

	png_uint_32 image_height = png_get_image_height(png_ptr, info_ptr);
	if (image_height < slice_of_input.y) {
		fprintf(stderr, "image %s has slice.y is %u, but image height was only %u\n", filename, slice_of_input.y, image_height);
		exit(1);
	}
	image_height -= slice_of_input.y;

	png_uint_32 width_in_tiles = image_width / 8;
	png_uint_32 height_in_tiles = image_height / 8;
	if (0 != slice_of_input.width_in_tiles && slice_of_input.width_in_tiles < width_in_tiles) {
		width_in_tiles = slice_of_input.width_in_tiles;
	}
	if (0 != slice_of_input.height_in_tiles && slice_of_input.height_in_tiles < height_in_tiles) {
		height_in_tiles = slice_of_input.height_in_tiles;
	}

	struct tile_image retval = {0};
	retval.width = width_in_tiles;
	retval.height = height_in_tiles;
	retval.attrs = calloc(retval.width * retval.height, sizeof(struct attrmap));
	retval.tiles = calloc(retval.width * retval.height, sizeof(tilemap_t));


	png_byte **row_pointers = png_get_rows(png_ptr, info_ptr);

	bool has_errors = false;

	for (unsigned tiley = 0; tiley < height_in_tiles; tiley++) {
	for (unsigned tilex = 0; tilex < width_in_tiles; tilex++) {
		const unsigned tileid = tiley * width_in_tiles + tilex;

		int palette_index = palette_of_tile(
			palette,
			row_pointers,
			slice_of_input.x + tilex * 8,
			slice_of_input.y + tiley * 8,
			horizontal_flip,
			image_width,
			filename,
			tilex,
			tiley);
		if (palette_index < 0) {
			has_errors = true;
			continue;
		}
		retval.attrs[tileid].palette = palette_index;

		const color555_t *chosen_palette = palette[palette_index];
		tiledata_t tiledata = {0};

		for (unsigned y = 0; y < 8; y++) {
		for (unsigned x = 0; x < 8; x++) {
			size_t pixel_x_in_image = (slice_of_input.x + tilex * 8 + x);
			if (horizontal_flip) {
				pixel_x_in_image = image_width - 1 - pixel_x_in_image;
			}

			png_byte red = row_pointers[slice_of_input.y + tiley * 8 + y][pixel_x_in_image * 3];
			png_byte green = row_pointers[slice_of_input.y + tiley * 8 + y][pixel_x_in_image * 3 + 1];
			png_byte blue = row_pointers[slice_of_input.y + tiley * 8 + y][pixel_x_in_image * 3 + 2];
			color555_t current_color = rgb24_to_rgb16(red, green, blue);
			ssize_t current_color_index = index_of_color(chosen_palette, current_color, 4);

			if (current_color_index < 0) {
				fprintf(stderr, "assumption broken: color not in palette");
				exit(1);
			}

			tiledata[y * 2 + 1] |= (current_color_index & 0x2 ? 1 : 0) << (7 - x);
			tiledata[y * 2] |= (current_color_index & 0x1) << (7 - x);
		}
		}

		tile_bank_insert_fn(
			out_bank0,
			out_bank1,
			&(retval.attrs[tileid]),
			&(retval.tiles[tileid]),
			tilex,
			tiley,
			tileid,
			&tiledata,
			filename,
			tile_bank_insert_arg);
	}
	}

	png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);

	if (has_errors) {
		exit(1);
	}

	return retval;
}


/****** Main ******/

/**
 * Prints any files listed in the instructions in a space-separated format,
 * for use as a dependency list in a Makefile
 */
void list_dependencies(struct Inputfile instructions) {
	if (instructions.palette_filename) {
		fputs(instructions.palette_filename, stdout);
		fputs(" ", stdout);
	}
	if (instructions.base.filename) {
		fputs(instructions.base.filename, stdout);
		fputs(" ", stdout);
	}
	for (size_t i = 0; i < instructions.reserved_count; i++) {
		if (instructions.reserved_values[i].filename) {
			fputs(instructions.reserved_values[i].filename, stdout);
			fputs(" ", stdout);
		}
	}
	for (size_t i = 0; i < instructions.tiledataset_count; i++) {
		struct InputfileTiledataset *i_set = &(instructions.tiledataset_values[i]);

		for (size_t j = 0; j < i_set->frame_count; j++) {
			struct InputfileTiledatasetFrame *j_frame = &(i_set->frame_values[j]);

			if (j_frame->filename) {
				fputs(j_frame->filename, stdout);
				fputs(" ", stdout);
			}
		}
	}
}

int main(int argc, char *argv[]) {
	get_args(argc, argv);
	argc -= optind;
	argv += optind;
	if (Options.help) {
		usage();
		return 0;
	}
	if (argc < 1) {
		usage();
		exit(1);
	}
	char *infilename = argv[0];
	struct Inputfile instructions = parse_inputfile(infilename);

	if (Options.list_dependencies) {
		list_dependencies(instructions);
		exit(0);
	}

	if (! instructions.palette_filename) {
		fprintf(stderr, "colorspec required\n");
		exit(1);
	}

	palettes_t palette;
	parse_psp_palette(&palette, instructions.palette_filename);

	if (Options.output_palette_filename) {
		FILE *file = fopen_verbose(Options.output_palette_filename, "wb");
		if (!file) {
			exit(1);
		}

		for (int i = 0; i < 8; i++) {
			for (int j = 0; j < 4; j++) {
				color555_t v = palette[i][j];
				uint16_t le = htole16(v);
				fwrite(&le, 2, 1, file);
			}
		}

		fclose(file);
	}

	tile_bank_t bank0 = {0};
	tile_bank_t bank1 = {0};
	struct queued_tiledata_list_list queued_tiledata = {0};
	struct optional_attrmap decided_base_attrs[32 * 32] = {0};

	/*
	 * Place reserved tiles first so that reserved tiles are
	 * guarenteed to be placed in their desired spots
	 */
	for (size_t i; i < instructions.reserved_count; i++) {
		struct InputfileReserved *instructions_reserved = &(instructions.reserved_values[i]);

		if (instructions_reserved->filename) {
			struct slice slice = {0};
			struct tile_image img = extract_tiles(
				&bank0,
				&bank1,
				palette,
				slice,
				/* horizontal_flip */ false,
				instructions_reserved->filename,
				&tile_bank_insert_reserved,
				instructions_reserved);

			free(img.attrs);
			free(img.tiles);
		} else {
			// no image, so skip writing image data, but still reserve the tiles
			tile_bank_t *bank = (instructions_reserved->bank ? &bank1 : &bank0);
			unsigned tileid_start = instructions_reserved->base_id;
			unsigned tileid_end = tileid_start + instructions_reserved->length;
			for (unsigned j = tileid_start; j < tileid_end; j++) {
				(*bank)[j].used = true;
			}
		}
	}

	/*
	 * The window uses tiles in the $00-$7F VRAM area,
	 * and thus requires the $8000 addressing mode.
	 * The window is drawn over the bottom two rows of the screen,
	 * and so the bottom two rows of the bg must also use $8000 addressing mode.
	 * Putting these tiles in the first half of the output 2bpp makes them accessible
	 * to either addressing mode.
	 */
	{
		struct slice slice = {
			.x = 0,
			.y = 128,
			.width_in_tiles = 32,
			.height_in_tiles = 2,
		};
		struct tile_image img = extract_tiles(
			&bank0,
			&bank1,
			palette,
			slice,
			/* horizontal_flip */ false,
			instructions.base.filename,
			tile_bank_insert_base,
			&decided_base_attrs);

		free(img.attrs);
		free(img.tiles);
	}

	for (size_t tiledataset_i = 0; tiledataset_i < instructions.tiledataset_count; tiledataset_i++) {
		struct InputfileTiledataset *tiledataset_value = &(instructions.tiledataset_values[tiledataset_i]);

		// Determine best attributes for tiledataset as a whole, since we don't write attributes during animation
		struct tile_image frame_images[tiledataset_value->frame_count];
		bool found;

		for (size_t frame_i = 0; frame_i < tiledataset_value->frame_count; frame_i++) {
			struct InputfileTiledatasetFrame *frame_value = &(tiledataset_value->frame_values[frame_i]);

			frame_images[frame_i] = extract_tiles(
				&bank0,
				&bank1,
				palette,
				frame_value->slice,
				frame_value->horizontal_flip,
				frame_value->filename,
				tile_bank_insert_search_mirrors,
				&found);
		}

		// assumes every frame has the same palette, width, height and ignored tiles
		if (tiledataset_value->frame_count > 0) {
			for (size_t y = 0; y < frame_images[0].height; ++y) {
			for (size_t x = 0; x < frame_images[0].width; ++x) {
				size_t frame_tileid = y * frame_images[0].width + x;
				size_t base_tileid = ((y + tiledataset_value->position.y) * 0x20) +
						(x + tiledataset_value->position.x);

				if (tiledataset_value->frame_values[0].ignore_tiles_with_palette_set &&
						frame_images[0].attrs[frame_tileid].palette == tiledataset_value->frame_values[0].ignore_tiles_with_palette) {
					continue;
				}

				unsigned vertical_flip_count = 0;
				unsigned horizontal_flip_count = 0;

				for (size_t frame_i = 0; frame_i < tiledataset_value->frame_count; frame_i++) {
					vertical_flip_count += (frame_images[frame_i].attrs[frame_tileid].vertical_flip ? 1 : 0);
					horizontal_flip_count += (frame_images[frame_i].attrs[frame_tileid].horizontal_flip ? 1 : 0);
				}

				decided_base_attrs[base_tileid].is_set = true;
				decided_base_attrs[base_tileid].value.vertical_flip = (vertical_flip_count * 2 > tiledataset_value->frame_count);
				decided_base_attrs[base_tileid].value.horizontal_flip = (horizontal_flip_count * 2 > tiledataset_value->frame_count);
				decided_base_attrs[base_tileid].value.bank = 1;
				decided_base_attrs[base_tileid].value.palette = frame_images[0].attrs[frame_tileid].palette;
			}
			}
		}

		for (size_t frame_i = 0; frame_i < tiledataset_value->frame_count; frame_i++) {
			struct InputfileTiledatasetFrame *frame_value = &(tiledataset_value->frame_values[frame_i]);

			void *tile_bank_insert_arg[] = {
				&decided_base_attrs,
				&(tiledataset_value->position),
				frame_value
			};
			struct tile_image img = extract_tiles(
				&bank0,
				&bank1,
				palette,
				frame_value->slice,
				frame_value->horizontal_flip,
				frame_value->filename,
				tile_bank_insert_tiledataset,
				&tile_bank_insert_arg);

			queued_tiledata.data = reallocarray(queued_tiledata.data, queued_tiledata.count + 1, sizeof(struct queued_tiledata_list));
			struct queued_tiledata_list *current_tiledata = &(queued_tiledata.data[queued_tiledata.count]);

			current_tiledata->function[0] = '\0';
			if (tiledataset_value->function) {
				strncpy(current_tiledata->function, tiledataset_value->function, 32);
			}
			current_tiledata->function[32] = '\0';
			snprintf(current_tiledata->label, 64, "%s_%s_%s_%s",
				tiledataset_value->label,
				frame_value->label,
				instructions.platform_label,
				instructions.field_label);
			current_tiledata->function[64] = '\0';
			current_tiledata->generate_header = tiledataset_value->generate_header;
			current_tiledata->total_count = 0;
			current_tiledata->parts_count = 0;
			struct queued_tiledata_item *current_tiledata_item = current_tiledata->parts;

			for (size_t y = 0; y < img.height; y++) {
				current_tiledata_item->count = 0;
				current_tiledata_item->y = tiledataset_value->position.y + y;

				for (size_t x = 0; x < img.width; x++) {
					size_t tileid = y * img.width + x;

					if (frame_value->ignore_tiles_with_palette_set &&
							img.attrs[tileid].palette == frame_value->ignore_tiles_with_palette) {
						if (0 != current_tiledata_item->count) {
							++current_tiledata_item;
							++current_tiledata->parts_count;

							current_tiledata_item->count = 0;
							current_tiledata_item->y = tiledataset_value->position.y + y;
						}

						continue;
					}

					++current_tiledata->total_count;
					if (0 == current_tiledata_item->count) {
						current_tiledata_item->x = tiledataset_value->position.x + x;
					}
					current_tiledata_item->tiles[current_tiledata_item->count] = img.tiles[tileid];
					++current_tiledata_item->count;
				}

				if (0 != current_tiledata_item->count) {
					++current_tiledata_item;
					++current_tiledata->parts_count;
				}
			}

			++queued_tiledata.count;
		}
	}

	struct tile_image base_img;
	{
		struct slice slice = {0};
		base_img = extract_tiles(
			&bank0,
			&bank1,
			palette,
			slice,
			/* horizontal_flip */ false,
			instructions.base.filename,
			tile_bank_insert_base,
			&decided_base_attrs);
	}

	/* Not only does the row below the billboard have reserved tileids,
	 * the graphics at those ids must be the same checkerboard pattern for all six.
	 * Can't build the graphics to have these tileids, so hard-code it.
	 */
	for (int i = 0; i < 6; i++) {
		base_img.tiles[8 * 0x20 + 7 + i] = 0xAE + i;
	}


	if (Options.output_pixeldata0_filename) {
		FILE *file = fopen_verbose(Options.output_pixeldata0_filename, "wb");
		if (!file) {
			exit(1);
		}

		// writing for use in gfx 8800 bank mode,
		for (int i = 128; i < 256; i++) {
			fwrite(bank0[i].data, 1, 16, file);
		}
		for (int i = 0; i < 128; i++) {
			fwrite(bank0[i].data, 1, 16, file);
		}

		fclose(file);
	}

	if (Options.output_pixeldata1_filename) {
		FILE *file = fopen_verbose(Options.output_pixeldata1_filename, "wb");
		if (!file) {
			exit(1);
		}

		// writing for use in gfx 8800 bank mode,
		for (int i = 128; i < 256; i++) {
			fwrite(bank1[i].data, 1, 16, file);
		}
		for (int i = 0; i < 128; i++) {
			fwrite(bank1[i].data, 1, 16, file);
		}

		fclose(file);
	}

	if (Options.output_attrmap_filename) {
		FILE *file = fopen_verbose(Options.output_attrmap_filename, "wb");
		if (!file) {
			exit(1);
		}

		size_t count = base_img.width * base_img.height;
		for (size_t i = 0; i < count; i++) {
			uint8_t v = (
				((base_img.attrs[i].priority & 1) << 7) |
				((base_img.attrs[i].vertical_flip & 1) << 6) |
				((base_img.attrs[i].horizontal_flip & 1) << 5) |
				((base_img.attrs[i].bank & 1) << 3) |
				(base_img.attrs[i].palette & 7));

			fwrite(&v, 1, 1, file);
		}

		fclose(file);
	}

	if (Options.output_tilemap_filename) {
		FILE *file = fopen_verbose(Options.output_tilemap_filename, "wb");
		if (!file) {
			exit(1);
		}
		size_t count = base_img.width * base_img.height;
		fwrite(base_img.tiles, 1, count, file);
		fclose(file);
	}

	if (Options.output_queuedtiledata_filename) {
		FILE *file = fopen_verbose(Options.output_queuedtiledata_filename, "wb");
		if (!file) {
			exit(1);
		}

		for (size_t i = 0; i < queued_tiledata.count; i++) {
			struct queued_tiledata_list *list = &(queued_tiledata.data[i]);
			if (list->generate_header) {
				fprintf(file, "TileDataPointer_%s:\n\tdb $01\n\tdw TileData_%s\n\n", list->label, list->label);
			}
			fprintf(file, "TileData_%s:\n", list->label);
			if ('\0' != list->function[0]) {
				fprintf(file, "\tdw %s\n", list->function);
			}
			fprintf(file, "\tdb $%02X\n\n", list->total_count);
			for (size_t j = 0; j < list->parts_count; j++) {
				struct queued_tiledata_item *elem = &(list->parts[j]);
				uint32_t offset = 0x20 * elem->y + elem->x;

				fprintf(file, "\tdb $%02X\n\tdw vBGMap + $%02X\n\tdb $%02X", elem->count, offset, elem->tiles[0]);
				for (int k = 1; k < elem->count; k++) {
					fprintf(file, ", $%02X", elem->tiles[k]);
				}
				fprintf(file, "\n\n");
			}
			fprintf(file, "\tdb $00\n\n");
		}
		free(queued_tiledata.data);
		queued_tiledata.count = 0;
		queued_tiledata.data = NULL;
	}

	return 0;
}

