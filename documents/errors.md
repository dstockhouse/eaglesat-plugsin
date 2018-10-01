# Vivado Error Log

###Error involving LOC property unconstrained for logical ports.

#### Description

Vivado uses the descriptor 'LOC' to mean the physical location of the port on
the device, in other words, the package pin. This error has been caused by ports
in the design that are left out of the constraints XDC file. In the past it has
been because I changed the number of pins in the block design without updating
the constraints file to reflect it.

## Contact

David Stockhouse, On-Board Computer Subsystem Lead  
[stockhod@my.erau.edu](mailto:stockhod@my.erau.edu)

Connect on [Facebook](https://www.facebook.com/eaglesaterau/).

