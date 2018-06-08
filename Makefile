CC=gcc
CFLAGS=-g -Wall
LIBS=
DEPS=sensor.h gpio.h generateFilename.h spiControl.h registerAccess.h
SRCS=sensor.c gpio.c generateFilename.c spiControl.c registerAccess.c main.c
OBJS=$(SRCS:.c=.o)
MAIN=testrun

$(MAIN): $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) -o $(MAIN) $(OBJS)

.c.o: $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	$(RM) *.o $(MAIN)
