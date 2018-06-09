/*****************************************************************************
 *
 * File:
 * 	registerAccess.h
 *
 * Description:
 * 	Header file for registerAccess.c that contains preprocessor defined
 * 	constants and function declarations.
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 3/10/18
 *
 ****************************************************************************/

#ifndef	REGISTER_ACCESS_H
#define	REGISTER_ACCESS_H

#include "sensor.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>


/**** Register names from CMV2000 datasheet rev3.8 ****/
#define	START1L		3
#define	START1H		4
#define	START2L		5
#define	START2H		6
#define	START3L		7
#define	START3H		8
#define	START4L		9
#define	START4H		10
#define	START5L		11
#define	START5H		12
#define	START6L		13
#define	START6H		14
#define	START7L		15
#define	START7H		16
#define	START8L		17
#define	START8H		18

#define	NUMBER_LINES_L	1
#define	NUMBER_LINES_H	2

#define	MONO		39
#define IMAGE_FLIPPING	40
#define NR_SLOPES	54

#define INTE_SYNC	41
#define EXP_DUAL	41
#define EXP_EXT		41

#define	EXP_TIMEL	42
#define	EXP_TIMEM	43
#define	EXP_TIMEH	44

#define	EXP_TIME2L	56
#define	EXP_TIME2M	57
#define	EXP_TIME2H	58

#define	EXP_STEPL	45
#define	EXP_STEPM	46
#define	EXP_STEPH	47

#define	EXP_STEP2L	59
#define	EXP_STEP2M	60
#define	EXP_STEP2H	61

#define	EXP_KP1L	48
#define	EXP_KP1M	49
#define	EXP_KP1H	50

#define	EXP_KP2L	51
#define	EXP_KP2M	52
#define	EXP_KP2H	53

#define	EXP_SEQ		55
#define	EXP2_SEQ	69

#define	NUMBER_FRAMES_L	70
#define	NUMBER_FRAMES_H	71

#define OUTPUT_MODE	72
#define FOT_LENGTH	73
#define I_LVDS_REC	74
#define COL_CALIB	77
#define ADC_CALIB	77

#define TRAINING_PATTERN_L	78
#define TRAINING_PATTERN_H	79

#define CHANNEL_EN_L	80
#define CHANNEL_EN_M	81
#define CHANNEL_EN_H	82

#define I_LVDS		83
#define I_COL		84
#define I_COL_PRECH	85
#define I_AMP		87

#define VTF_I1		88
#define VLOW2		89
#define VLOW3		90
#define VRES_LOW	91
#define V_PRECH		94
#define V_REF		95
#define VRAMP1		98
#define VRAMP2		99

#define OFFSET_L	100
#define OFFSET_H	101

#define T_DIG1		108
#define T_DIG2		109

#define BIT_MODE	111
#define ADC_RESOLUTION	112

#define PLL_ENABLE	113
#define PLL_IN_FRE	114
#define PLL_BYPASS	115
#define PLL_RANGE	116
#define PLL_DIV		116
#define PLL_OUT_FRE	116
#define PLL_LOAD	117

#define DUMMY		118

#define PGA_GAIN	102
#define ADC_GAIN	103
#define BLACK_COL_EN	121

#define V_BLACKSUN	123

#define TEMP_L		126
#define TEMP_H		127

#define SENSOR_TYPE	125


// Constants related to register values
#define	EXP_EXT_EXTERNAL	0x01
#define	EXP_EXT_INTERNAL	0x00

#define OUTPUT_MODE_2CH		0x03
#define OUTPUT_MODE_4CH		0x02
#define OUTPUT_MODE_8CH		0x01
#define OUTPUT_MODE_16CH	0x00

#define I_LVDS_REC_DISABLE	0x00

#define CHANNEL_EN_1		0x00
#define CHANNEL_EN_2		0x01
#define CHANNEL_EN_3		0x02
#define CHANNEL_EN_4		0x03
#define CHANNEL_EN_5		0x04
#define CHANNEL_EN_6		0x05
#define CHANNEL_EN_7		0x06
#define CHANNEL_EN_8		0x07
#define CHANNEL_EN_9		0x08
#define CHANNEL_EN_10		0x09
#define CHANNEL_EN_11		0x0a
#define CHANNEL_EN_12		0x0b
#define CHANNEL_EN_13		0x0c
#define CHANNEL_EN_14		0x0d
#define CHANNEL_EN_15		0x0e
#define CHANNEL_EN_16		0x0f


// Input clock options
#define CLK_IN_5MHZ		0x00
#define CLK_IN_7_5MHZ		0x01
#define CLK_IN_10MHZ		0x02
#define CLK_IN_15MHZ		0x03
#define CLK_IN_20MHZ		0x04
#define CLK_IN_30MHZ		0x05
#define CLK_IN_45MHZ		CLK_IN_30MHz


// Bit value offset
#define BV(I)	(1<<I)


/**** Function declarations ****/
int registerWrite(unsigned char, unsigned char);
int registerRead(unsigned char, unsigned char *);

int setTrainingPattern(int);
int getTrainingPattern(int *);

int setExpModeExternal(void);
int setOutputMode(unsigned char);
int disableLVDSReceiver(void);
int setInputClock(unsigned char);
int enableLVDSOutput(int);


#endif	// REGISTER_ACCESS_H

