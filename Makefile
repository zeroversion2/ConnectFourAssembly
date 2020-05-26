connectfour: c4.o c4startc.o c4lib.o
	gcc -no-pie -g -o connectfour c4.o c4startc.o c4lib.o

c4.o: c4.asm
	yasm -Worphan-labels -g dwarf2 -f elf64 c4.asm -l c4.lst

c4lib.o: c4lib.asm
	yasm -Worphan-labels -g dwarf2 -f elf64 c4lib.asm -l c4.lst

c4startc.o: c4startc.c
	gcc -g -c -o c4startc.o c4startc.c

ctoasm: c4startc.c
	gcc -g -S -masm=intel -o c4startc.asm c4startc.c

clean: 
	rm -f connectfour
	rm -f c4.o 
	rm -f c4.lst
	rm -f c4lib.o
	rm -f c4startc.o
	rm -f c4startc.asm 

