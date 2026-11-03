import 'package:ball_handler/core/level_catalog.dart';
import 'package:ball_handler/game/game_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every stage title and hint has an English translation', () {
    for (final level in m4Levels) {
      expect(
        GameLanguage.en.text(level.title),
        isNot(level.title),
        reason: 'stage ${level.id} title',
      );
      expect(
        GameLanguage.en.text(level.hint),
        isNot(level.hint),
        reason: 'stage ${level.id} hint',
      );
    }
  });

  test('dynamic feedback keeps its stage and star number', () {
    expect(
      GameLanguage.en.text('Qua màn 01 để mở.'),
      'Beat stage 01 to unlock.',
    );
    expect(GameLanguage.en.text('Đã bật công tắc 2.'), 'Star 2 activated.');
    expect(
      GameLanguage.en.text('Hãy bật công tắc 3 trước.'),
      'Activate star 3 first.',
    );
  });
}
