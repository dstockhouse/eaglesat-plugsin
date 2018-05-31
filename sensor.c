/*****************************************************************************
 *
 * File:
 * 	sensor.c
 *
 * Description:
 * 	Contains functions to read out a frame of the CMV2000 CMOS active 
 * 	pixel sensor through the Xillybus interface to PL. Xillybus is 
 * 	configured to have the following interfaces for capturing image data:
 * 		- xillybus_cmos_rh_32 & xillybus_cmos_rh_32
 * 			
 *
 * Author:
 * 	David Stockhouse & Amber Scarborough
 *
 * Revision 1.2
 * 	Last edited 3/31/18
 *
 ****************************************************************************/

#include "sensor.h"

#include "generateFilename.h"
#include "gpio.h"
#include "registerAccess.h"
#include "spiControl.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


/**** Function frameRead ****
 * Communicate with the sensor to read out one frame and store it in a new
 * image file using generateFilename().
 */
int frameRead(int exposure) {

	char filename[FILENAME_SIZE];
	int bytesInHigh = 0, bytesInLow = 0;
	
	// Buffer for pixel data
	unsigned char pixelBuf[APS_ROWS*APS_COLS];

	// open() file descriptors
	int dataHigh, dataLow, outputFile;


	// Ensure that exposure is a valid number, if not set it to default 
	// to 15 seconds
	if(exposure <= 0) {
		exposure = 15;
	}

	// Begin exposure
	GPIOPinPulse(T_EXP1);

	// Delay for /exposure/
	sleep(exposure);

	// End exposure, request frame
	GPIOPinPulse(FRAME_REQ);

	// Wait frame overhead time
	usleep(20000);



	/*** Start readout ***/


	// Open high order xillybus upstream file
	dataHigh = open(PIXEL_FILE_HIGH, O_RDONLY);

	// Ensure file opened correctly
	if (dataHigh < 0) {

		perror("Failed to open PIXEL_FILE_HIGH");
		return 1;

	} // if dataHigh not opened


	/*** Read until EOF on h/l ***/

	while(bytesInHigh < (APS_COLS * APS_ROWS / 2) - 1) {

		int newBytes;

		// Read high bytes
		newBytes = read(dataHigh, 
				&pixelBuf[APS_ROWS / 2], APS_COLS * APS_ROWS / 2);

		// Ensure read was successful
		if (newBytes < 0) {

			perror("read() failed to read high order file");

			// Close data input stream file
			close(dataHigh);

			return 3;

		} // if read failed

		// Add new amount of bytes read to running count
		bytesInHigh += newBytes;

		// Check if EOF reached before any data
		if (newBytes == 0) {
			printf("Reached read EOF before data for high order pixels.\n");

		} // if read succeeded but read nothing

	} // while bytes left to read


	// Open low order xillybus upstream file
	dataLow = open(PIXEL_FILE_LOW, O_RDONLY);

	// Ensure file opened successfully
	if (dataLow < 0) {

		perror("Failed to open PIXEL_FILE_LOW");
		return 2;

	} // if dataLow not opened

	while(bytesInLow < (APS_COLS * APS_ROWS / 2) - 1) {

		int newBytes;

		// Read low bytes
		newBytes = read(dataLow, &pixelBuf[0], APS_COLS * APS_ROWS / 2);

		// Ensure read was successful
		if (newBytes < 0) {

			perror("read() failed to read low order file");

			// Close data input stream file
			close(dataLow);

			return 4;

		} // if read failed

		// Add new amount of bytes read to running count
		bytesInLow += newBytes;

		// Check if EOF reached before any data
		if (newBytes == 0) {
			printf("Reached read EOF before data for low order pixels.\n");

		} // if read succeeded but read nothing

	} // while bytes left to read


	// Fill rest of pixels with white
	if(bytesInHigh < APS_COLS * APS_ROWS / 2) {

		int i;
		printf(
		"High order input stream reached EOF before expected end of frame.\n");

		// Set rest of half frame to white
		for(i = bytesInHigh; i < APS_COLS * APS_ROWS / 2; i++) {
			pixelBuf[i + (APS_COLS * APS_ROWS / 2)] = 0xff;
		}

	} // if not entire image filled

	if(bytesInLow < APS_COLS * APS_ROWS / 2) {

		int i;
		printf(
		"Low order input stream reached EOF before expected end of frame.\n");

		// Set rest of half frame to white
		for(i = bytesInLow; i < APS_COLS * APS_ROWS / 2; i++) {
			pixelBuf[i] = 0xff;
		}

	} // if not entire image filled




	/*** Write raw data to SD card file ***/

	// Come up with filename
	generateFilename(filename, FILENAME_SIZE, exposure);

	// Attempt to open file
	outputFile = open(filename, O_WRONLY | O_CREAT, 0644);

	// Ensure file was opened properly
	if (outputFile < 0) {

		// File was not opened, print errno

		char buf[128];

		// Format intended filename
		sprintf(buf, "Failed to create '%s'", PIXEL_FILE_HIGH);
		perror(buf);

		return 5;

	} else {

		int returnVal;

		// Write to file
		returnVal = allwrite(outputFile, pixelBuf, APS_ROWS * APS_COLS);

		// Check if allwrite() succeeded
		if(returnVal) {
			printf("Successfully wrote %d bytes to %s.\n", 
				returnVal, filename);
		}

	} // if/else outputFile opened successfully


	/****** Optional for plugs-in ******/

	/* Generate PNG (or other filetype) */
	/* Display image */

	/****** End optional ******/


	// If it made it this far, it must have succeeded at least in part
	return 0;

} // Function frameRead()


/**** Function registerInit ****
 * Initializes the sensor's register to their proper values as instructed by
 * the CMV2000 datasheet section 5.15
 */
int registerInit(void) {

	int returnVal;
	int newReturn = 0;

	// Ensure SPI has been initialized
	returnVal = spiIsNotInit();
	if(returnVal) {
		printf("SPI not initialized: Error %d\n", returnVal);
	}

	// Set chip select low so the following SPI writes can occur
	GPIOPinWrite(CS, CS_ACTIVE);

	returnVal = setExpModeExternal();
	if(returnVal) {
		printf("Failed to set external exposure mode. ");
		printf("Function returned with error %d\n", returnVal);
		newReturn |= 1;
	}

	returnVal = disableLVDSReceiver();
	if(returnVal) {
		printf("Failed to disable LVDS reciever. ");
		printf("Function returned with error %d\n", returnVal);
		newReturn |= 2;
	}

	returnVal = setInputClock(CLK_IN_5MHZ);
	if(returnVal) {
		printf("Failed to disable LVDS reciever. ");
		printf("Function returned with error %d\n", returnVal);
		newReturn |= 4;
	}

	returnVal = setOutputMode(OUTPUT_MODE_2CH);
	if(returnVal) {
		printf("Failed to disable LVDS reciever. ");
		printf("Function returned with error %d\n", returnVal);
		newReturn |= 8;
	}

	// Enable only channels 1 and 9
	returnVal = enableLVDSOutput(CHANNEL_EN_1 & CHANNEL_EN_9);
	if(returnVal) {
		printf("Failed to disable LVDS reciever. ");
		printf("Function returned with error %d\n", returnVal);
		newReturn |= 16;
	}

	// Miscellaneous register adjustments recommended by the datasheet
	// If any of these writes fails it will not be detected
	registerWrite(INTE_SYNC,	4);
	registerWrite(COL_CALIB,	0);
	registerWrite(I_COL,		4);
	registerWrite(I_COL_PRECH,	1);
	registerWrite(I_AMP,		12);
	registerWrite(VTF_I1,		64);
	registerWrite(VRES_LOW,		64);
	registerWrite(V_PRECH,		101);
	registerWrite(V_REF,		106);
	registerWrite(PGA_GAIN,		1);
	registerWrite(DUMMY,		1);
	registerWrite(V_BLACKSUN,	98);

	// Deactivate chip select
	GPIOPinWrite(CS, CS_INACTIVE);

	// Return whatever writes failed
	return newReturn;

} // Function registerInit();


/**** Function sensorInit() ****
 * Wrapper for all of the other initialization functions so that the sensor 
 * interface can be initialized with a single function call
 */
int sensorInit(void) {

	int returnVal;

	// Initialize SPI
	spiInit();
	returnVal = spiIsNotInit();
	if(returnVal) {
		printf("SPI not initialized: Error %d\n", returnVal);
		return 1;
	}

	// Initialize GPIO pins
	returnVal = GPIOPinInit(FRAME_REQ, GPIO_OUT);
	if(returnVal) {
		printf("Couldn't initialize pin %d (FRAME_REQ): Error %d\n",
				FRAME_REQ, returnVal);
		return 2;
	}
	returnVal = GPIOPinInit(T_EXP1, GPIO_OUT);
	if(returnVal) {
		printf("Couldn't initialize pin %d (T_EXP1): Error %d\n",
				T_EXP1, returnVal);
		return 3;
	}
	returnVal = GPIOPinInit(SYS_RES_N, GPIO_OUT);
	if(returnVal) {
		printf("Couldn't initialize pin %d (SYS_RES_N): Error %d\n",
				SYS_RES_N, returnVal);
		return 4;
	}

	// Write GPIO pins to initial values


} // Function sensorInit()


/******* Local functions *******/

/**** Function allwrite() taken from xillydemo example file streamread.c ****
 * Plain write() may not write all bytes requested in the buffer, so
 * allwrite() loops until all data was indeed written, or exits in
 * case of failure, except for EINTR. The way the EINTR condition is
 * handled is the standard way of making sure the process can be suspended
 * with CTRL-Z and then continue running properly.
 * The function doesn't expect to reach EOF.
 */
int allwrite(int fd, unsigned char *buf, int len) {

	int sent = 0;
	int rc;

	while (sent < len) {
		rc = write(fd, buf + sent, len - sent);

		if ((rc < 0) && (errno == EINTR))
			continue;

		if (rc < 0) {
			perror("allwrite() failed to write");
			return sent;
		}

		if (rc == 0) {
			fprintf(stderr, "Reached write EOF (?!)\n");
			return sent;
		}

		sent += rc;

	} // while bytes to send

	// Return 0 on success
	return 0;

} // Function allwrite()


