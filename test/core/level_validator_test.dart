import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/level_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'catalog has twenty unique valid levels with winning engine replays',
    () {
      expect(m4Levels.length, 20);
      expect(validateCatalog(m4Levels), isEmpty);
    },
  );

  test('rejects duplicate ids, bounds, bad switch refs and spawn hazard', () {
    final first = m4Levels.first;
    expect(validateCatalog([first, first]).join(' '), contains('trùng'));
    expect(
      validateLevel(first.copyWith(hazards: [const Rect2(-1, 0, 20, 20)]))
          .join(' '),
      contains('ngoài biên'),
    );
    expect(
      validateLevel(
        first.copyWith(
          switches: [const Rect2(80, 80, 40, 40)],
          switchIds: ['a'],
          gateRequires: [
            ['missing'],
          ],
          gates: [const Rect2(200, 0, 15, 480)],
        ),
      ).join(' '),
      contains('tham chiếu'),
    );
    final spawn = SandboxGeometry.shadowOnWall(first.initialLamp);
    expect(
      validateLevel(first.copyWith(hazards: [spawn])).join(' '),
      contains('spawn'),
    );
  });

  test('missing solution is unverified and a false solution is rejected', () {
    expect(
      validateLevel(m4Levels.first.copyWith(solution: [])).join(' '),
      contains('chưa xác minh'),
    );
    expect(
      validateLevel(m4Levels.first.copyWith(solution: [const Point2(220, 715)]))
          .join(' '),
      contains('replay'),
    );
  });

  test('JSON round trip preserves a playable level', () {
    final level = m4Levels[9];
    final decoded = Level.fromJson(level.toJson());
    expect(decoded.id, level.id);
    expect(decoded.switchIds, level.switchIds);
    expect(decoded.solution.length, level.solution.length);
    expect(validateLevel(decoded), isEmpty);
  });

  test('validator rejects moving danger outside wall at either endpoint', () {
    final level = m4Levels.first.copyWith(
      movingHazards: [
        const MovingHazard(
          bounds: Rect2(330, 200, 20, 40),
          travel: Point2(20, 0),
          periodSeconds: 3,
        ),
      ],
    );
    expect(validateLevel(level).join(' '), contains('màn chớp'));
  });

  test('timed reference replay must fit the 60 second attempt', () {
    final level = m4Levels.first.copyWith(
      solutionSteps: [
        const SolutionStep.wait(60),
        SolutionStep.move(m4Levels.first.solution.single, seconds: 1),
      ],
    );
    expect(validateLevel(level).join(' '), contains('replay'));
  });

  test('moving and timed level round trips without losing its rules', () {
    final level = m4Levels[2].copyWith(
      movingHazards: [
        const MovingHazard(
          bounds: Rect2(180, 100, 20, 50),
          travel: Point2(20, 0),
          periodSeconds: 4,
        ),
      ],
      gateWindowSeconds: 8,
      solutionSteps: [
        SolutionStep.move(m4Levels[2].solution.first, seconds: 1),
        const SolutionStep.wait(1),
        SolutionStep.move(m4Levels[2].solution.last, seconds: 2),
      ],
    );
    final decoded = Level.fromJson(level.toJson());
    expect(decoded.movingHazards.single.periodSeconds, 4);
    expect(decoded.gateWindowSeconds, 8);
    expect(decoded.solutionSteps.length, 3);
  });
}
