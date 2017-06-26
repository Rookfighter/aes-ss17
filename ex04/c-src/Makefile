CFLAGS=-Wall -g
LDFLAGS=

SRC = gpio.c
OBJ = $(SRC:%.c=%.o)
BIN = $(SRC:%.c=%)
HDR = i2c.h

.PHONY: all clean

all: $(BIN)

clean:
	@rm -f $(OBJ) $(BIN)

%.o: %.c
	@echo "  CC $@"
	@$(CC) $(CFLAGS) -c $<

gpio: $(OBJ)
	@echo "  LD $@"
	@$(CC) $(CFLAGS) $(LDFLAGS)-o $@ $(OBJ)
