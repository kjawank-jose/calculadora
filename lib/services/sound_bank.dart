import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundBank {
  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _rates = {};

  // Notas (Hz) de cada tecla que no es número
  static const _tones = <String, List<double>>{
    '+': [523, 784],
    '-': [784, 523],
    '×': [659, 659, 880],
    '÷': [440, 330],
    '=': [523, 659, 784, 1047],
    'C': [400, 300, 200],
    '⌫': [300],
    '(': [600],
    ')': [500],
    '.': [900],
  };

  Future<void> init() async {
    try {
      for (var d = 0; d < 10; d++) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource('sounds/meow.mp3'));
        _players['$d'] = p;
        _rates['$d'] = 0.75 + d * 0.07; // 0.75 ... 1.38
      }
      for (final e in _tones.entries) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(BytesSource(_wav(e.value)));
        _players[e.key] = p;
      }
      debugPrint('SoundBank: listo (${_players.length} sonidos)');
    } catch (err) {
      debugPrint('SoundBank init error: $err');
    }
  }

  Future<void> play(String key) async {
    final p = _players[key];
    if (p == null) return;
    try {
      await p.stop();
      final rate = _rates[key];
      if (rate != null) await p.setPlaybackRate(rate);
      await p.resume();
    } catch (err) {
      debugPrint('SoundBank play error: $err');
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
  }

  // Genera un WAV de 16 bits con una nota por cada frecuencia
  Uint8List _wav(List<double> notes, {int noteMs = 90, double volume = 0.5}) {
    const rate = 22050;
    final per = rate * noteMs ~/ 1000;
    final n = per * notes.length;
    final data = ByteData(44 + n * 2);

    void str(int o, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    data.setUint32(4, 36 + n * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, rate, Endian.little);
    data.setUint32(28, rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    str(36, 'data');
    data.setUint32(40, n * 2, Endian.little);

    var idx = 0;
    for (final f in notes) {
      for (var i = 0; i < per; i++) {
        final t = i / rate;
        final env = exp(-t * 28) * min(1.0, i / 100);
        final s = (sin(2 * pi * f * t) + 0.3 * sin(4 * pi * f * t)) * env * volume;
        final v = (s * 32767).round().clamp(-32768, 32767);
        data.setInt16(44 + idx * 2, v, Endian.little);
        idx++;
      }
    }
    return data.buffer.asUint8List();
  }
}