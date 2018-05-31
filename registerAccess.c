/*****************************************************************************
 *
 * File:
 * 	registerAccess.c
 *
 * Description:
 * 	Contains functions to read from and write to the internal registers
 * 	of the CMV2000 CMOS active pixel sensor using the SPI API found in 
 * 	spiControl.c and the Xillybus interface.
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 3/10/18
 *
 ****************************************************************************/

#include "registerAccess.h"

#include "sensor.h"
#include "spiControl.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


/**** Function registerWrite ****
 * Write the value of the register at /address/ 
 */
int registerWrite(unsigned char address, unsigned char value) {

	int returnVal;
	unsigned char buf[2];

	/*** Load output buffer with proper information ***/

	// First byte is 1 (write) followed by the 7 bit address
	buf[0] = BV(7) | address;

	// Second byte is the value to be written
	buf[1] = value;

	// Write to the SPI port
	returnVal = spiWrite(buf, 2);

	// Return the value returned by SPIWrite
	return returnVal;

} // Function registerWrite()


/**** Function registerRead ****
 * Read the value of the register at /address/ 
 */
int registerRead(unsigned char address, unsigned char *value) {

	int returnVal;
	// unsigned char buf[2];
	unsigned char buf;

	/*** Load output buffer with proper information ***/

	/*
	// First byte is 0 (read) followed by the 7 bit address
	buf[0] = (~BV(7)) & address;

	// Second byte is 0 so that the input buffer can be populated
	buf[1] = 0x00;
	*/
	buf = (~BV(7)) & address;

	// Write to the SPI port
	returnVal = spiWrite(&buf, 1);

	// Check return value, return the error if error
	if(returnVal < 1) {
		return returnVal;
	}

	// Read in the register value
	returnVal = spiRead(&buf, 1);

	// Put response into the return buffer
	// The first value read is just 0, so ignore it
	*value = buf;

	// Return the value returned by SPIWrite
	return returnVal;

} // Function registerRead()


/**** Function setTrainingPattern ****
 * Writes a new value to the training data registers
 */
int setTrainingPattern(int pattern) {

	int returnVal1, returnVal2;

	// Write pattern to the registers
	returnVal1 = registerWrite(TRAINING_PATTERN_L, pattern & 0xff);
	returnVal2 = registerWrite(TRAINING_PATTERN_H, (pattern >> 8) & 0xf);

	// Return both return values
	return returnVal1 | (returnVal2 << 8);

} // Function setTrainingPattern()


/**** Function getTraingPattern ****
 * Reads the pattern currently stored in the devices registers
 */
int getTrainingPattern(int *buf) {

	unsigned char temp;
	int returnVal1, returnVal2;

	// Ensure buffer pointer is non-null
	if(buf == NULL) {
		return 1;
	}

	// Read from the registers
	returnVal1 = registerRead(TRAINING_PATTERN_L, &temp);
	if(!returnVal1) {
		*buf = temp;
	}

	returnVal2 = registerRead(TRAINING_PATTERN_H, &temp);
	if(!returnVal2) {
		*buf |= (temp << 8);
	}

	// Return both return values
	return returnVal1 | (returnVal2 << 8);

} // Function getTrainingPattern()


/**** Function setExpModeExternal ****
 * Sets the exposure of the sensor to external mode
 */
int setExpModeExternal(void) {

	int returnVal;

	// Set exposure mode register to external mode
	returnVal = registerWrite(EXP_EXT, EXP_EXT_EXTERNAL);

	return returnVal;

} // Function set_ExpModeExternal()


/**** Function setOutputMode ****
 * Sets the number of LVDS output channels used by the sensor
 */
int setOutputMode(unsigned char outputMode) {

	int returnVal;

	// Set output mode register to the input value
	returnVal = registerWrite(OUTPUT_MODE, outputMode & 0x03);

	return returnVal;

} // Function setOutputMode()


/**** Functino disableLVDSReceiver ****
 * Disables the LVDS CLK input on the sensor
 */
int disableLVDSReceiver(void) {

	int returnVal;

	// Set LVDS receiver current to 0
	returnVal = registerWrite(I_LVDS_REC, I_LVDS_REC_DISABLE);

	return returnVal;

} // Function disableLVDSReceiver()


/**** Function setInputClock ****
 * Sets the sensor register to expect a CLK_IN frequency to a possible value
 */
int setInputClock(unsigned char freq) {

	int returnValRange, returnValOut, returnValIn;

	switch(freq) {
		case CLK_IN_5MHZ:

			returnValRange = registerWrite(PLL_RANGE, 0x00);
			returnValOut = registerWrite(PLL_OUT_FRE, 0x00);
			returnValIn = registerWrite(PLL_IN_FRE, 0x03);

			break;

		case CLK_IN_7_5MHZ:

			returnValRange = registerWrite(PLL_RANGE, 0x01);
			returnValOut = registerWrite(PLL_OUT_FRE, 0x02);
			returnValIn = registerWrite(PLL_IN_FRE, 0x03);

			break;

		case CLK_IN_10MHZ:

			returnValRange = registerWrite(PLL_RANGE, 0x00);
			returnValOut = registerWrite(PLL_OUT_FRE, 0x02);
			returnValIn = registerWrite(PLL_IN_FRE, 0x01);

			break;

		case CLK_IN_15MHZ:

			returnValRange = registerWrite(PLL_RANGE, 0x01);
			returnValOut = registerWrite(PLL_OUT_FRE, 0x01);
			returnValIn = registerWrite(PLL_IN_FRE, 0x01);

			break;

		case CLK_IN_20MHZ:

			returnValRange = registerWrite(PLL_RANGE, 0x00);
			returnValOut = registerWrite(PLL_OUT_FRE, 0x01);
			returnValIn = registerWrite(PLL_IN_FRE, 0x00);

			break;

		case CLK_IN_30MHZ:

			returnValRange = registerWrite(PLL_RANGE, 0x01);
			returnValOut = registerWrite(PLL_OUT_FRE, 0x05);
			returnValIn = registerWrite(PLL_IN_FRE, 0x00);

			break;

		default:
			// Must not have been a valid frequency
			return 0xff;
	}

	// Retrun all return values
	return returnValRange | (returnValOut << 8) | (returnValIn << 16);

} // Function setInputClock()


/**** Function enableLVDSOutput ****
 * Selects which LVDS data channels to enable. Does not allow accidental
 * disabling of clock or control channel, or enabling of input LVDS clock
 */
int enableLVDSOutput(int channel) {

	int returnVal1, returnVal2;

	returnVal1 = registerWrite(CHANNEL_EN_L, channel & 0xff);
	returnVal2 = registerWrite(CHANNEL_EN_M, (channel >> 8) & 0xff);

} // Function enableLVDSOutput()


