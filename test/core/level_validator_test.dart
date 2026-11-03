import 'dart:math' as math;

import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/level_validator.dart';
import 'package:ball_handler/core/rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gate may require a valid subset of ordered switches', () {
    final level = m4Levels[2].copyWith(
      gateRequires: [
        [m4Levels[2].switchIds.first],
      ],
    );
    expect(validateLevel(level), isEmpty);
  });
  test('timed gate requires the full star sequence in schema v2', () {
    final base = m4Levels[12];
    final level = base.copyWith(
      switches: [base.switches.first, const Rect2(150, 150, 20, 20)],
      switchIds: ['s1', 's2'],
      gateRequires: [
        ['s1'],
      ],
    );
    expect(validateLevel(level).join(' '), contains('thời hạn'));
  });
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
      validateLevel(m4Levels.first.copyWith(solution: [], solutionSteps: []))
          .join(' '),
      contains('chưa xác minh'),
    );
    expect(
      validateLevel(
        m4Levels.first.copyWith(
          solution: [const Point2(220, 715)],
          solutionSteps: [],
        ),
      ).join(' '),
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

  test('validator rejects a solid prop over the spawn', () {
    final spawn = SandboxGeometry.shadowOnWall(m4Levels.first.initialLamp);
    expect(
      validateLevel(m4Levels.first.copyWith(solids: [spawn])).join(' '),
      contains('spawn'),
    );
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

  test('chapters introduce distinct obstacles and authored timed routes', () {
    expect(m4Levels.length, 20);
    expect(m4Levels[3].solids, isNotEmpty);
    expect(m4Levels[7].movingHazards, isNotEmpty);
    expect(m4Levels[12].gateWindowSeconds, isNotNull);
    expect(m4Levels[16].solids, isNotEmpty);
    expect(m4Levels[16].movingHazards, isNotEmpty);
    expect(m4Levels[16].hazards, isNotEmpty);
    expect(m4Levels.every((level) => level.solutionSteps.isNotEmpty), isTrue);
    expect(
      {
        for (final level in m4Levels)
          '${level.exit.left}:${level.exit.top}:${level.solids.length}:'
              '${level.hazards.length}:${level.switches.length}:'
              '${level.movingHazards.length}:${level.gates.length}',
      }.length,
      greaterThanOrEqualTo(16),
    );
  });

  test('late stages sweep the wall and vary danger direction and exit', () {
    final later = m4Levels.skip(7);
    final fullHeight = later
        .expand((level) => level.movingHazards)
        .where((hazard) => hazard.travel.y.abs() >= 380);
    expect(fullHeight.length, greaterThanOrEqualTo(6));
    for (final hazard in fullHeight) {
      final otherTop = hazard.bounds.top + hazard.travel.y;
      expect(math.min(hazard.bounds.top, otherTop), lessThanOrEqualTo(12));
      expect(
        math.max(hazard.bounds.bottom, otherTop + hazard.bounds.height),
        greaterThanOrEqualTo(468),
      );
    }
    expect(
      later
          .expand((level) => level.movingHazards)
          .any((hazard) => hazard.travel.x.abs() >= 100),
      isTrue,
    );
    expect(
      {for (final level in m4Levels) '${level.exit.left}:${level.exit.top}'}
          .length,
      greaterThanOrEqualTo(4),
    );
  });

  test('stages fifteen and nineteen have separate zigzag obstacles', () {
    for (final id in [15, 19]) {
      final level = m4Levels[id - 1];
      final obstacles = [...level.solids, ...level.hazards, ...level.gates];
      for (var i = 0; i < obstacles.length; i++) {
        for (var j = i + 1; j < obstacles.length; j++) {
          expect(
            overlaps(obstacles[i], obstacles[j]),
            isFalse,
            reason: 'Màn $id: vật cản $i/$j chồng nhau',
          );
        }
      }
      expect(level.solids.length, 2);
      expect(level.solids[0].bottom, 480);
      expect(level.solids[1].top, lessThan(120));
      expect(level.solution.length, greaterThanOrEqualTo(7));
    }
  });
}
