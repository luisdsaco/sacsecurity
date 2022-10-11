# Makefile

ASM = nasm
ASMFLAGS = -f elf64
LINK = gcc -no-pie

.PHONY: all clean install uninstall
all: keyfinder

keyfinder: keyfinder.o
	$(LINK) -o $@ $<

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm keyfinder *.o

install: all
	cp keyfinder $(HOME)

uninstall:
	rm $(HOME)/keyfinder
	
