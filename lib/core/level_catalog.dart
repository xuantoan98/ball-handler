import 'geometry.dart';
import 'level.dart';

const _start = Point2(220, 715);
const _exit = Rect2(278, 74, 68, 76);
const _gate = Rect2(248, 0, 16, 480);

Point2 _at(double x, double y) => controlForShadow(x, y);

Level _scene(
  int id,
  String title,
  String hint,
  List<Point2> path, {
  List<Rect2> hazards = const [],
  List<Rect2> switches = const [],
  List<Rect2> gates = const [],
}) {
  final switchIds = [for (var i = 0; i < switches.length; i++) 's${i + 1}'];
  return Level(
    id: id,
    title: title,
    hint: hint,
    initialLamp: _start,
    exit: _exit,
    hazards: hazards,
    switches: switches,
    gates: gates,
    switchIds: switchIds,
    gateRequires: [for (final _ in gates) switchIds],
    solution: path,
  );
}

/// Hand-authored wall geometry and lamp waypoints. Each entry is replayed in tests.
final List<Level> m4Levels = List.unmodifiable([
  m2Levels[0],
  m2Levels[1],
  m2Levels[2].copyWith(
    switchIds: ['s1'],
    gateRequires: [
      ['s1'],
    ],
  ),

  // 04–07: route the full 36x54 shadow around red regions.
  _scene(
    4,
    'Lối dưới vườn trăng',
    'Đi vòng dưới dải đỏ.',
    [_at(130, 390), _at(285, 390), _at(285, 85)],
    hazards: [const Rect2(190, 150, 35, 220)],
  ),
  _scene(
    5,
    'Bờ lá tím',
    'Hạ bóng xuống rồi đi sang phải.',
    [_at(130, 400), _at(285, 400), _at(285, 85)],
    hazards: [const Rect2(188, 80, 44, 290)],
  ),
  _scene(
    6,
    'Hai mép giấy',
    'Giữ toàn bộ bóng dưới dải cảm biến.',
    [_at(125, 395), _at(285, 395), _at(285, 85)],
    hazards: [const Rect2(181, 140, 28, 230), const Rect2(58, 65, 36, 90)],
  ),
  _scene(
    7,
    'Lối hoa khuya',
    'Đưa bóng vòng qua góc dưới.',
    [_at(120, 405), _at(285, 405), _at(285, 85)],
    hazards: [const Rect2(175, 185, 39, 190), const Rect2(72, 72, 42, 120)],
  ),

  // 08–12: ordered stars, all gates open only after the last star.
  _scene(
    8,
    'Sao đầu tiên',
    'Bật sao trước khi qua cửa chắn.',
    [_at(75, 210), _at(285, 85)],
    switches: [const Rect2(65, 205, 40, 40)],
    gates: [_gate],
  ),
  _scene(
    9,
    'Hai nhịp sao',
    'Chạm sao 1 rồi sao 2.',
    [_at(75, 210), _at(75, 90), _at(285, 85)],
    switches: [const Rect2(65, 205, 40, 40), const Rect2(65, 82, 40, 40)],
    gates: [_gate],
  ),
  _scene(
    10,
    'Từ thấp lên cao',
    'Bật sao dưới rồi sao trên.',
    [_at(75, 385), _at(75, 210), _at(285, 85)],
    switches: [const Rect2(65, 382, 40, 40), const Rect2(65, 205, 40, 40)],
    gates: [_gate],
  ),
  _scene(
    11,
    'Chòm sao gấp',
    'Đi theo thứ tự sao ở mép trái.',
    [_at(75, 200), _at(75, 95), _at(285, 85)],
    switches: [const Rect2(65, 200, 40, 40), const Rect2(65, 87, 40, 40)],
    gates: [_gate],
  ),
  _scene(
    12,
    'Ba ngôi sao',
    'Bật ba sao theo thứ tự trước cửa.',
    [_at(75, 390), _at(75, 210), _at(75, 90), _at(285, 85)],
    switches: [
      const Rect2(65, 388, 40, 40),
      const Rect2(65, 205, 40, 40),
      const Rect2(65, 82, 40, 40),
    ],
    gates: [_gate],
  ),

  // 13–16: use open gates and a safe route around red sensors.
  _scene(
    13,
    'Cửa sau dải đỏ',
    'Bật sao, rồi vòng dưới cảm biến.',
    [_at(75, 210), _at(75, 390), _at(285, 390), _at(285, 85)],
    switches: [const Rect2(65, 205, 40, 40)],
    gates: [_gate],
    hazards: [const Rect2(173, 155, 34, 210)],
  ),
  _scene(
    14,
    'Hành lang giấy',
    'Đi dưới cảm biến sau khi mở cửa.',
    [_at(75, 215), _at(75, 400), _at(285, 400), _at(285, 85)],
    switches: [const Rect2(65, 210, 40, 40)],
    gates: [_gate],
    hazards: [const Rect2(180, 130, 38, 240)],
  ),
  _scene(
    15,
    'Rèm ngang',
    'Sao mở cửa; đường dưới vẫn an toàn.',
    [_at(75, 205), _at(75, 395), _at(285, 395), _at(285, 85)],
    switches: [const Rect2(65, 200, 40, 40)],
    gates: [_gate],
    hazards: [const Rect2(177, 120, 42, 245)],
  ),
  _scene(
    16,
    'Qua hai cánh rèm',
    'Giữ bóng thấp khi đi ngang.',
    [_at(75, 205), _at(75, 410), _at(285, 410), _at(285, 85)],
    switches: [const Rect2(65, 200, 40, 40)],
    gates: [_gate],
    hazards: [const Rect2(175, 150, 40, 225), const Rect2(91, 80, 30, 80)],
  ),

  // 17–20: combine ordered switches, a gate and full-body detours.
  _scene(
    17,
    'Sao dưới vườn',
    'Hai sao rồi đi dưới vùng đỏ.',
    [_at(75, 210), _at(75, 390), _at(285, 390), _at(285, 85)],
    switches: [const Rect2(65, 205, 40, 40), const Rect2(65, 388, 40, 40)],
    gates: [_gate],
    hazards: [const Rect2(177, 160, 39, 210)],
  ),
  _scene(
    18,
    'Vệt sáng xa',
    'Bật hai sao theo thứ tự rồi vòng dưới.',
    [_at(75, 205), _at(75, 395), _at(285, 395), _at(285, 85)],
    switches: [const Rect2(65, 200, 40, 40), const Rect2(65, 390, 40, 40)],
    gates: [_gate],
    hazards: [const Rect2(182, 125, 32, 245)],
  ),
  _scene(
    19,
    'Ba nhịp sân khấu',
    'Ba sao mở cửa; tránh cảm biến ở giữa.',
    [_at(75, 205), _at(75, 90), _at(75, 395), _at(285, 395), _at(285, 85)],
    switches: [
      const Rect2(65, 200, 40, 40),
      const Rect2(65, 82, 40, 40),
      const Rect2(65, 390, 40, 40),
    ],
    gates: [_gate],
    hazards: [const Rect2(180, 160, 36, 210)],
  ),
  _scene(
    20,
    'Cửa trăng cuối',
    'Theo ba sao rồi đưa cả bóng qua cửa.',
    [_at(75, 210), _at(75, 95), _at(75, 405), _at(285, 405), _at(285, 85)],
    switches: [
      const Rect2(65, 205, 40, 40),
      const Rect2(65, 87, 40, 40),
      const Rect2(65, 400, 40, 40),
    ],
    gates: [_gate],
    hazards: [const Rect2(178, 150, 40, 225)],
  ),
]);
