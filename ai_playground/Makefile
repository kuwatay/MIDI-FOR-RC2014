ASM = sjasmplus
.PHONY: clean
.SUFFIXES: .out .hex .asm .txt
TARGET : mPlayer1.txt

# for CPM (generate .txt file for download.com)
.asm.txt:
	$(ASM) -DCPM=1 $< --lst=$(<:.asm=.lst) --raw=$(<:.asm=.com)
	./file2hex 0 $(<:.asm=.com) $(<:.asm=.txt)

clean:
	rm -f  *.com *.lst  *.txt
