import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MeowPlayer {
  final List<AudioPlayer> _players = [];
  int _next = 0;

  Future<void> init() async {
    try {
      for (var i = 0; i < 4; i++) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource('sounds/meow.mp3'));
        _players.add(p);
      }
      debugPrint('MeowPlayer: listo (${_players.length} reproductores)');
    } catch (e) {
      debugPrint('MeowPlayer init error: $e');
    }
  }

  Future<void> play() async {
    if (_players.isEmpty) return;
    final p = _players[_next];
    _next = (_next + 1) % _players.length;
    try {
      await p.stop();
      await p.resume();
    } catch (e) {
      debugPrint('MeowPlayer play error: $e');
    }
  }

  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
  }
}