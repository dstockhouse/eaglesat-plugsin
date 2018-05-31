/*****************************************************************************
 *
 * File:
 * 	spiControl.c
 *
 * Description:
 * 	Contains funtions for controlling an SPI device through bit banging a
 * 	GPIO port. Because it uses software user-space accesses to GPIO ports
 * 	to manage SPI signals, this interface is very slow (~4kHz), so it
 * 	should not be used in a system with a minimum SPI data rate
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.2
 * 	Last edited 3/31/18
 *
 ****************************************************************************/

#include "spiControl.h"

#include "gpio.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


/**** Function spiInit ****
 * Initializes an SPI port 
 */
int spiInit(void) {

	int returnVal;


	/*** Initialize GPIO ports for use with SPI ***/

	// Initialize chip select
	returnVal = GPIOPinInit(CS, GPIO_OUT);
	if(returnVal) {
		printf("Couldn't initialize CS to pin %d.\n", CS);
		return returnVal;
	}

	// Initialize master in slave out
	returnVal = GPIOPinInit(MISO, GPIO_IN);
	if(returnVal) {
		printf("Couldn't initialize MISO to pin %d.\n", MISO);
		return returnVal;
	}

	// Initialize master out slave in
	returnVal = GPIOPinInit(MOSI, GPIO_OUT);
	if(returnVal) {
		printf("Couldn't initialize MOSI to pin %d.\n", MOSI);
		return returnVal;
	}

	// Initialize clock
	returnVal = GPIOPinInit(CLK, GPIO_OUT);
	if(returnVal) {
		printf("Couldn't initialize CLK to pin %d.\n", CLK);
		return returnVal;
	}


	/*** Set pins to initial values ***/
	returnVal = GPIOPinWrite(CS, CS_INACTIVE);
	if(returnVal) {
		printf("Couldn't set CS (pin %d) to %d. Error code %d.\n", CS, CS_INACTIVE, returnVal);
		return 7;
	}
	returnVal = GPIOPinWrite(MOSI, 0);
	if(returnVal) {
		printf("Couldn't set MOSI (pin %d) to 0. Error code %d.\n", MOSI, returnVal);
	}
	returnVal = GPIOPinWrite(CLK, 0);
	if(returnVal) {
		printf("Couldn't set CLK (pin %d) to 0. Error code %d.\n", CLK, returnVal);
	}

	// Return on success
	return 0;

} // Function spiInit()


/**** Function spiDeInit ****
 * Deinitializes an SPI port 
 */
int spiDeInit(void) {

	int returnVal;

	/*** Uninitialize SPI ports ***/

	// Initialize chip select
	returnVal = GPIOPinDeInit(CS);
	if(returnVal) {
		printf("Couldn't deinitialize CS to pin %d. Error code %d.\n", CS, returnVal);
	}

	// Initialize master in slave out
	returnVal = GPIOPinDeInit(MISO);
	if(returnVal) {
		printf("Couldn't deinitialize MISO to pin %d. Error code %d.\n", MISO, returnVal);
	}

	// Initialize master out slave in
	returnVal = GPIOPinDeInit(MOSI);
	if(returnVal) {
		printf("Couldn't deinitialize MOSI to pin %d. Error code %d.\n", MOSI, returnVal);
	}

	// Initialize clock
	returnVal = GPIOPinDeInit(CLK);
	if(returnVal) {
		printf("Couldn't deinitialize CLK to pin %d. Error code %d.\n", CLK, returnVal);
	}

	// Return on success
	return 0;

} // Function spiDeInit()


/**** Function spiIsNotInit ****
 * Verifies that the SPI port has already been initialized
 */
int spiIsNotInit(void) {

	int returnVal = 0;

	// Ensure pins initialized
	if(!GPIOPinIsInit(CS)) {
		returnVal |= 1;
	}
	if(!GPIOPinIsInit(MISO)) {
		returnVal |= 2;
	}
	if(!GPIOPinIsInit(MOSI)) {
		returnVal |= 4;
	}
	if(!GPIOPinIsInit(CLK)) {
		returnVal |= 8;
	}

	// Return which pins were uninitialized
	return returnVal;

} // Function spiIsNotInit()


/**** Function spiWrite ****
 * Writes bytes from a buffer out onto the GPIO SPI port
 */
int spiWrite(unsigned char *buf, int bufSize) {

	int returnVal;
	int fileMOSI, fileCLK;
	int i, bit;

	// Ensure SPI has been initialized
	if(
		!GPIOPinIsInit(CS) || 
		!GPIOPinIsInit(MISO) || 
		!GPIOPinIsInit(MOSI) || 
		!GPIOPinIsInit(CLK)
	  ) {

		printf("SPI module not yet initialized.\n");
		return -1;

	}

	// Ensure the buffer is not NULL
	if(buf == NULL) {
		return -2;
	}


	/*** Start write out ***/

	// Initially, MOSI and CLK should be low
	GPIOPinWrite(MOSI, GPIO_LOW);
	GPIOPinWrite(CLK, GPIO_LOW);

	// Start manual clock and data output
	for(i = 0; i < bufSize; i++) {
		for(bit = 0; bit < 8; bit++) {

			// Write current bit of output signal
			GPIOPinWrite(MOSI, (buf[i] >> (7 - bit)) & 0x01);

			// Pulse clock
			GPIOPinWrite(CLK, GPIO_HIGH);
			GPIOPinWrite(CLK, GPIO_LOW);

		} // for bits
	} // for bufSize

	// Make sure the MOSI and CLK lines are at low state
	GPIOPinWrite(MOSI, GPIO_LOW);
	GPIOPinWrite(CLK, GPIO_LOW);

	// If successful, return number of bytes written
	return i;

} // Function spiWrite()


/**** Function spiRead ****
 * Shifts in and reads bytes from a the GPIO SPI port into a buffer
 */
int spiRead(unsigned char *buf, int bufSize) {

	int returnVal;
	int i, bit;

	// Ensure SPI has been initialized
	if(
		!GPIOPinIsInit(CS) || 
		!GPIOPinIsInit(MISO) || 
		!GPIOPinIsInit(MOSI) || 
		!GPIOPinIsInit(CLK)
	  ) {

		printf("SPI module not yet initialized.\n");
		return -1;

	}

	// Ensure the buffer is not NULL
	if(buf == NULL) {
		if(bufSize > 0) {
			return -2;
		} else {
			return 0;
		}
	}

	// Clear the buffer
	for(i = 0; i < bufSize; i++) {
		buf[i] = 0x00;
	}


	/*** Start read in ***/

	// Init clock to low
	GPIOPinWrite(CLK, GPIO_LOW);

	// Start manual clock and data output
	for(i = 0; i < bufSize; i++) {

		// Read in 8 bits for every byte in the buffer
		for(bit = 0; bit < 8; bit++) {

			// Used to buffer an input bit from the MISO line
			char bitBuf;

			// Read MISO line right before clock signal and hope
			// that it is fast enough before CLK rising edge
			bitBuf = GPIOPinRead(MISO);

			// Write high clock signal 
			GPIOPinWrite(CLK, GPIO_HIGH);

			// Add buffered bit to byte buffer
			buf[i] |= (bitBuf & 0x01) << (7 - bit);

			// Write low clock signal
			GPIOPinWrite(CLK, GPIO_LOW);

		} // for bits
	} // for bufSize

	// Make sure the CLK line is at a low state
	GPIOPinWrite(CLK, GPIO_LOW);

	// If successful, return number of bytes read
	return i;

} // Function spiRead()


/**** Function spiTransact ****
 * Writes out a set of bytes and reads in a set of bytes on the SPI bus
 */
int spiTransact(unsigned char *outBuf, int outBufSize, unsigned char *inBuf, int inBufSize) {

	int returnVal;

	// Activate CS
	returnVal = GPIOPinWrite(CS, CS_ACTIVE);
	// Ensure write was successful
	if(returnVal) {
		printf("Couldn't activate CS.\n");
		return returnVal;
	}

	// Output bytes from buffer
	returnVal = spiWrite(outBuf, outBufSize);
	if(returnVal < outBufSize) {
		printf("SPI write failed.\n");
		// Deactivate CS
		GPIOPinWrite(CS, CS_INACTIVE);
		return returnVal;
	}

	// Input bytes to buffer
	returnVal = spiRead(inBuf, inBufSize);
	if(returnVal < inBufSize) {
		printf("SPI read failed.\n");
		// Deactivate CS
		GPIOPinWrite(CS, CS_INACTIVE);
		return returnVal;
	}

	// Deactivate CS
	returnVal = GPIOPinWrite(CS, CS_INACTIVE);
	// Ensure write was successful
	if(returnVal) {
		printf("Couldn't deactivate CS.\n");
		return returnVal;
	}

	// Return on success
	return 0;

} // Function spiTransact()




/**** Function main ****
 * Main function to test SPI functionality. Comment out if included in 
 * another project
 */
/*
int main(int argc, char **argv) {

	unsigned char WRMR[2] = {0x01, 0x00};
	unsigned char writeCommand[5] = {0x02, 0x00, 0x03, 0x00, 0x00};
	unsigned char readCommand[4] = {0x03, 0x00, 0x03, 0x00};
	unsigned char outBuf = 0x05;
	unsigned char inBuf;

	unsigned char output = 0x56;

	if(argc < 2) {
		writeCommand[4] = output;
	} else {
		int buf;
		sscanf(argv[1], "%x", &buf);
		writeCommand[4] = buf & 0xff;
	}


	printf("Initializing...\n");
	spiInit();

	// Ensure pins initialized
	if(GPIOPinIsInit(CS)) {
		// printf("CS Initialized\n");
	} else {
		printf("CS not Initialized\n");
	}
	if(GPIOPinIsInit(MISO)) {
		// printf("MISO Initialized\n");
	} else {
		printf("MISO not Initialized\n");
	}
	if(GPIOPinIsInit(MOSI)) {
		// printf("MOSI Initialized\n");
	} else {
		printf("MOSI not Initialized\n");
	}
	if(GPIOPinIsInit(CLK)) {
		// printf("CLK Initialized\n");
	} else {
		printf("CLK not Initialized\n");
	}

	printf("Setting mode register...\n");
	spiTransact(WRMR, 2, &inBuf, 0);

	printf("Writing 0x%x to address 0x%06x...\n", writeCommand[4], (writeCommand[1]<<16) | (writeCommand[2]<<8) | writeCommand[3]);
	spiTransact(writeCommand, 5, &inBuf, 0);

	printf("Reading from address 0x%06x...\n", (readCommand[1]<<16) | (readCommand[2]<<8) | readCommand[3]);
	spiTransact(readCommand, 4, &inBuf, 1);
	printf("Read 0x%x\n", inBuf);

	printf("Deinitializing...\n");
	spiDeInit();

	// Ensure pins not initialized
	if(GPIOPinIsInit(CS)) {
		printf("CS still Initialized\n");
	}
	if(GPIOPinIsInit(MISO)) {
		printf("MISO still Initialized\n");
	}
	if(GPIOPinIsInit(MOSI)) {
		printf("MOSI still Initialized\n");
	}
	if(GPIOPinIsInit(CLK)) {
		printf("CLK still Initialized\n");
	}

	// printf("Received %d\n", inBuf);

	return 0;

} // Function main()
*/
