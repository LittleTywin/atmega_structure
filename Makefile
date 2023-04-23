PROJECT:=talkypump
MCU:=atmega168
F_CPU:=8000000UL

CC=avr-gcc
CFLAGS:=-Wall -Wextra
OPTFLAGS:=
OPTIMIZATION:=1
DEBUGFLAGS:=-Wall -Wextra -g -DDEBUG
SRC = $(wildcard src/*.c)
TARGET=build/release
DEBUGTARGET=build/debug
OBJ=$(patsubst %.c,%.o,$(SRC))

all: $(TARGET)/$(PROJECT).hex

%.hex: %.elf
	avr-objcopy -j .text -j .data -O ihex $^ $@

%.elf: $(OBJ)
	@mkdir -p $(TARGET)
	$(CC) -mmcu=$(MCU) $^ -o  $@

%.o: %.c 
	$(CC) $(CFLAGS) $(OPTFLAGS) -O$(OPTIMIZATION) -mmcu=$(MCU) -DF_CPU=$(F_CPU) -c $^ -o $@

.PRECIOUS: %.elf
.PHONY: clean release debug test

clean:
	@rm -rf build/

release: all

debug:
	$(MAKE) all CFLAGS="$(DEBUGFLAGS)" TARGET=$(DEBUGTARGET)

PROGRAMMER = atmelice_isp
DEVICE = ATmega168
DUDE=avrdude -c $(PROGRAMMER) -p $(DEVICE) -q

EFUSE=0xf9
HFUSE=0xdf
LFUSE=0xe2


dude:
	$(DUDE)

flash-release:
	$(DUDE) -U flash:w:$(TARGET)/$(PROJECT).hex

verify-release:
	$(DUDE) -U flash:v:$(TARGET)/$(PROJECT).hex

flash-debug:
	$(DUDE) -U flash:w:$(DEBUGTARGET)/$(PROJECT).hex
verify-debug:
	$(DUDE) -U flash:v:$(DEBUGTARGET)/$(PROJECT).hex
erase:

fuses-write:
	$(DUDE) -U efuse:w:$(EFUSE):m
	$(DUDE) -U hfuse:w:$(HFUSE):m
	$(DUDE) -U lfuse:w:$(LFUSE):m
hfuse-write:
	$(DUDE) -q -U hfuse:w:$(HFUSE):m
fuses-save:
	@mkdir -p fuses
	$(DUDE) -U efuse:r:fuses/efuse.hex:i
	$(DUDE) -U hfuse:r:fuses/hfuse.hex:i
	$(DUDE) -U lfuse:r:fuses/lfuse.hex:i
flash-erase:
	$(DUDE) -e


