import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum GameSound { menu, switchOn, gate, wrong, collision, win }

abstract class GameAudioBackend {
  Future<void> startMusic();
  Future<void> stopMusic();
  Future<void> stopEffects();
  Future<void> play(GameSound sound);
  Future<void> dispose();
}

class PlayerAudioBackend implements GameAudioBackend {
  final AudioPlayer _music = AudioPlayer();
  final Map<GameSound, AudioPlayer> _effects = {
    for (final sound in GameSound.values) sound: AudioPlayer(),
  };
  final Set<GameSound> _configuredEffects = {};
  bool _musicStarted = false;

  @override
  Future<void> startMusic() async {
    if (_musicStarted) {
      await _music.resume();
    } else {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.play(AssetSource('audio/music.ogg'), volume: 1);
      _musicStarted = true;
    }
  }

  @override
  Future<void> stopMusic() => _music.pause();

  @override
  Future<void> stopEffects() async {
    for (final player in _effects.values) {
      await player.stop();
    }
  }

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
    if (!_configuredEffects.contains(sound)) {
      await player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      _configuredEffects.add(sound);
    }
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
  GameAudio({GameAudioBackend? backend, bool? requiresGesture})
    : _backend = backend ?? PlayerAudioBackend(),
      _unlocked = !(requiresGesture ?? kIsWeb);

  final GameAudioBackend _backend;
  bool _enabled = true;
  bool _foreground = true;
  bool _musicActive = false;
  bool _adOpen = false;
  bool _unlocked;
  bool _playing = false;
  bool _disposed = false;
  int _cueGeneration = 0;
  Future<void> _pending = Future.value();
  final Map<GameSound, DateTime> _lastCue = {};

  void unlock() {
    if (_unlocked) return;
    _unlocked = true;
    _reconcile();
  }

  void setEnabled(bool value) {
    if (_enabled && !value) _suppressEffects();
    _enabled = value;
    _reconcile();
  }

  void setForeground(bool value) {
    if (_foreground && !value) _suppressEffects();
    _foreground = value;
    _reconcile();
  }

  void setMusicActive(bool value) {
    _musicActive = value;
    _reconcile();
  }

  void setAdOpen(bool value) {
    if (!_adOpen && value) _suppressEffects();
    _adOpen = value;
    _reconcile();
  }

  void _suppressEffects() {
    _cueGeneration++;
    _pending = _pending.then((_) async {
      try {
        await _backend.stopEffects();
      } catch (_) {}
    });
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
    final generation = _cueGeneration;
    _pending = _pending.then((_) async {
      if (!_enabled ||
          !_foreground ||
          _adOpen ||
          _disposed ||
          generation != _cueGeneration) {
        return;
      }
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
