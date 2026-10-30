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
}
