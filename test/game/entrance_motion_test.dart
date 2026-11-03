import 'package:ball_handler/game/entrance_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entrance remains tappable from first frame and settles', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: EntranceMotion(
          child: TextButton(onPressed: () => taps++, child: const Text('Chơi')),
        ),
      ),
    );
    expect(
      tester.widget<Opacity>(find.byType(Opacity).first).opacity,
      greaterThan(0),
    );
    await tester.tap(find.text('Chơi'));
    expect(taps, 1);
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
  });

  testWidgets('reduced motion uses static state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const EntranceMotion(child: Text('Tĩnh')),
        ),
      ),
    );
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
  });
}
