import 'geometry.dart';
import 'level.dart';

const _start = Point2(220, 715);
const _ne = Rect2(278, 74, 68, 76);
const _nw = Rect2(14, 74, 68, 76);
const _em = Rect2(278, 215, 68, 76);
const _se = Rect2(278, 360, 68, 76);
const _gate = Rect2(248, 0, 16, 480);

Point2 _p(double x, double y) => controlForShadow(x, y);
List<SolutionStep> _steps(List<Point2> path) => [
  for (final point in path) SolutionStep.move(point, seconds: 1.5),
];

Level _scene(
  int id,
  String title,
  String hint,
  List<Point2> path, {
  Rect2 exit = _ne,
  List<Rect2> hazard = const [],
  List<Rect2> solid = const [],
  List<MovingHazard> moving = const [],
  List<Rect2> stars = const [],
  List<Rect2> gates = const [],
  double? window,
  List<SolutionStep>? timed,
}) {
  final ids = [for (var i = 0; i < stars.length; i++) 's${i + 1}'];
  return Level(
    id: id,
    schemaVersion: 2,
    title: title,
    hint: hint,
    initialLamp: _start,
    exit: exit,
    hazards: hazard,
    solids: solid,
    movingHazards: moving,
    switches: stars,
    gates: gates,
    gateWindowSeconds: window,
    switchIds: ids,
    gateRequires: [for (final _ in gates) ids],
    solution: path,
    solutionSteps: timed ?? _steps(path),
  );
}

/// Twenty authored wall puzzles. Decorative stage art never supplies collision.
final List<Level> m4Levels = List.unmodifiable([
  m2Levels[0].copyWith(
    schemaVersion: 2,
    solutionSteps: _steps(m2Levels[0].solution),
  ),
  m2Levels[1].copyWith(
    schemaVersion: 2,
    solutionSteps: _steps(m2Levels[1].solution),
  ),
  m2Levels[2].copyWith(
    schemaVersion: 2,
    switchIds: ['s1'],
    gateRequires: [
      ['s1'],
    ],
    solutionSteps: _steps(m2Levels[2].solution),
  ),

  // 04–07 · Vườn trăng: ink-and-brass props are solid, not lethal.
  _scene(
    4,
    'Gốc cây trăng',
    'Đạo cụ tối chỉ chắn bóng. Đi vòng dưới gốc cây.',
    [_p(130, 400), _p(285, 400), _p(285, 85)],
    solid: [const Rect2(185, 160, 38, 200)],
  ),
  _scene(
    5,
    'Hồ lá tím',
    'Tìm lối bên trái giữa hai đảo giấy.',
    [_p(55, 330), _p(22, 85)],
    exit: _nw,
    solid: [const Rect2(100, 175, 46, 105), const Rect2(195, 80, 54, 220)],
  ),
  _scene(
    6,
    'Nhà kính trăng',
    'Bóng dừng ở đạo cụ, chạm coral sẽ thua.',
    [_p(125, 215), _p(285, 225)],
    exit: _em,
    solid: [const Rect2(180, 290, 46, 105)],
    hazard: [const Rect2(196, 105, 36, 90)],
  ),
  _scene(
    7,
    'Cổng hoa khuya',
    'Đổi hướng hai lần để qua cổng hoa.',
    [_p(115, 405), _p(230, 405), _p(230, 90), _p(285, 85)],
    solid: [
      const Rect2(180, 145, 40, 220),
      const Rect2(60, 100, 48, 115),
      const Rect2(280, 260, 35, 95),
    ],
  ),

  // 08–12 · Xưởng sao: moving coral shutters, then ordered stars.
  _scene(
    8,
    'Màn chớp đầu tiên',
    'Đợi chớp lên rồi băng qua dưới.',
    [_p(130, 395), _p(285, 395), _p(285, 225)],
    exit: _em,
    moving: [
      const MovingHazard(
        bounds: Rect2(190, 8, 24, 64),
        travel: Point2(0, 400),
        periodSeconds: 4,
        phaseSeconds: 2,
      ),
    ],
    timed: [
      SolutionStep.move(_p(130, 395), seconds: .5),
      const SolutionStep.wait(1.5),
      SolutionStep.move(_p(285, 395), seconds: 1),
      SolutionStep.move(_p(285, 225), seconds: 2),
    ],
  ),
  _scene(
    9,
    'Bánh răng ngập sao',
    'Chờ ở khoảng trống bên dưới bánh răng.',
    [_p(125, 405), _p(285, 405), _p(285, 225)],
    exit: _em,
    solid: [const Rect2(235, 110, 35, 90)],
    moving: [
      const MovingHazard(
        bounds: Rect2(190, 8, 25, 64),
        travel: Point2(0, 400),
        periodSeconds: 6,
        phaseSeconds: 3,
      ),
    ],
  ),
  _scene(
    10,
    'Ròng rọc giấy',
    'Qua sao trước khi tới cửa chắn.',
    [_p(75, 205), _p(75, 390), _p(285, 390), _p(285, 225)],
    exit: _em,
    stars: [const Rect2(65, 200, 40, 40)],
    gates: [_gate],
    moving: [
      const MovingHazard(
        bounds: Rect2(185, 8, 25, 64),
        travel: Point2(0, 400),
        periodSeconds: 7,
        phaseSeconds: 3.5,
      ),
    ],
  ),
  _scene(
    11,
    'Hai nhịp đồng',
    'Bật sao theo thứ tự rồi né chớp ở giữa.',
    [
      _p(75, 330),
      _p(75, 205),
      _p(75, 90),
      _p(75, 395),
      _p(285, 395),
      _p(285, 85),
    ],
    stars: [const Rect2(65, 200, 40, 40), const Rect2(65, 82, 40, 40)],
    gates: [_gate],
    solid: [const Rect2(120, 250, 45, 55)],
    moving: [
      const MovingHazard(
        bounds: Rect2(185, 8, 22, 64),
        travel: Point2(0, 400),
        periodSeconds: 8,
        phaseSeconds: 1.5,
      ),
    ],
  ),
  _scene(
    12,
    'Đồng hồ thiên văn',
    'Chờ khoảng trống giữa hai màn chớp.',
    [
      _p(75, 390),
      _p(75, 205),
      _p(75, 88),
      _p(75, 405),
      _p(285, 405),
      _p(285, 225),
    ],
    exit: _em,
    stars: [
      const Rect2(65, 385, 40, 40),
      const Rect2(65, 200, 40, 40),
      const Rect2(65, 82, 40, 40),
    ],
    gates: [_gate],
    moving: [
      const MovingHazard(
        bounds: Rect2(178, 8, 20, 64),
        travel: Point2(0, 400),
        periodSeconds: 8,
        phaseSeconds: 1.5,
      ),
      const MovingHazard(
        bounds: Rect2(218, 8, 20, 64),
        travel: Point2(0, 400),
        periodSeconds: 8,
        phaseSeconds: 2,
      ),
    ],
  ),

  // 13–16 · Thư viện đêm: timed star gates.
  _scene(
    13,
    'Trang sách mở',
    'Bật sao; vòng mint báo lúc cửa khép.',
    [_p(75, 205), _p(285, 85)],
    stars: [const Rect2(65, 200, 40, 40)],
    gates: [_gate],
    window: 12,
  ),
  _scene(
    14,
    'Hành lang sách',
    'Sau sao cuối, chọn đường ngắn.',
    [_p(75, 205), _p(75, 390), _p(285, 390), _p(285, 85)],
    stars: [const Rect2(65, 200, 40, 40)],
    gates: [_gate],
    window: 15,
    solid: [const Rect2(176, 145, 42, 210)],
  ),
  _scene(
    15,
    'Phòng bản đồ trăng',
    'Sau sao cuối, lách trên rồi xuống giữa hai vách giấy.',
    [
      _p(75, 85),
      _p(75, 385),
      _p(75, 235),
      _p(160, 235),
      _p(160, 385),
      _p(285, 385),
      _p(285, 85),
    ],
    stars: [const Rect2(65, 82, 40, 40), const Rect2(65, 380, 40, 40)],
    gates: [_gate],
    window: 13,
    solid: [const Rect2(120, 380, 25, 100), const Rect2(205, 100, 25, 230)],
  ),
  _scene(
    16,
    'Gác chuông giấy',
    'Chờ chớp đi xa, bật sao rồi qua cửa.',
    [_p(75, 205), _p(75, 390), _p(285, 390), _p(285, 85)],
    stars: [const Rect2(65, 200, 40, 40)],
    gates: [_gate],
    window: 14,
    solid: [const Rect2(125, 120, 35, 60)],
    moving: [
      const MovingHazard(
        bounds: Rect2(185, 8, 22, 64),
        travel: Point2(0, 400),
        periodSeconds: 7,
        phaseSeconds: 3.5,
      ),
    ],
  ),

  // 17–20 · Sân khấu thiên hà combines learned rules.
  _scene(
    17,
    'Mở rèm thiên hà',
    'Né cảm biến đứng và chớp ngang qua hành lang.',
    [_p(125, 405), _p(285, 405), _p(285, 85)],
    solid: [const Rect2(95, 105, 50, 130)],
    hazard: [const Rect2(180, 140, 28, 170)],
    moving: [
      const MovingHazard(
        bounds: Rect2(180, 290, 60, 22),
        travel: Point2(120, 0),
        periodSeconds: 5,
        phaseSeconds: 1.5,
      ),
    ],
  ),
  _scene(
    18,
    'Quỹ đạo trăng',
    'Hai sao, một chớp và cửa sắp khép.',
    [_p(75, 200), _p(75, 385), _p(285, 385), _p(285, 85)],
    stars: [const Rect2(65, 195, 40, 40), const Rect2(65, 380, 40, 40)],
    gates: [_gate],
    window: 14,
    solid: [const Rect2(145, 90, 30, 90)],
    moving: [
      const MovingHazard(
        bounds: Rect2(190, 8, 24, 64),
        travel: Point2(0, 400),
        periodSeconds: 7,
        phaseSeconds: 3.5,
      ),
    ],
  ),
  _scene(
    19,
    'Ba nhịp sân khấu',
    'Bật ba sao rồi luồn chữ S qua hai vách.',
    [
      _p(75, 205),
      _p(75, 85),
      _p(75, 395),
      _p(75, 235),
      _p(160, 235),
      _p(160, 390),
      _p(285, 375),
    ],
    exit: _se,
    stars: [
      const Rect2(65, 200, 40, 40),
      const Rect2(65, 82, 40, 40),
      const Rect2(65, 390, 40, 40),
    ],
    gates: [_gate],
    window: 14,
    solid: [const Rect2(120, 380, 25, 100), const Rect2(205, 105, 25, 225)],
    hazard: [const Rect2(165, 75, 30, 100)],
  ),
  _scene(
    20,
    'Đại cảnh Rạp bóng nhỏ',
    'Ba sao, chớp dọc sát mép và chớp ngang.',
    [_p(75, 205), _p(75, 85), _p(75, 395), _p(285, 395), _p(285, 225)],
    exit: _em,
    stars: [
      const Rect2(65, 200, 40, 40),
      const Rect2(65, 82, 40, 40),
      const Rect2(65, 390, 40, 40),
    ],
    gates: [_gate],
    window: 15,
    solid: [const Rect2(180, 130, 34, 220), const Rect2(330, 180, 25, 150)],
    hazard: [const Rect2(210, 120, 25, 180)],
    moving: [
      const MovingHazard(
        bounds: Rect2(218, 8, 20, 64),
        travel: Point2(0, 400),
        periodSeconds: 8,
        phaseSeconds: 2.5,
      ),
      const MovingHazard(
        bounds: Rect2(180, 280, 65, 22),
        travel: Point2(105, 0),
        periodSeconds: 6,
        phaseSeconds: 5.5,
      ),
    ],
  ),
]);
