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
 * Author:
 * 	David Stockhouse & Amber Scarborough
 *
 * Revision 1.3
 * 	Last edited 6/7/18
 *
 ****************************************************************************/

#include "sensor.h"

#include "generateFilename.h"
#include "gpio.h"
#include "registerAccess.h"
#include "spiControl.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>


/**** Function frameRead ****
 * Communicate with the sensor to read out one frame and store it in a new
 * image file using generateFilename(). Input is the exposure time in
 * seconds.
 */
int frameRead(int exposure) {

	char capture_filename[FILENAME_SIZE];
	int bytesInHigh = 0, bytesInLow = 0;
	int readContinue;

	// Buffer for pixel data
	unsigned char pixelBuf[APS_ROWS*APS_COLS];

	// open() file descriptors
	int dataHigh, dataLow, outputFile;

	// Initialize all GPIO ports to be used
	printf("%s:%d: Initializing GPIO pins.\n", __FILE__, __LINE__);
	GPIOPinInit(T_EXP1, GPIO_OUT);
	GPIOPinInit(FRAME_REQ, GPIO_OUT);

	// Ensure that exposure is a valid number, if not set it to default 
	// to 15 seconds
	if(exposure <= 0) {
		exposure = 15;
	}

	// Come up with name for the capture
	printf("%s:%d: Generating capture filename\n", __FILE__, __LINE__);
	generateFilename(capture_filename, FILENAME_SIZE, exposure);
	printf("\tCapture file is '%s'\n", capture_filename);

	// Begin exposure
	printf("%s:%d: Pulsing T_EXP1\n", __FILE__, __LINE__);
	GPIOPinPulse(T_EXP1);

	// Delay for exposure time
	printf("%s:%d: Sleep...\n", __FILE__, __LINE__);
	sleep(exposure);

	// End exposure, request frame
	printf("%s:%d: Pulsing FRAME_REQ\n", __FILE__, __LINE__);
	GPIOPinPulse(FRAME_REQ);

	// Wait maximum frame overhead time, 20ms, readout will start automatically
	usleep(20000);


	/*** Start readout ***/

	// Open high order xillybus upstream file
	printf("%s:%d: Opening pixel file high\n", __FILE__, __LINE__);
	dataHigh = open(PIXEL_FILE_HIGH, O_RDONLY);

	// Ensure file opened correctly
	if (dataHigh < 0) {

		perror("Failed to open PIXEL_FILE_HIGH");
		return 1;

	} // if dataHigh not opened


	/*** Read until EOF on h/l ***/

	readContinue = 1;
	while(bytesInHigh < (APS_COLS * APS_ROWS / 2) - 1 && readContinue) {

		int newBytes;
		int pass = 0;

		// Read high bytes
		newBytes = read(dataHigh, 
				&pixelBuf[APS_ROWS / 2], APS_COLS * APS_ROWS / 2);
		printf("\tPass %d: newBytes = %d\n", pass, newBytes);

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
			readContinue = 0;

		} // if read succeeded but read nothing

		// Debugging counter
		pass++;

	} // while bytes left to read


	// Open low order xillybus upstream file
	printf("%s:%d: Opening pixel file low\n", __FILE__, __LINE__);
	dataLow = open(PIXEL_FILE_LOW, O_RDONLY);

	// Ensure file opened successfully
	if (dataLow < 0) {

		perror("Failed to open PIXEL_FILE_LOW");
		return 2;

	} // if dataLow not opened

	readContinue = 1;
	while(bytesInLow < (APS_COLS * APS_ROWS / 2) - 1 && readContinue) {

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
			readContinue = 0;

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

	// Attempt to open file to store image data
	printf("%s:%d: Opening output file\n", __FILE__, __LINE__);
	outputFile = open(capture_filename, O_WRONLY | O_CREAT, 0644);

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
				returnVal, capture_filename);
		}

	} // if/else outputFile opened successfully


	/****** Optional for plugs-in ******/

	/* Generate PNG (or other filetype) */
	/* Display image */

	/****** End optional ******/

	// De-initialize all GPIO ports to be used
	GPIOPinDeInit(T_EXP1);
	GPIOPinDeInit(FRAME_REQ);

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

