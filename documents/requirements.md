# Requirements for the Cosmic Ray Payload Prototype

EagleSat-2 is loosely following top-design design principles, so the first step
is defining system requirements. What I mean by "loosely" following is that the
satellite is payload-centered, so the objective of the payload is very vaguely
"to achieve as much science as possible within reason." Those in charge of the
payload design decide what is attainable and what hardware/software it would
take to do it, then determine what support systems (power, attitude control,
data rates) are needed and pass that information to the subsystems. The
subsystems (COMMS, OBC among them) then define their systems around what they
would need in order to service that design, determine what additional support
systems are needed for them, and propagate their needs to the other subsystems.
The result is a fluid, circular chain of propagation between all of the
subsystems based around attempting to flexibly service the needs of the
payloads. So rather than have power supply, data rates and other important
aspects of the design be requirements for the payload, most of the payload
requirements are determined by the science desired, and relevant needs to meet
those requirements propagate to the subsystems to form their requirements. 

The requirements listed here are requirements on the computer system responsible
for controlling the Cosmic Ray Payload prototype. 

The system shall...
* fit within the cubesat structure used on the balloon.
* interface with the CMV2000 CMOS APS as described by its device datasheet.
* interface with the communication module through Universal Asynchronous
  Receiver/Transmitter (UART). 
* capture images sequentially with 5 second exposure for the duration of the
  balloon flight.
* store entire captured images in nonvolatile memory.
* detect when errors have occurred in the process of collecting images and store
  a record of any errors detected.
* send a message to the ground of the status of every image captured, including
  an indication of any errors that occurred.
* communicate with and meet the needs of the Memory Degradation Experiment (MDE)
  through the Serial Peripheral Interface (SPI).

## Contact

David Stockhouse, On-Board Computer Subsystem Lead  
[stockhod@my.erau.edu](mailto:stockhod@my.erau.edu)

Connect on [Facebook](https://www.facebook.com/eaglesaterau/).

