import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/rules.dart';
import 'package:ball_handler/game/result_effect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('win cue starts once and does not mutate gameplay', () {
    final attempt = GameAttempt(m2Levels.first)..start();
    final lamp = attempt.lamp;
    final effect = ResultEffect();
    expect(effect.begin(AttemptPhase.won, reducedMotion: false), isTrue);
    expect(effect.begin(AttemptPhase.won, reducedMotion: false), isFalse);
    expect(effect.particles.length, inInclusiveRange(12, 20));
    expect(
      effect.progressAt(const Duration(milliseconds: 300)),
      closeTo(.5, .01),
    );
    expect(attempt.lamp, lamp);
    expect(attempt.phase, AttemptPhase.playing);
  });

  test('loss only marks collision when timed loss is excluded', () {
    final effect = ResultEffect();
    expect(effect.begin(AttemptPhase.lost, collision: false), isTrue);
    expect(effect.collisionHaptic, isFalse);
    effect.reset();
    expect(effect.begin(AttemptPhase.lost, collision: true), isTrue);
    expect(effect.collisionHaptic, isTrue);
    expect(effect.panelDelay, const Duration(milliseconds: 200));
    effect.reset();
    expect(effect.active, isFalse);
  });

  test('reduced motion has no particles or haptic', () {
    final effect = ResultEffect();
    effect.begin(AttemptPhase.won, reducedMotion: true);
    expect(effect.particles, isEmpty);
    expect(effect.visualsEnabled, isFalse);
    effect.reset();
    effect.begin(AttemptPhase.lost, collision: true, reducedMotion: true);
    expect(effect.collisionHaptic, isFalse);
  });
}
