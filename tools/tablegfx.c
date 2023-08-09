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
		"[--output file] "
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

/****** Options ******/

struct Options {
	int help;
	int list_dependencies;
	char *output_attrmap_filename;
	char *output_tilemap_filename;
	char *output_palette_filename;
	char *output_pixeldata_filename;
	char *output_queuedtiledata_filename;
};

struct Options Options = {
};

void get_args(int argc, char *argv[]) {
	struct option long_options[] = {
		{"attr-map", required_argument, 0, 'a'},
		{"tilemap", required_argument, 0, 't'},
		{"palette", required_argument, 0, 'p'},
		{"output", required_argument, 0, 'o'},
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
			Options.output_pixeldata_filename = optarg;
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

struct Inputfile {
	char* palette_filename;
	size_t imagec;
	struct InputfileSource* imagev;
};

struct InputfileSource {
	char *filename;
	bool horizontal_flip;
	bool generate_maps;
	struct {
		unsigned int x;
		unsigned int y;
		unsigned int width_in_tiles;
		unsigned int height_in_tiles;
	} slice;
	struct {
		char *label;
		char *header_label;
		bool ignore_tiles_with_palette_set;
		unsigned int ignore_tiles_with_palette;
		unsigned int position_x;
		unsigned int position_y;
	} tiledata;
};

enum InputfileCurrentTable {
	INPUTFILE_TABLE_SOURCE,
	INPUTFILE_TABLE_SOURCE_TILEDATA,
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
		fprintf(stderr, "%s:%zd: could not parse string value: %s\n", filename, line, input);
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
			fprintf(stderr, "%s:%zd: could not parse integer value: %s\n", filename, line, input);
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
		fprintf(stderr, "%s:%zd: could not parse boolean value: %s\n", filename, line, input);
		exit(1);
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

	struct Inputfile result = {0};
	struct InputfileSource result_current_source = {0};

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

			switch (current_table) {
			case INPUTFILE_TABLE_ROOT:
				if (0 == strcmp("[[source]]\n", bufferv)) {
					current_table = INPUTFILE_TABLE_SOURCE;
				} else {
					fprintf(stderr, "%s:%zd:0: illegal table transition from root to %s\n", filename, line, bufferv);
					exit(1);
				}

				break;
			case INPUTFILE_TABLE_SOURCE:
			case INPUTFILE_TABLE_SOURCE_TILEDATA:
				if (0 == strcmp("[source.tiledata]\n", bufferv)) {
					current_table = INPUTFILE_TABLE_SOURCE_TILEDATA;
				} else if (0 == strcmp("[[source]]\n", bufferv)) {
					current_table = INPUTFILE_TABLE_SOURCE;
					result.imagev = realloc(result.imagev, sizeof(struct InputfileSource) * (result.imagec + 1));
					memcpy(result.imagev + result.imagec, &result_current_source, sizeof(struct InputfileSource));
					memset(&result_current_source, '\0', sizeof(struct InputfileSource));
					result.imagec = result.imagec + 1;
				} else {
					fprintf(stderr, "%s:%zd:0: illegal table transition from [source] to %s\n", filename, line, bufferv);
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

		char* separator = strchr(bufferv, '=');
		if (separator) {
			// key-value pair
			*separator = '\0';
			char* value = strstrip_inplace(separator + 1);
			char* key = strstrip_inplace(bufferv);

			switch (current_table) {
			case INPUTFILE_TABLE_ROOT:
				if (0 == strcmp("palette", key)) {
					result.palette_filename = extract_toml_string_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in root table: %s\n", filename, line, key);
					exit(1);
				}

				break;
			case INPUTFILE_TABLE_SOURCE:
				if (0 == strcmp("filename", key)) {
					result_current_source.filename = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("horizontal_flip", key)) {
					result_current_source.horizontal_flip = extract_toml_bool_value(value, filename, line);
				} else if (0 == strcmp("generate_maps", key)) {
					result_current_source.generate_maps = extract_toml_bool_value(value, filename, line);
				} else if (0 == strcmp("slice.x", key)) {
					result_current_source.slice.x = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("slice.y", key)) {
					result_current_source.slice.y = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("slice.width_in_tiles", key)) {
					result_current_source.slice.width_in_tiles = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("slice.height_in_tiles", key)) {
					result_current_source.slice.height_in_tiles = extract_toml_uint_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in [source] table: %s\n", filename, line, key);
					exit(1);
				}

				break;
			case INPUTFILE_TABLE_SOURCE_TILEDATA:
				if (0 == strcmp("label", key)) {
					result_current_source.tiledata.label = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("header_label", key)) {
					result_current_source.tiledata.header_label = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("ignore_tiles_with_palette", key)) {
					result_current_source.tiledata.ignore_tiles_with_palette_set = true;
					result_current_source.tiledata.ignore_tiles_with_palette = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("position.x", key)) {
					result_current_source.tiledata.position_x = extract_toml_uint_value(value, filename, line);
				} else if (0 == strcmp("position.y", key)) {
					result_current_source.tiledata.position_y = extract_toml_uint_value(value, filename, line);
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

	result.imagev = realloc(result.imagev, sizeof(struct InputfileSource) * (result.imagec + 1));
	memcpy(result.imagev + result.imagec, &result_current_source, sizeof(struct InputfileSource));
	++result.imagec;

	free(bufferv);
	fclose(file);
	return result;
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
struct maps {
	size_t count;
	struct attrmap *attrs;
	tilemap_t *tiles;
};

typedef uint8_t tiledata_t[16];
struct tile_bank_entry {
	bool used;
	tiledata_t data;
};
typedef struct tile_bank_entry tile_bank_t[256];


struct queued_tiledata_item {
	uint8_t x;
	uint8_t y;
	uint8_t tile;
};
struct queued_tiledata_list {
	char *label;
	char *header_label;
	size_t count;
	struct queued_tiledata_item *data;
};
struct queued_tiledata_list_list {
	size_t count;
	struct queued_tiledata_list *data;
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

void extract_tiles(
		tile_bank_t *sink,
		struct maps *written_maps,
		struct queued_tiledata_list_list *written_queued_tiledata,
		const struct InputfileSource *input,
		const palettes_t palette) {
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

	FILE *file = fopen_verbose(input->filename, "rb");
	if (!file) {
		exit(1);
	}
	png_init_io(png_ptr, file);

	png_read_png(png_ptr, info_ptr, PNG_TRANSFORM_STRIP_ALPHA | PNG_TRANSFORM_PACKING, NULL);

	png_uint_32 image_width = png_get_image_width(png_ptr, info_ptr) - input->slice.x;
	png_uint_32 image_height = png_get_image_height(png_ptr, info_ptr) - input->slice.y;

	png_uint_32 width_in_tiles = image_width / 8;
	png_uint_32 height_in_tiles = image_height / 8;

	if (0 != input->slice.width_in_tiles && input->slice.width_in_tiles < width_in_tiles) {
		width_in_tiles = input->slice.width_in_tiles;
	}
	if (0 != input->slice.height_in_tiles && input->slice.height_in_tiles < height_in_tiles) {
		height_in_tiles = input->slice.height_in_tiles;
	}

	png_byte **row_pointers = png_get_rows(png_ptr, info_ptr);

	struct maps maps = {0};
	maps.count = width_in_tiles * height_in_tiles;
	maps.attrs = calloc(sizeof(struct attrmap), maps.count);
	maps.tiles = calloc(sizeof(tilemap_t), maps.count);

	struct queued_tiledata_list queued_tiledata = {0};
	queued_tiledata.count = 0;
	queued_tiledata.data = calloc(maps.count, sizeof(struct queued_tiledata_item));

	bool has_errors = 0;
	color555_t current_tile_color_v[EXTRACT_TILE_MAX_PALETTE];
	size_t current_tile_color_c;

	for (unsigned tiley = 0; tiley < height_in_tiles; tiley++) {
	for (unsigned tilex = 0; tilex < width_in_tiles; tilex++) {
		const unsigned tileid = tiley * width_in_tiles + tilex;
		current_tile_color_c = 0;

		for (unsigned y = 0; y < 8; y++) {
		for (unsigned x = 0; x < 8; x++) {
			size_t pixel_x_in_image = (input->slice.x + tilex * 8 + x);
			if (input->horizontal_flip) {
				pixel_x_in_image = image_width - 1 - pixel_x_in_image;
			}

			png_byte red = row_pointers[input->slice.y + tiley * 8 + y][pixel_x_in_image * 3];
			png_byte green = row_pointers[input->slice.y + tiley * 8 + y][pixel_x_in_image * 3 + 1];
			png_byte blue = row_pointers[input->slice.y + tiley * 8 + y][pixel_x_in_image * 3 + 2];
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
			fprintf(stderr, "%s: tile (%u:%u) has more than four colors", input->filename, tilex, tiley);
			has_errors = true;
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

		maps.attrs[tileid].palette = palette_index;
		if (palette_index >= 8) {
			fprintf(stderr, "%s: tile (%u:%u) colors does not fit in provided palettes\n", input->filename, tilex, tiley);
			has_errors = true;
			continue;
		}

		const color555_t *chosen_palette = palette[palette_index];
		tiledata_t tiledata = {0};

		for (unsigned y = 0; y < 8; y++) {
		for (unsigned x = 0; x < 8; x++) {
			size_t pixel_x_in_image = (input->slice.x + tilex * 8 + x);
			if (input->horizontal_flip) {
				pixel_x_in_image = image_width - 1 - pixel_x_in_image;
			}

			png_byte red = row_pointers[input->slice.y + tiley * 8 + y][pixel_x_in_image * 3];
			png_byte green = row_pointers[input->slice.y + tiley * 8 + y][pixel_x_in_image * 3 + 1];
			png_byte blue = row_pointers[input->slice.y + tiley * 8 + y][pixel_x_in_image * 3 + 2];
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

		queued_tiledata.data[queued_tiledata.count].x = tilex + input->tiledata.position_x;
		queued_tiledata.data[queued_tiledata.count].y = tiley + input->tiledata.position_y;

		// duplicate checking
		for (size_t i = 0; i < 256; i++) {
			if (! (*sink)[i].used) {
				continue;
			}

			if (0 == memcmp((*sink)[i].data, &tiledata, 16)) {
				// the stage bg tiles are placed at tile indexes 0x80 through 0x17F
				// the generated 2bpp is ignorant of this, but the tilemap has to care
				maps.tiles[tileid] = i ^ 0x80;
				if (!input->tiledata.ignore_tiles_with_palette_set ||
						palette_index != input->tiledata.ignore_tiles_with_palette) {
					queued_tiledata.data[queued_tiledata.count].tile = i ^ 0x80;
					queued_tiledata.count++;
				}
				goto next_tile;
			}

			bool horizontal_mirror_matches = true;
			for (int j = 0; j < 16; j++) {
				horizontal_mirror_matches &= (*sink)[i].data[j] == bitreverse(tiledata[j]);
			}
			if (horizontal_mirror_matches) {
				maps.attrs[tileid].horizontal_flip = 1;
				maps.tiles[tileid] = i ^ 0x80;
				if (!input->tiledata.ignore_tiles_with_palette_set ||
						palette_index != input->tiledata.ignore_tiles_with_palette) {
					queued_tiledata.data[queued_tiledata.count].tile = i ^ 0x80;
					queued_tiledata.count++;
				}
				goto next_tile;
			}

			// TODO: vertical mirror duplicates
		}

		size_t i = 0;
		while ((*sink)[i].used) {
			// TODO: overflow checking
			i++;

			if (i >= 256) {
				fprintf(stderr, "%s: too many unique tiles in images\n", input->filename);
				goto next_tile;
			}

		}
		(*sink)[i].used = true;
		memcpy((*sink)[i].data, &tiledata, 16);

		// the stage bg tiles are placed at tile indexes 0x80 through 0x17F
		// the generated 2bpp is ignorant of this, but the tilemap has to care
		maps.tiles[tileid] = i ^ 0x80;
		if (!input->tiledata.ignore_tiles_with_palette_set ||
				palette_index != input->tiledata.ignore_tiles_with_palette) {
			queued_tiledata.data[queued_tiledata.count].tile = i ^ 0x80;
			queued_tiledata.count++;
		}
next_tile:
	}
	}

	png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);

	if (has_errors) {
		exit(1);
	}

	if (input->tiledata.label) {
		size_t index = written_queued_tiledata->count;

		written_queued_tiledata->data = reallocarray(
			written_queued_tiledata->data,
			written_queued_tiledata->count + 1,
			sizeof(struct queued_tiledata_list));
		written_queued_tiledata->count = written_queued_tiledata->count + 1;

		written_queued_tiledata->data[index].label = strdup(input->tiledata.label);
		written_queued_tiledata->data[index].header_label = strdup(input->tiledata.header_label);
		written_queued_tiledata->data[index].count = queued_tiledata.count;
		written_queued_tiledata->data[index].data = queued_tiledata.data;
	} else {
		free(queued_tiledata.data);
	}

	if (input->generate_maps) {
		free(written_maps->attrs);
		free(written_maps->tiles);

		written_maps->count = maps.count;
		written_maps->attrs = maps.attrs;
		written_maps->tiles = maps.tiles;
	} else {
		free(maps.attrs);
		free(maps.tiles);
	}
}


/****** Main ******/

void list_dependencies(struct Inputfile instructions) {
	if (instructions.palette_filename) {
		fputs(instructions.palette_filename, stdout);
		fputs(" ", stdout);
	}
	for (size_t i = 0; i < instructions.imagec; i++) {
		if (instructions.imagev[i].filename) {
			fputs(instructions.imagev[i].filename, stdout);
			fputs(" ", stdout);
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
	struct Inputfile indata = parse_inputfile(infilename);

	if (Options.list_dependencies) {
		list_dependencies(indata);
		exit(0);
	}

	if (! indata.palette_filename) {
		fprintf(stderr, "colorspec required\n");
		exit(1);
	}

	palettes_t palette;
	parse_psp_palette(&palette, indata.palette_filename);

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
	struct queued_tiledata_list_list queued_tiledata = {0};
	struct maps maps = {0};

	for (size_t i = 0; i < indata.imagec; i++) {
		extract_tiles(&bank0, &maps, &queued_tiledata, (indata.imagev) + i, palette);
	}

	if (Options.output_pixeldata_filename) {
		FILE *file = fopen_verbose(Options.output_pixeldata_filename, "wb");
		if (!file) {
			exit(1);
		}

		for (int i = 0; i < 256; i++) {
			fwrite(bank0[i].data, 1, 16, file);
		}

		fclose(file);
	}

	if (Options.output_attrmap_filename) {
		FILE *file = fopen_verbose(Options.output_attrmap_filename, "wb");
		if (!file) {
			exit(1);
		}

		for (size_t i = 0; i < maps.count; i++) {
			uint8_t v = (
				((maps.attrs[i].priority & 1) << 7) |
				((maps.attrs[i].vertical_flip & 1) << 6) |
				((maps.attrs[i].horizontal_flip & 1) << 5) |
				((maps.attrs[i].bank & 1) << 3) |
				(maps.attrs[i].palette & 7));

			fwrite(&v, 1, 1, file);
		}

		fclose(file);
	}

	if (Options.output_tilemap_filename) {
		FILE *file = fopen_verbose(Options.output_tilemap_filename, "wb");
		if (!file) {
			exit(1);
		}
		fwrite(maps.tiles, 1, maps.count, file);
		fclose(file);
	}

	if (Options.output_queuedtiledata_filename) {
		FILE *file = fopen_verbose(Options.output_queuedtiledata_filename, "wb");
		if (!file) {
			exit(1);
		}

		for (size_t i = 0; i < queued_tiledata.count; i++) {
			struct queued_tiledata_list list = queued_tiledata.data[i];
			fprintf(file, "%s:\n\tdb $01\n\tdw %s\n\n", list.header_label, list.label);
			fprintf(file, "%s:\n\tdw LoadTileLists\n\tdb $%02zX\n\n", list.label, list.count);
			for (size_t j = 0; j < list.count; j++) {
				struct queued_tiledata_item elem = list.data[j];
				uint32_t offset = 0x20 * elem.y + elem.x;

				// TODO: combine rows
				fprintf(file, "\tdb $01\n\tdw vBGMap + $%02X\n\tdb $%02X\n\n", offset, elem.tile);
			}
			fprintf(file, "\tdb $00\n\n");

			free(list.label);
			free(list.data);
		}
		free(queued_tiledata.data);
		queued_tiledata.count = 0;
		queued_tiledata.data = NULL;
	}

	return 0;
}

