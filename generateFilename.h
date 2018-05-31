/*****************************************************************************
 *
 * File:
 * 	generateFilename.h
 *
 * Description:
 * 	Header file for generateFilename.c which contains preprocessor
 * 	definitions and function headers
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 3/3/18
 *
 ****************************************************************************/

#ifndef GENERATE_FILENAME_H
#define GENERATE_FILENAME_H

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define	FILENAME_SIZE	64

int generateFilename(char *, int, int);

#endif // GENERATE_FILENAME_H

