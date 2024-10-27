; 
; ファイルをメモリに読み込む (内容を表示しない）
; メモリ上限をチェックする
;

            .ORG    100H ; プログラム開始アドレスを$100に設定

FCB1        EQU     5CH ; FCBのアドレス定義
BUFFER      EQU     1000H ; バッファアドレス定義
BDOS        EQU     5H ; BDOS呼び出しの定義
BUFFER_SIZE EQU     80H ; 128バイト（80H）

            LD      DE,FCB1 ; DEにファイルコントロールブロックのアドレスを設定
            LD      C,0FH ; BDOS関数 0FH (ファイルオープン)
            CALL    BDOS ; BDOS呼び出し
            CP      04H ; Aと4を比較　（0-3は成功）
            JP      NC,OPN_ERROR ; A >= 4 ならエラー処理へ
; 
; Memory 上限を確認
; BIOSの開始アドレスを取得
            LD      HL,0006H ; BIOSのジャンプテーブルがあるアドレス
            LD      E,(HL) ; ジャンプ先アドレスの下位バイトを読み込み
            INC     HL 
            LD      D,(HL) ; ジャンプ先アドレスの上位バイトを読み込み

; BIOSの開始アドレスから1引いてTPAの上限を設定
            LD      HL,DE ; DEに格納されたBIOS開始アドレスをHLにコピー
            DEC     HL ; TPAの上限アドレスを計算 (BIOS開始 - 1)
            LD      DE,256 ; 256バイトリザーブ
            SBC     HL,DE ; 

            LD      (MEMORY_TOP),HL ; メモリトップを記録しておく

            LD      HL,BUFFER ; バッファの初期アドレスを設定
            LD      (BUFFER_PTR),HL ; バッファポインタを初期化

READ_LOOP:           
; DMAアドレスを設定
            LD      HL,(BUFFER_PTR) ; 現在のバッファアドレスをHLにロード
            LD      DE,HL ; DEにバッファアドレスを設定
            LD      C,1AH ; BDOS関数 1AH (DMAアドレス設定)
            CALL    BDOS ; BDOS呼び出し

            LD      DE,FCB1 ; 読み込むFCBをDEに設定
            LD      C,14H ; BDOS関数 14H (順次読込み)
            CALL    BDOS ; BDOS呼び出し
            OR      A ; 読み込み結果確認
            JP      Z,DISPLAY ; 読み込み成功時は表示ループへ
            JP      NC,CLOSE_FILE ; EOFに達したらファイルを閉じる

DISPLAY:             
            PUSH    HL ; HLを保存
            PUSH    BC ; BCを保存（djnzがBCを使うため）
            LD      C,02H ; BDOS関数 02H (コンソール出力)
            LD      A,"*" 
            LD      E,A 
            CALL    BDOS ; BDOS呼び出し
            POP     BC ; BCを復元
            POP     HL ; HLを復元

; バッファポインタを128バイト進める
            LD      HL,(BUFFER_PTR) 
            LD      DE,BUFFER_SIZE ; DEに128バイトを設定
            ADD     HL,DE ; HLに128バイト分を加算
            LD      (BUFFER_PTR),HL ; 新しいバッファアドレスを保存
; 
; メモリ上限をチェックする
            LD      DE,(MEMORY_TOP) ; メモリ上限値をDEレジスタにロード
            EX      DE,HL ; DEとHLを交換（DEにHLの値が入る）
            SBC     HL,DE ; HLとメモリ上の値を比較（HL - DE）
            JR      C,MEM_ERROR ; HL >= メモリの値ならループを抜ける
            JP      READ_LOOP ; 次のデータを読み込む

CLOSE_FILE:          
            LD      DE,FCB1 ; FCBをDEに再設定
            LD      C,10H ; BDOS関数 10H (ファイルを閉じる)
            CALL    BDOS ; BDOS呼び出し
            JP      END_PROGRAM ; プログラム終了

OPN_ERROR:               
            LD      DE,OPN_ERR_MSG ; エラーメッセージをDEに設定
            LD      C,09H ; BDOS関数 09H (文字列表示)
            CALL    BDOS ; BDOS呼び出し
            JP      END_PROGRAM 

MEM_ERROR:           
            LD      DE,MEM_ERR_MSG ; エラーメッセージをDEに設定
            LD      C,09H ; BDOS関数 09H (文字列表示)
            CALL    BDOS ; BDOS呼び出し
            JP      END_PROGRAM 
; 
END_PROGRAM:         
            JP      0 ; プログラム終了

BUFFER_PTR: DS      2 ; バッファポインタ用メモリ
MEMORY_TOP: DS      2 ; TPAの上限値

OPN_ERR_MSG:           
            DB      "File open error",0DH, 0AH, "$"; エラーメッセージ
MEM_ERR_MSG:         
            DB      "Out of Memory",0DH, 0AH,'$' ; エラーメッセージ

