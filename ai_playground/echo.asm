    ORG $100        ; プログラムの開始アドレスを0x100に設定

start:
    ; メインループ
main_loop:
    ; コンソールから1文字読み込む
    ld  c, 1         ; BDOS Function 1: コンソール入力
    call 0005h       ; BDOSコール
    cp  0dh          ; 改行文字かどうかをチェック (0DHはキャリッジリターン)
    jr  z, end       ; 改行文字なら終了へジャンプ

    ; 読み込んだ文字をコンソールに表示
 ;   ld  c, 2         ; BDOS Function 2: コンソール出力
;    call 0005h       ; BDOSコール

    ; 繰り返す
    jr  main_loop

end:
    ; プログラムの終了
    ret
