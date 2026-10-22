import 'geometry.dart';

/// Gameplay bounds are wall coordinates (360 x 480), never screen pixels.
class Level {
  const Level({
    required this.id,
    required this.title,
    required this.hint,
    required this.initialLamp,
    required this.exit,
    this.hazards = const [],
    this.switches = const [],
    this.gates = const [],
    required this.solution,
  });

  final int id;
  final String title;
  final String hint;
  final Point2 initialLamp;
  final Rect2 exit;
  final List<Rect2> hazards;
  final List<Rect2> switches;
  final List<Rect2> gates;

  /// Reference waypoints in lamp-control coordinates. Replayed by GameAttempt.
  final List<Point2> solution;
}

/// Inverse of the shared control mapping, used to author exact targets.
Point2 controlForShadow(double shadowLeft, double shadowTop) {
  final lightX = (3 * SandboxGeometry.caster.left - shadowLeft) / 2;
  final lightY = (3 * SandboxGeometry.caster.top - shadowTop) / 2;
  return Point2(
    SandboxGeometry.controlCenters.left +
        (lightX - SandboxGeometry.lightPlane.left) /
            SandboxGeometry.lightPlane.width *
            SandboxGeometry.controlCenters.width,
    SandboxGeometry.controlCenters.top +
        (lightY - SandboxGeometry.lightPlane.top) /
            SandboxGeometry.lightPlane.height *
            SandboxGeometry.controlCenters.height,
  );
}

const _start = Point2(220, 715);
final _exitTarget = controlForShadow(285, 85);

final List<Level> m2Levels = List.unmodifiable([
  Level(
    id: 1,
    title: 'Đánh thức ánh sáng',
    hint: 'Đèn sang trái, bóng sang phải. Đưa cả bóng vào cửa trăng.',
    initialLamp: _start,
    exit: const Rect2(278, 74, 68, 76),
    solution: [_exitTarget],
  ),
  Level(
    id: 2,
    title: 'Qua miền gai đỏ',
    hint: 'Đi dưới cảm biến đỏ, rồi đưa bóng lên cửa trăng.',
    initialLamp: _start,
    exit: const Rect2(278, 74, 68, 76),
    hazards: const [Rect2(190, 160, 40, 205)],
    solution: [
      controlForShadow(134, 380),
      controlForShadow(285, 380),
      _exitTarget,
    ],
  ),
  Level(
    id: 3,
    title: 'Chìa khóa sân khấu',
    hint: 'Chạm ngôi sao bên trái để mở cửa chắn, rồi về cửa trăng.',
    initialLamp: _start,
    exit: const Rect2(278, 74, 68, 76),
    switches: const [Rect2(65, 205, 40, 40)],
    // The gate separates the whole wall. The exit cannot be reached while shut.
    gates: const [Rect2(248, 0, 16, 480)],
    solution: [controlForShadow(75, 210), _exitTarget],
  ),
]);
