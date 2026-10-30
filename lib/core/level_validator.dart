import 'geometry.dart';
import 'level.dart';
import 'rules.dart';

/// Static checks plus a deterministic replay through the shipping rules.
List<String> validateLevel(Level level) {
  final issues = <String>[];
  if (level.schemaVersion != 1) issues.add('schemaVersion không hỗ trợ');
  if (level.id < 1) issues.add('id không hợp lệ');
  if (level.title.trim().isEmpty || level.hint.trim().isEmpty) {
    issues.add('thiếu tên hoặc hướng dẫn');
  }
  bool sameRect(Rect2 a, Rect2 b) =>
      a.left == b.left &&
      a.top == b.top &&
      a.width == b.width &&
      a.height == b.height;
  if (!sameRect(level.logicalBounds, const Rect2(0, 0, 360, 480)) ||
      !sameRect(level.lightBounds, SandboxGeometry.controlCenters) ||
      !sameRect(level.caster, SandboxGeometry.caster)) {
    issues.add('geometry không khớp engine hiện tại');
  }
  bool finite(double n) => n.isFinite;
  bool validRect(Rect2 r) =>
      finite(r.left) &&
      finite(r.top) &&
      finite(r.width) &&
      finite(r.height) &&
      r.width > 0 &&
      r.height > 0 &&
      r.left >= 0 &&
      r.top >= 0 &&
      r.right <= level.logicalBounds.right &&
      r.bottom <= level.logicalBounds.bottom;
  for (final entry in <MapEntry<String, Rect2>>[
    MapEntry('exit', level.exit),
    for (final r in level.hazards) MapEntry('hazard', r),
    for (final r in level.switches) MapEntry('switch', r),
    for (final r in level.gates) MapEntry('gate', r),
  ]) {
    if (!validRect(entry.value)) {
      issues.add('${entry.key} ngoài biên hoặc rỗng');
    }
  }
  if (!level.lightBounds.contains(level.initialLamp) ||
      !finite(level.initialLamp.x) ||
      !finite(level.initialLamp.y)) {
    issues.add('initialLight ngoài biên');
  }
  if (level.switchIds.length != level.switches.length ||
      level.switchIds.any((id) => id.trim().isEmpty) ||
      level.switchIds.toSet().length != level.switchIds.length) {
    issues.add('switch ID thiếu hoặc trùng');
  }
  if (level.gateRequires.length != level.gates.length) {
    issues.add('gate tham chiếu thiếu');
  } else {
    final all = level.switchIds.toSet();
    for (final refs in level.gateRequires) {
      if (refs.isEmpty ||
          refs.toSet().length != refs.length ||
          refs.any((id) => !all.contains(id)) ||
          refs.toSet().length != all.length) {
        issues.add('gate tham chiếu công tắc sai; cửa không bao giờ mở');
      }
    }
  }
  final spawn = SandboxGeometry.shadowOnWall(level.initialLamp);
  if (level.hazards.any((r) => overlaps(spawn, r))) {
    issues.add('spawn chạm vùng đỏ');
  }
  if (level.solution.isEmpty) {
    issues.add('chưa xác minh: thiếu solutionWaypoints');
    return issues;
  }
  if (level.solutionHoldSeconds < 1 || !level.solutionHoldSeconds.isFinite) {
    issues.add('thiếu thời gian giữ cửa 1 giây');
  }
  for (final p in level.solution) {
    if (!finite(p.x) || !finite(p.y) || !level.lightBounds.contains(p)) {
      issues.add('solution waypoint ngoài biên');
    }
  }
  if (issues.isNotEmpty) return issues;
  final attempt = GameAttempt(level)..start();
  for (final point in level.solution) {
    attempt.moveLamp(point);
    if (attempt.phase != AttemptPhase.playing) {
      issues.add('replay thua trước cửa');
      return issues;
    }
  }
  attempt.tick(level.solutionHoldSeconds);
  if (attempt.phase != AttemptPhase.won) {
    issues.add('replay không thắng bằng engine rules');
  }
  return issues;
}

List<String> validateCatalog(List<Level> levels) {
  final issues = <String>[];
  final ids = <int>{};
  for (final level in levels) {
    if (!ids.add(level.id)) issues.add('ID trùng: ${level.id}');
    issues.addAll(validateLevel(level).map((item) => 'Màn ${level.id}: $item'));
  }
  return issues;
}
