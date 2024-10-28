            .ORG    100h ; プログラムの開始アドレス
START:               
; MIDIファイルの開始アドレスをメモリに保存
            LD      HL,MIDI_START 
            LD      (PARSE_ADDR),HL ; PARSE_ADDRにMIDIファイルの開始アドレスを格納

; ヘッダチャンクのチェック ("MThd" をチェック)
            CALL    CHECK_HEADER 

; チャンクの長さやフォーマット情報を解析して表示
            CALL    PARSE_HEADER 

; トラックチャンクのチェック ("MTrk" をチェック)
            CALL    CHECK_TRACK_HEADER 

; トラックデータの長さを表示
            CALL    PARSE_TRACK_HEADER 

; トラック内のMIDIイベントをパースして表示
            CALL    PARSE_TRACK_EVENTS 

; プログラム終了
            JP      0 

CHECK_HEADER:        
; "MThd"がメモリに存在するか確認
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      A,(HL) 
            CP      "M" 
            JR      NZ,ERROR 
            INC     HL 
            LD      A,(HL) 
            CP      "T" 
            JR      NZ,ERROR 
            INC     HL 
            LD      A,(HL) 
            CP      "h" 
            JR      NZ,ERROR 
            INC     HL 
            LD      A,(HL) 
            CP      "d" 
            JR      NZ,ERROR 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 新しいアドレスをPARSE_ADDRに保存
            RET      

ERROR:               
; エラーメッセージを表示し終了
            LD      DE,ERROR_MSG 
            LD      C,9 ; BDOS Print String
            CALL    5 
            JP      EXIT 
ERROR_MSG:  DB      "ERROR: Invalid MIDI file$" 

;---------------------------------------------------------
; 
;　parse MIDI Header
; 
PARSE_HEADER:        
; "size"のラベル表示
            LD      DE,SIZE_LABEL 
            CALL    PRINT_STRING 

; チャンク長の表示（4バイト）
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      A,(HL) ; チャンク長の最上位バイト
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      A,(HL) 
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      A,(HL) 
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      A,(HL) 
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            CALL    PRINT_NEWLINE 

; "type"のラベル表示
            LD      DE,TYPE_LABEL 
            CALL    PRINT_STRING 

; フォーマットタイプの表示（2バイト）
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      D,(HL) 
            INC     HL 
            LD      E,(HL) 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            LD      HL,DE 
            CALL    PRINT_HEX 
            CALL    PRINT_NEWLINE 

; "#Track"のラベル表示
            LD      DE,TRACK_LABEL 
            CALL    PRINT_STRING 

; トラック数の表示（2バイト）
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      D,(HL) 
            INC     HL 
            LD      E,(HL) 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            LD      HL,DE 
            CALL    PRINT_HEX 
            CALL    PRINT_NEWLINE 

; "Time Divison"のラベル表示
            LD      DE,TD_LABEL 
            CALL    PRINT_STRING 

; Time Divisionの表示（2バイト）
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      D,(HL) 
            INC     HL 
            LD      E,(HL) 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            LD      HL,DE 
            CALL    PRINT_HEX 
            CALL    PRINT_NEWLINE 
; 
            RET      
; 
SIZE_LABEL: DB      "Header size:","$" 
TYPE_LABEL: DB      "MIDI Type:","$" 
TRACK_LABEL: DB     "#Tracks:","$" 
TD_LABEL:   DB      "Time Division:","$" 

;---------------------------------------------------------
; 
;　parse Track
; 
CHECK_TRACK_HEADER:  
; "MTrk"がメモリに存在するか確認
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      A,(HL) 
            CP      "M" 
            JR      NZ,ERROR_Track 
            INC     HL 
            LD      A,(HL) 
            CP      "T" 
            JR      NZ,ERROR_Track 
            INC     HL 
            LD      A,(HL) 
            CP      "r" 
            JR      NZ,ERROR_Track 
            INC     HL 
            LD      A,(HL) 
            CP      "k" 
            JR      NZ,ERROR_Track 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 新しいアドレスをPARSE_ADDRに保存
            RET      

PARSE_TRACK_HEADER:  
; トラックの長さ（4バイト）を表示
            LD      DE,TRACK_LENGTH_LABEL 
            CALL    PRINT_STRING 

; アドレス保存 (その場でスタック操作)
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      A,(HL) ; トラック長の最上位バイト
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      A,(HL) 
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      A,(HL) 
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      A,(HL) 
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            CALL    PRINT_NEWLINE 
            RET      
; 
ERROR_TRACK:         
; エラーメッセージを表示し終了
            LD      DE,ERROR_MSG_Track 
            LD      C,9 ; BDOS Print String
            CALL    5 
            JP      EXIT 
ERROR_MSG_TRACK: DB "ERROR: Invalid MIDI Track$" 

; parse delta time
PARSE_DELTA_TIME:    
; デルタタイムをパースして表示
            LD      DE,DELTA_LABEL 
            CALL    PRINT_STRING 

; デルタタイムの値を可変長エンコードからデコード
            LD      DE,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            CALL    READ_VLQ 
            CALL    PRINT_HEX 
            LD      (PARSE_ADDR),DE ;更新されたアドレスをPARSE_ADDRに保存

            RET      
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
            LD      A,H ; CHECK Overflow
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
OVFL_MSG:   DB      "LVQ overflow",0x0D,0x0A,"$" 

PARSE_TRACK_EVENTS:  
; トラック内のMIDIイベントを順次パース
; まずデルタタイムを表示
            CALL    PARSE_DELTA_TIME 
; 
; ステータスバイトの確認
            LD      HL,(PARSE_ADDR) 
            LD      A,(HL) 
            CP      80h ; ステータスバイトは80h以上
            JP      C,ERROR_Track ; ステータスバイトでなければエラー
            CALL    PRINT_EVENT_TYPE 
            INC     HL ; 次のバイトへ

; MIDIイベントの種類によってパースする方法を変える
; ここでは基本的なノートオン（90h〜9Fh）のイベントを処理
            LD      A,(HL) 
            CP      90h ; ノートオンイベント (90h)
            JR      NZ,CHECK_OTHER_EVENTS 
; ノートオンイベントの処理
            CALL    PARSE_NOTE_ON 
            JP      NEXT_EVENT 

CHECK_OTHER_EVENTS:  
; ここで他のイベントを処理（例: ノートオフ、コントロールチェンジなど）
            JP      NEXT_EVENT 

NEXT_EVENT:          
; 次のMIDIイベントに進む
            INC     HL 
            LD      (PARSE_ADDR),HL 
            RET      

PARSE_NOTE_ON:       
; ノートオンイベントのパース
; アドレスをメモリから取得し、2バイト（ノート番号とベロシティ）を表示
            LD      HL,(PARSE_ADDR) 
            INC     HL ; ステータスバイトの次のバイト（ノート番号）
            LD      A,(HL) 
            LD      DE,NOTE_LABEL 
            CALL    PRINT_STRING 
            CALL    PRINT_HEX 
            INC     HL ; ベロシティ
            LD      A,(HL) 
            LD      DE,VELOCITY_LABEL 
            CALL    PRINT_STRING 
            CALL    PRINT_HEX 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            CALL    PRINT_NEWLINE 
            RET      

PRINT_EVENT_TYPE:    
            PUSH    HL 
; ステータスバイトを表示 (イベントの種類を識別)
            LD      DE,EVENT_LABEL 
            CALL    PRINT_STRING 
            CALL    PRINT_HEX_BYTE 
            CALL    PRINT_NEWLINE 
            POP     HL 
            RET      
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
            PUSH    HL 
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
            POP     HL 
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

PRINT_STRING:        
; DEレジスタで指された文字列を表示
            LD      C,9 
            CALL    5 
            RET      

EXIT:                
            JP      0 


; データ領域
PARSE_ADDR: DW      0 ; パース中のアドレスを格納するメモリ領域
TRACK_LENGTH_LABEL: DB "Track length:","$" 
DELTA_LABEL: DB     "Delta time:","$" 
EVENT_LABEL: DB     "Event:","$" 
NOTE_LABEL: DB      "Note:",0Dh,0Ah,"$" 
VELOCITY_LABEL: DB  "Velocity:",0Dh,0Ah,"$" 
HEX_STRING: DB      "00","$" ; 16進数表示用の文字列
CRLF:       DB      0Dh,0Ah,"$" 

MIDI_START:          
            DB      "MThd",0x00,0x00,0x00,0x06,0x00,0x01,0x00,0x02,0x01,0x80 ; 00000000
            DB      "MTrk",0x00,0x00,0x01,0x38,0x00,0xFF,0x58,0x04,0x04,0x02,0x18,0x08,0x00,0xFF ; 00000010
            DB      0x51,0x03,0x08,0x52,0xAE,0x00,0xFF,0x03,0x0E,0x45,0x6C,0x65,0x63,0x74,0x72,0x69 ; 00000020
            DB      0x63,0x20,0x50,0x69,0x61,0x6E,0x6F,0x00,0xC0,0x00,0x00,0x90,0x21,0x32,0x60,0x80 ; 00000030
            DB      0x21,0x00,0x00,0x90,0x22,0x32,0x60,0x80,0x22,0x00,0x00,0x90,0x23,0x32,0x60,0x80 ; 00000040
            DB      0x23,0x00,0x00,0x90,0x24,0x32,0x60,0x80,0x24,0x00,0x00,0x90,0x25,0x32,0x60,0x80 ; 00000050
            DB      0x25,0x00,0x00,0x90,0x26,0x32,0x60,0x80,0x26,0x00,0x00,0x90,0x27,0x32,0x60,0x80 ; 00000060
            DB      0x27,0x00,0x00,0x90,0x28,0x32,0x60,0x80,0x28,0x00,0x00,0x90,0x29,0x32,0x60,0x80 ; 00000070
            DB      0x29,0x00,0x00,0x90,0x2A,0x32,0x60,0x80,0x2A,0x00,0x00,0x90,0x2B,0x32,0x60,0x80 ; 00000080
            DB      0x2B,0x00,0x00,0x90,0x2C,0x32,0x60,0x80,0x2C,0x00,0x00,0x90,0x2D,0x32,0x60,0x80 ; 00000090
            DB      0x2D,0x00,0x00,0x90,0x2E,0x32,0x60,0x80,0x2E,0x00,0x00,0x90,0x2F,0x32,0x60,0x80 ; 000000A0
            DB      0x2F,0x00,0x00,0x90,0x30,0x32,0x60,0x80,0x30,0x00,0x00,0x90,0x31,0x32,0x60,0x80 ; 000000B0
            DB      0x31,0x00,0x00,0x90,0x32,0x32,0x60,0x80,0x32,0x00,0x00,0x90,0x33,0x32,0x60,0x80 ; 000000C0
            DB      0x33,0x00,0x00,0x90,0x34,0x32,0x60,0x80,0x34,0x00,0x00,0x90,0x35,0x32,0x60,0x80 ; 000000D0
            DB      0x35,0x00,0x00,0x90,0x36,0x32,0x60,0x80,0x36,0x00,0x00,0x90,0x37,0x32,0x60,0x80 ; 000000E0
            DB      0x37,0x00,0x00,0x90,0x38,0x32,0x60,0x80,0x38,0x00,0x00,0x90,0x39,0x32,0x60,0x80 ; 000000F0
            DB      0x39,0x00,0x00,0x90,0x3A,0x32,0x60,0x80,0x3A,0x00,0x00,0x90,0x3B,0x32,0x60,0x80 ; 00000100
            DB      0x3B,0x00,0x00,0x90,0x3C,0x32,0x60,0x80,0x3C,0x00,0x00,0x90,0x3D,0x32,0x60,0x80 ; 00000110
            DB      0x3D,0x00,0x00,0x90,0x3E,0x32,0x60,0x80,0x3E,0x00,0x00,0x90,0x3F,0x32,0x60,0x80 ; 00000120
            DB      0x3F,0x00,0x00,0x90,0x3F,0x32,0x60,0x80,0x3F,0x00,0x00,0x90,0x3F,0x32,0x60,0x80 ; 00000130
            DB      0x3F,0x00,0x00,0x90,0x3F,0x32,0x60,0x80,0x3F,0x00,0x00,0xFF,0x2F,0x00,0x4D,0x54 ; 00000140
            DB      0x72,0x6B,0x00,0x00,0x00,0x3B,0x00,0xFF,0x03,0x0F,0x41,0x63,0x6F,0x75,0x73,0x74 ; 00000150
            DB      0x69,0x63,0x20,0x47,0x75,0x69,0x74,0x61,0x72,0x00,0xC1,0x1B,0x99,0x40,0x91,0x40 ; 00000160
            DB      0x32,0x60,0x81,0x40,0x00,0x00,0x91,0x41,0x32,0x60,0x81,0x41,0x00,0x00,0x91,0x42 ; 00000170
            DB      0x32,0x60,0x81,0x42,0x00,0x00,0x91,0x43,0x32,0x60,0x81,0x43,0x00,0x00,0xFF,0x2F ; 00000180
            DB      0x00 ; 00000190


            DB      "MThd",00,00,00,06,00,00,00,01,01,80H ; サンプルのMIDIヘッダ
            DB      "MTrk",00,00,08,0d0h,00,0ffh,58h,04,04,02,18h,08,00,0ffh 
            DB      72h,6bh,00,00,08,0d0h,00h,0ffh,58h,04,04,02,18h,08h,00,0ffh 
