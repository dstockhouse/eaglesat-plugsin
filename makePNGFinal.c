#include <stdio.h>
#include <malloc.h>
#include <png.h>


void setRGB(png_byte* ptr, float val);
float *createImage(int width, int height, int bitsreamArray[]);
int writeImage(char* filename, int width, int height, float *buffer, char* title);


int main(int argc, char *argv[])
{
	int width = 2048;
	int height = 1088;
	int bitstream[2228224];

	printf("Creating Image\n");
	float *buffer = createImage(width, height, bitstream);
	if (buffer == NULL) {
		return 1;
	}

	printf("Saving PNG\n");
	int result = writeImage(argv[1], width, height, buffer, "This is my test image");

	free(buffer);
	return result;
}

void setRGB(png_byte *ptr, float val)
{
	int v = (int)(val);
	if (v==1) {
		ptr[0] = 255;
	}
	else if (v==0) {
		ptr[0] = 0;
	}
}

int writeImage(char* filename, int width, int height, float *buffer, char* title)
{
	int code = 0;
	FILE *fp = NULL;
	png_structp png_ptr = NULL;
	png_infop info_ptr = NULL;
	png_bytep row = NULL;

	// Open file for writing (binary mode)
	fp = fopen(filename, "w");
	if (fp == NULL) {
		fprintf(stderr, "Could not open file %s for writing\n", filename);
		code = 1;
		goto finalise;
	}

	// Initialize write structure
	png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (png_ptr == NULL) {
		fprintf(stderr, "Could not allocate write struct\n");
		code = 1;
		goto finalise;
	}

	// Initialize info structure
	info_ptr = png_create_info_struct(png_ptr);
	if (info_ptr == NULL) {
		fprintf(stderr, "Could not allocate info struct\n");
		code = 1;
		goto finalise;
	}

	// Setup Exception handling
	if (setjmp(png_jmpbuf(png_ptr))) {
		fprintf(stderr, "Error during png creation\n");
		code = 1;
		goto finalise;
	}

	png_init_io(png_ptr, fp);

	// Write header (1 bit colour depth)
	png_set_IHDR(png_ptr, info_ptr, width, height,
			1, PNG_COLOR_TYPE_GRAY, PNG_INTERLACE_NONE,
			PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);

	// Set title
	if (title != NULL) {
		png_text title_text;
		title_text.compression = PNG_TEXT_COMPRESSION_NONE;
		title_text.key = "Title";
		title_text.text = title;
		png_set_text(png_ptr, info_ptr, &title_text, 1);
	}

	png_write_info(png_ptr, info_ptr);

	// Allocate memory for one row (1 bytes per pixel - RGB)
	row = (png_bytep) malloc(width * sizeof(png_byte));

	// Write image data
	int x, y;
	for (y=0 ; y<height ; y++) {
		for (x=0 ; x<width ; x++) {
			setRGB(&(row[x]), buffer[y*width + x]);
		}
		png_write_row(png_ptr, row);
	}

	// End write
	png_write_end(png_ptr, NULL);

finalise:
	if (fp != NULL) fclose(fp);
	if (info_ptr != NULL) png_free_data(png_ptr, info_ptr, PNG_FREE_ALL, -1);
	if (png_ptr != NULL) png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
	if (row != NULL) free(row);

	return code;
}

float *createImage(int width, int height, int bitstreamArray[])
{
	int arrayCount=0;
	float* buffer = (float *) malloc(width*height*sizeof(float));
	if (buffer == NULL)
	{
		fprintf(stderr, "Could not create image buffer\n");
		return NULL;
	}
	int xPos, yPos;

	for (yPos=0; yPos<height; yPos++)
	{
		for (xPos=0; xPos<width; xPos++)
		{
			if (bitstreamArray[arrayCount]==1)
				buffer[yPos*width+xPos]=1;
			else if (bitstreamArray[arrayCount]==0)
				buffer[yPos*width+xPos]=0;
		}
	}
}
