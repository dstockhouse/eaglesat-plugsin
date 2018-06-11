CC=gcc
CFLAGS=-g -Wall
LIBS=
DEPS=src/ps/sensor.h src/ps/gpio.h src/ps/generateFilename.h src/ps/spiControl.h src/ps/registerAccess.h
SRCS=src/ps/sensor.c src/ps/gpio.c src/ps/generateFilename.c src/ps/spiControl.c src/ps/registerAccess.c src/ps/main.c
OBJS=$(SRCS:.c=.o)
MAIN=testrun

$(MAIN): $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) -o $(MAIN) $(OBJS)

.c.o: $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	$(RM) src/ps/*.o $(MAIN)
