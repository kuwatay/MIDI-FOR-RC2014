;
; ゼロサプレス付き10進表示
;
   ORG 100H           ; プログラム開始アドレスを$100に設定

    ; HLに任意の値を設定（テスト用）
    LD   HL, 01203      ; HLに10進数で1203を設定

    CALL PRINT_DEC      ; HLの値を10進数で表示

    LD   HL, 12345      ; HLに10進数で12345を設定

    CALL PRINT_DEC      ; HLの値を10進数で表示

END_PROGRAM:
    JP 0                ; プログラム終了

;---------------------------------------------------------
; サブルーチン：PRINT_DEC
; HLにある値を10進数5桁でコンソールに表示する
; ただし、リーディングゼロは表示しない
;---------------------------------------------------------
PRINT_DEC:
    PUSH HL             ; HLを保存
    LD   DE, 10000      ; 万の位（10000）をDEに設定
    LD   A, 0           ; フラグ（最初の0以外の数字が出たかどうか）を0に初期化
    LD   (ZERO_FLAG), A ; フラグを初期化
    CALL DIVIDE         ; HL ÷ DE (10000)
    CALL PRINT_DIGIT_IF_NOT_ZERO    ; 商（万の位）を表示、リーディングゼロをスキップ

    LD   DE, 1000       ; 千の位（1000）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (1000)
    CALL PRINT_DIGIT_IF_NOT_ZERO    ; 商（千の位）を表示、リーディングゼロをスキップ

    LD   DE, 100        ; 百の位（100）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (100)
    CALL PRINT_DIGIT_IF_NOT_ZERO    ; 商（百の位）を表示、リーディングゼロをスキップ

    LD   DE, 10         ; 十の位（10）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (10)
    CALL PRINT_DIGIT_IF_NOT_ZERO    ; 商（十の位）を表示、リーディングゼロをスキップ

    LD   DE, 1          ; 一の位（1）をDEに設定
    CALL DIVIDE         ; 残りの値 ÷ DE (1)
    CALL DISPLAY_DIGIT   ; 商（一の位）は必ず表示

    POP  HL             ; HLを復元
    RET

;---------------------------------------------------------
; サブルーチン：DIVIDE
; HL ÷ DE を計算し、商をAレジスタ、余りをHLに返す
;---------------------------------------------------------
DIVIDE:
    XOR  A              ; 商（Aレジスタ）を0に初期化
DIV_LOOP:
    ; キャリーフラグをクリアしてからHLとDEを比較・減算
    OR   A              ; キャリーフラグをクリア
    SBC  HL, DE         ; HLからDEを引き算する
    JR   C, DIV_END     ; キャリーがセットされていたら終了
    INC  A              ; 商を増やす
    JR   DIV_LOOP       ; ループを続ける

DIV_END:
    ADD  HL, DE         ; 最後に引きすぎた分を戻す
    RET

;---------------------------------------------------------
; サブルーチン：PRINT_DIGIT_IF_NOT_ZERO
; Aレジスタにある数値が0以外なら表示し、リーディングゼロをスキップ
;---------------------------------------------------------
PRINT_DIGIT_IF_NOT_ZERO:
    PUSH AF             ; Aレジスタを保存
    LD   A, (ZERO_FLAG) ; フラグを確認
    OR   A              ; フラグがセットされているか確認
    JR   NZ, PRINT_DIGIT_IF_NOT_ZERO_1 ; フラグがセットされていたら数字を表示

    POP  AF             ; Aレジスタを復元
    CP   0              ; Aレジスタが0か確認
    JR   NZ, PRINT_DIGIT_IF_NOT_ZERO_2    ; Aが0なら表示せずに戻る
     RET
	 
PRINT_DIGIT_IF_NOT_ZERO_1:
    POP  AF             ; Aレジスタを復元
PRINT_DIGIT_IF_NOT_ZERO_2:
    CALL DISPLAY_DIGIT    ; 数字を表示
    PUSH AF             ; Aレジスタを保存
    LD   A, 1           ; フラグをセット（0以外の数字が表示された）
    LD   (ZERO_FLAG), A  ; フラグを保存
	POP AF
    RET

NO_PRINT:


;---------------------------------------------------------
; サブルーチン：DISPLAY_DIGIT
; Aレジスタにある数値を文字に変換して表示
;---------------------------------------------------------
DISPLAY_DIGIT:
    PUSH AF             ; Aレジスタを保存
    PUSH HL             ; HLレジスタを保存
    ADD  A, 30H         ; AをASCIIコードに変換
    LD   C, 02H         ; BDOS関数 0x02 (コンソール出力)
    LD   E, A           ; 出力する文字をEに格納
    CALL 5H             ; BDOS呼び出し
    POP  HL             ; HLレジスタを復元
    POP  AF             ; Aレジスタを復元
    RET

;---------------------------------------------------------
; メモリ領域
;---------------------------------------------------------
ZERO_FLAG:  DB 0         ; リーディングゼロをスキップするフラグ
