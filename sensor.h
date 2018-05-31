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
 * Revision 1.0
 * 	Last edited 3/3/18
 *
 ****************************************************************************/

#ifndef	SENSOR_READOUT_H
#define	SENSOR_READOUT_H

#include "generateFilename.h"
#include "gpio.h"
#include "registerAccess.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define APS_ROWS	1088
#define APS_COLS	2048

#define PIXEL_FILE_HIGH	"/dev/xillybus_cmos_rh_32"
#define PIXEL_FILE_LOW	"/dev/xillybus_cmos_rl_32"

// Pin connections from the Zedboard PS to the CMV2000. Available pins found
// in the xillydemo.ucf file in the src directory of the vivado xillybus code

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
