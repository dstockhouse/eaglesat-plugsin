# CMV2000 CMOS Active Pixel Sensor (APS) Datasheet Summary

This information is taken from the CMV2000 device datasheet rev3.8 downloaded
from the CMOSIS website in early December 2017.

The CMV2000 (now on referred to as “the sensor”) is a 2048x1088 CMOS APS with
5.5 µm x 5.5 µm pixel size. EagleSat-II is using this sensor as test equipment
to prepare our detection methods for use with the more expensive CMV50000
sensor which will eventually fly on the Cosmic Ray Payload (CRP). The two
devices have many similarities, primarily the use of LVDS for digital image
readout. The CMV2000 is driven by an externally provided master clock signal at
TTL levels ranging from 5 MHz to 48 MHz. An LVDS clock with a frequency ten or
twelve times that of the master clock may also be provided to drive the LVDS
block, otherwise an internal PLL must be used.

The sensor configuration is controlled by internal registers that can be
accessed and modified using SPI. The sensor can be configured to collect pixel
data in 10 or 12 bits. It can control its own integration time or rely on
external signaling for exposure start and end control. The device also includes
an internal temperature sensor accessed through SPI.

The CRP configuration attempts to optimize power consumption, relying on low
clock frequencies and few LVDS channels. Our configuration is 5MHz master input
clock, 10-bit ADC, and 2 LVDS channels. Therefore, most power consumption and
timing information offered by the datasheet as a sample is incorrect for our
configuration. We will need to run tests of the relevant parameters once we
start prototyping sensor boards.

## Driving the Sensor

The sensor requires multiple supply voltage inputs, given by the table on page
13 of the datasheet.

The power consumption values listed in the table assume all 16 LVDS output
channels are utilized, but it does not give power consumption estimates when a
configuration closer to that of the CRP. The varying and precise voltage
supplies may not be directly supplied by the Electronic Power System (EPS), so
the sensor board will likely need its own suite of voltage regulators to
generate supplies of 2.0, 3.0, and 3.3 volts with more direct control than the
EPS board.

Any jitter on the supplies will contribute to noise on the sensor readout, so it
is critical that the sensor is given a very stable supply (most likely isolated
from any microprocessor). The datasheet recommends several decoupling capacitors
directly on the output of each voltage regulator to filter out low-frequency
noise:
* 330 µF electrolytic
* 33 µF tantalum
* 10 µF ceramic

Additionally, the datasheet recommends lower-capacitance decoupling capacitors
on the sensor side for each power supply to filter out high-frequency noise:
* 100 nF ceramic at each power supply pin
* 100 µF ceramic at each power supply plane (all listed except Vres_h)

Analog and digital ground can be shared. A full list of decoupling capacitors
required for several pins can be found on page 54 of the sensor datasheet.

### Digital Inputs

The digital inputs to the device include:
* Master input clock (CLK_IN) 3.3V input clock that can range from 5MHz to 48MHz
* System reset (SYS_RES_N) active low sequencer, must be kept low during startup
* Frame request (FRAME_REQ) used to signal start of frame capture in any mode
* Exposure end (T_EXP1) used to signal the end of integration time and start of
  data readout in external integration control mode
* SPI MOSI (SPI_IN) input SPI signal from control device
* SPI CS (SPI_EN) active high SPI chip select from control device
* SPI CLK (SPI_CLK) SPI clock, maximum 48MHz
* Optional: LVDS input clock (LVDS_CLK_IN_P/N) LVDS input clock, only required
  if PLL is not used

### Startup and Reset Sequence

For cold startup:
* Hold SYS_RES_N low to begin
* Bring supply voltages to stable levels
* Start CLK_IN
* After 1 µs of clock pulses, bring SYS_RES_N high
* After at least 1 µs after SYS_RES_N is high, optionally upload SPI data to
  registers

After every SPI upload, the device must wait a minimum settling time to allow
any configuration changes to take effect. The settling time is dependent on what
configurations were changed, with the largest contributing factor being the ADC
gain. The settling time for changing the ADC gain is 7-20 ms (in extreme cases).

Frames can be requested after the settling time, or 1 µs after SYS_RES_N is high
if no SPI upload is necessary

If the sensor is reset while operating, the same timing requirements apply
starting from SYS_RES_N being brought high.

### Integration Time

The device can be set for variable integration time by sending a pulse to the
pin T_EXP1 to start exposure and another pulse to pin FRAME_REQ to end the
exposure and automatically start readout.

Required configuration: register Exp_ext (register 41) set to ‘1’

The pixel data is read out using up to 16 low-voltage differential signaling
(LVDS) pairs. The maximum number of channels is used to optimize frame rate,
which is not one of our driving factors. Using 2 LVDS channels, the minimum
allowed, would vastly decrease power consumption while leaving the readout time
within our (~5 second preliminary window.

## Required Readout Time Estimate

Image readout time consists of the actual time to read out image data and the
time required to sample all pixels, called the frame overhead time. These
estimates assume 10-bit ADC is used (likely) and

### Calculation for image readout time

These calculations are from page 15 of the device datasheet.

*Image Readout Time = 129 * Master Clock Period * 16/# Outputs Used * # Rows in
Frame*

For our configuration:
* Master Clock Period = 1/5MHz = .2 µs (the minimum frequency)
* # Outputs Used = 2 (the minimum, to minimize power consumption)
* # Rows in Frame = 1088 (full frame)

Image readout time = 224.6 ms; well within our requirements

### Calculation for frame overhead time (FOT)

*Frame Overhead Time (FOT) = (fot_length + (2\*16/# Outputs Used)) * 129 *
Master Clock Period*

where fot_length is a device register, default value 10

For our configuration:
* Master Clock Period = 1/5MHz = .2 µs
* # Outputs Used = 2
* fot_length = 10 (default)

FOT = 670.8 µs; insignificant compared to the image readout time

This gives a total minimum time to readout the whole sensor of ~225 ms

In addition to the data channels, there is one LVDS channel used for control
that gives information about which stage in the readout process is currently
underway, as well as validity of sensor data and actual measured time of
integration which may be useful to monitor degradation of the sensor.

## LVDS Specifications 

The sensors LVDS block follows TIA/EIA 644A standard. Up to 18 LVDS outputs (16
data + 1 control + 1 output clock) and 1 input (LVDS input clock). We will use 4
LVDS outputs (2 data). All LVDS clocking is dual data rate (DDR). The standard
requires each communication pair to be bridged with a 100Ω resistor at the
receiver end. The MAX9121 receiver does not include this terminating resistor,
so the board housing the LVDS receivers will need the terminating resistors
externally added.

For the first prototype, the external LVDS receiver will be used, but in future
designs it would be better to rely on LVDS input pins on the FPGA used for the
rest of the interface.

## SPI Usage

Internal device registers can be read from or written to. All data capture
occurs on the rising edge of SPI_CLK. An SPI operation is initiated by a rising
edge of SPI_EN, and the first rising edge of SPI_CLK must occur at least half of
one clock period after the rise in SPI_EN.

Each SPI communication contains 16 bits:
* 15 – Control; ‘0’ for read, ‘1’ for write 
* [14:8] – Register address; MSB first 
* [7:0] – Data; MSB first

For a write operation, the data to fill a register is supplied to the sensor pin
SPI_IN (MOSI); for a read it is output from the sensor pin SPI_OUT (MISO)

Multiple registers may be written to or read from in sequence without any delay
or SPI_EN change between writes. Registers should be written to while the sensor
is idle, though some registers can be written during active operation without
disrupting data capture.

## Pixel Data Read Sequence 

Data read through the LVDS outputs is initiated automatically after the
integration time and frame overhead time have completed. One master clock
(CLK_IN) pulse corresponds to one pixel being read out on each LVDS channel
used, so the LVDS data is output at 5 times (because it's DDR) the CLK_IN
frequency for 10-bit operation.

Readout is in the form of 2 serial LVDS channels for pixel data sent and one
line of control metadata sent along with all pixel data (and DDR LVDS clock,
even bits on rising edge). To get all the data converted to parallel, there will
need to be three separate shift registers for each serial LVDS channel.

Because this is such an uncommon system (as far as I have found), there isn't a
standard IC that implements this specific functionality. We need to design our
own ASIC, on an FPGA, just to interface to the sensor. The image processing can
be completed in software on a hard processor, but getting the image data from
the FPGA to a processor at this high speed is still a challenge. The Zynq-7000
SoC from Xilinx is ideal for this application because it includes FPGA
programmable fabric and ARM processor cores integrated closely together. In
addition, the Zynq has differential LVDS input pins to obviate the need for a
discrete LVDS line receiver. In the prototype, however, we are using the MAX9121
LVDS line receiver IC on the same board as the sensor itself. 

## Modified Power Consumption 

The power consumption will be reduced by ~18mW for each LVDS channel disabled,
so reducing the number of channels from 16 down to 2 reduces overall power
consumption by ~250 mW. Reducing frequency of operation reduces power
consumption, though less drastically according to the datasheet. Reducing LVDS
clock from 480MHz to 128MHz reduces power consumption by ~25 mW.

## Other Notes 

According to page 59 of the datasheet, the device can be ordered to have either
a 5 µm or 12 µm thick epitaxial layer thickness. I’m not sure what has been
ordered so far, but generally a thick epitaxial layer is better for particle
detection. If the thinner sensor was ordered, at least we know the thickness of
the substrate before we begin testing.

For ease and efficiency of memory usage, we will only use 8 of the 10 bits
provided for each pixel. At one byte per pixel, a single complete frame in
memory would take up 2048 x 1088 x = 2,228,224 bytes = 2.125 MB.

After taking a closer look at the datasheet, I noticed that the LVDS clock is
only 5 times the CLK_IN frequency, because of its DDR nature. Only the data rate
is 10 times faster. So with the minimum CLK_IN frequency of 5MHz, the LVDS clock
has a frequency of 25MHz, not 50MHz as the table on page 15 would indicate. This
slightly relaxes the requirements of the PCB as the LVDS signals are moving half
as fast as we had thought.

## Contact

David Stockhouse, On-Board Computer Subsystem Lead  
[stockhod@my.erau.edu](mailto:stockhod@my.erau.edu)

Connect on [Facebook](https://www.facebook.com/eaglesaterau/).

