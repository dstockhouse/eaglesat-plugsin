/*****************************************************************************
 *
 * File:
 * 	generateFilename.c
 *
 * Description:
 * 	Generates a filename to store raw image data
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 3/3/18
 *
 ****************************************************************************/

#include "generateFilename.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>


/**** Function generateFilename ****
 * Generate a filename for the EagleSat 2 plugs-in test in March 2018 that 
 * matches the format "captureN-mm.dd.yyyy-hh:mm:ss.RAW" where "N" is the 
 * number index of the current capture within this process.
 */
int generateFilename(char *buf, int bufSize, int exposure) {

	static int captureNum = 0;
	int charsWritten;

	// Time variables
	time_t t;
	struct tm currentTime;

	// Get current time in UTC
	t = time(NULL);
	currentTime = *localtime(&t);

	// If the exposure is more than three digits, it may as well be
	// infinite, so cap at 999
	if(exposure > 999) exposure = 999;

	// Create filename using date/time and exposure length
	charsWritten = snprintf(buf, bufSize, 
			"capture%d-%02d.%02d.%04d_%02d:%02d:%02d_exp%03d.RAW",
			captureNum,
			currentTime.tm_mon + 1,
			currentTime.tm_mday,
			currentTime.tm_year + 1900,
			currentTime.tm_hour,
			currentTime.tm_min,
			currentTime.tm_sec,
			exposure);

	// Increment counter number
	captureNum++;


	// Return length of the new string
	return charsWritten;

} // Function generateFilename()


/**** Function main ****
 * Comment out if using as included file
 *
main() {

	char buf[64];
	int i;

	for(i = 0; i < 13; i++) {
		generateFilename(buf, 64, captureNum * 2 + 3);
		printf("%s\n", buf);
		sleep(4);
	}
}
***/

