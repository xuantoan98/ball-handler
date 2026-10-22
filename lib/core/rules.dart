import 'dart:math' as math;

import 'geometry.dart';
import 'level.dart';

enum AttemptPhase { preview, playing, paused, won, lost }

/// Strict overlap: edge contact alone is not occupancy.
bool overlaps(Rect2 a, Rect2 b) =>
    a.left < b.right &&
    a.right > b.left &&
    a.top < b.bottom &&
    a.bottom > b.top;

bool containsRect(Rect2 outer, Rect2 inner) =>
    outer.left <= inner.left &&
    outer.top <= inner.top &&
    outer.right >= inner.right &&
    outer.bottom >= inner.bottom;

/// First contact time of a moving AABB against a fixed AABB, in [0, 1].
/// Returns null if the full segment misses. Touching while moving away is clear.
double? sweptAabb(Rect2 moving, Point2 delta, Rect2 fixed) {
  if (overlaps(moving, fixed)) return 0;
  var entry = double.negativeInfinity;
  var exit = double.infinity;

  for (final axis in [0, 1]) {
    final velocity = axis == 0 ? delta.x : delta.y;
    final near = axis == 0 ? moving.left : moving.top;
    final far = axis == 0 ? moving.right : moving.bottom;
    final wallNear = axis == 0 ? fixed.left : fixed.top;
    final wallFar = axis == 0 ? fixed.right : fixed.bottom;
    if (velocity == 0) {
      if (far <= wallNear || near >= wallFar) return null;
      continue;
    }
    final t1 = (wallNear - far) / velocity;
    final t2 = (wallFar - near) / velocity;
    entry = math.max(entry, math.min(t1, t2));
    exit = math.min(exit, math.max(t1, t2));
  }
  if (entry > exit || exit <= 0 || entry < 0 || entry > 1) return null;
  return entry;
}

class _Contact {
  const _Contact(this.time, this.priority, this.kind, this.index);
  final double time;
  final int priority;
  final String kind;
  final int index;
}

/// Deterministic M2 attempt. No Flutter or frame clock dependency.
class GameAttempt {
  GameAttempt(this.level) : lamp = level.initialLamp;

  final Level level;
  AttemptPhase phase = AttemptPhase.preview;
  Point2 lamp;
  int activatedSwitches = 0;
  double exitHoldSeconds = 0;
  String feedback = '';

  Rect2 get shadow => SandboxGeometry.shadowOnWall(lamp);
  bool get gateOpen => activatedSwitches == level.switches.length;
  bool get insideExit => gateOpen && containsRect(level.exit, shadow);

  void start() {
    if (phase != AttemptPhase.preview) return;
    phase = AttemptPhase.playing;
    feedback = level.hint;
  }

  void pause() {
    if (phase == AttemptPhase.playing) phase = AttemptPhase.paused;
  }

  void resume() {
    if (phase == AttemptPhase.paused) phase = AttemptPhase.playing;
  }

  void reset() {
    phase = AttemptPhase.preview;
    lamp = level.initialLamp;
    activatedSwitches = 0;
    exitHoldSeconds = 0;
    feedback = '';
  }

  void retry() {
    reset();
    start();
  }

  void moveLamp(Point2 desired) {
    if (phase != AttemptPhase.playing) return;
    final target = SandboxGeometry.controlCenters.clampPoint(desired);
    final from = shadow;
    final to = SandboxGeometry.shadowOnWall(target);
    final delta = Point2(to.left - from.left, to.top - from.top);
    if (delta.x == 0 && delta.y == 0) return;

    final contacts = <_Contact>[];
    for (var i = 0; i < level.hazards.length; i++) {
      final t = sweptAabb(from, delta, level.hazards[i]);
      if (t != null) contacts.add(_Contact(t, 0, 'hazard', i));
    }
    for (var i = 0; i < level.gates.length; i++) {
      final t = sweptAabb(from, delta, level.gates[i]);
      if (t != null) contacts.add(_Contact(t, 1, 'gate', i));
    }
    for (var i = activatedSwitches; i < level.switches.length; i++) {
      final t = sweptAabb(from, delta, level.switches[i]);
      if (t != null) contacts.add(_Contact(t, 2, 'switch', i));
    }
    contacts.sort((a, b) {
      final time = a.time.compareTo(b.time);
      return time == 0 ? a.priority.compareTo(b.priority) : time;
    });

    final oldLamp = lamp;
    for (final contact in contacts) {
      if (contact.kind == 'hazard') {
        lamp = _lerp(oldLamp, target, contact.time);
        exitHoldSeconds = 0;
        phase = AttemptPhase.lost;
        feedback = 'Bóng chạm cảm biến đỏ.';
        return;
      }
      if (contact.kind == 'gate' && !gateOpen) {
        lamp = _lerp(oldLamp, target, math.max(0, contact.time - 1e-6));
        exitHoldSeconds = 0;
        feedback = 'Cửa chắn đang khóa. Hãy chạm công tắc sao.';
        return;
      }
      if (contact.kind == 'switch') {
        if (contact.index == activatedSwitches) {
          activatedSwitches++;
          feedback = 'Đã bật công tắc $activatedSwitches.';
        } else if (contact.index > activatedSwitches) {
          feedback = 'Hãy bật công tắc ${activatedSwitches + 1} trước.';
        }
      }
    }
    lamp = target;
    if (!insideExit) exitHoldSeconds = 0;
  }

  void tick(double seconds) {
    if (phase != AttemptPhase.playing || seconds <= 0) return;
    if (!insideExit) {
      exitHoldSeconds = 0;
      return;
    }
    exitHoldSeconds += seconds;
    if (exitHoldSeconds >= 1) {
      exitHoldSeconds = 1;
      phase = AttemptPhase.won;
      feedback = 'Bóng đã qua cửa trăng!';
    }
  }

  static Point2 _lerp(Point2 from, Point2 to, double t) =>
      Point2(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t);
}
