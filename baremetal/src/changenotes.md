# Notes on progress to EE4218 Lab 03 adaptations

This document is intended to track my debugging changes and progress as I
attempt to adapt the example lab to fit the EagleSat CRP payload.

### September 25, 2018

#### 10:26 PM  

##### Summary

Began tracking document.

##### Current state of things

Debugging is a challenge because it takes Vivado no less than 15 minutes to
synthesize the VHDL design and generate a bitstream that can be tested on the
FPGA. Each time I make an incremental change to the hardware design to see if it
will break the system I have to wait a quarter of an hour before I can test it.

I'm attempting to make a design that will be able to send data from the FPGA to
the processor in large enough chunks to be useful for retrieval of data from the
CRP sensor interface. Data will be produced at 5MB/s, too fast for most
non-hardware solutions. After attempting for far longer than I should have to
get Xillybus to work flexibly with our design, I decided to go back to a bare
metal design with a direct AXI interface from FPGA to processor. My hope is that
if I get this working, much of the code I had written for Xillybus will transfer
without too much pain. 

The last change I made was to set the master TLAST signal to always be on when
TVALID is on, so that each byte is interpreted as a packet, in accordance with
the ARM AMBA AXI stream specification document retrieved from the source, ARM
Ltd. Earlier I changed the design so that TVALID wouldn't be on the whole time
data was being produced, a closer design to what is required for CRP. 

#### 10:34 PM

Implementation finished, will test on hardware.

#### 10:47 PM

Successful test! I was able to read each word as a single packet, without the
DMA transfer not completing, and that told me some things I needed to know about
the driver. **I need the TLAST signal to go high at the last byte of every
packet, and the packet size *has* to be the same for the FPGA design and the
software.** It seems obvious, but it wasn't for me knowing nothing about the
poorly documented, dynamically generated board support package.

So for CRP design I have to ensure that the packet size is consistent. But it
may work. 

For the next iteration I added a PACKET_SIZE constant and packet_counter signal
to determine when the TLAST signal should go high, rather than just following
TVALID all the time. For the first test I set the system to output 256 words in
4-word packets. 

I still would like to test if the DMA transfer needs to be requested beforehand
for the data to be transferred or if it will transfer the bytes on its own
whether requested or not. But for now I think I can rely on requesting the
transfer before the data is actually produced. 

If this next test is successful I will try re-integrating with a FIFO buffer,
then look at implementing the cascading FIFO idea I had before to combine the
bytes of data being generated simultaneously into packets that can together be
transferred to the processor rather than requiring two DMA controllers.

Implementation complete at 11:03 PM. I will test this.

#### 11:15 PM

Moderately confusing results. The writes performed perfectly, every single byte I
had programmed to output output without delaying the DMA, but for some reason
the first four bytes came through as zeros and I'm not sure why. 

This next run I just changed the system so that it wouldn't depend on TREADY
from the DMA controller, to see if the software can keep up with the hardware
without missing data or if the FIFO is necessary. I want to implement the FIFO
either way, but this is an incremental test to see if I can fix the earlier
problem by chance. 

Started using Git within Atom. Seems very convenient, I hope I can remember to
keep using it.

So the software for this test shouldn't change at all, I've just changed the
hardware to see if the software is slow enough to miss data without a FIFO.
Implementation should be done soon. I should really start doing my other work
while I wait, but at least these tracking messages keep me from having to switch
contexts too often.

Implementation finished at 11:28 PM.

#### 11:51 PM

Unsuccessful test. The DMA wouldn't even complete the first transaction. I
suspect it is because it is missing too much data from the AXI interface.

It is now September 26. I should sleep soon. The next may be my last test of the
night.

#### 12:04 AM

Added FIFO functionality to the design, and ensured resets were occurring
properly for the counters. Hopefully the FIFOs will ensure that the software
never misses bytes and therefore receives a packet a different length than the
software has told the DMA to expect.

I hope initial values in simulations were the cause of the first DMA reads being
invalid. The sims showed that TLAST was being set for the first byte because the
timers were initializing to zero rather than the maximum value. I should
probably at some point take a look at the difference between counting up and
counting down, to see if there is any practical difference in effect, but for
now I will leave everything counting down because that's how the example code
was.

#### 12:24 AM

Test was almost perfect. The data outputted correctly (I changed the input to
the FIFO so that it would count down along with nr_of_writes), but the first
word out was 0 rather than FF, and the last word was 1. Somehow the FIFO is
reading in a 0 as its first value. I will debug tomorrow.

Something else is that the first DMA transfer had to wait a single count before
data was available. Unsure why, other than generic hardware/software timing
delay.

### September 26, 2018

#### 12:47 PM

Working between classes. Collecting ideas.

The next thing I should test is a longer string of bytes being written out.
Closer to the interface for the actual sensor.

Then split it into two streams of data being produced and combine with FIFOs.

Then integrate it with the interface to the actual sensor and the TCL testbench
that I've already written. I can write a testbench IP that will generate data
like the sensor will, with programmable clock offset and the like, potentially
with an input GPIO port so that I wouldn't have to re-synthesize every time that
I want to test a new configuration. That wouldn't be a bad idea in general to
get up and running with different data widths.

I should implement a GPIO input that determines the number of bytes to be sent,
maybe also the packet size, so that it is up to the software that everything be
configurable. 

#### 2:28 PM

Tried to set up a remote Git repo on PRClab, but I don't know how to create a repository to push to from an already existing git repo. 

Now I'm going to start working on the combined interface on the eaglesat-plugsin
repo because I won't know if that is correct until I start simulating anyway, no
risk of breaking anything that doesn't work yet. 

#### 5:52 PM

Back home.

Most of my work so far today was to the combined AXI and CMV interface, which
won't be tested for a little while, but now I'm back to working on the example
AXI project. Regenerating bitstream now for my first tests. 

#### 6:00 PM

Finished implementation. Now to remember what I thought the problem was last
night...

Either a 0 is being written to the FIFO at first, or the output is being read
while the FIFO is still empty.

I did check whether or not the 0 was there from being written or being not
written by initializing all of the DMA's memory to 0xFFFFFFFF instead of 0. The
0 still showed up, so it is being written by the DMA.

For some reason the DMA is still all completing successfully, as every TLAST
must be received properly for the driver not to fail. 

Maybe the data signal is updating offset from the rest of the AXI signals.

I added the reset condition that the nr_of_writes would be set to its max value
rather than 0. I also changed the input to the FIFO to be 0xa5a5a5a5 so that I
can see if the 0 showing up in the wrong spot is due to a 0 initial on the input
or output of the FIFO. This still won't solve the problem if the initial
condition is at fault, so next I'll check with a value being assigned within the
process just as if a counter, but the value will be static, or at least never
crossing 0.

Next I want to try still counting but offsetting the counter so that it passes 0
in the middle.

#### 6:31 PM

Got some dinner and it finished implementing, testing now.

Test has interesting results. The first byte is still writing 0. Gonna see if I
can understand why so I can find a way to mitigate that. 

#### 6:36 PM

I think I'm going to give up on that and just recognize that it'll read an extra
byte for some reason, or maybe I can put in a way to make the first packet one
byte longer and still read in all the data, or maybe just move on.

I'm going to start implementing joining words together in a FIFO to see if
that's practical.

#### 6:45 PM

I made 2 counters, each 16 bits. The LSB counter counts up and the MSB counter
counts down, and they are concatenated together before going into the FIFO. So
I'll see if the software can swap half-words as effectively as it will need to
for the CMV interface. I think I will make the interface shift in two pixels at
a time from each stream so that I don't have to mess too much with any of the
DMA or FIFO width settings. 

#### 7:07 PM

I'm inching towards the CMV interface.

Next test is to see if I can DMA enough memory for an entire image, then see if
the processor can parse all of the data and store it where it needs to go. First
is the large volume of bytes.

#### 7:13 PM

I increased the packet size to 2048 bytes (1 row) and the number of packets to
half an image. I just realized I did that wrong and need to redo it.

#### 7:20 PM

So the slight complication was that I'm sending 4 bytes per word, so basically
all of my sizes needed to be divided by 4. Easy fix. I will test that and write
the corresponding software a little later tonight.

#### 8:34 PM

Set up so that the FPGA generates 2048 * 1088 bytes of data (2048 * 1088 / 4
words) and packetizes them at 2048 bytes. The system works for a while, but the
DMA can only keep up with so many packets before it either fails or something
can't keep up and errors start happening.

The first test I ran, each DMA would start almost immediately after the
previous, except for a few blocking printf statements. The system would
successfully read 150 packets, but the 151st packet consistently failed. Each
DMA would have to wait 10-15 counts for the previous one to finish before it
would start.

Then I introduced a delay, starting at 100 us, and the number of successful
reads went up to 177. I sped up The data dump so that it would print out every
4th word, then that was still too much so I increased it to every 64th word. I
saw that the data went back to the initial value at address 0x16400 (or within
0x40 on either side). This corresponds to 91,136 words, or 356 kB. Unsure why.
I'll keep increasing the delay. My worry on the other side is that the FIFO will
overflow, I actually can't remember how large I made the FIFO so I'll have to
see if it is even capable of overflowing with the amount of data I'm producing.

Increased delay to 100 ms. This was probably too much. I could see the DMA
transfers finishing in real time, and it only made it to 130 before it failed, I
assume because the FIFO overflowed, I don't see how the DMA was moving too fast
for the interface to keep up with. 

A 10 ms delay only makes it to 140 DMA transfers. 

It may be that the TLAST signal for the end of a packet isn't coming when it is
supposed to after a while, for unknown reasons. If that's the reason, it is
shockingly consistent.

#### 9:25 PM

Trying to reduce the packet size to see if that helps. I should try implementing
a dynamic packet size at some point. 

There are skips recognizable in the output data. I just need to track down why
they start happening and apparently keep happening. A section of the log output:

```
... Lots of data of the form XXX0XXXF ...
At 10E00: F2000DFF; At 10E40: F1C00E3F; At 10E80: F1800E7F; At 10EC0: F1400EBF;
At 10F00: F1000EFF; At 10F40: F0C00F3F; At 10F80: F0800F7F; At 10FC0: F0400FBF;
At 11000: F0000FFF; At 11040: ED3B12C4; At 11080: ECFB1304; At 110C0: ECBB1344;
```

Stopped the regular pattern some time after word 0x110000, skipping 0x2C5 = 709
words by the next print point. 

At 11100: EC7B1384; At 11140: EC3B13C4; At 11180: EBFB1404; At 111C0: EBBB1444;
At 11200: EB7B1484; At 11240: C1273ED8; At 11280: C0E73F18; At 112C0: C0A73F58;
At 11300: C0673F98; At 11340: C0273FD8; At 11380: BFE74018; At 113C0: BFA74058;
At 11400: BF674098; At 11440: 95136AEC; At 11480: 94D36B2C; At 114C0: 94936B6C;
At 11500: 94536BAC; At 11540: 94136BEC; At 11580: 93D36C2C; At 115C0: 93936C6C;
At 11600: 93536CAC; At 11640: 674E98B1; At 11680: 670E98F1; At 116C0: 66CE9931;
At 11700: 668E9971; At 11740: 664E99B1; At 11780: 660E99F1; At 117C0: 65CE9A31;
At 11800: 658E9A71; At 11840: 3987C678; At 11880: 3947C6B8; At 118C0: 3907C6F8;
At 11900: 38C7C738; At 11940: 3887C778; At 11980: 3847C7B8; At 119C0: 3807C7F8;
At 11A00: 37C7C838; At 11A40: 0BC1F43E; At 11A80: 0B81F47E; At 11AC0: 0B41F4BE;
At 11B00: 0B01F4FE; At 11B40: 0AC1F53E; At 11B80: 0A81F57E; At 11BC0: 0A41F5BE;
At 11C00: 0A01F5FE; At 11C40: DDFC2203; At 11C80: DDBC2243; At 11CC0: DD7C2283;
At 11D00: DD3C22C3; At 11D40: DCFC2303; At 11D80: DCBC2343; At 11DC0: DC7C2383;
At 11E00: DC3C23C3; At 11E40: B0364FC9; At 11E80: AFF65009; At 11EC0: AFB65049;
At 11F00: AF765089; At 11F40: AF3650C9; At 11F80: AEF65109; At 11FC0: AEB65149;
At 12000: AE765189; At 12040: 82707D8F; At 12080: 82307DCF; At 120C0: 81F07E0F;
At 12100: 81B07E4F; At 12140: 81707E8F; At 12180: 81307ECF; At 121C0: 80F07F0F;
At 12200: 80B07F4F; At 12240: 54A9AB56; At 12280: 5469AB96; At 122C0: 5429ABD6;
At 12300: 53E9AC16; At 12340: 53A9AC56; At 12380: 5369AC96; At 123C0: 5329ACD6;
At 12400: 52E9AD16; At 12440: 26E3D91C; At 12480: 26A3D95C; At 124C0: 2663D99C;
At 12500: 2623D9DC; At 12540: 25E3DA1C; At 12580: 25A3DA5C; At 125C0: 2563DA9C;
At 12600: 2523DADC; At 12640: F91E06E1; At 12680: F8DE0721; At 126C0: F89E0761;
At 12700: F85E07A1; At 12740: F81E07E1; At 12780: F7DE0821; At 127C0: F79E0861;
At 12800: F75E08A1; At 12840: CB5734A8; At 12880: CB1734E8; At 128C0: CAD73528;
At 12900: CA973568; At 12940: CA5735A8; At 12980: CA1735E8; At 129C0: C9D73628;
At 12A00: C9973668; At 12A40: 9D92626D; At 12A80: 9D5262AD; At 12AC0: 9D1262ED;
At 12B00: 9CD2632D; At 12B40: 9C92636D; At 12B80: 9C5263AD; At 12BC0: 9C1263ED;
At 12C00: 9BD2642D; At 12C40: 6FCB9034; At 12C80: 6F8B9074; At 12CC0: 6F4B90B4;
At 12D00: 6F0B90F4; At 12D40: 6ECB9134; At 12D80: 6E8B9174; At 12DC0: 6E4B91B4;
At 12E00: 6E0B91F4; At 12E40: 4205BDFA; At 12E80: 41C5BE3A; At 12EC0: 4185BE7A;
At 12F00: 4145BEBA; At 12F40: 4105BEFA; At 12F80: 40C5BF3A; At 12FC0: 4085BF7A;
At 13000: 4045BFBA; At 13040: 143FEBC0; At 13080: 13FFEC00; At 130C0: 13BFEC40;
At 13100: 137FEC80; At 13140: 133FECC0; At 13180: 12FFED00; At 131C0: 12BFED40;
At 13200: 127FED80; At 13240: E6791986; At 13280: E63919C6; At 132C0: E5F91A06;
At 13300: E5B91A46; At 13340: E5791A86; At 13380: E5391AC6; At 133C0: E4F91B06;
At 13400: E4B91B46; At 13440: B8B3474C; At 13480: B873478C; At 134C0: B83347CC;
At 13500: B7F3480C; At 13540: B7B3484C; At 13580: B773488C; At 135C0: B73348CC;
At 13600: B6F3490C; At 13640: 8AEE7511; At 13680: 8AAE7551; At 136C0: 8A6E7591;
At 13700: 8A2E75D1; At 13740: 89EE7611; At 13780: 89AE7651; At 137C0: 896E7691;
At 13800: 892E76D1; At 13840: 5D27A2D8; At 13880: 5CE7A318; At 138C0: 5CA7A358;
At 13900: 5C67A398; At 13940: 5C27A3D8; At 13980: 5BE7A418; At 139C0: 5BA7A458;
At 13A00: 5B67A498; At 13A40: 2F61D09E; At 13A80: 2F21D0DE; At 13AC0: 2EE1D11E;
At 13B00: 2EA1D15E; At 13B40: 2E61D19E; At 13B80: 2E21D1DE; At 13BC0: 2DE1D21E;
At 13C00: 2DA1D25E; At 13C40: 019CFE63; At 13C80: 015CFEA3; At 13CC0: 011CFEE3;
At 13D00: 00DCFF23; At 13D40: 009CFF63; At 13D80: 005CFFA3; At 13DC0: 001CFFE3;
At 13E00: FFDC0023; At 13E40: D3D42C2B; At 13E80: D3942C6B; At 13EC0: D3542CAB;
At 13F00: D3142CEB; At 13F40: D2D42D2B; At 13F80: D2942D6B; At 13FC0: D2542DAB;
At 14000: D2142DEB; At 14040: A60F59F0; At 14080: A5CF5A30; At 140C0: A58F5A70;
At 14100: A54F5AB0; At 14140: A50F5AF0; At 14180: A4CF5B30; At 141C0: A48F5B70;
At 14200: A44F5BB0; At 14240: 784987B6; At 14280: 780987F6; At 142C0: 77C98836;
At 14300: 77898876; At 14340: 774988B6; At 14380: 770988F6; At 143C0: 76C98936;
At 14400: 76898976; At 14440: 4A83B57C; At 14480: 4A43B5BC; At 144C0: 4A03B5FC;
At 14500: 49C3B63C; At 14540: 4983B67C; At 14580: 4943B6BC; At 145C0: 4903B6FC;
At 14600: 48C3B73C; At 14640: 1CBDE342; At 14680: 1C7DE382; At 146C0: 1C3DE3C2;
At 14700: 1BFDE402; At 14740: 1BBDE442; At 14780: 1B7DE482; At 147C0: 1B3DE4C2;
At 14800: 1AFDE502; At 14840: EEF71108; At 14880: EEB71148; At 148C0: EE771188;
At 14900: EE3711C8; At 14940: EDF71208; At 14980: EDB71248; At 149C0: ED771288;
At 14A00: ED3712C8; At 14A40: C1313ECE; At 14A80: C0F13F0E; At 14AC0: C0B13F4E;
At 14B00: C0713F8E; At 14B40: C0313FCE; At 14B80: BFF1400E; At 14BC0: BFB1404E;
At 14C00: BF71408E; At 14C40: 936C6C93; At 14C80: 932C6CD3; At 14CC0: 92EC6D13;
At 14D00: 92AC6D53; At 14D40: 926C6D93; At 14D80: 922C6DD3; At 14DC0: 91EC6E13;
At 14E00: 91AC6E53; At 14E40: 65A69A59; At 14E80: 65669A99; At 14EC0: 65269AD9;
At 14F00: 64E69B19; At 14F40: 64A69B59; At 14F80: 64669B99; At 14FC0: 64269BD9;
At 15000: 63E69C19; At 15040: 37DFC820; At 15080: 379FC860; At 150C0: 375FC8A0;
At 15100: 371FC8E0; At 15140: 36DFC920; At 15180: 369FC960; At 151C0: 365FC9A0;
At 15200: 361FC9E0; At 15240: 0A19F5E6; At 15280: 09D9F626; At 152C0: 0999F666;
At 15300: 0959F6A6; At 15340: 0919F6E6; At 15380: 08D9F726; At 153C0: 0899F766;
At 15400: 0859F7A6; At 15440: DC5423AB; At 15480: DC1423EB; At 154C0: DBD4242B;
At 15500: DB94246B; At 15540: DB5424AB; At 15580: DB1424EB; At 155C0: DAD4252B;
At 15600: DA94256B; At 15640: AE8E5171; At 15680: AE4E51B1; At 156C0: AE0E51F1;
At 15700: ADCE5231; At 15740: AD8E5271; At 15780: AD4E52B1; At 157C0: AD0E52F1;
At 15800: ACCE5331; At 15840: 80C77F38; At 15880: 80877F78; At 158C0: 80477FB8;
At 15900: 80077FF8; At 15940: 7FC78038; At 15980: 7F878078; At 159C0: 7F4780B8;
At 15A00: 7F0780F8; At 15A40: 5301ACFE; At 15A80: 52C1AD3E; At 15AC0: 5281AD7E;
At 15B00: 5241ADBE; At 15B40: 5201ADFE; At 15B80: 51C1AE3E; At 15BC0: 5181AE7E;
At 15C00: 5141AEBE; At 15C40: 253BDAC4; At 15C80: 24FBDB04; At 15CC0: 24BBDB44;
At 15D00: 247BDB84; At 15D40: 243BDBC4; At 15D80: 23FBDC04; At 15DC0: 23BBDC44;
At 15E00: 237BDC84; At 15E40: F7760889; At 15E80: F73608C9; At 15EC0: F6F60909;
At 15F00: F6B60949; At 15F40: F6760989; At 15F80: F63609C9; At 15FC0: F5F60A09;
At 16000: F5B60A49; At 16040: C9B0364F; At 16080: C970368F; At 160C0: C93036CF;
At 16100: C8F0370F; At 16140: C8B0374F; At 16180: C870378F; At 161C0: C83037CF;
At 16200: C7F0380F; At 16240: 9BEA6415; At 16280: 9BAA6455; At 162C0: 9B6A6495;
At 16300: 9B2A64D5; At 16340: 9AEA6515; At 16380: 9AAA6555; At 163C0: 9A6A6595;
At 16400: FFFFFFFF; At 16440: FFFFFFFF; At 16480: FFFFFFFF; At 164C0: FFFFFFFF;
At 16500: FFFFFFFF; At 16540: FFFFFFFF; At 16580: FFFFFFFF; At 165C0: FFFFFFFF;
At 16600: FFFFFFFF; At 16640: FFFFFFFF; At 16680: FFFFFFFF; At 166C0: FFFFFFFF; 
... Lots of 0xFFFFFFFF ...

I'll consider printing this out to make notes.

#### 9:39 PM

Realized I hard-coded 1024 as the packet size, when it was actually 512
before... So we'll see if this helps or hurts. 

It hurt, it only made it to 117 words transferred. Next test will be a
hard-coded packet size of 128 words. 

#### 10:00 PM

Inadvertantly tested what would happen if the software used a different packet
size than the FPGA used. It wasn't pretty, but worked surprisingly well. The DMA
transfers never finished, in that the busy wait timed out every time, but adding
a new transfer never failed and broke out of the loop. It was bizarre. 

I started a PuTTY log file in the Git repo, so that should help to clarify some
of the things occurring. It also motivates me to make cleaner output and more
helpful print messages. 

#### 10:16 PM

I am lost for a reason why this is happening. 

I realized I can write an extra GPIO flag that will set if the FIFO ever gets
full. I'll do that now. 

#### 10:37 PM

Added an overflow signal output to the FPGA. If the FIFO ever becomes full, the
OVERFLOW flag is set and is never reset until the processor returns to idle
mode, so hopefully the processor can detect the overflow before that occurs. 

#### 11:04 PM

Apparently the overflow is setting after the first 8 DMA transfers. I would say
this is a problem. 

I need to readjust the data creation so that it generates one byte per channel
per 5MHz clock pulse, right now it is generating one word so running twice as
fast as it should be.

If this problem persists, I'll need to switch to scatter gather mode instead of
using simple transfers just so the DMA can keep up. I will look into that
tomorrow, but that's all for tonight.

### September 27, 2018

#### 4:09 PM

Reading the documentation for the BSP DMA driver to figure out how to make
something work in scatter gather mode. I think I'm starting to understand the
driver. 

Scatter gather mode works by providing the DMA a set of objects called buffer
descriptors arranged in a linked list. Each buffer descriptor contains
information about how many bytes to read in and where they should go in memory.
It's not as well documented as I would like.

#### 10:19 PM

Went back to attempting to get something out of watching tutorial videos.
Hopefully this isn't all a waste of time.

#### 12:08 AM

I talked to Dr. Siewert today and that sort of helped instill some confidence,
but I just don't know. I'm so uncertain about everything that I do. This project
is tearing me apart. I sort of got the feeling that I shouldn't be struggling
with this at all. It's making me think I'm not qualified to do this, but then
apparently neither is anyone else on the team. 

### September 28, 2018

#### 7:10 PM

It's the weekend, so I expect to spend many of the upcoming hours working on
this project. 

I spoke with Dr. Davis today about the overflow problem, and he gave me some
ideas about what might be causing my problems, and potentially some ways I can
go about debugging.

#### 8:17 PM

I'm going through the Xilinx/Avnet Hardware Speedway tutorial, I'm pretty much
at the end, after mostly paying attention to all the videos and doing all the
labs with something new. This lab shows how to use the integrated logic analyzer
in vivado, so this will be very good for showing me how to analyze the logic
while it's running on the hardware, as long as I don't need a JTAG programmer to
do that. 

If this is as capable as it should be, I can follow Dr. Davis's advice about
investigating the buses to see if any are underutilized and causing a lot of
latency in the DMA transfers, potentially causing overflows in the FIFO. 

#### 9:07 PM

Okay, this is pretty damn cool. The Integrated Logic Analyzer is the way to go,
I should have found this so long ago. 

#### 11:17 PM

Got it working conditionally using a slower clock time, so we'll see if it'll
work when I put it through the vast amount of data expected for the image
sensor.

#### 11:21 PM

Maybe it was the 2x too fast clock rate that was screwing everything up. It
seems to work without missing a beat now, with 2048 word packets.

#### 11:32 PM

Not exactly perfect. It still can't transfer a whole image without skipping. It
seems that the FIFO gets completely full very early in the program, and that
problem is only avoided if there aren't enough bytes generated to cause it to
overflow in the first place. I will debug more this weekend.

I want to replace the clunky GPIO out system with an AXI lite system. I'll do
that this weekend, the Vivado custom AXI IP peripheral can generate such a
system if I know how to use it. I will figure that out, and then move on to
debugging the interface to see where the FIFO drain latency is coming from.

### September 29, 2018

#### 9:23 AM

Going to start the day by redefining the IP using Vivado's AXI IP generation
wizard. I want to make sure that my use of the AXI ports isn't what's causing
the problems.

AXI stream master for writing out data to processor and AXI lite slave for
configuration registers to read from and write to, rather than the clunky GPIO
stuff.

#### 10:38 PM

For now I went back to the GPIO design because it was already made, but I added
the ILA block to snoop on the AXI communication channel. I haven't aded one for
the other channels out of the DAQ IP yet, but I want to check on the utilization
of the channel first (and I forgot before I started generating the bitstream).
If it gives me confusing results I'll add more snooping channels.

#### 11:15 PM

I couldn't get the ILA core with AXI probes to work properly, perhaps there's
just some necessary configuration that I'm missing, but I added the native port
probe to check the GPIO transfer signals.

#### 11:49 PM

I figured out what the problem was, that I just don't understand using the ILA
in the hardware manager properly. I just had to refresh the netlist file for it
to find the ILA ports. So it's working now, but because I set it up to use
separate ILAs for GPIO and AXI signals I can't view them both at the same time,
so I combined them into a port and am implementing that, but the last time I
implemented a design with ILA cores it took 20 minutes so I'm not hopeful it'll
be quick. 

Something I have noticed so far is that even though I set up the software and
the hardware (I thought) to repeat the data generation, it will only go through
once. The second, every DMA will timeout but they won't stop the next from
running. And no data gets written.

Looking at the ILA traces, the TVALID signal never goes low, the TREADY signal
never goes high, sort of the opposite of what I was expecting for a faulty IP
problem.

I suspect I may need to do some extra work to reset the DMA controller from
software. I will investigate.

#### 12:16

After taking 20 minutes to synthesize, it failed because I had too high a buffer
for the ILA and it was using more than the available system resources. I reduced
it and am starting again, hopefully it won't take quite as long this time.

#### 12:43 PM

Still working on reducing the resource utilization.

I stumbled upon the width of buffer length register option for the DMA IP
configuration. It's set to 14 bits, but has a max value of 23 bits. This would
potentially account for why the maximum transfer I could make happen was 4096
words (16384 = 2^14 bytes). By increasing that single register to 22, which
would allow room for 4 MB transfers, enough for what I need to do in a single
DMA. It might not be elegant to specify a single massive transfer as such, but
it would potentially work. 

#### 1:07 PM

I reduced the FIFO depth from 128k to 16k, so hopefully that will bring the
resource usage down.

#### 2:46 PM

Now the timing constraints aren't met. I'll try to cut down some of the large
buffers to help that. It's close, just fractions of a nanosecond off, so it will
hopefully be fixable. I reduced the FIFO depth to 8k, because if I can fix where
these latencies are happening, the FIFO shouldn't come anywhere close to full
anyway. 

#### 4:04 Pm

I'm starting to get pretty frustrated again. Vivado has some buggy errors that I
don't know how to resolve. 

#### 4:32 PM

The errors were due to the ILA block, so those are not critical and they aren't
the reason that the design is failing to properly execute the DMA. I'll do more
tests to see what's up. 

#### 4:36 PM

Well shit! It seems to work now. Almost. 

#### 7:42 PM

Still not perfect. There's the problem that it's reading a word of all zeros as
the first input to the FIFO, which also appears in simulation and I'm not sure
what is causing. I should be able to debug it and find a reason though because
it's all happening in my code. 

There is something bad happening with the FIFO reset. I will debug. 

Also fixed a problem with TLAST.

#### 8:09 PM

So maybe I don't understand how the FIFO works. I assumed that it was the case
that the output data was always the same as the next value out, but based on
simulation results it looks like the output only appears as the value pulled out
the end after a clock pulse with rd_en high. This is odd, because it means any
system draining the FIFO has to sample the output data a clock cycle after it
asserts rd_en. But now that I got that figured outit shouldn't be a problem
anymore. 

I attempted to solve the problem by triggering TVALID only after detecting
fifo_rden high, it looks like it's working so far.

#### 8:27 PM

It seems to have worked, at least as far as simulations are concerned. I will
implement and test on the hardware with ILA. 

#### 9:02 PM

It's working except TLAST is triggering one byte early, most likely because I
have nr_of_writes counter linked to fifo_rd_en instead of TVALID. I'll fix that
and see if it works after. 

#### 9:11 PM

Simulation works, though to be honest I don't remember the sim not working
before. But I'm implmenting it to test on the hardware, and if it works I'll
move on to implementing it with the actual hardware. 

#### 9:32 PM

Alright, it is working! Things left to do:

* There is not yet a way to detect the DMA being absent for a while and missing
  bytes from the FIFO before it gets full (easy, just add an interrupt flag)
* If a DMA transfer ever fails it hangs up the system and I don't know of a way
  to fix it, except for rebooting or reflashing the FPGA
* It needs to be adapted to take input serial data from the sensor rather than
  count to generate its own output. I am planning to make a sensor-imitator
block to generate the same signals the sensor should for testing.
* The images need to be stored in NV memory, like the SD card
* SPI functionality needs to be added to the software and tested
* 'Command line' interface through the UART. At least some kind of input buffer
  and interrupt-driven way to get input robustly and keep running the program
until the user wants to terminate

Further down the line:

* Plug into sensor and test on actual hardware!
* Figure out actual UART interfacing with COMMS and MDE. Will need an additional
  2 UARTs than the one I use for control through a computer COM port, so I might
need to resort to using soft cores

### September 30, 2018

#### 9:04 AM

Getting started by implementing the CMV interface logic with the current design.

### 9:20 AM

Moved the sources to the existing plugsin repository, as a separate directory
from the xillybus stuff.

Unfortunately that means there's lots of project and IP recreation to deal with,
But I want to transition away from the setup I have been working with and move
to something a little more formal and manageable. 

#### 10:07 PM

Copied system works, now I will start making modifications to make sure it
doesn't break.

#### 10:24 PM

Removed the read channel for the DMA block and the AXIS input for the CMV
interface, so now there is only AXIS output coming from the CMV interface block.

#### 11:28 PM

I think I've successfully adapted the new_latch interface to 16 bit output
words. I will simulate and then implement in hardware with a signal generator.

#### 6:02 PM

Getting back to modifying the system to allow the interface signals to work.

Still need to adjust the AXI triggering.

