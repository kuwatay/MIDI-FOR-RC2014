            .ORG    100h ; プログラムの開始アドレス
START:               
; MIDIファイルの開始アドレスをメモリに保存
            LD      HL,MIDI_START2
            LD      (PARSE_ADDR),HL ; PARSE_ADDRにMIDIファイルの開始アドレスを格納

; ヘッダチャンクのチェック ("MThd" をチェック)
            CALL    CHECK_HEADER 
; チャンクの長さやフォーマット情報を解析して表示
            CALL    PARSE_HEADER
TRACK:               
            LD      A,1 
            LD      (PARSE_TRACK_NO),A 

TRACK_LOOP:
; Print Track No
            CALL    PRINT_TRACK_NO
            LD      A,(PARSE_TRACK_NO)
            CALL    PRINT_HEX_BYTE
            CALL    PRINT_NEWLINE
            
; トラックチャンクのチェック ("MTrk" をチェック)
            CALL    CHECK_TRACK_HEADER 

; トラックデータの長さを表示
            CALL    PARSE_TRACK_HEADER 
;            JP      0 ;for test

; トラック内のMIDIイベントをパースして表示
            CALL    PARSE_TRACK_EVENTS 
; トラックの終了判定
            LD      A,(PARSE_TRACK_NO)
            LD      HL,NUM_OF_TRACK
            CP     (HL)
            JR      Z,END_TRACK
            INC     A
            LD      (PARSE_TRACK_NO),A
            JR      TRACK_LOOP
; プログラム終了
END_TRACK:
            LD      DE,END_MSG
            LD      C,9
            CALL    5
            JP      0 
END_MSG:    DB      "End Of MIDI File",0DH, 0AH,"$"

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
            LD      (FORMAT_TYPE),HL ; フォーマットタイプを記録
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
            LD      A,E
            LD      (NUM_OF_TRACK),A ; トラック数を記録
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
            LD      (TIME_DIVISION),HL ; Time Divisionを記録
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

; 
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      D,(HL) ; UPPER 16bit
            INC     HL 
            LD      E,(HL) 
            INC     HL 
            LD      (PARSE_ADDR),HL 
            LD      HL,DE 
            CALL    PRINT_HEX 
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      D,(HL) ; LOWER 16bit
            INC     HL 
            LD      E,(HL) 
            INC     HL 
            LD      (PARSE_ADDR),HL 
            LD      HL,DE 
            LD      (PAESE_TRACK_LEN),HL ; ignore upper 16bit
            CALL    PRINT_HEX 
            CALL    PRINT_NEWLINE 
            
            CALL    PRINT_TRACK_END
            LD      HL,(PARSE_ADDR) ; 現在のアドレスをHLにロード
            LD      DE,(PAESE_TRACK_LEN) 
            ADD     HL,DE 
            LD      (PARSE_TRACK_END),HL ; TRACKの最後のアドレス
            CALL    PRINT_HEX 
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
            LD      (PARSE_ADDR),DE ;更新されたアドレスをPARSE_ADDRに保存
            CALL    PRINT_HEX 

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

; 
; トラック内のMIDIイベントを順次パース
; 
PARSE_TRACK_EVENTS:  
            LD      HL,(PARSE_ADDR) 
            CALL    PRINT_HEX 
            CALL    PRINT_SPACE 
; デルタタイムを表示
            LD      DE,(PARSE_ADDR) 
            CALL    PARSE_DELTA_TIME 
            CALL    PRINT_SPACE
;            CALL    PRINT_NEWLINE
; ステータスバイトの確認
            LD      HL,(PARSE_ADDR) 
            CALL    PRINT_HEX 
            CALL    PRINT_SPACE 
            LD      HL,(PARSE_ADDR) 
            LD      A,(HL) 
            INC     HL 
            LD      (PARSE_ADDR),HL 
;            PUSH    AF ; for debug
;            CALL    PRINT_HEX_BYTE ; for debug
;            POP     AF ; for debug
            CP      0FFh 
            JR      Z,SKIP_META_EVENT ; メタイベントの場合はスキップ処理へ
; MIDIイベントの種類によって処理を分ける
            AND     0F0H  ; mask channel no.
            CP      0C0h ; Program Change
            JP      Z,PARSE_P_CHANGE ;   プログラムチェンジの場合
            CP      90h 
            JP      Z,PARSE_NOTE_ON ; ノートオンイベントの場合
            CP      80h 
            JP      Z,PARSE_NOTE_OFF ; ノートオフイベントの場合
;            CALL    PRINT_EVENT_TYPE
; 他のイベントもここで追加可能
            CP      80h ; ステータスバイトは80h以上
            JP      C,ERROR_Track ; ステータスバイトでなければエラー
            JP      EVENT_ERROR

SKIP_META_EVENT:     
            CALL    PRINT_META 
            ;CALL    PRINT_NEWLINE 
; メタイベントをスキップ
            LD      HL,(PARSE_ADDR) 
            LD      A,(HL) ; メタイベントの種類
            INC     HL 
            LD      (PARSE_ADDR),HL 
            CALL    PRINT_HEX_BYTE ; for debug

; メタイベントのデータ長を読み込み、HLを進めてスキップ
            LD      DE,HL 
            CALL    READ_VLQ ; データ長を読み込み、HLに格納
METASKIP_X:
            ADD     HL,DE ; データ長分だけHLを進める
            LD      (PARSE_ADDR),HL 
            CALL    PRINT_NEWLINE 
            JP      NEXT_EVENT 

CHECK_OTHER_EVENTS:  
; ここで他のイベントを処理（例: ノートオフ、コントロールチェンジなど）
            JP      NEXT_EVENT 

EVENT_ERROR: 
            PUSH    AF
            LD      DE,TD_LABEL 
            CALL    PRINT_STRING
            POP     AF
            CALL    PRINT_HEX_BYTE ; for debug
            CALL    PRINT_NEWLINE
            JP      0
EVENT_ERROR_LABEL:
            DB      "Unsopported Event:$"
NEXT_EVENT:          
; 次のMIDIイベントに進む
;            INC     HL
;            LD      (PARSE_ADDR),HL
;            RET
            LD      DE,(PARSE_ADDR) ; トラックの終わりか調べる
            LD      HL,(PARSE_TRACK_END) 
            SBC     HL,DE
            JP      C,EVENT_END 
            JP      Z,EVENT_END
            JP      PARSE_TRACK_EVENTS 
EVENT_END:           
            RET      

PARSE_NOTE_ON:
            CALL    PRINT_NOTEON
            JP      PARSE_NOTE_ONOFF
PARSE_NOTE_OFF:
            CALL    PRINT_NOTEOFF
PARSE_NOTE_ONOFF:    
;            CALL    PRINT_NEWLINE ; ノートオンオフイベントのパース
; アドレスをメモリから取得し、2バイト（ノート番号とベロシティ）を表示
            LD      HL,(PARSE_ADDR) 
            LD      A,(HL) ; ステータスバイトの次のバイト（ノート番号）
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      A,(HL) ; ベロシティ
            CALL    PRINT_HEX_BYTE 
            INC     HL 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            CALL    PRINT_NEWLINE 
            JP      NEXT_EVENT 

PARSE_P_CHANGE:      
            CALL    PRINT_P_CHANGE 
 ;           CALL    PRINT_NEWLINE 
            LD      HL,(PARSE_ADDR) 
            LD      A,(HL) ; ステータスバイトの次のバイト（ノート番号）
            INC     HL 
            LD      (PARSE_ADDR),HL ; 更新されたアドレスをPARSE_ADDRに保存
            CALL    PRINT_HEX_BYTE 
            CALL    PRINT_NEWLINE 
            JP      NEXT_EVENT 

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
            JP      PRINT_STRING 

PRINT_SPACE:         
; 空文字を表示
            LD      DE,SPACE_LABEL 
            JP      PRINT_STRING 

PRINT_TRACK_NO:      
            LD      DE,TRACK_NO_LABEL 
            JP      PRINT_STRING 
PRINT_TRACK_END:      
            LD      DE,TRACK_END_LABEL 
            JP      PRINT_STRING 

PRINT_META: LD      DE,META_LABEL 
            JP      PRINT_STRING 

PRINT_NOTEON: LD    DE,NOTEON_LABEL 
            JP      PRINT_STRING 

PRINT_NOTEOFF: LD   DE,NOTEOFF_LABEL 
            JP      PRINT_STRING 

PRINT_P_CHANGE:      
            LD      DE,P_CHANGE_LABEL 
            JP      PRINT_STRING 

PRINT_STRING:        
; DEレジスタで指された文字列を表示
            LD      C,9 
            CALL    5 
            RET      

EXIT:                
            JP      0 


; データ領域
FORMAT_TYPE: DW     1 ; フォーマットタイプ
NUM_OF_TRACK: DB    1 ; トラック数
TIME_DIVISION: DW   1 ; Time Divison
TRACK_LEN:  DS      32 ; トラックごとの長さ (16*2)
PARSE_ADDR: DW      0 ; パース中のアドレスを格納するメモリ領域
PARSE_TRACK_NO: DB  1 ; パース中のトラック番号
PAESE_TRACK_LEN: DW 0 ; パース中のトラック長
PARSE_TRACK_END: DW 1 ; パース中のトラックの最後

;  表示用ラベル
TRACK_NO_LABEL: DB  "Track #$"
TRACK_LENGTH_LABEL: DB "Track length:$" 
TRACK_END_LABEL: DB "Track End:$" 
DELTA_LABEL: DB     "Delta time:$" 
EVENT_LABEL: DB     "Event:$" 
VELOCITY_LABEL: DB  "Velocity:$" 
P_CHANGE_LABEL: DB  "Program Change:$" 
HEX_STRING: DB      "00","$" ; 16進数表示用の文字列
SPACE_LABEL: DB     " $" 
CRLF:       DB      0Dh,0Ah,"$" 
META_LABEL: DB      "META:$" 
NOTEON_LABEL: DB    "Note ON: $" 
NOTEOFF_LABEL: DB   "Note OFF:$" 

; MIDI Data dump from Untitled(2)
MIDI_START1:         

            DB      0x4D,0x54,0x68,0x64,0x00,0x00,0x00,0x06,0x00,0x00,0x00,0x01,0x01,0x80,0x4D,0x54 ; 00000000
            DB      0x72,0x6B,0x00,0x00,0x02,0xC5,0x00,0xFF,0x58,0x04,0x04,0x02,0x18,0x08,0x00,0xFF ; 00000010
            DB      0x51,0x03,0x12,0x4F,0x80,0x00,0xFF,0x03,0x0B,0x47,0x72,0x61,0x6E,0x64,0x20,0x50 ; 00000020
            DB      0x69,0x61,0x6E,0x6F,0x00,0xC0,0x00,0x00,0x90,0x49,0x32,0x00,0x90,0x31,0x32,0x00 ; 00000030
            DB      0x90,0x29,0x32,0x60,0x90,0x3D,0x32,0x60,0x80,0x49,0x00,0x00,0x80,0x3D,0x00,0x00 ; 00000040
            DB      0x90,0x48,0x32,0x00,0x90,0x41,0x32,0x60,0x80,0x41,0x00,0x00,0x80,0x48,0x00,0x00 ; 00000050
            DB      0x90,0x49,0x32,0x00,0x90,0x44,0x32,0x60,0x80,0x44,0x00,0x00,0x90,0x41,0x32,0x60 ; 00000060
            DB      0x80,0x49,0x00,0x00,0x80,0x41,0x00,0x00,0x90,0x48,0x32,0x00,0x90,0x3D,0x32,0x60 ; 00000070
            DB      0x80,0x29,0x00,0x00,0x80,0x31,0x00,0x00,0x80,0x3D,0x00,0x00,0x80,0x48,0x00,0x00 ; 00000080
            DB      0x90,0x50,0x32,0x00,0x90,0x30,0x32,0x00,0x90,0x27,0x32,0x60,0x90,0x3C,0x32,0x60 ; 00000090
            DB      0x80,0x3C,0x00,0x00,0x90,0x41,0x32,0x60,0x80,0x41,0x00,0x00,0x90,0x44,0x32,0x60 ; 000000A0
            DB      0x80,0x50,0x00,0x00,0x80,0x44,0x00,0x00,0x90,0x50,0x32,0x00,0x90,0x41,0x32,0x60 ; 000000B0
            DB      0x80,0x41,0x00,0x00,0x80,0x50,0x00,0x00,0x90,0x50,0x32,0x00,0x90,0x3C,0x32,0x60 ; 000000C0
            DB      0x80,0x27,0x00,0x00,0x80,0x30,0x00,0x00,0x80,0x3C,0x00,0x00,0x80,0x50,0x00,0x00 ; 000000D0
            DB      0x90,0x52,0x32,0x00,0x90,0x2E,0x32,0x00,0x90,0x25,0x32,0x60,0x90,0x3A,0x32,0x60 ; 000000E0
            DB      0x80,0x52,0x00,0x00,0x80,0x3A,0x00,0x00,0x90,0x50,0x32,0x00,0x90,0x41,0x32,0x60 ; 000000F0
            DB      0x80,0x41,0x00,0x00,0x80,0x50,0x00,0x00,0x90,0x52,0x32,0x00,0x90,0x46,0x32,0x60 ; 00000100
            DB      0x80,0x46,0x00,0x00,0x80,0x52,0x00,0x00,0x90,0x54,0x32,0x00,0x90,0x41,0x32,0x60 ; 00000110
            DB      0x80,0x41,0x00,0x00,0x80,0x54,0x00,0x00,0x90,0x55,0x32,0x00,0x90,0x3A,0x32,0x60 ; 00000120
            DB      0x80,0x25,0x00,0x00,0x80,0x2E,0x00,0x00,0x80,0x3A,0x00,0x00,0x80,0x55,0x00,0x00 ; 00000130
            DB      0x90,0x50,0x32,0x00,0x90,0x2C,0x32,0x00,0x90,0x24,0x32,0x60,0x90,0x38,0x32,0x60 ; 00000140
            DB      0x80,0x38,0x00,0x00,0x90,0x41,0x32,0x60,0x80,0x41,0x00,0x00,0x90,0x44,0x32,0x60 ; 00000150
            DB      0x80,0x50,0x00,0x00,0x80,0x44,0x00,0x00,0x90,0x4D,0x32,0x00,0x90,0x41,0x32,0x60 ; 00000160
            DB      0x80,0x41,0x00,0x00,0x90,0x38,0x32,0x60,0x80,0x24,0x00,0x00,0x80,0x2C,0x00,0x00 ; 00000170
            DB      0x80,0x4D,0x00,0x00,0x80,0x38,0x00,0x00,0x90,0x52,0x32,0x00,0x90,0x2A,0x32,0x00 ; 00000180
            DB      0x90,0x22,0x32,0x60,0x90,0x36,0x32,0x60,0x80,0x52,0x00,0x00,0x80,0x36,0x00,0x00 ; 00000190
            DB      0x90,0x50,0x32,0x00,0x90,0x3D,0x32,0x60,0x80,0x3D,0x00,0x00,0x80,0x50,0x00,0x00 ; 000001A0
            DB      0x90,0x52,0x32,0x00,0x90,0x42,0x32,0x60,0x80,0x42,0x00,0x00,0x80,0x52,0x00,0x00 ; 000001B0
            DB      0x90,0x54,0x32,0x00,0x90,0x3D,0x32,0x60,0x80,0x3D,0x00,0x00,0x80,0x54,0x00,0x00 ; 000001C0
            DB      0x90,0x55,0x32,0x00,0x90,0x36,0x32,0x60,0x80,0x22,0x00,0x00,0x80,0x2A,0x00,0x00 ; 000001D0
            DB      0x80,0x36,0x00,0x00,0x80,0x55,0x00,0x00,0x90,0x50,0x32,0x00,0x90,0x29,0x32,0x00 ; 000001E0
            DB      0x90,0x20,0x32,0x60,0x90,0x35,0x32,0x60,0x80,0x50,0x00,0x00,0x80,0x35,0x00,0x00 ; 000001F0
            DB      0x90,0x4E,0x32,0x00,0x90,0x3C,0x32,0x60,0x80,0x3C,0x00,0x00,0x80,0x4E,0x00,0x00 ; 00000200
            DB      0x90,0x4D,0x32,0x00,0x90,0x41,0x32,0x60,0x80,0x41,0x00,0x00,0x90,0x3C,0x32,0x60 ; 00000210
            DB      0x80,0x4D,0x00,0x00,0x80,0x3C,0x00,0x00,0x90,0x49,0x32,0x00,0x90,0x35,0x32,0x60 ; 00000220
            DB      0x80,0x20,0x00,0x00,0x80,0x29,0x00,0x00,0x80,0x35,0x00,0x00,0x80,0x49,0x00,0x00 ; 00000230
            DB      0x90,0x4D,0x32,0x00,0x90,0x27,0x32,0x00,0x90,0x22,0x32,0x60,0x90,0x33,0x32,0x60 ; 00000240
            DB      0x80,0x4D,0x00,0x00,0x80,0x33,0x00,0x00,0x90,0x4B,0x32,0x00,0x90,0x3A,0x32,0x60 ; 00000250
            DB      0x80,0x3A,0x00,0x00,0x80,0x4B,0x00,0x00,0x90,0x46,0x32,0x00,0x90,0x3F,0x32,0x60 ; 00000260
            DB      0x80,0x3F,0x00,0x00,0x90,0x3A,0x32,0x60,0x80,0x46,0x00,0x00,0x80,0x3A,0x00,0x00 ; 00000270
            DB      0x90,0x4D,0x32,0x00,0x90,0x33,0x32,0x60,0x80,0x22,0x00,0x00,0x80,0x27,0x00,0x00 ; 00000280
            DB      0x80,0x33,0x00,0x00,0x80,0x4D,0x00,0x00,0x90,0x4B,0x32,0x00,0x90,0x2C,0x32,0x00 ; 00000290
            DB      0x90,0x24,0x32,0x60,0x90,0x38,0x32,0x60,0x80,0x4B,0x00,0x00,0x80,0x38,0x00,0x00 ; 000002A0
            DB      0x90,0x3C,0x32,0x60,0x80,0x3C,0x00,0x00,0x90,0x44,0x32,0x60,0x80,0x44,0x00,0x00 ; 000002B0
            DB      0x90,0x3C,0x32,0x60,0x80,0x3C,0x00,0x00,0x90,0x38,0x32,0x60,0x80,0x24,0x00,0x00 ; 000002C0
            DB      0x80,0x2C,0x00,0x00,0x80,0x38,0x00,0x00,0xFF,0x2F,0x00 ; 000002D0

            .ORG    1000H
MIDI_START2:          

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







