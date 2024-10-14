**singlePlayer**

singlePlayer is a dedicated program for playing a single song. It pre-processes a MIDI file by parsing it with a MIDI parser, converting it into a data table, and then creating an executable program.
It comes with a Makefile that can generate both CP/M COM files and binaries for SCM.

- **For SCM:**
  A program starting from address $8000 (in .hex format) is generated. Copy and paste the text file into the SCM console and run it from address $8000 using the `g` command.

- **For CP/M:**
  A program starting from address $100 (in .com format) is generated. A .txt file in DOWNLOAD.COM format is also generated. Copy and paste it into the CP/M console and execute the resulting file.

Samples of **GreenSleeves** and **Nyancat** are included.
