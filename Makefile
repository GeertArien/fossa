AS = nasm
LD = ld
ASFLAGS = -f elf64

program: main.o dict.o lib.o
	$(LD) -o program main.o dict.o lib.o

lib.o: lib.asm
	$(AS) $(ASFLAGS) -o lib.o lib.asm

dict.o: dict.asm
	$(AS) $(ASFLAGS) -o dict.o dict.asm

main.o: main.asm
	$(AS) $(ASFLAGS) -o main.o main.asm

clean:
	rm main.o dict.o lib.o program

help:
	echo 'This is the help'

.PHONY: clean