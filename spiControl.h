/*****************************************************************************
 *
 * File:
 * 	spitest.h
 *
 * Description:
 * 	Contains function and structure declarations and preprocessor defined
 * 	constants for use in spitest.c
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 3/24/18
 *
 ****************************************************************************/

#include "gpio.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


/* Eventual definitions for SPI GPIO pins */

/**** Zedboard pinout definitions are in 
 **** xillinux-eval-zedboard/vhdl/src/xillydemo.ucf
 ****/

#define	CS	54+24
#define MOSI	54+25
#define MISO	54+26
#define CLK	54+27


// For the CMV2000, the SPI transaction uses an active high CS
#define CS_ACTIVE	0
#define CS_INACTIVE	1

#define CLK_DELAY	1000

struct SpiPort {
	int cs, mosi, miso, clk;
	int initialized;
};


/**** Function declarations ****/

int spiInit(void);
int spiDeInit(void);
int spiIsNotInit(void);

int spiWrite(unsigned char *, int);
int spiRead(unsigned char *, int);
int spiTransact(unsigned char *, int, unsigned char *, int);



