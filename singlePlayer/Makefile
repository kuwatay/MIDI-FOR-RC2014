ASM = sjasmplus
.PHONY: clean
.SUFFIXES: .out .hex .asm .txt
TARGET : nyancat.txt greens.txt nyancat.hex greens.hex

# for SCM (generate .hex file for pasting SCM)
.asm.hex:
	$(ASM) -DSCM=1 $< --lst=$(<:.asm=.scmlst) --raw=$(<:.asm=.bin)
	bin2hex -o0x8000 -b16 $(<:.asm=.bin) > $@

# for CPM (generate .txt file for download.com)
.asm.txt:
	$(ASM) -DCPM=1 $< --lst=$(<:.asm=.cpmlst) --raw=$(<:.asm=.com)
	./file2hex 0 $(<:.asm=.com) $(<:.asm=.txt)

clean:
	rm -f *.bin *.hex *.com *.cpmlst *.scmlst *.txt
