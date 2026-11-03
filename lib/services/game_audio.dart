import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

enum GameSound { menu, switchOn, gate, wrong, collision, win }

abstract class GameAudioBackend {
  Future<void> startMusic();
  Future<void> stopMusic();
  Future<void> play(GameSound sound);
  Future<void> dispose();
}

class PlayerAudioBackend implements GameAudioBackend {
  final AudioPlayer _music = AudioPlayer();
  final Map<GameSound, AudioPlayer> _effects = {
    for (final sound in GameSound.values) sound: AudioPlayer(),
  };
  bool _musicStarted = false;

  @override
  Future<void> startMusic() async {
    if (_musicStarted) {
      await _music.resume();
    } else {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.play(AssetSource('audio/music.ogg'), volume: .12);
      _musicStarted = true;
    }
  }

  @override
  Future<void> stopMusic() => _music.pause();

  @override
  Future<void> play(GameSound sound) async {
    final file = switch (sound) {
      GameSound.menu => 'menu.ogg',
      GameSound.switchOn => 'switch.ogg',
      GameSound.gate => 'gate.ogg',
      GameSound.wrong => 'wrong.ogg',
      GameSound.collision => 'collision.ogg',
      GameSound.win => 'win.ogg',
    };
    final player = _effects[sound]!;
    await player.stop();
    await player.play(AssetSource('audio/$file'), volume: .32);
  }

  @override
  Future<void> dispose() async {
    await _music.dispose();
    for (final player in _effects.values) {
      await player.dispose();
    }
  }
}

/// One controller for both targets; a gesture unlocks browser playback.
class GameAudio {
  GameAudio({GameAudioBackend? backend})
    : _backend = backend ?? PlayerAudioBackend();

  final GameAudioBackend _backend;
  bool _enabled = true;
  bool _foreground = true;
  bool _musicActive = false;
  bool _adOpen = false;
  bool _unlocked = false;
  bool _playing = false;
  bool _disposed = false;
  Future<void> _pending = Future.value();
  final Map<GameSound, DateTime> _lastCue = {};

  void unlock() {
    _unlocked = true;
    _reconcile();
  }

  void setEnabled(bool value) {
    _enabled = value;
    _reconcile();
  }

  void setForeground(bool value) {
    _foreground = value;
    _reconcile();
  }

  void setMusicActive(bool value) {
    _musicActive = value;
    _reconcile();
  }

  void setAdOpen(bool value) {
    _adOpen = value;
    _reconcile();
  }

  void _reconcile() {
    if (_disposed) return;
    _pending = _pending.then((_) async {
      final wanted =
          _enabled && _foreground && _musicActive && !_adOpen && _unlocked;
      if (wanted == _playing) return;
      try {
        if (wanted) {
          await _backend.startMusic();
        } else {
          await _backend.stopMusic();
        }
        _playing = wanted;
      } catch (_) {
        _playing = false;
      }
    });
  }

  void play(GameSound sound) {
    if (_disposed || !_enabled || !_foreground || _adOpen || !_unlocked) return;
    final now = DateTime.now();
    final last = _lastCue[sound];
    if (last != null && now.difference(last).inMilliseconds < 150) return;
    _lastCue[sound] = now;
    _pending = _pending.then((_) async {
      if (!_enabled || !_foreground || _adOpen || _disposed) return;
      try {
        await _backend.play(sound);
      } catch (_) {
        // A browser may still reject playback; the next gesture can retry.
      }
    });
  }

  Future<void> flush() => _pending;

  Future<void> dispose() async {
    _disposed = true;
    await _pending;
    await _backend.dispose();
  }
}
