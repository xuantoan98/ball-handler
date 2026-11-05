import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Paints the illustrated proscenium within the fixed stage rectangle.
abstract final class StageBackdropRenderer {
  /// Keep the illustrated top/bottom proscenium at its native proportions.
  /// Only the quiet central wall is shortened to fit the gameplay viewport.
  static void paint(Canvas canvas, ui.Image image, Rect destination) {
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final scale = destination.width / width;
    final visibleHeight = destination.height / scale;
    final basePaint = Paint()..filterQuality = FilterQuality.medium;
    if (visibleHeight >= height) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, width, height),
        destination,
        basePaint,
      );
      return;
    }
    final join = visibleHeight * .54;
    final fade = math.min(80.0, visibleHeight * .1);
    final fadeStart = join - fade / 2;
    final lowerSourceStart = height - (visibleHeight - fadeStart);
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, lowerSourceStart, width, height),
      Rect.fromLTRB(
        destination.left,
        destination.top + fadeStart * scale,
        destination.right,
        destination.bottom,
      ),
      basePaint,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, width, fadeStart),
      Rect.fromLTRB(
        destination.left,
        destination.top,
        destination.right,
        destination.top + fadeStart * scale,
      ),
      basePaint,
    );
    const strips = 16;
    for (var i = 0; i < strips; i++) {
      final sourceTop = fadeStart + fade * i / strips;
      final sourceBottom = fadeStart + fade * (i + 1) / strips;
      final alpha = (1 - (i + .5) / strips).clamp(0.0, 1.0);
      canvas.drawImageRect(
        image,
        Rect.fromLTRB(0, sourceTop, width, sourceBottom),
        Rect.fromLTRB(
          destination.left,
          destination.top + sourceTop * scale,
          destination.right,
          destination.top + sourceBottom * scale,
        ),
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }
}
