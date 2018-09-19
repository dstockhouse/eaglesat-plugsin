# Description of interface.vhd

Instead of trying to frame the LVDS output one pixel at a time, why not attempt
to frame the entire 40-bit word (to be compressed to 32 bits)? If we make it so
that the shift register shifts in say 50-60 bits, the first 10-20 are used for
framing of the training data, and then as data is shifted in the position that
the 32-bit word is grabbed from shifts within the whole space. This would
ensure that all the words are as close together as possible, whichever is ahead
of the rest. 

This is just me jotting down my ideas and is in no means intended to be a formal
document.

## Contact

David Stockhouse, On-Board Computer Subsystem Lead  
[stockhod@my.erau.edu](mailto:stockhod@my.erau.edu)

Connect on [Facebook](https://www.facebook.com/eaglesaterau/).

