# Makefile

ASM = nasm
ASMFLAGS = -f elf64
LD = gcc
LDFLAGS = -no-pie
INSTALLDIR = /usr/local/bin

.PHONY: all clean install uninstall
all: keyfinder

keyfinder: keyfinder.o
	$(LD) $(LDFLAGS) -o $@ $<

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm keyfinder *.o

install: all
	cp keyfinder $(INSTALLDIR)

uninstall:
	rm $(INSTALLDIR)/keyfinder
	
