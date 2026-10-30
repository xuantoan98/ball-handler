import 'geometry.dart';
export 'level_catalog.dart' show m4Levels;

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
    this.schemaVersion = 1,
    this.logicalBounds = const Rect2(0, 0, 360, 480),
    this.lightBounds = SandboxGeometry.controlCenters,
    this.caster = SandboxGeometry.caster,
    this.switchIds = const [],
    this.gateRequires = const [],
    this.solutionHoldSeconds = 1,
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
  final int schemaVersion;
  final Rect2 logicalBounds;
  final Rect2 lightBounds;
  final Rect2 caster;
  final List<String> switchIds;
  final List<List<String>> gateRequires;
  final double solutionHoldSeconds;

  Level copyWith({
    Rect2? exit,
    List<Rect2>? hazards,
    List<Rect2>? switches,
    List<Rect2>? gates,
    List<Point2>? solution,
    List<String>? switchIds,
    List<List<String>>? gateRequires,
  }) => Level(
    id: id,
    title: title,
    hint: hint,
    initialLamp: initialLamp,
    exit: exit ?? this.exit,
    hazards: hazards ?? this.hazards,
    switches: switches ?? this.switches,
    gates: gates ?? this.gates,
    solution: solution ?? this.solution,
    schemaVersion: schemaVersion,
    logicalBounds: logicalBounds,
    lightBounds: lightBounds,
    caster: caster,
    switchIds: switchIds ?? this.switchIds,
    gateRequires: gateRequires ?? this.gateRequires,
    solutionHoldSeconds: solutionHoldSeconds,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'schemaVersion': schemaVersion,
    'title': title,
    'hint': hint,
    'logicalBounds': _rectJson(logicalBounds),
    'lightBounds': _rectJson(lightBounds),
    'initialLight': _pointJson(initialLamp),
    'caster': _rectJson(caster),
    'hazards': hazards.map(_rectJson).toList(),
    'switches': [
      for (var i = 0; i < switches.length; i++)
        {'id': switchIds[i], 'bounds': _rectJson(switches[i]), 'order': i + 1},
    ],
    'gates': [
      for (var i = 0; i < gates.length; i++)
        {'bounds': _rectJson(gates[i]), 'requires': gateRequires[i]},
    ],
    'exit': _rectJson(exit),
    'solutionWaypoints': solution.map(_pointJson).toList(),
    'solutionHoldSeconds': solutionHoldSeconds,
  };

  factory Level.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> obj(Object? value) =>
        Map<String, dynamic>.from(value as Map);
    List<dynamic> list(String key) => json[key] as List<dynamic>;
    final rawSwitches = list('switches').map(obj).toList()
      ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
    final rawGates = list('gates').map(obj).toList();
    return Level(
      id: json['id'] as int,
      schemaVersion: json['schemaVersion'] as int,
      title: json['title'] as String,
      hint: json['hint'] as String,
      logicalBounds: _readRect(json['logicalBounds']),
      lightBounds: _readRect(json['lightBounds']),
      initialLamp: _readPoint(json['initialLight']),
      caster: _readRect(json['caster']),
      hazards: list('hazards').map(_readRect).toList(),
      switches: rawSwitches.map((s) => _readRect(s['bounds'])).toList(),
      switchIds: rawSwitches.map((s) => s['id'] as String).toList(),
      gates: rawGates.map((g) => _readRect(g['bounds'])).toList(),
      gateRequires: rawGates
          .map((g) => (g['requires'] as List).cast<String>())
          .toList(),
      exit: _readRect(json['exit']),
      solution: list('solutionWaypoints').map(_readPoint).toList(),
      solutionHoldSeconds: (json['solutionHoldSeconds'] as num).toDouble(),
    );
  }
}

List<double> _rectJson(Rect2 r) => [r.left, r.top, r.width, r.height];
List<double> _pointJson(Point2 p) => [p.x, p.y];
Rect2 _readRect(Object? value) {
  final a = value as List;
  if (a.length != 4) throw const FormatException('Invalid rectangle');
  return Rect2(
    (a[0] as num).toDouble(),
    (a[1] as num).toDouble(),
    (a[2] as num).toDouble(),
    (a[3] as num).toDouble(),
  );
}

Point2 _readPoint(Object? value) {
  final a = value as List;
  if (a.length != 2) throw const FormatException('Invalid point');
  return Point2((a[0] as num).toDouble(), (a[1] as num).toDouble());
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
    switchIds: const ['s1'],
    gateRequires: const [
      ['s1'],
    ],
    // The gate separates the whole wall. The exit cannot be reached while shut.
    gates: const [Rect2(248, 0, 16, 480)],
    solution: [controlForShadow(75, 210), _exitTarget],
  ),
]);
