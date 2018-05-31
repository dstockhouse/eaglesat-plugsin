/*****************************************************************************
 *
 * File:
 * 	gpio.h
 *
 * Description:
 * 	Header file for gpio.c that contains preprocessor defined constants
 * 	and function declarations.
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 3/3/18
 *
 ****************************************************************************/

#ifndef	GPIO_CUSTOM_H
#define GPIO_CUSTOM_H

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/stat.h>

#define GPIO_OUT	"out"
#define GPIO_IN		"in"

#define GPIO_HIGH	1
#define GPIO_LOW	0

// Redundancies for ease of use
#define GPIO_OUTPUT	GPIO_OUT
#define GPIO_INPUT	GPIO_IN

#define GPIO_ON		GPIO_HIGH
#define GPIO_OFF	GPIO_LOW
#define GPIO_HI		GPIO_HIGH
#define GPIO_LO		GPIO_LOW

// Arbitrary, "large enough" size of a string buffer
#define STR_BUF		128

// File paths for GPIO drivers
#define GPIO_EXPORT	"/sys/class/gpio/export"
#define GPIO_UNEXPORT	"/sys/class/gpio/unexport"
// Must be used along with a *printf() function
#define GPIO_FMT_PIN_BASEDIR	"/sys/class/gpio/gpio%d/"
#define GPIO_FMT_PIN_DIR	"/sys/class/gpio/gpio%d/direction"
#define GPIO_FMT_PIN_VAL	"/sys/class/gpio/gpio%d/value"


/**** Function declarations ****/
int GPIOPinInit(int, char *);
int GPIOPinDeInit(int);
int GPIOPinIsInit(int);

int GPIOPinWrite(int, int);
int GPIOPinRead(int);
int GPIOPinPulse(int);


#endif	// GPIO_CUSTOM_H
