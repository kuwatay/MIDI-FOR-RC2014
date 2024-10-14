import struct
import argparse

# ヘッダーチャンクを解析する関数
def parse_header(file):
    chunk_type = file.read(4)  # "MThd"という4バイトのシグネチャ
    if chunk_type != b'MThd':
        raise ValueError("Invalid MIDI file: Missing 'MThd' header")

    length = struct.unpack('>I', file.read(4))[0]  # ヘッダーチャンクのサイズは4バイト
    if length != 6:
        raise ValueError("Unexpected header length")

    # MIDIフォーマット（2バイト）、トラック数（2バイト）、タイムディビジョン（2バイト）
    format_type, num_tracks, division = struct.unpack('>HHH', file.read(6))
    
    print(f"Format type: {format_type}")
    print(f"Number of tracks: {num_tracks}")
    print(f"Time division: {division}")
    return num_tracks, division

# トラックチャンクを解析する関数
def parse_track(file, division):
    chunk_type = file.read(4)  # "MTrk"という4バイトのシグネチャ
    if chunk_type != b'MTrk':
        raise ValueError("Invalid MIDI file: Missing 'MTrk' track chunk")

    length = struct.unpack('>I', file.read(4))[0]  # トラックチャンクのサイズは4バイト
    track_data = file.read(length)  # トラックのデータを読み取る
    print(f"Track length: {length} bytes")

    total_time = 0  # 総デルタタイムを保持
    i = 0
    running_status = None  # ランニングステータス用の変数

    while i < len(track_data):
        # デルタタイムの可変長エンコードを処理
        delta_time = 0
        while True:
            byte = track_data[i]
            delta_time = (delta_time << 7) | (byte & 0x7F)
            i += 1
            if byte & 0x80 == 0:
                break
        total_time += delta_time  # 総デルタタイムを更新
        print(f"Delta time: {delta_time}, Total time: {total_time} ticks")

        # ステータスバイトまたはランニングステータスを取得
        status_byte = track_data[i]
        if status_byte & 0x80 == 0:  # ステータスバイトではない場合はランニングステータス
            status_byte = running_status
        else:
            running_status = status_byte
            i += 1

        # チャンネルメッセージ
        if 0x80 <= status_byte <= 0xEF:
            message_type = status_byte & 0xF0  # メッセージのタイプを取得
            channel = status_byte & 0x0F  # チャンネル番号を取得

            if message_type in [0x80, 0x90]:  # ノートオフまたはノートオン
                note = track_data[i]
                velocity = track_data[i + 1]
                i += 2
                if message_type == 0x90 and velocity > 0:
                    print(f"Note ON - Channel: {channel}, Note: {note}, Velocity: {velocity}")
                else:
                    print(f"Note OFF - Channel: {channel}, Note: {note}, Velocity: {velocity}")
            
            elif message_type == 0xB0:  # コントロールチェンジ
                control_number = track_data[i]
                control_value = track_data[i + 1]
                i += 2
                print(f"Control Change - Channel: {channel}, Control Number: {control_number}, Value: {control_value}")
            
            elif message_type == 0xC0:  # プログラムチェンジ
                program_number = track_data[i]
                i += 1
                print(f"Program Change - Channel: {channel}, Program Number: {program_number}")
            
            elif message_type == 0xD0:  # チャンネルプレッシャー
                pressure = track_data[i]
                i += 1
                print(f"Channel Pressure - Channel: {channel}, Pressure: {pressure}")
            
            elif message_type == 0xE0:  # ピッチベンド
                lsb = track_data[i]
                msb = track_data[i + 1]
                i += 2
                pitch_bend_value = (msb << 7) + lsb
                print(f"Pitch Bend - Channel: {channel}, Value: {pitch_bend_value}")
        
        # メタイベント
        elif status_byte == 0xFF:
            meta_type = track_data[i]
            i += 1
            length = track_data[i]
            i += 1
            meta_data = track_data[i:i + length]
            i += length
            print(f"Meta event: Type {hex(meta_type)}, Length: {length}, Data: {meta_data}")
        
        else:
            print(f"Unknown status byte: {hex(status_byte)}")

# MIDIファイル全体を解析する関数
def parse_midi(file_path):
    with open(file_path, 'rb') as file:
        # ヘッダーチャンクを解析
        num_tracks, division = parse_header(file)
        
        # 各トラックを解析
        for i in range(num_tracks):
            print(f"\nParsing track {i+1}...")
            parse_track(file, division)

# メイン関数
def main():
    # argparseでコマンドライン引数を設定
    parser = argparse.ArgumentParser(description="MIDIファイルを解析します。")
    parser.add_argument('midi_file', help='解析するMIDIファイルのパス')
    args = parser.parse_args()

    # 解析するMIDIファイルを指定
    parse_midi(args.midi_file)

# スクリプトが直接実行された場合のみメイン関数を呼び出す
if __name__ == '__main__':
    main()
