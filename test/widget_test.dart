import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/rules.dart';
import 'package:ball_handler/game/game_painter.dart';
import 'package:ball_handler/main.dart';
import 'package:ball_handler/services/lives_service.dart';
import 'package:ball_handler/services/save_service.dart';
import 'package:ball_handler/services/tab_ownership.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GamePainter currentPainter(WidgetTester tester) =>
    (tester.widget<CustomPaint>(find.byKey(const Key('game-canvas'))).painter!
        as GamePainter);

GameAttempt currentAttempt(WidgetTester tester) =>
    currentPainter(tester).attempt;

ViewportMapper currentMapper(WidgetTester tester) {
  final size = tester.getSize(find.byKey(const Key('game-canvas')));
  return ViewportMapper.contain(
    viewportWidth: size.width,
    viewportHeight: size.height,
    boardWidth: SandboxGeometry.boardWidth,
    boardHeight: SandboxGeometry.boardHeight,
  );
}

void setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _MemoryStore implements SaveStore {
  String? value;
  bool failWrites = false;
  Completer<void>? writeGate;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String candidate) async {
    await writeGate?.future;
    if (failWrites) throw StateError('quota exceeded');
    value = candidate;
  }
}

class _Writer implements TabOwnership {
  @override
  Future<bool> acquire() async => true;
  @override
  void release() {}
}

class _FixedClock implements GameClock {
  _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

Future<void> _pumpM3(
  WidgetTester tester, {
  _MemoryStore? store,
  GameClock? clock,
}) async {
  await tester.pumpWidget(
    ShadowTheatreApp(
      saveStore: store ?? _MemoryStore(),
      clock: clock,
      tabOwnership: _Writer(),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Bóng Mơ animates at rest and responds to drag direction', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    await _pumpM3(tester);
    final idlePhase = currentPainter(tester).animation.value;
    await tester.pump(const Duration(milliseconds: 450));
    expect(currentPainter(tester).animation.value, isNot(idlePhase));

    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    final gesture = await tester.startGesture(const Offset(220, 715));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    final painter = currentPainter(tester);
    expect(painter.travelDirection.dx, lessThan(0));
    expect(painter.lastMovementMs, greaterThanOrEqualTo(0));
    await gesture.up();
  });

  for (final scenario in [
    (size: const Size(1366, 768), kind: PointerDeviceKind.mouse),
    (size: const Size(360, 800), kind: PointerDeviceKind.touch),
    (size: const Size(390, 844), kind: PointerDeviceKind.touch),
    (size: const Size(420, 900), kind: PointerDeviceKind.touch),
  ]) {
    testWidgets('one pointer drag is stable at ${scenario.size}', (
      tester,
    ) async {
      setSize(tester, scenario.size);
      await _pumpM3(tester);
      await tester.tap(find.text('Bắt đầu'));
      await tester.pump();
      expect(find.byType(Scrollable), findsNothing);
      final mapper = currentMapper(tester);
      final lamp = mapper.boardToViewport(const Point2(220, 715));
      final gesture = await tester.startGesture(
        Offset(lamp.x + 10 * mapper.scale, lamp.y + 8 * mapper.scale),
        kind: scenario.kind,
      );
      await tester.pump();
      expect(currentAttempt(tester).lamp.x, 220);
      await gesture.moveBy(const Offset(-25, 12));
      await tester.pump();
      expect(
        currentAttempt(tester).lamp.x,
        closeTo(220 - 25 / mapper.scale, 1e-5),
      );
      expect(
        currentAttempt(tester).lamp.y,
        closeTo(715 + 12 / mapper.scale, 1e-5),
      );
      await gesture.cancel();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('level 2 loses on fast sweep, retry resets state', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    await _pumpM3(tester);
    await tester.tap(find.text('Màn sau'));
    await tester.pump();
    expect(currentAttempt(tester).level.id, 2);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    final mapper = currentMapper(tester);
    final start = mapper.boardToViewport(m2Levels[1].initialLamp);
    final target = mapper.boardToViewport(m2Levels[1].solution.last);
    final gesture = await tester.startGesture(Offset(start.x, start.y));
    await gesture.moveTo(Offset(target.x, target.y));
    await gesture.up();
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.lost);
    expect(currentPainter(tester).lives, 2);
    await tester.pump();
    await tester.tap(find.text('Thử lại').first);
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.playing);
    expect(currentPainter(tester).lives, 2);
    expect(currentAttempt(tester).lamp.x, m2Levels[1].initialLamp.x);
  });

  testWidgets('pause, resize and reset preserve or clear the right state', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    await _pumpM3(tester);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    final gesture = await tester.startGesture(const Offset(220, 715));
    await gesture.moveBy(const Offset(20, 18));
    await gesture.up();
    await tester.pump();
    final before = currentAttempt(tester).lamp;
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.paused);
    tester.view.physicalSize = const Size(360, 800);
    await tester.pump();
    expect(currentAttempt(tester).lamp.x, before.x);
    expect(currentAttempt(tester).lamp.y, before.y);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.playing);
    await tester.tap(find.byIcon(Icons.replay));
    await tester.pump();
    expect(currentAttempt(tester).lamp.x, m2Levels[0].initialLamp.x);
    expect(currentAttempt(tester).lamp.y, m2Levels[0].initialLamp.y);
  });

  testWidgets('win appears after one second and opens next preview', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    await _pumpM3(tester);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    final mapper = currentMapper(tester);
    final start = mapper.boardToViewport(m2Levels[0].initialLamp);
    final target = mapper.boardToViewport(m2Levels[0].solution.single);
    final gesture = await tester.startGesture(Offset(start.x, start.y));
    await gesture.moveTo(Offset(target.x, target.y));
    await gesture.up();
    await tester.pump();
    expect(currentAttempt(tester).insideExit, isTrue);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(currentAttempt(tester).phase, AttemptPhase.won);
    expect(currentPainter(tester).lives, 3);
    await tester.pump();
    await tester.tap(find.text('Màn tiếp theo'));
    await tester.pump();
    expect(currentAttempt(tester).level.id, 2);
    expect(currentAttempt(tester).phase, AttemptPhase.playing);
    expect(currentPainter(tester).lives, 3);
  });

  testWidgets('app losing focus pauses the attempt', (tester) async {
    setSize(tester, const Size(390, 844));
    await _pumpM3(tester);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.paused);
  });

  testWidgets('lamp reaches four corners and shadow touches every wall edge', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    await _pumpM3(tester);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    final mapper = currentMapper(tester);
    final bounds = SandboxGeometry.controlCenters;
    final corners = [
      Point2(bounds.left, bounds.top),
      Point2(bounds.right, bounds.top),
      Point2(bounds.left, bounds.bottom),
      Point2(bounds.right, bounds.bottom),
    ];
    for (final corner in corners) {
      final start = mapper.boardToViewport(currentAttempt(tester).lamp);
      final end = mapper.boardToViewport(corner);
      final gesture = await tester.startGesture(
        Offset(start.x, start.y),
        kind: PointerDeviceKind.touch,
      );
      await gesture.moveTo(Offset(end.x, end.y));
      await gesture.up();
      await tester.pump();
      expect(currentAttempt(tester).lamp.x, closeTo(corner.x, 1e-6));
      expect(currentAttempt(tester).lamp.y, closeTo(corner.y, 1e-6));
      final shadow = currentAttempt(tester).shadow;
      expect(
        corner.x == bounds.left ? shadow.right : shadow.left,
        closeTo(corner.x == bounds.left ? SandboxGeometry.wallWidth : 0, 1e-6),
      );
      expect(
        corner.y == bounds.top ? shadow.bottom : shadow.top,
        closeTo(corner.y == bounds.top ? SandboxGeometry.wallHeight : 0, 1e-6),
      );
    }
  });

  testWidgets('failed start save leaves preview and all lives intact', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    final store = _MemoryStore();
    await _pumpM3(tester, store: store);
    store.failWrites = true;
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.preview);
    expect(currentPainter(tester).lives, 3);
    expect(find.textContaining('Không lưu được dữ liệu'), findsOneWidget);
  });

  testWidgets('reload restores active attempt at spawn without a life debit', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    final store = _MemoryStore();
    await _pumpM3(tester, store: store);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    final gesture = await tester.startGesture(const Offset(220, 715));
    await gesture.moveBy(const Offset(30, 10));
    await gesture.up();
    await tester.pump();
    expect(currentAttempt(tester).lamp.x, isNot(220));
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpM3(tester, store: store);
    expect(currentAttempt(tester).phase, AttemptPhase.playing);
    expect(currentAttempt(tester).lamp.x, m2Levels[0].initialLamp.x);
    expect(currentPainter(tester).lives, 3);
  });

  testWidgets('mock ad cancelled before five seconds gives no life', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    final now = DateTime.utc(2026, 10, 22);
    final store = _MemoryStore()
      ..value = SaveRecord.fresh
          .change(
            lives: 2,
            nextRefillAtMs: now.millisecondsSinceEpoch + LivesService.refillMs,
          )
          .encode();
    await _pumpM3(tester, store: store, clock: _FixedClock(now));
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(currentPainter(tester).lives, 2);
    await tester.tap(find.text('Xem quảng cáo\n+1 lượt'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Đóng · không nhận lượt'));
    await tester.pump();
    expect(currentPainter(tester).lives, 2);
    expect(find.textContaining('không nhận lượt'), findsOneWidget);
  });

  testWidgets('reward save disables cancel and reports earned after commit', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    final now = DateTime.utc(2026, 10, 22);
    final store = _MemoryStore()
      ..value = SaveRecord.fresh
          .change(
            lives: 2,
            nextRefillAtMs: now.millisecondsSinceEpoch + LivesService.refillMs,
          )
          .encode();
    await _pumpM3(tester, store: store, clock: _FixedClock(now));
    final gate = Completer<void>();
    store.writeGate = gate;
    await tester.tap(find.text('Xem quảng cáo\n+1 lượt'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Đang lưu thưởng…'), findsWidgets);
    await tester.tap(find.text('Đang lưu thưởng…').last);
    await tester.pump();
    expect(currentPainter(tester).lives, 2);
    gate.complete();
    await tester.pump();
    expect(currentPainter(tester).lives, 3);
    expect(find.textContaining('Đã nhận +1 lượt'), findsOneWidget);
  });

  testWidgets('zero lives disables start and shows refill plus ad', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));
    final now = DateTime.utc(2026, 10, 22);
    final store = _MemoryStore()
      ..value = SaveRecord.fresh
          .change(
            lives: 0,
            nextRefillAtMs: now.millisecondsSinceEpoch + LivesService.refillMs,
          )
          .encode();
    await _pumpM3(tester, store: store, clock: _FixedClock(now));
    expect(find.text('Hết lượt'), findsOneWidget);
    expect(find.text('Hồi sau\n30:00'), findsOneWidget);
    expect(find.text('Xem quảng cáo\n+1 lượt'), findsOneWidget);
    await tester.tap(find.text('Hết lượt'));
    await tester.pump();
    expect(currentAttempt(tester).phase, AttemptPhase.preview);
    expect(currentPainter(tester).lives, 0);
  });
}
