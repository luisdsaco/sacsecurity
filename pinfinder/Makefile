# Makefile

ASM = nasm
ASMFLAGS = -f elf64
LD = gcc
LDFLAGS = -no-pie
INSTALLDIR = /usr/local/bin
PROGNAME = pinfinder

.PHONY: all clean install uninstall
all: $(PROGNAME)

$(PROGNAME): $(PROGNAME).o
	$(LD) $(LDFLAGS) -o $@ $<

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm $(PROGNAME) *.o

install: all
	cp $(PROGNAME) $(INSTALLDIR)

uninstall:
	rm $(INSTALLDIR)/$(PROGNAME)
	
