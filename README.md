# EagleSat-2 Plugs-In

This repository contains code for the EagleSat-2 project at Embry-Riddle
Aeronautical University, Prescott, plugs-in prototype test. This is a public
repository because having a private repository is non-free, but edits will only
be accepted by members of EagleSat.

The project is intended to run with [Xillybus](http://xillybus.com/) on a
Zynq-7020 SoC. Xillybus handles the communication between the processor and FPGA
components of the Zynq by interfacig as a file stream to the processor (running
their own Linux distro, Xillinux) and as a FIFO buffer to the FPGA. More
information can be found in the [Xillybus
documentation](http://xillybus.com/doc).

The C code running on Xillinux has been tested to a limited capacity. The FPGA
configuration for Vivado (2017?) still has yet to be completed and fully tested.
The Vivado project directories contain a lot of files for Vivado's use that
aren't necessary for editing for most purposes. 

Currently the project contains several redundant files and lots to be flushed
out, but that will be in the process of being fixed soon.

### TODO

* The FPGA configuration is incomplete. While the LVDS interface to the image
  sensor works as far as limited tests have shown, that module needs to be
tested more rigorously and integrated together with the UART and other
communication modules. 

* FPGA configuration files are kept all over the place. Some early files are in
  the **vhdl** directory, but most of the working VHDL code is buried within the
Vivado project **plugsin_PL** directory. This needs to be more accessible and
less redundant.

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

### Contact

Hilly Paige, Project Manager  
[paigeh@my.erau.edu](mailto:paigeh@my.erau.edu)

David Stockhouse, On-Board Computer Subsystem Lead  
[stockhod@my.erau.edu](mailto:stockhod@my.erau.edu)

Connect on [Facebook](https://www.facebook.com/eaglesaterau/).

