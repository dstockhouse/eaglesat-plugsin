/*****************************************************************************
 *
 * File:
 * 	spiControl.h
 *
 * Description:
 * 	Contains function declarations and preprocessor defined constants for 
 * 	use in spiControl.c.
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.1
 * 	Last edited 6/7/18
 *
 ****************************************************************************/

#include "gpio.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>


/****
 **** Zedboard pinout definitions can be found on Zynq filesystem in 
 **** xillinux-eval-zedboard/vhdl/src/xillydemo.ucf
 ****/


// SPI pins for testing purposes, not permanent
#define	CS	54+24
#define MOSI	54+25
#define MISO	54+26
#define CLK	54+27

// For the CMV2000, the SPI transaction uses an active high CS
#define CS_ACTIVE	0
#define CS_INACTIVE	1


/**** Function declarations ****/

int spiInit(void);
int spiDeInit(void);
int spiIsNotInit(void);

int spiWrite(unsigned char *, int);
int spiRead(unsigned char *, int);
int spiTransact(unsigned char *, int, unsigned char *, int);

