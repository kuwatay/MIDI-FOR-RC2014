    ORG 100H           ; プログラム開始アドレスを$100に設定

    ; HLに任意の値を設定（テスト用）
    LD   HL, 12345      ; HLに10進数で12345を設定

    CALL PRINT_DEC      ; HLの値を10進数で表示

    LD   HL, 123      ; HLに10進数で123を設定

    CALL PRINT_DEC      ; HLの値を10進数で表示


END_PROGRAM:
    JP 0                ; プログラム終了

;---------------------------------------------------------
; サブルーチン：PRINT_DEC
; HLにある値を10進数5桁でコンソールに表示する
;---------------------------------------------------------
PRINT_DEC:
    PUSH HL             ; HLを保存
    LD   DE, 10000      ; 万の位（10000）をDEに設定
    CALL DIVIDE         ; HL ÷ DE (10000)
    CALL PRINT_DIGIT    ; 商（万の位）を表示

    LD   DE, 1000       ; 千の位（1000）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (1000)
    CALL PRINT_DIGIT    ; 商（千の位）を表示

    LD   DE, 100        ; 百の位（100）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (100)
    CALL PRINT_DIGIT    ; 商（百の位）を表示

    LD   DE, 10         ; 十の位（10）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (10)
    CALL PRINT_DIGIT    ; 商（十の位）を表示

    LD   DE, 1          ; 一の位（1）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (1)
    CALL PRINT_DIGIT    ; 商（一の位）を表示

    POP  HL             ; HLを復元
    RET

;---------------------------------------------------------
; サブルーチン：DIVIDE
; HL ÷ DE を計算し、商をAレジスタ、余りをHLに返す
;---------------------------------------------------------
DIVIDE:
    XOR  A              ; 商（Aレジスタ）を0に初期化
DIV_LOOP:
    OR A    ; Clear carry
    SBC  HL, DE         ; HLからDEを引く
    JR   C, DIV_END     ; HL < DEなら終了
    INC  A              ; 商を増やす
    JR   DIV_LOOP       ; 再度ループ

DIV_END:
    ADD  HL, DE         ; 最後に引きすぎた分を戻す
    RET

;---------------------------------------------------------
; サブルーチン：PRINT_DIGIT
; Aレジスタにある数値を文字に変換して表示
;---------------------------------------------------------
PRINT_DIGIT:
	PUSH HL
    ADD  A, 30H         ; AをASCIIコードに変換
    PUSH AF             ; Aレジスタを保存
    LD   C, 02H         ; BDOS関数 0x02 (コンソール出力)
    LD   E, A           ; 出力する文字をEに格納
    CALL 5H             ; BDOS呼び出し
    POP  AF             ; Aレジスタを復元
	POP HL
    RET
