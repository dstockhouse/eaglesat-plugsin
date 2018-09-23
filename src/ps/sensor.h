/*****************************************************************************
 *
 * File:
 * 	sensor.h
 *
 * Description:
 * 	Header file for sensor.c which contains preprocessor
 * 	definitions and function headers
 *
 * Author:
 * 	David Stockhouse & Amber Scarborough
 *
 * Revision 1.3
 * 	Last edited 6/7/18
 *
 ****************************************************************************/

#ifndef	SENSOR_READOUT_H
#define	SENSOR_READOUT_H

#include "generateFilename.h"
#include "gpio.h"
#include "registerAccess.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>


#define APS_ROWS	1088
#define APS_COLS	2048

// #define PIXEL_FILE_HIGH	"/dev/xillybus_cmos_rh_32"
// #define PIXEL_FILE_LOW	"/dev/xillybus_cmos_rl_32"
<<<<<<< HEAD
#define PIXEL_FILE_HIGH "testdata1"
#define PIXEL_FILE_LOW "testdata2"
=======

#define PIXEL_FILE_HIGH	"/dev/xillybus_read_8"
#define PIXEL_FILE_LOW	"/dev/xillybus_read_32"
>>>>>>> new_ddr

// Pin connections from the Zedboard PS to the CMV2000. Available pins found
// in the xillydemo.ucf file in the src directory of the vivado xillybus code.
// Path to that file in spiControl.h

// JB1
#define T_EXP1		(32+54)
// JB3
#define FRAME_REQ	(34+54)
// JB8
#define SYS_RES_N	(37+54)


/**** Function Declarations ****/
int frameRead(int);
int registerInit(void);

int allwrite(int, unsigned char *, int);


#endif // SENSOR_READOUT_H
