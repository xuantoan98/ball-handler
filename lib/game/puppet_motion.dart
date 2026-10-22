import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Visual-only motion; collision and projection stay in the core rules.
abstract final class PuppetMotion {
  static const decayMs = 650;

  static double activity(int nowMs, int lastMovementMs) {
    final age = nowMs - lastMovementMs;
    if (age < 0 || age >= decayMs) return 0;
    return 1 - age / decayMs;
  }

  static double bob(double cycle, double activity) {
    final phase = cycle * 2 * math.pi;
    return math.sin(phase) * 1.5 * (1 - activity) +
        math.sin(2 * phase) * .65 * activity;
  }

  /// Offset in logical board pixels for one of four trailing feet.
  static Offset footTip(
    int index,
    double cycle,
    double activity,
    Offset travelDirection,
  ) {
    final phase = cycle * 2 * math.pi;
    final idle = math.sin(phase + index * .85) * 3.3;
    final swimming = math.sin(2 * phase + index * .72) * 5.2;
    final x =
        idle * (1 - activity) +
        swimming * activity -
        travelDirection.dx * activity * 6;
    final y =
        math.cos(phase + index * .75) * (1 - activity) * 1.1 +
        math.cos(2 * phase + index * .6) * activity * 1.8 -
        travelDirection.dy * activity * 2;
    return Offset(x, y);
  }
}
