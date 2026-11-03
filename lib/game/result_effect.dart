import 'dart:math' as math;

import '../core/rules.dart';

class PaperParticle {
  const PaperParticle(this.dx, this.dy, this.radius, this.gold);
  final double dx;
  final double dy;
  final double radius;
  final bool gold;
}

/// Decorative outcome state. It never owns or modifies a GameAttempt.
class ResultEffect {
  static const duration = Duration(milliseconds: 600);
  AttemptPhase? _phase;
  Stopwatch? _clock;
  bool _reducedMotion = false;
  bool _collision = false;

  bool get active => _phase != null;
  AttemptPhase? get phase => _phase;
  bool get collisionHaptic =>
      _phase == AttemptPhase.lost && _collision && !_reducedMotion;
  Duration get elapsed => _clock?.elapsed ?? Duration.zero;

  List<PaperParticle> get particles {
    if (_phase != AttemptPhase.won || _reducedMotion) return const [];
    final random = math.Random(1817);
    return List.generate(16, (_) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 20 + random.nextDouble() * 70;
      return PaperParticle(
        math.cos(angle) * distance,
        math.sin(angle) * distance,
        2 + random.nextDouble() * 3,
        random.nextBool(),
      );
    });
  }

  bool begin(
    AttemptPhase phase, {
    bool collision = false,
    bool reducedMotion = false,
  }) {
    if (_phase != null ||
        (phase != AttemptPhase.won && phase != AttemptPhase.lost)) {
      return false;
    }
    _phase = phase;
    _collision = collision;
    _reducedMotion = reducedMotion;
    _clock = Stopwatch()..start();
    return true;
  }

  double progressAt(Duration elapsed) =>
      (elapsed.inMicroseconds / duration.inMicroseconds).clamp(0, 1).toDouble();

  void reset() {
    _clock?.stop();
    _clock = null;
    _phase = null;
    _collision = false;
  }
}
