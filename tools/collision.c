/*
 * Creates the masks and maps for a table's collision
 *
 * gbagfx is insufficient in this instance because
 * gbagfx can neither force certain tiles to a particular location
 * nor output which index certain tiles have been placed.
 * At least one of the two is for collision checks which ask which type of tile is being collided with
 *
 * Being able to share the masks for two similar collision datas is not neccessary, but is nice to have,
 * As is being able to have two similar collision datas sourced from one image
 * when the collision datas only differ in e.g. the launch lane is nice to have.
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

#define append_to_list(list, value, typ) \
	(list)->values = reallocarray((list)->values, (list)->count + 1, sizeof(typ)); \
	memcpy((list)->values + (list)->count, (value), sizeof(typ)); \
	(list)->count = (list)->count + 1;

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) > (b) ? (b) : (a))


static void usage(void) {
	fprintf(stderr, "Usage: tablegfx "
		"[--tilemap file] "
		"[--object-data file] "
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
	char *output_tilemap_filename;
	char *output_pixeldata_filename;
	char *output_objectdata_filename;
};

struct Options Options = {
};

void get_args(int argc, char *argv[]) {
	struct option long_options[] = {
		{"tilemap", required_argument, 0, 't'},
		{"output", required_argument, 0, 'o'},
		{"object-data", required_argument, 0, 'q'},
		{"list-dependencies", no_argument, &Options.list_dependencies, 1},
		{"help", no_argument, 0, 'h'},
		{0}
	};
	for (int opt = 0; opt != -1;) {
		switch (opt = getopt_long(argc, argv, "h", long_options)) {
		case 'h':
			Options.help = true;
			break;
		case 't':
			Options.output_tilemap_filename = optarg;
			break;
		case 'o':
			Options.output_pixeldata_filename = optarg;
			break;
		case 'q':
			Options.output_objectdata_filename = optarg;
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

struct ColorList {
	size_t count;
	uint32_t *values;
};

struct InputfileVariant {
	struct ColorList colors;
};

struct InputfileObject {
	char* label;
	struct ColorList colors;
};

struct Inputfile {
	struct {
		size_t count;
		struct InputfileVariant *values;
	} variants;

	struct {
		size_t count;
		struct InputfileObject *values;
	} objects;
};

enum InputfileCurrentTable {
	INPUTFILE_TABLE_VARIANT,
	INPUTFILE_TABLE_OBJECT,
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
	// strtol does not fail if the input contains data other than the number

	if ('0' == input[0] && 'x' == input[1]) {
		input += 2;
		while ('\0' != input[0]) {
			if ('0' <= input[0] && input[0] <= '9') {
				retval *= 16;
				retval += input[0] - '0';
			} else if ('a' <= input[0] && input[0] <= 'f') {
				retval *= 16;
				retval += input[0] - 'a' + 10;
			} else if ('A' <= input[0] && input[0] <= 'F') {
				retval *= 16;
				retval += input[0] - 'A' + 10;
			} else if ('_' == input[0] && '_' != input[1]) {
				// do nothing
			} else {
				fprintf(stderr, "%s:%zd:0: could not parse integer value: %s\n", filename, line, input);
				exit(1);
			}

			++input;
		}

	} else {
		if ('+' == input[0]) {
			++input;
		}
		while ('\0' != input[0]) {
			if ('0' <= input[0] && input[0] <= '9') {
				retval *= 10;
				retval += input[0] - '0';
			} else if ('_' == input[0] && '_' != input[1]) {
				// do nothing
			} else {
				fprintf(stderr, "%s:%zd:0: could not parse integer value: %s\n", filename, line, input);
				exit(1);
			}

			++input;
		}
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

struct ColorList extract_toml_uint_list_value(char* input, const char* filename, size_t line) {
	struct ColorList retval = {0};
	retval.values = calloc(8, sizeof(unsigned int));

	if ('[' == input[0] && ']' == input[strlen(input) - 1]) {
		++input;
		input[strlen(input) - 1] = '\0';

		char *next_separator = strchr(input, ',');
		while (next_separator) {
			*next_separator = '\0';
			input = strstrip_inplace(input);

			unsigned int x = extract_toml_uint_value(input, filename, line);
			retval.values = reallocarray(retval.values, retval.count + 1, sizeof(unsigned int));
			retval.values[retval.count] = x;
			retval.count += 1;

			input = next_separator + 1;
			next_separator = strchr(input, ',');
		}

		input = strstrip_inplace(input);

		unsigned int x = extract_toml_uint_value(input, filename, line);
		retval.values = reallocarray(retval.values, retval.count + 1, sizeof(unsigned int));
		retval.values[retval.count] = x;
		retval.count += 1;
	} else {
		fprintf(stderr, "%s:%zd:0: could not parse array of int value: %s\n", filename, line, input);
		exit(1);
	}

	return retval;
}

void close_variant_if_open(
		struct Inputfile *inputfile,
		bool *dataset_is_open,
		struct InputfileVariant *dataset) {
	if (*dataset_is_open) {
		append_to_list(&(inputfile->variants), dataset, struct InputfileVariant);

		*dataset_is_open = false;
		memset(dataset, 0, sizeof(struct InputfileVariant));
	}
}

void close_object_if_open(
		struct Inputfile *inputfile,
		bool *dataset_is_open,
		struct InputfileObject *dataset) {
	if (*dataset_is_open) {
		append_to_list(&(inputfile->objects), dataset, struct InputfileObject);

		*dataset_is_open = false;
		memset(dataset, 0, sizeof(struct InputfileObject));
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

	bool variant_open = false;
	struct InputfileVariant retval_variant = {0};
	bool object_open = false;
	struct InputfileObject retval_object = {0};

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
			if (0 == strcmp("[[variant]]\n", bufferv)) {
				transition_to = INPUTFILE_TABLE_VARIANT;
			} else if (0 == strcmp("[[object]]\n", bufferv)) {
				transition_to = INPUTFILE_TABLE_OBJECT;
			} else {
				fprintf(stderr, "%s:%zd:0: unknown table: %s\n", filename, line, bufferv);
				exit(1);
			}

			close_variant_if_open(
				&retval,
				&variant_open,
				&retval_variant
			);

			close_object_if_open(
				&retval,
				&object_open,
				&retval_object
			);

			switch (transition_to) {
			case INPUTFILE_TABLE_ROOT:
				break;
			case INPUTFILE_TABLE_VARIANT:
				variant_open = true;
				break;
			case INPUTFILE_TABLE_OBJECT:
				object_open = true;
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
				{
					fprintf(stderr, "%s:%zd:0: unknown key in root table: %s\n", filename, line, key);
					exit(1);
				}
				break;

			case INPUTFILE_TABLE_VARIANT:
				if (0 == strcmp("solid", key)) {
					retval_variant.colors = extract_toml_uint_list_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in root table: %s\n", filename, line, key);
					exit(1);
				}
				break;

			case INPUTFILE_TABLE_OBJECT:
				if (0 == strcmp("label", key)) {
					retval_object.label = extract_toml_string_value(value, filename, line);
				} else if (0 == strcmp("color", key)) {
					retval_object.colors = extract_toml_uint_list_value(value, filename, line);
				} else {
					fprintf(stderr, "%s:%zd:0: unknown key in [source] table: %s\n", filename, line, key);
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

	close_variant_if_open(
		&retval,
		&variant_open,
		&retval_variant
	);

	close_object_if_open(
		&retval,
		&object_open,
		&retval_object
	);

	free(bufferv);
	fclose(file);
	return retval;
}

/****** Tiles ******/

typedef uint8_t tilemap_entry;
typedef tilemap_entry tilemap[32 * 32];


typedef uint8_t tiledata_t[8];
struct tile_bank_entry {
	bool used;
	tiledata_t data;
};
typedef struct tile_bank_entry tile_bank_t[256];


struct tilemap_entry_bitset {
	uint32_t data[8];
};


tilemap_entry insert_tile_into_bank(
		tile_bank_t *out_bank,
		const tiledata_t *tile,
		const char *filename) {

	for (unsigned i = 0; i < 256; i++) {
		if (! (*out_bank)[i].used) {
			continue;
		}

		if (0 == memcmp((*out_bank)[i].data, tile, sizeof(tiledata_t))) {
			return (tilemap_entry) i;
		}
	}

	for (unsigned i = 0; i < 256; i++) {
		if ((*out_bank)[i].used) {
			continue;
		}

		(*out_bank)[i].used = true;
		memcpy((*out_bank)[i].data, tile, sizeof(tiledata_t));
		return (tilemap_entry) i;
	}

	fprintf(stderr, "%s: too many unique tiles for one tile bank\n", filename);
	return 0;
}


void process_tile(
		tile_bank_t *out_bank,
		tilemap **out_tilemaps,
		struct tilemap_entry_bitset **out_object_data,
		png_byte **image_data,
		const size_t tileid,
		struct Inputfile instructions,
		const char *filename) {

	for (size_t variants_i = 0; variants_i < instructions.variants.count; variants_i++) {
		struct InputfileVariant *variant = &(instructions.variants.values[variants_i]);

		tiledata_t tile = {0};
		bool in_objects[instructions.objects.count];
		memset(in_objects, 0, sizeof(bool) * instructions.objects.count);

		for (int y = 0; y < 8; y++) {
		for (int x = 0; x < 8; x++) {
			png_byte red = image_data[y][(x * 3) + 0];
			png_byte green = image_data[y][(x * 3) + 1];
			png_byte blue = image_data[y][(x * 3) + 2];
			uint32_t color = ((red << 16) & 0xFF0000) | ((green << 8) & 0xFF00) | (blue & 0xFF);

			bool is_solid = false;

			for (size_t i = 0; i < variant->colors.count; i++) {
				if (color == variant->colors.values[i]) {
					is_solid = true;
					break;
				}
			}

			if (is_solid) {
				tile[y] |= 1 << (7 - x);

				for (size_t object_i = 0; object_i < instructions.objects.count; object_i++) {
					struct InputfileObject *object = &(instructions.objects.values[object_i]);
					for (size_t i = 0; i < object->colors.count; i++) {
						if (color == object->colors.values[i]) {
							in_objects[object_i] = true;
						}
					}
				}
			}
		}
		}

		tilemap_entry entry = insert_tile_into_bank(
			out_bank,
			&tile,
			filename);

		(*out_tilemaps)[variants_i][tileid] = entry;

		for (size_t object_i = 0; object_i < instructions.objects.count; object_i++) {
			if (in_objects[object_i]) {
				((*out_object_data)[object_i]).data[entry / 32] |= 1 << (entry % 32);
			}
		}
	}

}


void process_image(
		tile_bank_t *out_bank,
		tilemap **out_tilemaps,
		struct tilemap_entry_bitset **out_object_data,
		struct Inputfile instructions,
		const char *filename) {

	if (! out_bank) {
		fputs("assumption violated: out_bank0 required", stderr);
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
	png_uint_32 image_height = png_get_image_height(png_ptr, info_ptr);
	png_uint_32 width_in_tiles = image_width / 8;
	png_uint_32 height_in_tiles = image_height / 8;


	png_byte **row_pointers = png_get_rows(png_ptr, info_ptr);

	bool has_errors = false;

	for (unsigned tiley = 0; tiley < height_in_tiles; tiley++) {
	for (unsigned tilex = 0; tilex < width_in_tiles; tilex++) {
		const unsigned tileid = tiley * width_in_tiles + tilex;

		png_byte *tile_data[8];
		for (size_t i = 0; i < 8; i++) {
			tile_data[i] = row_pointers[tiley * 8 + i] + (tilex * 8 * 3);
		}

		process_tile(
			out_bank,
			out_tilemaps,
			out_object_data,
			tile_data,
			tileid,
			instructions,
			filename);
	}
	}

	png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
	fclose(file);

	if (has_errors) {
		exit(1);
	}
}


/****** Main ******/

int main(int argc, char *argv[]) {
	get_args(argc, argv);
	argc -= optind;
	argv += optind;
	if (Options.help) {
		usage();
		return 0;
	}
	if (argc < 2) {
		usage();
		exit(1);
	}
	char *image_filename = argv[1];
	char *instructions_filename = argv[0];
	struct Inputfile instructions = parse_inputfile(instructions_filename);

	tile_bank_t bank0 = {0};
	tilemap tilemaps[instructions.variants.count];
	memset(tilemaps, 0, sizeof(tilemap) * instructions.variants.count);
	struct tilemap_entry_bitset object_datas[instructions.objects.count];
	memset(object_datas, 0, sizeof(struct tilemap_entry_bitset) * instructions.objects.count);

	bank0[0].used = true;
	memset(bank0[0].data, 0x00, sizeof(tiledata_t));


	tilemap *tilemaps_but_with_the_pointer_conversion_applied = tilemaps;
	struct tilemap_entry_bitset *object_datas_but_with_the_pointer_conversion_applied = object_datas;


	process_image(
			&bank0,
			&tilemaps_but_with_the_pointer_conversion_applied,
			&object_datas_but_with_the_pointer_conversion_applied,
			instructions,
			image_filename);


	if (Options.output_pixeldata_filename) {
		FILE *file = fopen_verbose(Options.output_pixeldata_filename, "wb");
		if (!file) {
			exit(1);
		}

		for (int i = 0; i < 256; i++) {
			fwrite(bank0[i].data, 1, 8, file);
		}

		fclose(file);
	}

	if (Options.output_tilemap_filename) {
		char *position_of_argument = strstr(Options.output_tilemap_filename, "%d");
		if (position_of_argument) {
			for (size_t i = 0; i < instructions.variants.count; i++) {
				char filename[128];
				size_t prefix_len = MIN(128, position_of_argument - Options.output_tilemap_filename);
				memcpy(filename, Options.output_tilemap_filename, prefix_len);
				snprintf(filename + prefix_len, 128 - prefix_len, "%zd%s", i, position_of_argument + 2);
				filename[127] = '\0';

				FILE *file = fopen_verbose(filename, "wb");
				if (!file) {
					exit(1);
				}
				fwrite(tilemaps[i], 1, 32 * 32, file);
				fclose(file);
			}
		} else {
			FILE *file = fopen_verbose(Options.output_tilemap_filename, "wb");
			if (!file) {
				exit(1);
			}

			fwrite(tilemaps[0], 1, 32 * 32, file);
			fclose(file);
		}
	}

	if (Options.output_objectdata_filename) {
		FILE *file = fopen_verbose(Options.output_objectdata_filename, "wb");
		if (!file) {
			exit(1);
		}

		for (size_t i = 0; i < instructions.objects.count; i++) {
			struct InputfileObject object_instructions = instructions.objects.values[i];
			struct tilemap_entry_bitset object_data = object_datas[i];

			fprintf(file, "%s:\n", object_instructions.label);
			fprintf(file, "\tdb $00 ; flat list");
			unsigned values_printed = 0;
			for (unsigned i = 0; i < 256; i++) {
				if ((object_data.data[i / 32]) & (1 << (i % 32))) {
					if (values_printed % 8 == 0) {
						fprintf(file, "\n\tdb");
					} else {
						fprintf(file, ",");
					}
					values_printed = values_printed + 1;
					fprintf(file, " $%02X", i);
				}
			}
			fprintf(file, "\n");
			fprintf(file, "\tdb $FF ; terminator\n\n");
		}
	}

	for (size_t i = 0; i < instructions.objects.count; i++) {
		free(instructions.objects.values[i].label);
		free(instructions.objects.values[i].colors.values);
	}
	free(instructions.objects.values);
	for (size_t i = 0; i < instructions.variants.count; i++) {
		free(instructions.variants.values[i].colors.values);
	}
	free(instructions.variants.values);

	return 0;
}
