/*****************************************************************************
 *
 * File:
 * 	gpio.c
 *
 * Description:
 * 	Contains functions to handle GPIO operations on Xillinux through file
 * 	read and write operations as described primarily by 
 * 	https://falsinsoft.blogspot.co.il/2012/11/access-gpio-from-linux-user-space.html
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 3/3/18
 *
 ****************************************************************************/

#include "gpio.h"

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


// Local function declarations
int directoryExists(char *);


/**** Function GPIOPinInit ****
 * Initializes a GPIO pin on the PS side identified by /pin/ and sets the 
 * direction to input or output specified by /dir/ (a string)
 */
int GPIOPinInit(int pin, char *direction) {

	int file;
	char strBuf[STR_BUF];

	// Ensure direction is a valid value
	if(strcmp(direction, GPIO_OUT) && strcmp(direction, GPIO_IN)) {
		printf("Not a valid direction. Must be either GPIO_OUTPUT or \
GPIO_INPUT.\n");

		return 10;
	} // if valid direction

	// Check if GPIO pin has already been initialized by user
	if(GPIOPinIsInit(pin)) {
		int confirm = -1;
		char input;

		// If the directory exists, then the pin has already been
		// initialized
		printf("Pin %d already in use. Disable and reinitialize for \
your own use? [y/n] ", pin); 

		while(confirm < 0) {
			do {
				scanf("%c", &input);
				if(tolower(input) == 'y') {
					confirm = 1;
				} else if(tolower(input) == 'n') {
					confirm = 0;
				} // if 'y'

			} while(!(isalpha(input)));

			if(confirm < 0) {
				printf("Enter [y/n] ");
			} // if

		} // while

		if(confirm) {

			// Deinitialize GPIO pin
			if(GPIOPinDeInit(pin)) {
				printf("Couldn't deinitialize pin %d.\n", pin);

				return 5;

			}


		} else {
			printf("Cannot initialize pin %d.\n", pin);
			return 1;
		} // if/else confirm

	}// if pin already in use



	/*** Initialize GPIO ***/

	// Open export file
	file = open(GPIO_EXPORT, O_WRONLY);

	if(file > 0) {

		// Open succeeded
		sprintf(strBuf, "%d", pin);
		write(file, strBuf, strlen(strBuf));

		// Close file
		close(file);

	} else {

		printf("Couldn't open file \"%s\".\n",
				GPIO_EXPORT);

		return 4;

	} // if/else file opened successfully 

	// Wait for operation to complete
	sleep(1);

	// Check if GPIO successfully initialized
	if(!GPIOPinIsInit(pin)) {

		printf("Couldn't initializes GPIO pin %d.\n", pin);

		return 5;

	} // if not created successfully



	/*** Now that GPIO initialized, set direction ***/

	// Attempt to open direction file

	sprintf(strBuf, GPIO_FMT_PIN_DIR, pin);
	file = open(strBuf, O_WRONLY);

	// Ensure file opened
	if(file > 0) {

		// Open succeeded, write direction
		write(file, direction, strlen(direction));

		// Close file
		close(file);

	} else {

		printf("Couldn't open file \"%s\".\n",
				strBuf);
		printf("Couldn't set direction of pin %d.\n", pin);

		return 6;

	} // if/else file opened successfully 


	// Return no error if nothing failed
	return 0;

} // int GPIOPinInit()

/**** Function GPIOPinDeInit ****
 * Deinitializes GPIO /pin/
 */
int GPIOPinDeInit(int pin) {

	char strBuf[STR_BUF];
	int file;

	// Ensure pin has already been initialized
	if(!GPIOPinIsInit(pin)) {
		printf("Pin %d is not initialized.\n", pin);

		// Might as well be a success
		return 0;
	}

	// Deinitialize GPIO pin

	sprintf(strBuf, "%d", pin);
	file = open(GPIO_UNEXPORT, O_WRONLY);
	if(file > 0) {
		// Open succeeded
		write(file, strBuf, strlen(strBuf));

		// Close file
		close(file);

		// Wait a second so operation completes
		sleep(1);

		if(GPIOPinIsInit(pin)) {

			return 2;

		} // if pin still initialized

	} else {
		// Open failed
		printf("Couldn't open \"%s\".\n", GPIO_UNEXPORT);
		perror("Error");

		return 1;

	} // if/else file opened successfully


	// Successully deinitialized
	return 0;
}


/**** Function GPIOPinIsInit ****
 * Checks to see if GPIO /pin/ is initialized
 */
int GPIOPinIsInit(int pin) {

	char strBuf[STR_BUF];

	// Check if GPIO pin has already been initialized by user
	sprintf(strBuf, GPIO_FMT_PIN_BASEDIR, pin);
	if(directoryExists(strBuf) > 0) {
		// If directory exists, pin has been initialized
		return 1;
	}

	// Pin is not initialized
	return 0;

} // int GPIOPinIsInit()


/**** Function GPIOPinWrite ****
 * Writes /value/ to GPIO /pin/
 */
int GPIOPinWrite(int pin, int value) {

	char strBuf[STR_BUF];
	int file;

	// Ensure /value/ is a boolean
	value = value?1:0;

	// Ensure /pin/ has been initialized
	if(!GPIOPinIsInit(pin)) {
		printf("Pin %d has not been initialized.\n", pin);
		return 1;
	}

	// Open value file
	sprintf(strBuf, GPIO_FMT_PIN_VAL, pin);
	file = open(strBuf, O_WRONLY);

	if(file > 0) {

		// Open succeeded
		sprintf(strBuf, "%d", value);
		write(file, strBuf, strlen(strBuf));

		// Close file
		close(file);

	} else {

		printf("Couldn't open file \"%s\".\n",
				GPIO_EXPORT);

		return 4;

	} // if/else file opened successfully 


	return 0;

} // int GPIOPinWrite()


/**** Function GPIOPinRead ****
 * Reads the value of GPIO /pin/
 */
int GPIOPinRead(int pin) {

	char strBuf[STR_BUF];
	int file, valueBuf;

	// Ensure /pin/ has been initialized
	if(!GPIOPinIsInit(pin)) {
		printf("Pin %d has not been initialized.\n", pin);
		return 1;
	}

	// Open value file
	sprintf(strBuf, GPIO_FMT_PIN_VAL, pin);
	file = open(strBuf, O_RDONLY);

	if(file > 0) {

		// Open succeeded, read one byte
		read(file, &valueBuf, 1);

		// Close file
		close(file);

		return valueBuf - '0';

	} else {

		printf("Couldn't open file \"%s\".\n",
				GPIO_EXPORT);

		return 4;

	} // if/else file opened successfully 

} // int GPIOPinRead()


/**** Function GPIOPinPulse ****
 * Pulses the value of GPIO /pin/ to HIGH as briefly as possible for at least
 * 500 ns
 */
int GPIOPinPulse(int pin) {

	char strBuf[STR_BUF];
	int file;

	// Ensure /pin/ has been initialized
	if(!GPIOPinIsInit(pin)) {
		printf("Pin %d has not been initialized.\n", pin);
		return 1;
	}

	// Open value file
	sprintf(strBuf, GPIO_FMT_PIN_VAL, pin);
	file = open(strBuf, O_WRONLY);

	if(file > 0) {
		// Open succeeded

		/*** Pulse output ***/

		// Output on
		write(file, "1", 1);

		// Delay minimum convenient amount (1 us)
		// The write() system service call will most likely have its
		// own delay amounting to enough to take up more than one clock
		// cycle, but this is here to make sure that is the case. As 
		// far as I can tell, there is no downside to taking up more
		// than one clock cycle of the CMV2000
		// usleep(1);

		// Output off
		write(file, "0", 1);

		// Close file
		close(file);

	} else {

		printf("Couldn't open file \"%s\".\n",
				GPIO_EXPORT);

		return 4;

	} // if/else file opened successfully 


	return 0;

} // int GPIOPinPulse()





/******* Local Functions *******/
/**** Function directoryExists ****
 * Checks to see if a directory exists, to check if a pin has been initialized
 */
int directoryExists(char *dirname) {

	DIR *dir;

	if(dirname == NULL) {
		// String is a null pointer
		return -1;
	} // if dirname is NULL

	// Attempt to open /dir/ 
	dir = opendir(dirname);

	if(dir == NULL) {
		// Directory couldn't be opened

		if(errno == ENOENT) {
			// Directory doesn't exist
			return 0;

		} else if(errno == EACCES) {

			// Permission denied
			printf("Couldn't access \"%s\": Permission denied\n.",
					dirname);
			return -2;

		} // if not exist / else if no permissions

	} else {

		// Directory exists
		closedir(dir);

		return 1;

	} // if/else directory pointer is NULL


	// The function won't make it this far, but return on mega error to
	// make the compiler happy
	return -3;

} // int directoryExists()



/**** Function main ****
 * Tests functionality of GPIO stuff. Comment out if included in other project
 *
int main(void) {

	int i;
	int pin = 32+54;

	// Initialize pin 61 as output
	if(GPIOPinInit(pin, GPIO_OUT)) {
		printf("Couldn't init\n");
		return 1;
	}

// 	// Write 1 to output pin
// 	if(GPIOPinWrite(pin, GPIO_HIGH)) {
// 		printf("Couldn't write 1\n");
// 		return 2;
// 	}
// 
// 	// Delay 
// 	// sleep(5);
// 
// 	// Write 0 to output pin
// 	if(GPIOPinWrite(pin, GPIO_LOW)) {
// 		printf("Couldn't write 0\n");
// 		return 3;
// 	}

	for(i = 0; i < 2000; i++) {

		// Pulse GPIO pin
		GPIOPinPulse(pin);
		usleep(5000);

	} // for

	// Deinitialize GPIO pin
	if(GPIOPinDeInit(pin)) {
		printf("Couldn't deinit\n");
		return 4;
	}

	return 0;
} // Function main()
 ****/
