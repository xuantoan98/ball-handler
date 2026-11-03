import 'package:ball_handler/game/attempt_timer_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('time indicator pulses once at the start of each final second', () {
    expect(timerPulseActive(11000), isFalse);
    for (var second = 10; second >= 1; second--) {
      expect(timerPulseActive(second * 1000.0 - 100), isTrue);
      expect(timerPulseActive(second * 1000.0 - 500), isFalse);
    }
    expect(timerPulseActive(0), isFalse);
  });
}
