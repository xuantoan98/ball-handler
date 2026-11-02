import 'package:ball_handler/game/stage_backdrop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all twenty stages resolve to distinct packaged artwork', () async {
    final paths = [for (var id = 1; id <= 20; id++) stageBackdropPath(id)];
    expect(paths.toSet().length, 20);
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(10000), reason: path);
    }
  });
}
