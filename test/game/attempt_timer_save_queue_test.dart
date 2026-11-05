import 'dart:async';

import 'package:ball_handler/game/attempt_timer_save_queue.dart';
import 'package:ball_handler/services/save_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'flush waits for coalesced timer saves before terminal operation',
    () async {
      final first = Completer<void>();
      final second = Completer<void>();
      final written = <int>[];
      final queue = AttemptTimerSaveQueue((remainingMs) {
        written.add(remainingMs);
        return written.length == 1 ? first.future : second.future;
      }, (_) => fail('unexpected save failure'));

      queue.queue(59000);
      queue.queue(58000);
      queue.queue(57000);
      var flushed = false;
      final flush = queue.flush().then((_) => flushed = true);
      expect(written, [59000]);
      first.complete();
      await Future<void>.delayed(Duration.zero);
      expect(written, [59000, 57000]);
      expect(flushed, isFalse);
      second.complete();
      await flush;
      expect(flushed, isTrue);
      queue.dispose();
    },
  );

  test('save failure is reported and a newer pending time can retry', () async {
    final first = Completer<void>();
    final written = <int>[];
    final errors = <String>[];
    final queue = AttemptTimerSaveQueue((remainingMs) {
      written.add(remainingMs);
      return written.length == 1 ? first.future : Future<void>.value();
    }, (error) => errors.add(error.message));

    queue.queue(59000);
    queue.queue(58000);
    first.completeError(const SaveFailure('disk failed'));
    await queue.flush();
    expect(errors, ['disk failed']);
    expect(written, [59000, 58000]);
    queue.dispose();
  });
}
