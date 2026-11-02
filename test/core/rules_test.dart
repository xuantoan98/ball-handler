import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each gate opens from its own required switch IDs', () {
    final level = m2Levels[2].copyWith(
      switches: [const Rect2(90, 90, 20, 20), const Rect2(120, 90, 20, 20)],
      switchIds: ['first', 'second'],
      gates: [const Rect2(200, 0, 6, 180), const Rect2(250, 0, 6, 180)],
      gateRequires: [
        ['first'],
        ['first', 'second'],
      ],
    );
    final attempt = GameAttempt(level)..start();
    expect(attempt.isGateOpen(0), isFalse);
    attempt.activatedSwitches = 1;
    expect(attempt.isGateOpen(0), isTrue);
    expect(attempt.isGateOpen(1), isFalse);
  });
  test('60 seconds is a loss exactly once', () {
    final attempt = GameAttempt(m2Levels[0])..start();
    attempt.tick(59.9);
    expect(attempt.phase, AttemptPhase.playing);
    expect(attempt.remainingMs, closeTo(100, 1));
    attempt.tick(0.1);
    expect(attempt.phase, AttemptPhase.lost);
    expect(attempt.remainingMs, 0);
    expect(attempt.feedback, 'Hết 60 giây.');
    attempt.tick(5);
    expect(attempt.phase, AttemptPhase.lost);
  });

  test('timeout wins tie with exit hold completion', () {
    final attempt = GameAttempt(m2Levels[0], remainingMs: 1000)..start();
    attempt.moveLamp(m2Levels[0].solution.single);
    attempt.tick(1);
    expect(attempt.phase, AttemptPhase.lost);
  });

  test(
    'pause and puzzle reset preserve time while retry restores 60 seconds',
    () {
      final attempt = GameAttempt(m2Levels[0])..start();
      attempt.tick(8);
      attempt.pause();
      attempt.tick(10);
      expect(attempt.remainingMs, 52000);
      attempt.resume();
      attempt.resetPuzzle();
      expect(attempt.phase, AttemptPhase.playing);
      expect(attempt.remainingMs, 52000);
      attempt.tick(52);
      expect(attempt.phase, AttemptPhase.lost);
      attempt.retry();
      expect(attempt.phase, AttemptPhase.playing);
      expect(attempt.remainingMs, 60000);
    },
  );

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

  test('solid prop stops a fast drag without losing the attempt', () {
    final level = m2Levels.first.copyWith(
      solids: [const Rect2(190, 295, 20, 110)],
    );
    final attempt = GameAttempt(level)..start();
    attempt.moveLamp(controlForShadow(285, 320));
    expect(attempt.phase, AttemptPhase.playing);
    expect(attempt.shadow.right, lessThanOrEqualTo(190.001));
  });

  test('moving danger reaches a stationary shadow during a long tick', () {
    final level = m2Levels.first.copyWith(
      movingHazards: [
        const MovingHazard(
          bounds: Rect2(180, 320, 20, 60),
          travel: Point2(-60, 0),
          periodSeconds: 2,
        ),
      ],
    );
    final attempt = GameAttempt(level)..start();
    attempt.tick(1);
    expect(attempt.phase, AttemptPhase.lost);
    expect(attempt.feedback, contains('chớp'));
  });

  test('crossing shadow and shutter paths lose within one tick', () {
    final level = Level(
      id: 97,
      title: 'crossing',
      hint: 'crossing',
      initialLamp: controlForShadow(100, 100),
      exit: const Rect2(300, 20, 50, 70),
      movingHazards: const [
        MovingHazard(
          bounds: Rect2(200, 100, 20, 20),
          travel: Point2(-100, 100),
          periodSeconds: 2,
        ),
      ],
      solution: const [],
    );
    final attempt = GameAttempt(level)..start();
    attempt.moveLamp(controlForShadow(200, 200));
    expect(attempt.phase, AttemptPhase.playing);
    attempt.tick(1);
    expect(attempt.phase, AttemptPhase.lost);
  });

  test('pause freezes moving danger and reset restarts its phase', () {
    final level = m2Levels.first.copyWith(
      movingHazards: [
        const MovingHazard(
          bounds: Rect2(250, 100, 20, 60),
          travel: Point2(-40, 0),
          periodSeconds: 4,
        ),
      ],
    );
    final attempt = GameAttempt(level)..start();
    attempt.tick(1);
    final left = attempt.movingHazardBounds.single.left;
    attempt.pause();
    attempt.tick(2);
    expect(attempt.movingHazardBounds.single.left, left);
    attempt.resume();
    attempt.resetPuzzle();
    expect(attempt.movingHazardBounds.single.left, 250);
    expect(attempt.remainingMs, 59000);
  });

  test('timed star gate expires and can be reopened in one attempt', () {
    final level = m2Levels[2].copyWith(gateWindowSeconds: 3);
    final attempt = GameAttempt(level)..start();
    attempt.moveLamp(level.solution.first);
    expect(attempt.gateOpen, isTrue);
    attempt.tick(3);
    expect(attempt.gateOpen, isFalse);
    expect(attempt.activatedSwitches, 0);
    attempt.moveLamp(level.initialLamp);
    attempt.moveLamp(level.solution.first);
    expect(attempt.gateOpen, isTrue);
    expect(attempt.remainingMs, 57000);
  });
}
