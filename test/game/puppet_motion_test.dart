import 'package:ball_handler/game/puppet_motion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('swimming response decays to idle after movement stops', () {
    expect(PuppetMotion.activity(1000, 1000), 1);
    expect(PuppetMotion.activity(1325, 1000), closeTo(.5, 1e-9));
    expect(PuppetMotion.activity(1650, 1000), 0);
    expect(PuppetMotion.activity(900, 1000), 0);
  });

  test('feet wave at rest and trail opposite the direction of travel', () {
    final stillA = PuppetMotion.footTip(0, 0, 0, Offset.zero);
    final stillB = PuppetMotion.footTip(0, .25, 0, Offset.zero);
    expect(stillA.dx, isNot(stillB.dx));

    final movingRight = PuppetMotion.footTip(1, .25, 1, const Offset(1, 0));
    final movingLeft = PuppetMotion.footTip(1, .25, 1, const Offset(-1, 0));
    expect(movingRight.dx, lessThan(movingLeft.dx));
    expect(movingLeft.dx - movingRight.dx, closeTo(12, 1e-9));
  });
}
