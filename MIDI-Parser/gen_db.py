import argparse

def display_file_in_hex(filepath):
    try:
        with open(filepath, 'rb') as file:
            byte = file.read(1)
            line = []
            address = 0  # アドレス表示用
            
            while byte:
                # バイトを16進数の形式でリストに追加
                line.append(f"0x{int.from_bytes(byte, 'big'):02X}")
                
                # 16バイトごとに出力
                if len(line) == 16:
                    print(f"\tDB " + ",".join(line) + f" ; {address:08X}")
                    line = []  # 次の行に備えてリセット
                    address += 16  # アドレスを16バイト進める
                
                # 次のバイトを読み込み
                byte = file.read(1)
            
            # 残ったバイトがあれば出力
            if line:
                print(f"\tDB " + ", ".join(line) + f" ; {address:08X}")
                
    except FileNotFoundError:
        print("ファイルが見つかりません。パスを確認してください。")

# コマンドライン引数を処理
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Display file contents in hexadecimal format.")
    parser.add_argument("filepath", type=str, help="Path to the file to display in hex format")
    args = parser.parse_args()
    
    display_file_in_hex(args.filepath)
