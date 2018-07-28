# EagleSat-2 Plugs-In

This repository contains code for the EagleSat-2 project at Embry-Riddle
Aeronautical University, Prescott, plugs-in prototype test. This is a public
repository because having a private repository is non-free, but edits will only
be accepted by members of EagleSat.

The project is intended to run with [Xillybus](http://xillybus.com/) on the
Avnet [Zedboard](http://www.zedboard.org/product/zedboard) housing a Zynq-7020
SoC, to be soon migrated to the
[Microzed](http://www.zedboard.org/product/microzed). Xillybus handles the
communication between the processor (PS) and FPGA (PL) components of the Zynq by
interfacing as a file stream to the processor (running their own Linux distro,
Xillinux) and as an interface to a FIFO buffer to the FPGA. More information can
be found in the [Xillybus documentation](http://xillybus.com/doc).

The C code running on Xillinux has been tested to a limited capacity. The FPGA
configuration for Vivado (2017.4) still has yet to be completed and fully
tested.

## Building

### C Source

The software can only be run successfully on a Zedboard processor system running
Xillinux because there are GPIO and FPGA data stream files that need to exist in
order to be accessed. But it is still useful for remote work to compile in order
to make sure there are no errors or warnings in compilation. To build, type
`make` into any Unix shell while in the project base directory. The `testrun`
executable is created in the same directory and can be invoked from the command
line. The intermediary object files are left in **src/ps/**. There aren't
currently any required libraries not included in most systems.

### VHDL Source

The VHDL source code in this project can't be compiled as easily as the C source
(or not by any means that I'm aware of). Instead we use the Vivado IDE to
synthesize and simulate all of the source code when it is ready. The intention
for this repository is that any miscellaneous files required by a Vivado project
be left out of version control so that they don't clutter all of the commits
with hundreds of files unnecessary to be shared all the time. It's possible in
Vivado to use source files from a directory outside the project directory
without copying the files into the project directory and modifying local copies
instead of the repository source files (as a check box in the source addition
dialog). Directory names of the form "vivado\*/" will be ignored by git. 

Another reason for the necessity of Vivado is that we use intellectual property
(IP) blocks included with Vivado that would be difficult and not as robust for
us to generate on our own. Specifically, there are three IP blocks we have need
of so far: a clock generator, phase-locked loop (PLL), and FIFO buffer.

For testing and debugging smaller modules that do not require Vivado IP, 
[GHDL](https://github.com/ghdl/ghdl) is a workable command-line VHDL simulator.

## TODO

* The FPGA configuration is incomplete. While the LVDS interface to the image
  sensor works as far as limited tests have shown, that module needs to be
tested more rigorously and integrated together with the UART and other
communication modules. 

* The C code running on Linux on the Zynq is in working order but hasn't been
  exhaustively tested. The file I/O operations need to be tested with simulated
data streams to make sure the software correctly handles missed pixels and any
other error conditions we can throw at it. 

* If convenient, a hardware SPI module on the FPGA that can operate more quickly
  than the bit-banged SPI code thrown together for Linux. Alternatively, the
Zynq has a hard SPI hardware interface if we can figure out how to get Linux to
use it directly. I looked into this a few months ago but never found a solution
I was comfortable with. The software SPI is functional when using a
high-tolerance SPI slave, but the camera's SPI interface may be more particular
about clock timing and require a dedicated hardware solution. If nothing else,
it needs to be investigated further.

## Contact

Hilly Paige, Project Manager  
[paigeh@my.erau.edu](mailto:paigeh@my.erau.edu)

David Stockhouse, On-Board Computer Subsystem Lead  
[stockhod@my.erau.edu](mailto:stockhod@my.erau.edu)

Connect on [Facebook](https://www.facebook.com/eaglesaterau/).

