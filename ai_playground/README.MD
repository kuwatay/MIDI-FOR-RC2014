1. **echo.asm**  
   A simple echo program. It reads user input and echoes the entered charactor back to the console. It uses BDOS calls, leveraging function 1 for console input and function 2 for console output.

2. **hello.asm**  
   A program that displays the message "Hello, World" on the console. It uses BDOS call function 9 to display a predefined string.

3. **memlimit.asm**  
   A program to checks memory limits of CP/M, and print the top address of TPA.

4. **print.asm**  
   A program that outputs characters to the console. It uses BDOS function 2 to output characters one at a time. The program is optimized for continuous output of multiple strings.

5. **printde2.asm**  
   A part of a program that displays decimal numbers stored in the DE register. It implements an algorithm to convert the contents of HL into a displayable format on the console.

6. **printdec.asm**  
   A program that displays the decimal value stored in the HL register on the console. It converts the value in the HL register into a string format and prints it.

7. **readline.asm**  
   A program that reads a line of input from the console and stores it in a buffer. It uses BDOS call function 1 to handle console input.

8. **readmem.asm**  
   A program that reads data from file to memory. It also dislay the contents, thus file must be text, not binary.

9. **readmem1.asm**  
   A program that reads data from file to memory. Unlike readmem.asm, contents of file is not displayed.

10. **vlq.asm**  
   A program that reads data formatted 'variable-length quantity'. VLQ is used to represent delta time in midi data.
   