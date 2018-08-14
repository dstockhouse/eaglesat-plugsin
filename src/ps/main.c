/*****************************************************************************
 *
 * File:
 * 	main.c
 *
 * Description:
 * 	The main function for the CMV2000 interface. Initializes the sensor and
 * 	starts reading image data from the input streams from the FPGA.
 *
 * Author:
 * 	David Stockhouse
 *
 * Revision 1.0
 * 	Last edited 6/7/18
 *
 ****************************************************************************/

#include "generateFilename.h"
#include "gpio.h"
#include "registerAccess.h"
#include "sensor.h"
#include "spiControl.h"

#include <stdio.h>
#include <stdlib.h>

/**** Function main ****
 * Initializes the sensor and starts collecting image data. 
 */
int main() {

	// Initialize the sensor
	spiInit();
	// registerInit();

	/**** Will have image capture code ****/
	// Read out a frame with 5 second exposure
	printf("%s:%d: Starting read...\n", __FILE__, __LINE__);
	frameRead(1);

	spiDeInit();
	

} // Function main()

