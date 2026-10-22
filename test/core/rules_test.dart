import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all three reference solutions win through the actual rules', () {
    for (final level in m2Levels) {
      final attempt = GameAttempt(level)..start();
      for (final waypoint in level.solution) {
        attempt.moveLamp(waypoint);
        expect(
          attempt.phase,
          AttemptPhase.playing,
          reason: 'level ${level.id}',
        );
      }
      expect(attempt.activatedSwitches, level.switches.length);
      expect(attempt.insideExit, isTrue, reason: 'level ${level.id}');
      attempt.tick(0.99);
      expect(attempt.phase, AttemptPhase.playing);
      attempt.tick(0.01);
      expect(attempt.phase, AttemptPhase.won, reason: 'level ${level.id}');
    }
  });

  test('level 2 fast diagonal drag hits sensor between endpoints', () {
    final attempt = GameAttempt(m2Levels[1])..start();
    attempt.moveLamp(m2Levels[1].solution.last);
    expect(attempt.phase, AttemptPhase.lost);
    expect(attempt.feedback, contains('cảm biến'));
  });

  test('thin closed gate stops fast drag before switch behind it', () {
    final custom = Level(
      id: 99,
      title: 'test',
      hint: 'test',
      initialLamp: const Point2(220, 715),
      exit: const Rect2(278, 74, 68, 76),
      gates: const [Rect2(200, 0, 2, 480)],
      switches: const [Rect2(280, 190, 30, 30)],
      solution: const [],
    );
    final attempt = GameAttempt(custom)..start();
    attempt.moveLamp(controlForShadow(285, 200));
    expect(attempt.phase, AttemptPhase.playing);
    expect(attempt.shadow.right, lessThanOrEqualTo(200));
    expect(attempt.activatedSwitches, 0);
    expect(attempt.feedback, contains('khóa'));
  });

  test('level 3 gate blocks until star switch is touched', () {
    final attempt = GameAttempt(m2Levels[2])..start();
    attempt.moveLamp(m2Levels[2].solution.last);
    expect(attempt.shadow.right, lessThanOrEqualTo(248));
    expect(attempt.gateOpen, isFalse);
    attempt.retry();
    attempt.moveLamp(m2Levels[2].solution.first);
    expect(attempt.activatedSwitches, 1);
    expect(attempt.gateOpen, isTrue);
    attempt.moveLamp(m2Levels[2].solution.last);
    expect(attempt.insideExit, isTrue);
  });

  test(
    'pause freezes door timer, leaving door resets it, reset clears state',
    () {
      final attempt = GameAttempt(m2Levels[0])..start();
      attempt.moveLamp(m2Levels[0].solution.single);
      attempt.tick(0.6);
      attempt.pause();
      attempt.tick(10);
      expect(attempt.exitHoldSeconds, closeTo(0.6, 1e-9));
      attempt.resume();
      attempt.moveLamp(m2Levels[0].initialLamp);
      expect(attempt.exitHoldSeconds, 0);
      attempt.moveLamp(m2Levels[0].solution.single);
      attempt.tick(1);
      expect(attempt.phase, AttemptPhase.won);
      attempt.moveLamp(m2Levels[0].initialLamp);
      expect(attempt.insideExit, isTrue);
      attempt.reset();
      expect(attempt.phase, AttemptPhase.preview);
      expect(attempt.exitHoldSeconds, 0);
      expect(attempt.lamp.x, m2Levels[0].initialLamp.x);
    },
  );

  test('hazard is resolved before simultaneous exit completion', () {
    final target = controlForShadow(285, 85);
    final custom = Level(
      id: 98,
      title: 'test',
      hint: 'test',
      initialLamp: const Point2(220, 715),
      exit: const Rect2(278, 74, 68, 76),
      hazards: const [Rect2(285, 85, 36, 54)],
      solution: [target],
    );
    final attempt = GameAttempt(custom)..start();
    attempt.moveLamp(target);
    expect(attempt.phase, AttemptPhase.lost);
    attempt.tick(2);
    expect(attempt.phase, AttemptPhase.lost);
  });

  test('swept AABB ignores a boundary when moving away', () {
    const moving = Rect2(100, 100, 36, 54);
    const wall = Rect2(136, 80, 5, 100);
    expect(sweptAabb(moving, const Point2(-40, 0), wall), isNull);
    expect(sweptAabb(moving, const Point2(40, 0), wall), 0);
  });
}
