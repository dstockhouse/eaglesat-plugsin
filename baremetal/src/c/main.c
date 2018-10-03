/******************************************************************************
 *
 * (c) Copyright 2010-2013 Xilinx, Inc. All rights reserved.
 *
 * This file contains confidential and proprietary information of Xilinx, Inc.
 * and is protected under U.S. and international copyright and other
 * intellectual property laws.
 *
 * DISCLAIMER
 * This disclaimer is not a license and does not grant any rights to the
 * materials distributed herewith. Except as otherwise provided in a valid
 * license issued to you by Xilinx, and to the maximum extent permitted by
 * applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
 * FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
 * IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
 * MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
 * and (2) Xilinx shall not be liable (whether in contract or tort, including
 * negligence, or under any other theory of liability) for any loss or damage
 * of any kind or nature related to, arising under or in connection with these
 * materials, including for any direct, or any indirect, special, incidental,
 * or consequential loss or damage (including loss of data, profits, goodwill,
 * or any type of loss or damage suffered as a result of any action brought by
 * a third party) even if such damage or loss was reasonably foreseeable or
 * Xilinx had been advised of the possibility of the same.
 *
 * CRITICAL APPLICATIONS
 * Xilinx products are not designed or intended to be fail-safe, or for use in
 * any application requiring fail-safe performance, such as life-support or
 * safety devices or systems, Class III medical devices, nuclear facilities,
 * applications related to the deployment of airbags, or any other applications
 * that could lead to death, personal injury, or severe property or
 * environmental damage (individually and collectively, "Critical
 * Applications"). Customer assumes the sole risk and liability of any use of
 * Xilinx products in Critical Applications, subject only to applicable laws
 * and regulations governing limitations on product liability.
 *
 * THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
 * AT ALL TIMES.
 *
 ******************************************************************************/
/*****************************************************************************/
/**
 *
 * @file xaxidma_example_simple_poll.c
 *
 * This file demonstrates how to use the xaxidma driver on the Xilinx AXI
 * DMA core (AXIDMA) to transfer packets in polling mode when the AXI DMA core
 * is configured in simple mode.
 *
 * This code assumes a loopback hardware widget is connected to the AXI DMA
 * core for data packet loopback.
 *
 * To see the debug print, you need a Uart16550 or uartlite in your system,
 * and please set "-DDEBUG" in your compiler options. You need to rebuild your
 * software executable.
 *
 * Make sure that MEMORY_BASE is defined properly as per the HW system. The
 * h/w system built in Area mode has a maximum DDR memory limit of 64MB. In
 * throughput mode, it is 512MB.  These limits are need to ensured for
 * proper operation of this code.
 *
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date     Changes
 * ----- ---- -------- -------------------------------------------------------
 * 4.00a rkv  02/22/11 New example created for simple DMA, this example is for
 *                  simple DMA
 * 5.00a srt  03/06/12 Added Flushing and Invalidation of Caches to fix CRs
 *               648103, 648701.
 *               Added V7 DDR Base Address to fix CR 649405.
 * 6.00a srt  03/27/12 Changed API calls to support MCDMA driver.
 * 7.00a srt  06/18/12 API calls are reverted back for backward compatibility.
 * 7.01a srt  11/02/12 Buffer sizes (Tx and Rx) are modified to meet maximum
 *               DDR memory limit of the h/w system built with Area mode
 * 7.02a srt  03/01/13 Updated DDR base address for IPI designs (CR 703656).
 *
 * </pre>
 *
 * ***************************************************************************

 */
/***************************** Include Files *********************************/
#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"
#include "xgpio.h"

#include <sleep.h>

/******************** Constant Definitions **********************************/

/*
 * Device hardware build related constants.
 */

#define DMA_DEV_ID        XPAR_AXIDMA_0_DEVICE_ID
#define DDR_BASE_ADDR        XPAR_DDR_MEM_BASEADDR

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
  DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR        0x01000000
#else
#define MEM_BASE_ADDR        (DDR_BASE_ADDR + 0x1000000)
#endif

#define RX_BUFFER_BASE        (MEM_BASE_ADDR + 0x00100000)
#define RX_BUFFER_HIGH        (MEM_BASE_ADDR + 0x004FFFFF)

#define NUMBER_OF_WORDS     32
#define NUMBER_OF_BYTES         NUMBER_OF_WORDS * 4

#define TEST_START_VALUE    10

#define NUMBER_OF_TRANSFERS    NUMBER_OF_WORDS / 4

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

#if (!defined(DEBUG))
extern void xil_printf(const char *format, ...);
#endif

int XAxiDma_SimplePollExample(u16 DeviceId);
static int CheckData(u32 cur_indx);
static int CheckEdges(u32 distance);

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */
XAxiDma AxiDma;

XGpio Gpio;

/*****************************************************************************/
/*
 * The entry point for this example. It invokes the example function,
 * and reports the execution status.
 *
 * @param    None.
 *
 * @return
 *        - XST_SUCCESS if example finishes successfully
 *        - XST_FAILURE if example fails.
 *
 * @note        None.
 *
 ******************************************************************************/
int main() {
	int Status;

	xil_printf("\r\n--- Entering main() --- \r\n");

	Xil_DCacheDisable();

	// Initialize GPIO trigger into PL
	XGpio_Initialize(&Gpio, XPAR_GPIO_0_DEVICE_ID);

	XGpio_SetDataDirection(&Gpio, 1, 0x0000);
	XGpio_SetDataDirection(&Gpio, 2, 0xFFFF);

	XGpio_DiscreteWrite(&Gpio, 1, 0x0000);

	/* Run the poll example for simple transfer */
	Status = XAxiDma_SimplePollExample(DMA_DEV_ID);

	if (Status != XST_SUCCESS) {

		xil_printf("XAxiDma_SimplePollExample: Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("XAxiDma_SimplePollExample: Passed\r\n");

	xil_printf("--- Exiting main() --- \r\n");

	return XST_SUCCESS;

}

/*****************************************************************************/
/**
 * The example to do the simple transfer through polling. The constant
 * NUMBER_OF_TRANSFERS defines how many times a simple transfer is repeated.
 *
 * @param    DeviceId is the Device Id of the XAxiDma instance
 *
 * @return
 *        - XST_SUCCESS if example finishes successfully
 *        - XST_FAILURE if error occurs
 *
 * @note        None
 *
 *
 ******************************************************************************/
#define PIXELS_PER_ROW	2048
#define NUM_ROWS		1088

//#define PACKET_SIZE		(PIXELS_PER_ROW / 4)
#define TRIGGER			0x01
#define TRIGGER_INDEX	0
#define TRIGGER_MASK	0x01

#define CLOCK_DIV		40
#define CLOCK_DIV_INDEX	1
#define CLOCK_DIV_MASK	0x03FE

// PACKET_SIZE * 4 is the number of bytes per packet
#define PACKET_SIZE			(PIXELS_PER_ROW * NUM_ROWS / 4)
#define PACKET_SIZE_INDEX	10
#define PACKET_SIZE_MASK	0x000FFC00

#define NUM_PACKETS			1
#define NUM_PACKETS_INDEX	20
#define NUM_PACKETS_MASK	0xFFF00000

//#define NUM_READS		(PIXELS_PER_ROW * NUM_ROWS)
#define NUM_READS (NUM_PACKETS * PACKET_SIZE)

#define BUSYWAIT_MAX		10000000

#define REQUEST_DELAY	0
int XAxiDma_SimplePollExample(u16 DeviceId) {
	XAxiDma_Config *CfgPtr;
	int Status, overflow;
	u32 Index;
	u32 *RxBufferPtr;

	u32 Value;

	int i;
	int continueTest = 1;
	char inChar;

	RxBufferPtr = (u32 *) RX_BUFFER_BASE;

	/* Initialize the XAxiDma device.
	 */
	CfgPtr = XAxiDma_LookupConfig(DeviceId);
	if (!CfgPtr) {
		xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	}
	xil_printf("Found config for AXI DMA\n\r");

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}
	xil_printf("Finish initializing configurations for AXI DMA\n\r");

	if (XAxiDma_HasSg(&AxiDma)) {
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}
	xil_printf("AXI DMA is configured as Simple Transfer mode\n\r");

	xil_printf("PACKET_SIZE: %d\n\rNUM_READS: %d\n\rREQUEST_DELAY: %d\n\r",
	PACKET_SIZE, NUM_READS, REQUEST_DELAY);

	/* Disable interrupts, we use polling mode
	 */
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	Value = TEST_START_VALUE;

	Value = 0xFFFFFFFF;
	for (Index = 0; Index < NUM_READS; Index++) {
		RxBufferPtr[Index] = Value;
	}

	/* Flush the SrcBuffer before the DMA transfer, in case the Data Cache
	 * is enabled
	 */
	Xil_DCacheFlushRange((u32) RxBufferPtr, NUMBER_OF_BYTES);

	Index = 0;
	i = 0;

	while (continueTest) {

		Value = 0xFFFFFFFF;
		for (Index = 0; Index < NUM_READS; Index++) {
			RxBufferPtr[Index] = Value;
		}
		xil_printf("Sample mem: %x\tPress any key to continue.\n\r", RxBufferPtr[NUM_READS / 2]);
		inbyte();

//		for (i = 0; i < (NUM_READS / PACKET_SIZE); i++) {

//			// Check overflow signal
//			overflow = XGpio_DiscreteRead(&Gpio, 2) & 0x01;
//			if (overflow) {
//				xil_printf("Detected overflow before initiating %d\n\r", i);
//			}

			Status = XAxiDma_SimpleTransfer(&AxiDma,
					(u32) (RxBufferPtr + (i * PACKET_SIZE)), 4 * PACKET_SIZE,
					XAXIDMA_DEVICE_TO_DMA);

			if (Status != XST_SUCCESS) {
				xil_printf("    DMA %d failed, breaking loop\n\r", i);
				xil_printf(
						"\n\rSuccessfully transferred %d words (%d bytes) before missing a transfer. ",
						PACKET_SIZE * (i - 1), 4 * PACKET_SIZE * (i - 1));
				break;
				//			return XST_FAILURE;
			}

			if (i == 0) {
				// Send timing and packet info to PL and trigger data production
				u32 outByte =
						((PACKET_SIZE << PACKET_SIZE_INDEX) & PACKET_SIZE_MASK)
								| ((NUM_PACKETS << NUM_PACKETS_INDEX)
										& NUM_PACKETS_MASK)
								| ((CLOCK_DIV << CLOCK_DIV_INDEX)
										& CLOCK_DIV_MASK)
								| ((TRIGGER << TRIGGER_INDEX) & TRIGGER_MASK);

				xil_printf("Writing out %x. Press any key to continue.\n\r",
						outByte);

				// Block until user confirmation
//				inbyte();

				xil_printf("\n\rWriting config and trigger to GPIO\n\r");
				XGpio_DiscreteWrite(&Gpio, 1, outByte);
				XGpio_DiscreteWrite(&Gpio, 1, outByte & ~(0x01));
			}

			//		usleep(REQUEST_DELAY);

			Index = 0;
			while (XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA) && Index < BUSYWAIT_MAX) {
				int overflowDetected = 0;
				//wait
				Index++;
				// Check overflow signal
				overflow = XGpio_DiscreteRead(&Gpio, 2) & 0x01;
				if (overflow && !overflowDetected) {
					xil_printf("Detected overflow at wait %d\n\r", Index);
					overflowDetected = 1;
				}

			}
			if (Index > 0) {
				xil_printf("DEVICE_TO_DMA %d waited for %d counts\n\r", i,
						Index);
			}
			if (Index % 10 == 0) {
				xil_printf("DEVICE_TO_DMA finishes %d\n\r", i);
			}
//		}

		if (Index < BUSYWAIT_MAX) {
			// Successfully read all intended bytes
			xil_printf(
					"Success! DMA successfully transmitted %d words (%d bytes). ",
					NUM_PACKETS * PACKET_SIZE, NUM_PACKETS * PACKET_SIZE * 4);
		}
		xil_printf("Press 'd' to dump memory contents, 'e' to sample beginning and end of data region\n\r");
		inChar = inbyte();
		if (inChar == 'd') {

			// Call CheckData to dump accessed memory
			Status = CheckData(Index);
			if (Status != XST_SUCCESS) {
				return XST_FAILURE;
			}
		} else if (inChar == 'e') {
			CheckEdges(0x40);
		}

		xil_printf("Run test again? ['n' to quit]\n\r");
		inChar = inbyte();
		if (inChar == 'n' || inChar == 'N') {
			continueTest = 0;
		}

	}

//  }

	/* Test finishes successfully
	 */
	return XST_SUCCESS;
}

/*****************************************************************************/
/*
 *
 * This function checks data buffer after the DMA transfer is finished.
 *
 * @param    None
 *
 * @return
 *
 * @note        None.
 *
 ******************************************************************************/
#define EXTRA_BYTES	4
static int CheckData(u32 cur_indx) {
	u32 *RxPacket;
	int Index = 0;

	RxPacket = (u32 *) (RX_BUFFER_BASE);

	/* Invalidate the DestBuffer before receiving the data, in case the
	 * Data Cache is enabled
	 */
	Xil_DCacheInvalidateRange((u32) RxPacket, NUMBER_OF_BYTES);

	// Dump data left by DMA
	for (Index = 0; Index < NUM_READS + EXTRA_BYTES; Index += 0x40) {
		xil_printf("At %5x: %08x; ", Index, (unsigned int) RxPacket[Index]);
	}

	xil_printf("\n\n\r");

	return XST_SUCCESS;
}

static int CheckEdges(u32 distance) {
	u32 *RxPacket;
	int Index = 0;

	RxPacket = (u32 *) (RX_BUFFER_BASE);

	/* Invalidate the DestBuffer before receiving the data, in case the
	 * Data Cache is enabled
	 */
	Xil_DCacheInvalidateRange((u32) RxPacket, NUMBER_OF_BYTES);

	// Dump data left by DMA
	for (Index = 0; Index < distance; Index += 1) {
		xil_printf("At %5x: %08x; ", Index, (unsigned int) RxPacket[Index]);
	}

	xil_printf("\n\n\r");

	for (Index = NUM_READS - distance; Index < NUM_READS; Index += 1) {
		xil_printf("At %5x: %08x; ", Index, (unsigned int) RxPacket[Index]);
	}

	xil_printf("\n\n\r");

	return XST_SUCCESS;
}
