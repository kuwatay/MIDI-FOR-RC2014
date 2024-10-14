**singlePlayer**

singlePlayer is a program that converts MIDI files parsed by a MIDI parser into assembly code and plays them. It comes with a Makefile that can generate both CP/M COM files and binaries for SCM.

- **For SCM:**
  A program starting from address $8000 (in .hex format) is generated. Copy and paste the text file into the SCM console and run it from address $8000 using the `g` command.

- **For CP/M:**
  A program starting from address $100 (in .com format) is generated. A .txt file in DOWNLOAD.COM format is also generated. Copy and paste it into the CP/M console and execute the resulting file.

Samples of **GreenSleeves** and **Nyancat** are included.
