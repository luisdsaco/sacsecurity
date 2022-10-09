# Makefile

ASM = nasm
ASMFLAGS = -f elf64
LINK = ld

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
	
