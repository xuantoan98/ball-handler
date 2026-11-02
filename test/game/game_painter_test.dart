import 'dart:ui' as ui;

import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/rules.dart';
import 'package:ball_handler/game/game_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<int>> _pixel(GameAttempt attempt, Rect2 wallRect) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  GamePainter(
    attempt: attempt,
    pressed: false,
    animation: const AlwaysStoppedAnimation<double>(0),
    motionClock: Stopwatch(),
    lastMovementMs: 0,
    travelDirection: Offset.zero,
    lives: 3,
  ).paint(canvas, const Size(390, 844));
  final image = await recorder.endRecording().toImage(390, 844);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final p = SandboxGeometry.wallRectToBoard(wallRect);
  final x = p.center.x.round();
  final y = p.center.y.round();
  final offset = (y * 390 + x) * 4;
  final rgba = bytes!.buffer.asUint8List().sublist(offset, offset + 4);
  image.dispose();
  return rgba;
}

void main() {
  test(
    'solid prop and moving danger are visibly drawn from level bounds',
    () async {
      const solid = Rect2(80, 80, 50, 70);
      const moving = Rect2(230, 115, 36, 70);
      final base = GameAttempt(m2Levels.first)..start();
      final level = m2Levels.first.copyWith(
        solids: [solid],
        movingHazards: [
          const MovingHazard(
            bounds: moving,
            travel: Point2(0, 45),
            periodSeconds: 4,
          ),
        ],
      );
      final decorated = GameAttempt(level)..start();
      expect(await _pixel(decorated, solid), isNot(await _pixel(base, solid)));
      expect(
        await _pixel(decorated, moving),
        isNot(await _pixel(base, moving)),
      );
    },
  );
}
