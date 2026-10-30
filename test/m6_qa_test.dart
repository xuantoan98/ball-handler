import 'package:ball_handler/core/rules.dart';
import 'package:ball_handler/game/game_painter.dart';
import 'package:ball_handler/main.dart';
import 'package:ball_handler/services/save_service.dart';
import 'package:ball_handler/services/tab_ownership.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Store implements SaveStore {
  String? value;
  int writes = 0;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String candidate) async {
    value = candidate;
    writes++;
  }
}

class _Writer implements TabOwnership {
  @override
  Future<bool> acquire() async => true;
  @override
  void release() {}
}

GameAttempt _attempt(WidgetTester tester) =>
    (tester.widget<CustomPaint>(find.byKey(const Key('game-canvas'))).painter!
            as GamePainter)
        .attempt;

Future<void> _open(WidgetTester tester, _Store store) async {
  await tester.pumpWidget(
    ShadowTheatreApp(saveStore: store, tabOwnership: _Writer()),
  );
  await tester.pump();
}

void main() {
  testWidgets('30 start reset pause menu cycles keep one saved session', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = _Store();
    await _open(tester, store);
    for (var i = 0; i < 30; i++) {
      await tester.tap(find.text('Bắt đầu'));
      await tester.pump();
      expect(_attempt(tester).phase, AttemptPhase.playing, reason: 'cycle $i');
      await tester.tap(find.byIcon(Icons.replay));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      expect(_attempt(tester).phase, AttemptPhase.paused, reason: 'cycle $i');
      await tester.tap(find.text('Xem màn'));
      await tester.pump();
      expect(_attempt(tester).phase, AttemptPhase.preview, reason: 'cycle $i');
      expect(SaveRecord.decode(store.value!).activeLevel, isNull);
      expect(tester.takeException(), isNull);
    }
    expect(SaveRecord.decode(store.value!).lives, 3);
    expect(store.writes, 61); // Initial save + start and abandon per cycle.
  });

  testWidgets('phone landscape asks for portrait and preserves paused game', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _open(tester, _Store());
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    expect(_attempt(tester).phase, AttemptPhase.playing);
    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();
    expect(find.text('Xoay dọc để tiếp tục'), findsOneWidget);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    expect(_attempt(tester).phase, AttemptPhase.paused);
    expect(find.text('Tiếp tục'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
