    ORG 0x100       ; Start of the program at 0x100 (standard for CP/M)

    LD  DE, message ; Load address of the string into DE
    LD  C, 9        ; BDOS function 9 - print string
    CALL 5          ; Call BDOS

    RET             ; Return to CP/M

message:
    DB 'Hello, World!$'  ; The message string terminated with a '$' sign
