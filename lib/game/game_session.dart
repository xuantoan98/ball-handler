import '../core/lamp_drag.dart';
import '../core/level.dart';
import '../core/rules.dart';

/// Owns the mutable puzzle attempt and its pointer capture for one stage.
class GameSession {
  GameSession() : attempt = GameAttempt(m4Levels[0]) {
    drag = LampDrag(initial: attempt.lamp);
  }

  int levelIndex = 0;
  GameAttempt attempt;
  late LampDrag drag;

  void selectLevel(int index) {
    levelIndex = index;
    attempt = GameAttempt(m4Levels[index]);
    drag = LampDrag(initial: attempt.lamp);
  }

  void start(int index) {
    selectLevel(index);
    attempt.start();
  }

  void restore(int index, int remainingMs) {
    levelIndex = index;
    attempt = GameAttempt(m4Levels[index], remainingMs: remainingMs.toDouble())
      ..start()
      ..pause();
    drag = LampDrag(initial: attempt.lamp);
  }

  void pause() => attempt.pause();
  void resume() => attempt.resume();
  void tick(double seconds) => attempt.tick(seconds);

  void resetPuzzle() {
    attempt.resetPuzzle();
    drag = LampDrag(initial: attempt.lamp);
  }

  void resetPreview() {
    attempt.reset();
    drag = LampDrag(initial: attempt.lamp);
  }
}
