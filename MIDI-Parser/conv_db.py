import struct
import argparse

# MIDIヘッダチャンクを読み込む
def read_header_chunk(file):
    chunk_type = file.read(4)
    if chunk_type != b'MThd':
        raise ValueError("Invalid MIDI file: Missing 'MThd'")
    length = struct.unpack('>I', file.read(4))[0]
    format_type, num_tracks, division = struct.unpack('>HHH', file.read(6))
    return {
        'format_type': format_type,
        'num_tracks': num_tracks,
        'division': division
    }

# MIDIトラックチャンクを読み込む
def read_track_chunk(file):
    chunk_type = file.read(4)
    if chunk_type != b'MTrk':
        raise ValueError("Invalid MIDI file: Missing 'MTrk'")
    length = struct.unpack('>I', file.read(4))[0]
    track_data = file.read(length)
    return track_data

# MIDIイベントをパースする
def parse_midi_events(track_data):
    events = []
    i = 0
    while i < len(track_data):
        delta_time = 0
        while True:
            delta_byte = track_data[i]
            i += 1
            delta_time = (delta_time << 7) | (delta_byte & 0x7F)
            if not (delta_byte & 0x80):
                break

        status_byte = track_data[i]
        i += 1

        if 0x80 <= status_byte <= 0xEF:
            # ノートオン、ノートオフ、他のMIDIイベント
            event_type = status_byte & 0xF0
            channel = status_byte & 0x0F
            param1 = track_data[i]
            i += 1
            param2 = track_data[i] if event_type != 0xC0 and event_type != 0xD0 else None
            if param2 is not None:
                i += 1
            events.append({
                'delta_time': delta_time,
                'event_type': event_type,
                'channel': channel,
                'param1': param1,
                'param2': param2
            })
        elif status_byte == 0xFF:
            # メタイベント
            meta_type = track_data[i]
            i += 1
            length = track_data[i]
            i += 1
            meta_data = track_data[i:i+length]
            i += length
            events.append({
                'delta_time': delta_time,
                'event_type': 'meta',
                'meta_type': meta_type,
                'meta_data': meta_data
            })
        else:
            raise ValueError(f"Unknown MIDI event: {status_byte}")

    return events

# MIDIイベントをDB命令形式に変換
def midi_events_to_asm_table(events):
    asm_lines = []
    for event in events:
        if event['event_type'] == 144:  # ノートオン
            asm_line = f"    DB {event['event_type']}, {event['param1']}, {event['param2']}, {event['delta_time']}"
            asm_lines.append(asm_line)
        elif event['event_type'] == 128:  # ノートオフ
            asm_line = f"    DB {event['event_type']}, {event['param1']}, 0, {event['delta_time']}"
            asm_lines.append(asm_line)

    # テーブルの終わりに終了バイトを追加
    asm_lines.append("    DB 0xFF")
    
    return asm_lines

# MIDIファイルをパースしてアセンブラ形式に変換する
def parse_midi_file_to_asm(file_path):
    with open(file_path, 'rb') as file:
        header = read_header_chunk(file)
        print(f"Header: {header}")

        for track_num in range(header['num_tracks']):
            print(f"\nTrack {track_num + 1}:")
            track_data = read_track_chunk(file)
            events = parse_midi_events(track_data)
            asm_table = midi_events_to_asm_table(events)
            for line in asm_table:
                print(line)

# メイン関数
def main():
    # argparseでコマンドライン引数を設定
    parser = argparse.ArgumentParser(description="MIDIファイルを解析します。")
    parser.add_argument('midi_file', help='解析するMIDIファイルのパス')
    args = parser.parse_args()

    # 解析するMIDIファイルを指定
    parse_midi_file_to_asm(args.midi_file)

# スクリプトが直接実行された場合のみメイン関数を呼び出す
if __name__ == '__main__':
    main()
