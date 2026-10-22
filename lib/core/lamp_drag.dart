import 'geometry.dart';

/// One-pointer lamp drag. The grab offset is preserved until up or cancel.
class LampDrag {
  LampDrag({
    Point2 initial = const Point2(220, 715),
    this.hitRadius = 35,
    this.bounds = SandboxGeometry.controlCenters,
  }) : position = bounds.clampPoint(initial);

  final double hitRadius;
  final Rect2 bounds;
  Point2 position;
  int? activePointer;
  Point2? _grabOffset;

  bool begin(int pointer, Point2 at) {
    if (activePointer != null) return false;
    final dx = at.x - position.x;
    final dy = at.y - position.y;
    if (dx * dx + dy * dy > hitRadius * hitRadius) return false;
    activePointer = pointer;
    _grabOffset = position - at;
    return true;
  }

  bool move(int pointer, Point2 at) {
    if (pointer != activePointer || _grabOffset == null) return false;
    position = bounds.clampPoint(at + _grabOffset!);
    return true;
  }

  /// Re-anchor after a gate rejects part of a drag, so reversing feels immediate.
  void correctPosition(int pointer, Point2 at, Point2 accepted) {
    if (pointer != activePointer) return;
    position = accepted;
    _grabOffset = accepted - at;
  }

  bool end(int pointer) {
    if (pointer != activePointer) return false;
    activePointer = null;
    _grabOffset = null;
    return true;
  }
}
