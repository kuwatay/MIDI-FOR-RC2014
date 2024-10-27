    ORG 100h        ; プログラムの開始アドレス
START:  
    ; MIDIファイルの開始アドレスをメモリに保存
    LD HL, MIDI_START
    LD (PARSE_ADDR), HL    ; PARSE_ADDRにMIDIファイルの開始アドレスを格納

    ; ヘッダチャンクのチェック ("MThd" をチェック)
    CALL CHECK_HEADER

    ; チャンクの長さやフォーマット情報を解析して表示
    CALL PARSE_HEADER

     ; トラックチャンクのチェック ("MTrk" をチェック)
    CALL CHECK_TRACK_HEADER

    ; トラックデータの長さを表示
    CALL PARSE_TRACK_HEADER

    ; トラック内のMIDIイベントをパースして表示
    ;CALL PARSE_TRACK_EVENTS

   ; プログラム終了
    JP EXIT

CHECK_HEADER:
    ; "MThd"がメモリに存在するか確認
    LD HL, (PARSE_ADDR)   ; 現在のアドレスをHLにロード
    LD A, (HL)
    CP 'M'
    JR NZ, ERROR
    INC HL
    LD A, (HL)
    CP 'T'
    JR NZ, ERROR
    INC HL
    LD A, (HL)
    CP 'h'
    JR NZ, ERROR
    INC HL
    LD A, (HL)
    CP 'd'
    JR NZ, ERROR
    INC HL
    LD (PARSE_ADDR), HL   ; 新しいアドレスをPARSE_ADDRに保存
    RET

ERROR:
    ; エラーメッセージを表示し終了
    LD DE, ERROR_MSG
    LD C, 9    ; BDOS Print String
    CALL 5
    JP EXIT
ERROR_MSG:   DB 'ERROR: Invalid MIDI file$'

;---------------------------------------------------------
;
;　parse MIDI Header 
;
PARSE_HEADER:
    ; "size"のラベル表示
    LD DE, SIZE_LABEL
    CALL PRINT_STRING

    ; チャンク長の表示（4バイト）
    LD HL, (PARSE_ADDR)    ; 現在のアドレスをHLにロード
    LD A, (HL)        ; チャンク長の最上位バイト
    CALL PRINT_HEX_BYTE
    INC HL
    LD A, (HL)
    CALL PRINT_HEX_BYTE
    INC HL
    LD A, (HL)
    CALL PRINT_HEX_BYTE
    INC HL
    LD A, (HL)
    CALL PRINT_HEX_BYTE
    INC HL
	LD (PARSE_ADDR), HL   ; 更新されたアドレスをPARSE_ADDRに保存
    CALL PRINT_NEWLINE
 
    ; "type"のラベル表示
    LD DE, TYPE_LABEL
    CALL PRINT_STRING

    ; フォーマットタイプの表示（2バイト）
  	LD HL, (PARSE_ADDR)    ; 現在のアドレスをHLにロード
	LD D, (HL)
	INC HL
	LD E, (HL)
	INC HL
	LD (PARSE_ADDR), HL   ; 更新されたアドレスをPARSE_ADDRに保存
	LD HL,DE
	CALL PRINT_HEX
    CALL PRINT_NEWLINE

    ; "#Track"のラベル表示
    LD DE, TRACK_LABEL
    CALL PRINT_STRING

    ; トラック数の表示（2バイト）
	LD HL, (PARSE_ADDR)    ; 現在のアドレスをHLにロード
	LD D, (HL)
	INC HL
	LD E, (HL)
	INC HL
	LD (PARSE_ADDR), HL   ; 更新されたアドレスをPARSE_ADDRに保存
	LD HL,DE
	CALL PRINT_HEX
    CALL PRINT_NEWLINE
 
     ; "Time Divison"のラベル表示
    LD DE, TD_LABEL
    CALL PRINT_STRING

    ; Time Divisionの表示（2バイト）
    LD HL, (PARSE_ADDR)    ; 現在のアドレスをHLにロード
	LD D, (HL)
	INC HL
	LD E, (HL)
	INC HL
	LD (PARSE_ADDR), HL   ; 更新されたアドレスをPARSE_ADDRに保存
	LD HL,DE
	CALL PRINT_HEX
	CALL PRINT_NEWLINE
	
    RET
; 
SIZE_LABEL:  DB 'Header size:', '$'
TYPE_LABEL:  DB 'MIDI Type:',  '$'
TRACK_LABEL: DB '#Tracks:',  '$'
TD_LABEL: DB 'Time Division:',  '$'

;---------------------------------------------------------
;
;　parse Track 
;
CHECK_TRACK_HEADER:
    ; "MTrk"がメモリに存在するか確認
    LD HL, (PARSE_ADDR)   ; 現在のアドレスをHLにロード
    LD A, (HL)
    CP 'M'
    JR NZ, ERROR_Track
    INC HL
    LD A, (HL)
    CP 'T'
    JR NZ, ERROR_Track
    INC HL
    LD A, (HL)
    CP 'r'
    JR NZ, ERROR_Track
    INC HL
    LD A, (HL)
    CP 'k'
    JR NZ, ERROR_Track
    INC HL
    LD (PARSE_ADDR), HL   ; 新しいアドレスをPARSE_ADDRに保存
    RET

PARSE_TRACK_HEADER:
    ; トラックの長さ（4バイト）を表示
    LD DE, TRACK_LENGTH_LABEL
    CALL PRINT_STRING

    ; アドレス保存 (その場でスタック操作)
    LD HL, (PARSE_ADDR)    ; 現在のアドレスをHLにロード
    LD A, (HL)        ; トラック長の最上位バイト
    CALL PRINT_HEX_BYTE
    INC HL
    LD A, (HL)
    CALL PRINT_HEX_BYTE
    INC HL
    LD A, (HL)
    CALL PRINT_HEX_BYTE
    INC HL
    LD A, (HL)
    CALL PRINT_HEX_BYTE
    INC HL
	LD (PARSE_ADDR), HL   ; 更新されたアドレスをPARSE_ADDRに保存
    CALL PRINT_NEWLINE
    RET
	
ERROR_Track:
    ; エラーメッセージを表示し終了
    LD DE, ERROR_MSG_Track
    LD C, 9    ; BDOS Print String
    CALL 5
    JP EXIT
ERROR_MSG_Track:   DB 'ERROR: Invalid MIDI Track$'

; parse delta time 
PARSE_DELTA_TIME:
    ; デルタタイムをパースして表示
    LD DE, DELTA_LABEL
    CALL PRINT_STRING

    ; デルタタイムの値を可変長エンコードからデコード
    LD HL, (PARSE_ADDR)    ; 現在のアドレスをHLにロード
    LD B, 0               ; デルタタイムを格納するレジスタペアBC（上位バイトは常に0）
PARSE_DELTA_LOOP:
    LD A, (HL)
    INC HL
    RL B                 ; 7ビット左シフトでBCレジスタに格納
    RL C
    AND 7Fh              ; 上位ビットをマスクして残り7ビットを保存
    OR C
    LD C, A
    CP 80h               ; 最上位ビットがセットされているか？
    JR NC, DELTA_DONE    ; セットされていなければ終了
    JP PARSE_DELTA_LOOP

DELTA_DONE:
    INC HL
	LD (PARSE_ADDR), HL   ; 更新されたアドレスをPARSE_ADDRに保存
    ; パースが完了したらデルタタイムを16進数で表示
	LD HL, BC  ; BCに格納されたデルタタイムを表示
    CALL PRINT_HEX
    CALL PRINT_NEWLINE

    RET
	
PARSE_TRACK_EVENTS:
    ; トラック内のMIDIイベントを順次パース
    ; まずデルタタイムを表示
    CALL PARSE_DELTA_TIME 
	
	; ステータスバイトの確認
    LD HL, (PARSE_ADDR)
    LD A, (HL)
    CP 80h        ; ステータスバイトは80h以上
    JR C, ERROR_Track   ; ステータスバイトでなければエラー
    CALL PRINT_EVENT_TYPE
    INC HL        ; 次のバイトへ

    ; MIDIイベントの種類によってパースする方法を変える
    ; ここでは基本的なノートオン（90h〜9Fh）のイベントを処理
    LD A, (HL)
    CP 90h        ; ノートオンイベント (90h)
    JR NZ, CHECK_OTHER_EVENTS
    ; ノートオンイベントの処理
    CALL PARSE_NOTE_ON
    JP NEXT_EVENT

CHECK_OTHER_EVENTS:
    ; ここで他のイベントを処理（例: ノートオフ、コントロールチェンジなど）
    JP NEXT_EVENT

NEXT_EVENT:
    ; 次のMIDIイベントに進む
    INC HL
    LD (PARSE_ADDR), HL
    RET

PARSE_NOTE_ON:
    ; ノートオンイベントのパース
    ; アドレスをメモリから取得し、2バイト（ノート番号とベロシティ）を表示
    LD HL, (PARSE_ADDR)
    INC HL        ; ステータスバイトの次のバイト（ノート番号）
    LD A, (HL)
    LD DE, NOTE_LABEL
    CALL PRINT_STRING
    CALL PRINT_HEX
    INC HL        ; ベロシティ
    LD A, (HL)
    LD DE, VELOCITY_LABEL
    CALL PRINT_STRING
    CALL PRINT_HEX
    LD (PARSE_ADDR), HL   ; 更新されたアドレスをPARSE_ADDRに保存
    CALL PRINT_NEWLINE
    RET

PRINT_EVENT_TYPE:
    PUSH HL
    ; ステータスバイトを表示 (イベントの種類を識別)
    LD DE, EVENT_LABEL
    CALL PRINT_STRING
    CALL PRINT_HEX_BYTE
    CALL PRINT_NEWLINE
	POP HL
    RET
;---------------------------------------------------------
; サブルーチン：PRINT_HEX
; HLにある値を16進数4桁でコンソールに表示する
;---------------------------------------------------------
PRINT_HEX:
    PUSH HL            ; HLを保存

    ; 上位バイト（H）を16進数に変換して表示
    LD   A, H          ; HレジスタをAにコピー
    CALL PRINT_HEX_BYTE ; Aに格納された1バイトを16進数表示

    POP  HL            ; HLを復元
    ; 下位バイト（L）を16進数に変換して表示
    LD   A, L          ; LレジスタをAにコピー
    CALL PRINT_HEX_BYTE ; Aに格納された1バイトを16進数表示

    RET

;---------------------------------------------------------
; サブルーチン：PRINT_HEX_BYTE
; Aにある値を16進数2桁でコンソールに表示する
;---------------------------------------------------------
PRINT_HEX_BYTE:
    PUSH HL
    PUSH AF            ; Aレジスタを保存
 ;   PUSH BC            ; BCを保存

    ; 上位4ビットをシフトして取得
    RRA
    RRA
    RRA
    RRA
    AND  0FH           ; 下位4ビットを残す
	CALL PRINT_HEX_DIGIT ; 上位4ビットを表示

    ; 下位4ビットを取得
    POP  AF            ; Aレジスタを復元
    AND  0FH           ; 下位4ビットを残す
    CALL PRINT_HEX_DIGIT ; 下位4ビットを表示

;    POP  BC            ; BCを復元
      POP HL
    RET

;---------------------------------------------------------
; サブルーチン：PRINT_HEX_DIGIT
; Aレジスタの4ビットの値を16進数で表示
;---------------------------------------------------------
PRINT_HEX_DIGIT:
    ADD  A, 30H        ; 数値を文字コードに変換
    CP   3AH           ; 9を超えた場合、A～Fにする
    JR   C, OUTPUT_DIGIT
    ADD  A, 07H        ; A～Fを表示するために調整

OUTPUT_DIGIT:
  ;  PUSH AF            ; Aレジスタを保存
    LD   C, 02H        ; BDOS関数 0x02 (コンソール出力)
    LD   E, A          ; 出力する文字をEに格納
    CALL 5H            ; BDOS呼び出し
;    POP  AF            ; Aレジスタを復元
    RET

PRINT_NEWLINE:
    ; 改行を表示
    LD DE, CRLF
    LD C, 9
    CALL 5
    RET

PRINT_STRING:
    ; DEレジスタで指された文字列を表示
    LD C, 9
    CALL 5
    RET

EXIT:
    JP 0
    ; BDOSコールでプログラム終了
    LD C, 0
    JP 5


; データ領域
PARSE_ADDR:  DW 0       ; パース中のアドレスを格納するメモリ領域
TRACK_LENGTH_LABEL:  DB 'Track length:',  '$'
DELTA_LABEL:          DB 'Delta time:',  '$'
EVENT_LABEL:          DB 'Event:',  '$'
NOTE_LABEL:           DB 'Note:', 0Dh, 0Ah, '$'
VELOCITY_LABEL:       DB 'Velocity:', 0Dh, 0Ah, '$'
HEX_STRING:  DB '00', '$'    ; 16進数表示用の文字列
CRLF:        DB 0Dh, 0Ah, '$'

MIDI_START:  DB 'MThd',00,00,00,06,00,00, 00, 01,01, 80H    ; サンプルのMIDIヘッダ
	DB 'MTrk', 00, 00, 08, 0d0h, 00, 0ffh, 58h, 04, 04, 02, 18h, 08, 00, 0ffh
	DB 72h, 6bh, 00, 00, 08, 0d0h, 00h, 0ffh, 58h, 04, 04, 02, 18h, 08h, 00, 0ffh