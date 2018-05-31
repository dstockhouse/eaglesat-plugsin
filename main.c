
#include "sensor.h"
#include "spiControl.h"
#include "registerAccess.h"
#include "generateFilename.h"
#include "gpio.h"

#include <stdio.h>
#include <stdlib.h>

int main() {

	spiInit();

	registerInit();


	spiDeInit();

}

