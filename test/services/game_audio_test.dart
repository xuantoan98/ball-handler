import 'package:ball_handler/services/game_audio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Backend implements GameAudioBackend {
  int starts = 0;
  int stops = 0;
  int effectsStopped = 0;
  final sounds = <GameSound>[];

  @override
  Future<void> startMusic() async => starts++;
  @override
  Future<void> stopMusic() async => stops++;
  @override
  Future<void> stopEffects() async => effectsStopped++;
  @override
  Future<void> play(GameSound sound) async => sounds.add(sound);
  @override
  Future<void> dispose() async {}
}

void main() {
  test('music follows mute, foreground, ad and first gesture', () async {
    final backend = _Backend();
    final audio = GameAudio(backend: backend);
    audio.setMusicActive(true);
    await audio.flush();
    expect(backend.starts, 0);
    audio.unlock();
    await audio.flush();
    expect(backend.starts, 1);
    audio.setForeground(false);
    await audio.flush();
    expect(backend.stops, 1);
    audio.setForeground(true);
    await audio.flush();
    expect(backend.starts, 2);
    audio.setAdOpen(true);
    await audio.flush();
    expect(backend.stops, 2);
    audio.setAdOpen(false);
    audio.setEnabled(false);
    await audio.flush();
    expect(backend.starts, 2);
    await audio.dispose();
  });

  test('repeated immediate cue is heard once', () async {
    final backend = _Backend();
    final audio = GameAudio(backend: backend);
    audio.unlock();
    audio.play(GameSound.collision);
    audio.play(GameSound.collision);
    await audio.flush();
    expect(backend.sounds, [GameSound.collision]);
    await audio.dispose();
  });

  test('mute and background cancel a cue already playing', () async {
    final backend = _Backend();
    final audio = GameAudio(backend: backend);
    audio.unlock();
    audio.play(GameSound.win);
    await audio.flush();
    audio.setEnabled(false);
    await audio.flush();
    expect(backend.effectsStopped, 1);
    audio.setEnabled(true);
    audio.play(GameSound.gate);
    await audio.flush();
    audio.setForeground(false);
    await audio.flush();
    expect(backend.effectsStopped, 2);
    await audio.dispose();
  });
}
