    ORG 0x100        ; CP/Mのプログラム開始アドレス

START:
    ; コマンドラインバッファの読み込み
    LD DE, PARMBUF   ; コマンドラインバッファのアドレスをDEに設定
    LD C, 10         ; BDOS Function 10 - Read Console Buffer
    CALL 5           ; BDOSコール実行

    ; コマンドライン引数を出力
    LD HL, PARMBUF+1 ; コマンドライン引数の先頭文字（バッファの1バイト目は文字数）
    LD B, (HL)  ; Bに引数の文字数を格納
    OR B             ; Bが0ならば引数なし
    JR Z, END        ; 引数がなければ終了
    INC HL

PRINT_LOOP:
    LD A, (HL)       ; HLが指す文字をAにロード
    PUSH HL
    PUSH BC
    LD C, 2          ; BDOS Function 2 - Console Output
    LD E, A          ; 表示する文字をEに格納
    CALL 5           ; BDOSコールで文字を表示
    POP BC
    POP HL
    INC HL           ; 次の文字へ
    DJNZ PRINT_LOOP  ; Bカウンタが0になるまでループ

END:
    JP 0             ; プログラム終了

PARMBUF: 
    DB 128		  ; バッファサイズ
    DS 128           ; コマンドライン引数用のバッファ (128バイト)
