CC=gcc
CFLAGS=-g -Wall
LIBS=
DEPS=src/sensor.h src/gpio.h src/generateFilename.h src/spiControl.h src/registerAccess.h
SRCS=src/sensor.c src/gpio.c src/generateFilename.c src/spiControl.c src/registerAccess.c src/main.c
OBJS=$(SRCS:.c=.o)
MAIN=testrun

$(MAIN): $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) -o $(MAIN) $(OBJS)

.c.o: $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	$(RM) src/*.o $(MAIN)
