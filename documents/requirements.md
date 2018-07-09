# Requirements for the Cosmic Ray Payload Prototype

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
