import 'dart:convert';

import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/editor/editor_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dragged hazard is exported as JSON geometry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EditorApp(initialLevel: m4Levels[3])),
    );
    final board = tester.getTopLeft(find.byKey(const Key('editor-board')));
    final gesture = await tester.startGesture(board + const Offset(195, 200));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.tap(find.text('Export JSON'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byKey(const Key('json-text')));
    final json = jsonDecode(field.controller!.text) as Map<String, dynamic>;
    expect((json['hazards'] as List).first[0], greaterThan(190.0));
  });

  testWidgets('dev editor can reorder switches and run a replay check', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: EditorApp(initialLevel: m4Levels[8])),
    );
    expect(find.text('Màn 09'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('switch-down')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('switch-down')));
    await tester.pump();
    expect(find.textContaining('s2 → s1'), findsWidgets);
    await tester.ensureVisible(find.byKey(const Key('validate-level')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('validate-level')));
    await tester.pump();
    expect(find.textContaining('replay'), findsWidgets);
  });
}
