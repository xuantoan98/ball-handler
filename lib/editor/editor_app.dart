import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/level.dart';
import '../core/level_validator.dart';
import '../core/rules.dart';

/// Dev-only editor. The release entrypoint never imports this library.
class EditorApp extends StatefulWidget {
  const EditorApp({super.key, this.initialLevel});
  final Level? initialLevel;

  @override
  State<EditorApp> createState() => _EditorAppState();
}

class _EditorAppState extends State<EditorApp> {
  late Level level;
  GameAttempt? trial;
  String report = '';
  String selection = 'hazard';
  int selectedIndex = 0;
  double boardScale = 1;

  @override
  void initState() {
    super.initState();
    level = widget.initialLevel ?? m4Levels.first;
    selection = level.switches.isNotEmpty ? 'switch' : 'hazard';
  }

  List<Rect2> get selectedList => switch (selection) {
    'hazard' => level.hazards,
    'switch' => level.switches,
    'gate' => level.gates,
    _ => [level.exit],
  };

  void setList(List<Rect2> items) {
    setState(() {
      level = switch (selection) {
        'hazard' => level.copyWith(hazards: items),
        'switch' => level.copyWith(switches: items),
        'gate' => level.copyWith(gates: items),
        _ => level.copyWith(exit: items.single),
      };
      trial = null;
      report = 'Hình học đã đổi. Kiểm tra lại replay.';
    });
  }

  void moveSelection(Offset delta) {
    final list = [...selectedList];
    if (list.isEmpty || selectedIndex >= list.length) return;
    final old = list[selectedIndex];
    final left = (old.left + delta.dx / boardScale)
        .clamp(0.0, 360 - old.width)
        .toDouble();
    final top = (old.top + delta.dy / boardScale)
        .clamp(0.0, 480 - old.height)
        .toDouble();
    list[selectedIndex] = Rect2(left, top, old.width, old.height);
    setList(list);
  }

  void add(String kind) {
    selection = kind;
    final list = [...selectedList];
    list.add(switch (kind) {
      'hazard' => const Rect2(150, 150, 35, 80),
      'switch' => const Rect2(65, 200, 40, 40),
      _ => const Rect2(248, 0, 16, 480),
    });
    final nextIndex = list.length - 1;
    if (kind == 'switch') {
      final ids = [...level.switchIds, 's${level.switchIds.length + 1}'];
      level = level.copyWith(
        switchIds: ids,
        gateRequires: [for (final _ in level.gates) ids],
      );
    } else if (kind == 'gate') {
      level = level.copyWith(
        gateRequires: [...level.gateRequires, level.switchIds],
      );
    }
    selectedIndex = nextIndex;
    setList(list);
  }

  void reorderSwitch(int direction) {
    if (level.switches.length < 2) return;
    final target = (selectedIndex + direction).clamp(
      0,
      level.switches.length - 1,
    );
    final boxes = [...level.switches];
    final ids = [...level.switchIds];
    final box = boxes.removeAt(selectedIndex);
    final id = ids.removeAt(selectedIndex);
    boxes.insert(target, box);
    ids.insert(target, id);
    setState(() {
      selectedIndex = target;
      level = level.copyWith(switches: boxes, switchIds: ids);
      report = 'Thứ tự: ${ids.join(' → ')}. Cần kiểm tra lại replay.';
      trial = null;
    });
  }

  void validate() => setState(() {
    final issues = validateLevel(level);
    report = issues.isEmpty
        ? 'PASS: replay thắng sau 1 giây giữ cửa.'
        : issues.join('\n');
  });

  Future<void> showJson({required bool import}) async {
    final controller = TextEditingController(
      text: import
          ? ''
          : const JsonEncoder.withIndent('  ').convert(level.toJson()),
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(import ? 'Import JSON' : 'Export JSON'),
        content: SizedBox(
          width: 560,
          child: TextField(
            key: const Key('json-text'),
            controller: controller,
            maxLines: 15,
            minLines: 8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          if (import)
            TextButton(
              onPressed: () {
                try {
                  final decoded = jsonDecode(controller.text);
                  final candidate = Level.fromJson(
                    Map<String, dynamic>.from(decoded as Map),
                  );
                  final issues = validateLevel(candidate);
                  setState(() {
                    level = candidate;
                    selection = 'hazard';
                    selectedIndex = 0;
                    trial = null;
                    report = issues.isEmpty
                        ? 'Import hợp lệ.'
                        : issues.join('\n');
                  });
                  Navigator.pop(context);
                } catch (error) {
                  setState(() => report = 'JSON không hợp lệ: $error');
                  Navigator.pop(context);
                }
              },
              child: const Text('Nạp'),
            ),
        ],
      ),
    );
    controller.dispose();
  }

  void startTrial() => setState(() {
    trial = GameAttempt(level)..start();
    report = 'Chạy thử: kéo hai thanh đèn, giữ cửa bằng nút +1 giây.';
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Editor dev — Màn ${level.id.toString().padLeft(2, '0')}'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              DropdownButton<int>(
                value: m4Levels.any((item) => item.id == level.id)
                    ? level.id
                    : null,
                hint: const Text('Màn nhập'),
                items: [
                  for (final item in m4Levels)
                    DropdownMenuItem(
                      value: item.id,
                      child: Text('Màn ${item.id.toString().padLeft(2, '0')}'),
                    ),
                ],
                onChanged: (id) => setState(() {
                  level = m4Levels.firstWhere((item) => item.id == id);
                  trial = null;
                  report = '';
                  selection = level.switches.isNotEmpty ? 'switch' : 'hazard';
                  selectedIndex = 0;
                }),
              ),
              TextButton(
                onPressed: () => showJson(import: true),
                child: const Text('Import JSON'),
              ),
              TextButton(
                onPressed: () => showJson(import: false),
                child: const Text('Export JSON'),
              ),
              TextButton(
                key: const Key('validate-level'),
                onPressed: validate,
                child: const Text('Kiểm tra replay'),
              ),
              TextButton(onPressed: startTrial, child: const Text('Chạy thử')),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              boardScale = (constraints.maxWidth / 360).clamp(0.5, 1.0);
              return GestureDetector(
                key: const Key('editor-board'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (event) {
                  final p = event.localPosition / boardScale;
                  final boxes = selectedList;
                  for (var i = boxes.length - 1; i >= 0; i--) {
                    final r = boxes[i];
                    if (p.dx >= r.left &&
                        p.dx <= r.right &&
                        p.dy >= r.top &&
                        p.dy <= r.bottom) {
                      setState(() => selectedIndex = i);
                      break;
                    }
                  }
                },
                onPanUpdate: trial == null
                    ? (event) => moveSelection(event.delta)
                    : null,
                child: SizedBox(
                  width: 360 * boardScale,
                  height: 480 * boardScale,
                  child: CustomPaint(
                    painter: _EditorPainter(
                      level,
                      trial,
                      selection,
                      selectedIndex,
                    ),
                  ),
                ),
              );
            },
          ),
          if (trial == null) ...[
            Wrap(
              spacing: 8,
              children: [
                for (final kind in ['hazard', 'switch', 'gate', 'exit'])
                  ChoiceChip(
                    label: Text(kind),
                    selected: selection == kind,
                    onSelected: (_) => setState(() {
                      selection = kind;
                      selectedIndex = 0;
                    }),
                  ),
                TextButton(
                  onPressed: () => add('hazard'),
                  child: const Text('+ vùng đỏ'),
                ),
                TextButton(
                  onPressed: () => add('switch'),
                  child: const Text('+ sao'),
                ),
                TextButton(
                  onPressed: () => add('gate'),
                  child: const Text('+ cửa chắn'),
                ),
              ],
            ),
            if (selection == 'switch')
              Wrap(
                spacing: 8,
                children: [
                  Text('Thứ tự: ${level.switchIds.join(' → ')}'),
                  TextButton(
                    onPressed: () => reorderSwitch(-1),
                    child: const Text('↑'),
                  ),
                  TextButton(
                    key: const Key('switch-down'),
                    onPressed: () => reorderSwitch(1),
                    child: const Text('↓'),
                  ),
                ],
              ),
          ] else ...[
            Text(
              'Bóng: ${trial!.shadow.left.toStringAsFixed(0)}, ${trial!.shadow.top.toStringAsFixed(0)} · ${trial!.phase.name}',
            ),
            Slider(
              value: trial!.lamp.x,
              min: 49,
              max: 341,
              onChanged: (x) =>
                  setState(() => trial!.moveLamp(Point2(x, trial!.lamp.y))),
            ),
            Slider(
              value: trial!.lamp.y,
              min: 694,
              max: 782,
              onChanged: (y) =>
                  setState(() => trial!.moveLamp(Point2(trial!.lamp.x, y))),
            ),
            TextButton(
              onPressed: () => setState(() => trial!.tick(1)),
              child: const Text('Giữ cửa +1 giây'),
            ),
            TextButton(
              onPressed: () => setState(() => trial = null),
              child: const Text('Thoát chạy thử'),
            ),
          ],
          Text(report, key: const Key('editor-report')),
        ],
      ),
    ),
  );
}

class _EditorPainter extends CustomPainter {
  _EditorPainter(this.level, this.trial, this.selection, this.index);
  final Level level;
  final GameAttempt? trial;
  final String selection;
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 360, size.height / 480);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 360, 480),
      Paint()..color = const Color(0xFF211A38),
    );
    void box(Rect2 r, Color color, bool selected) {
      final rect = Rect.fromLTWH(r.left, r.top, r.width, r.height);
      canvas.drawRect(rect, Paint()..color = color);
      if (selected) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    box(
      level.exit,
      const Color(0xFF83D9C5),
      selection == 'exit' && trial == null,
    );
    for (var i = 0; i < level.hazards.length; i++) {
      box(
        level.hazards[i],
        const Color(0xFFDE746F),
        selection == 'hazard' && i == index && trial == null,
      );
    }
    for (var i = 0; i < level.gates.length; i++) {
      box(
        level.gates[i],
        const Color(0xFF53648E),
        selection == 'gate' && i == index && trial == null,
      );
    }
    for (var i = 0; i < level.switches.length; i++) {
      box(
        level.switches[i],
        const Color(0xFF65BDAF),
        selection == 'switch' && i == index && trial == null,
      );
    }
    box(
      trial?.shadow ?? SandboxGeometry.shadowOnWall(level.initialLamp),
      Colors.black,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant _EditorPainter old) => true;
}
