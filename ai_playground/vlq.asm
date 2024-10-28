            .ORG    $100 ; プログラムの開始位置

; メインプログラム開始
            LD      DE,DATA1 ; データの先頭アドレスをDEに設定
            CALL    READ_VLQ ; VLQ読み取りサブルーチン呼び出し
            CALL    PRINT_HEX ; HLの内容（読み取ったVLQ値）を16進数で表示
            CALL    PRINT_NEWLINE 

            LD      DE,DATA2 ; データの先頭アドレスをDEに設定
            CALL    READ_VLQ ; VLQ読み取りサブルーチン呼び出し
            CALL    PRINT_HEX ; HLの内容（読み取ったVLQ値）を16進数で表示
            CALL    PRINT_NEWLINE 

            LD      DE,DATA3 ; データの先頭アドレスをDEに設定
            CALL    READ_VLQ ; VLQ読み取りサブルーチン呼び出し
            CALL    PRINT_HEX ; HLの内容（読み取ったVLQ値）を16進数で表示
            CALL    PRINT_NEWLINE 

            LD      DE,DATA4 ; データの先頭アドレスをDEに設定
            CALL    READ_VLQ ; VLQ読み取りサブルーチン呼び出し
            CALL    PRINT_HEX ; HLの内容（読み取ったVLQ値）を16進数で表示
            CALL    PRINT_NEWLINE 
            
            LD      DE,DATA5 ; データの先頭アドレスをDEに設定
            CALL    READ_VLQ ; VLQ読み取りサブルーチン呼び出し
            CALL    PRINT_HEX ; HLの内容（読み取ったVLQ値）を16進数で表示
            CALL    PRINT_NEWLINE 
           ; プログラム終了
            JP      0 
; データ配置
DATA1:      DB      81H,80H,00H ; MIDIのVLQデータ（81h 80h 00h） -> $4000
DATA2:      DB      0C0H,00H ; MIDIのVLQデータ（C0h 00h） -> $2000
DATA3:      DB      81H,00H ; MIDIのVLQデータ（81h 00h） -> $80
DATA4:      DB      83H, 0FFH, 7FH ; MIDIのVLQデータ（83 FF 7F） -> $0000FFFF
DATA5:      DB      0C0H, 80H, 00H ; MIDIのVLQデータ（C0 80 00） -> $00100000

; -------------------------------------
; READ_VLQ - MIDIのVLQデータを読み取る
; 入力:
;  DE - 読み取り開始のメモリアドレス
; 出力:
;  HL - 読み取った値
; -------------------------------------
READ_VLQ:            
            LD      HL,0 ; HLを初期化（結果格納用）

READ_LOOP:           
            LD      A,H  ; CHECK Overflow
            CP      2
            JR      NC,OVERFLOW
SHIFT_LEFT_7:
            SLA     L ; Lレジスタを1ビット左シフト、キャリーに最上位ビットが入る
            RL      H ; Hレジスタを1ビット左シフト、キャリーを最下位ビットに入れる
            SLA     L ; 2ビット目のシフト
            RL      H 
            SLA     L ; 3ビット目のシフト
            RL      H 
            SLA     L ; 4ビット目のシフト
            RL      H 
            SLA     L ; 5ビット目のシフト
            RL      H 
            SLA     L ; 6ビット目のシフト
            RL      H 
            SLA     L ; 7ビット目のシフト
            RL      H 

            LD      A,(DE) ; DEアドレスのデータをAにロード
            AND     7FH ; MSBを除いた7ビットをAに残す
; Aレジスタの値をHLに加算
ADD_A_TO_HL:         
            ADD     A,L ; A + Lの結果をAに格納
            LD      L,A ; 結果をLレジスタに格納
            LD      A,H ; AにHレジスタの値をロード
            ADC     A,0 ; A + キャリーを計算（キャリーがあれば1加算）
            LD      H,A ; 結果をHレジスタに格納
; 読み取ったバイトのMSBが1ならループを継続
            LD      A,(DE) ; DEアドレスのデータをAにロード
            INC     DE ; 次のバイトに進む
            AND     $80 ; MSBが1か確認
            JR      NZ,READ_LOOP ; MSBが1ならループを継続

            RET      ; HLに累積値を保持してリターン

OVERFLOW:
; 改行を表示
            LD      DE,OVFL_MSG 
            LD      C,9 
            CALL    5 
            JP      0            
OVFL_MSG:   DB      'LVQ overflow',0x0D,0x0A,'$'

;---------------------------------------------------------
; サブルーチン：PRINT_HEX
; HLにある値を16進数4桁でコンソールに表示する
;---------------------------------------------------------
PRINT_HEX:           
            PUSH    HL ; HLを保存

; 上位バイト（H）を16進数に変換して表示
            LD      A,H ; HレジスタをAにコピー
            CALL    PRINT_HEX_BYTE ; Aに格納された1バイトを16進数表示

            POP     HL ; HLを復元
; 下位バイト（L）を16進数に変換して表示
            LD      A,L ; LレジスタをAにコピー
            CALL    PRINT_HEX_BYTE ; Aに格納された1バイトを16進数表示

            RET      

;---------------------------------------------------------
; サブルーチン：PRINT_HEX_BYTE
; Aにある値を16進数2桁でコンソールに表示する
;---------------------------------------------------------
PRINT_HEX_BYTE:      
            PUSH    AF ; Aレジスタを保存
;   PUSH BC            ; BCを保存

; 上位4ビットをシフトして取得
            RRA      
            RRA      
            RRA      
            RRA      
            AND     0FH ; 下位4ビットを残す
            CALL    PRINT_HEX_DIGIT ; 上位4ビットを表示

; 下位4ビットを取得
            POP     AF ; Aレジスタを復元
            AND     0FH ; 下位4ビットを残す
            CALL    PRINT_HEX_DIGIT ; 下位4ビットを表示

;    POP  BC            ; BCを復元
            RET      

;---------------------------------------------------------
; サブルーチン：PRINT_HEX_DIGIT
; Aレジスタの4ビットの値を16進数で表示
;---------------------------------------------------------
PRINT_HEX_DIGIT:     
            ADD     A,30H ; 数値を文字コードに変換
            CP      3AH ; 9を超えた場合、A～Fにする
            JR      C,OUTPUT_DIGIT 
            ADD     A,07H ; A～Fを表示するために調整

OUTPUT_DIGIT:        
;  PUSH AF            ; Aレジスタを保存
            LD      C,02H ; BDOS関数 0x02 (コンソール出力)
            LD      E,A ; 出力する文字をEに格納
            CALL    5H ; BDOS呼び出し
;    POP  AF            ; Aレジスタを復元
            RET      

PRINT_NEWLINE:       
; 改行を表示
            LD      DE,CRLF 
            LD      C,9 
            CALL    5 
            RET      

CRLF:       DB      0x0D,0x0A,"$" 
