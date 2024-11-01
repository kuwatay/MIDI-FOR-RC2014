    ORG 100H           ; プログラム開始アドレスを$100に設定

FCB   EQU 5CH          ; FCBのアドレス定義
BDOS  EQU 5H           ; BDOS呼び出しの定義

    LD   DE, FCB       ; DEにファイルコントロールブロックのアドレスを設定
    LD   C, 0FH        ; BDOS関数 0FH (ファイルオープン)
    CALL BDOS          ; BDOS呼び出し
    OR    A            ; ファイルオープン成功か確認
    JP    NZ, ERROR    ; オープンに失敗した場合はエラー処理へ

    LD   DE, BUFFER    ; DMAアドレスを設定
    LD   C, 1AH        ; BDOS関数 1AH (DMAアドレス設定)
    CALL BDOS          ; BDOS呼び出し

READ_LOOP:
    LD   DE, FCB       ; FCBアドレスを設定
    LD   C, 14H        ; BDOS関数 14H (順次読込み)
    CALL BDOS          ; BDOS呼び出し
    OR    A            ; 読み込み結果確認
    JP    Z, DISPLAY   ; 読み込み成功時は表示へ
    JP    NC, CLOSE_FILE ; EOFに達したらファイルを閉じる

DISPLAY:
    LD   HL, BUFFER    ; バッファのアドレスを設定
    LD   B, 80H        ; バッファサイズ（128バイト）を設定

DISPLAY_CHAR:
    LD   A, (HL)       ; バッファから1バイト読み込み
    CP   1AH           ; EOFチェック
    JP    Z, CLOSE_FILE ; EOFならファイルを閉じる
    PUSH HL
    PUSH BC            ; BCを保存（djnzがBCを使うため）
    LD   C, 02H        ; BDOS関数 02H (コンソール出力)
    LD   E, A
    CALL BDOS          ; BDOS呼び出し
    POP  BC            ; BCを復元
    POP  HL
    INC  HL            ; バッファポインタを進める
    DJNZ DISPLAY_CHAR  ; 128バイト全て処理するまで繰り返す
    JP   READ_LOOP     ; 次のデータを読み込む

CLOSE_FILE:
    LD   DE, FCB       ; FCBアドレスを設定
    LD   C, 10H        ; BDOS関数 10H (ファイルを閉じる)
    CALL BDOS          ; BDOS呼び出し
    JP   END_PROGRAM   ; プログラム終了

ERROR:
    LD   DE, ERROR_MSG ; エラーメッセージのアドレスを設定
    LD   C, 09H        ; BDOS関数 09H (文字列表示)
    CALL BDOS          ; BDOS呼び出し
    JP   END_PROGRAM   ; プログラム終了

END_PROGRAM:
    JP 0               ; プログラム終了

BUFFER:
    DS   80H           ; 読み込みバッファ（128バイト）

ERROR_MSG:
    DB 'File open error$', 00H
