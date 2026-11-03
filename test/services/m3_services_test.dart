import 'dart:async';
import 'dart:convert';

import 'package:ball_handler/services/lives_service.dart';
import 'package:ball_handler/services/rewarded_ads.dart';
import 'package:ball_handler/services/save_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClock implements GameClock {
  FakeClock(this.current);
  DateTime current;
  @override
  DateTime now() => current;
  void advance(Duration duration) => current = current.add(duration);
}

class MemoryStore implements SaveStore {
  String? value;
  bool failRead = false;
  bool failWrite = false;
  Completer<void>? writeGate;
  int writes = 0;

  @override
  Future<String?> read() async {
    if (failRead) throw StateError('read error');
    return value;
  }

  @override
  Future<void> write(String candidate) async {
    await writeGate?.future;
    if (failWrite) throw StateError('quota exceeded');
    value = candidate;
    writes++;
  }
}

class FakeIds implements RewardIdFactory {
  FakeIds(this.id);
  final String id;
  @override
  String nextId() => id;
}

class FakeAd implements RewardedAdSource {
  FakeAd(this.behavior);
  final Future<AdOutcome> Function(Future<void> Function(String)) behavior;
  @override
  AdPhase get phase => AdPhase.showing;
  @override
  double get progress => 0;
  @override
  Future<AdOutcome> show(Future<void> Function(String) onEarned) =>
      behavior(onEarned);
  @override
  void cancel() {}
}

void main() {
  final origin = DateTime.utc(2026, 10, 22, 0);

  test(
    'fresh guide, locked levels and timer persist only after save',
    () async {
      final store = MemoryStore();
      final lives = LivesService(SaveService(store), FakeClock(origin));
      await lives.initialize();
      expect(lives.record.introSeen, false);
      expect(await lives.startAttempt(19), SessionResult.locked);
      expect(lives.activeLevel, isNull);
      await lives.setIntroSeen();
      expect(lives.record.introSeen, true);
      expect(await lives.startAttempt(0), SessionResult.ok);
      expect(lives.record.attemptRemainingMs, 60000);
      await lives.setAttemptRemainingMs(41321);
      final reloaded = LivesService(SaveService(store), FakeClock(origin));
      await reloaded.initialize();
      expect(reloaded.record.introSeen, true);
      expect(reloaded.record.attemptRemainingMs, 41321);
      store.failWrite = true;
      await expectLater(
        reloaded.setAttemptRemainingMs(20000),
        throwsA(isA<SaveFailure>()),
      );
      expect(reloaded.record.attemptRemainingMs, 41321);
    },
  );

  test('old v2 active save gets full clock and does not show guide', () async {
    final old = jsonDecode(
      SaveRecord.fresh.change(activeLevel: 0).encode(),
    ) as Map<String, dynamic>;
    old['schemaVersion'] = 2;
    old.remove('introSeen');
    old.remove('attemptRemainingMs');
    final store = MemoryStore()..value = jsonEncode(old);
    final lives = LivesService(SaveService(store), FakeClock(origin));
    await lives.initialize();
    expect(lives.record.introSeen, true);
    expect(lives.record.attemptRemainingMs, 60000);
    expect(jsonDecode(store.value!)['schemaVersion'], 4);
  });

  test('saved progress and active attempt can reach level twenty', () async {
    final store = MemoryStore();
    store.value = SaveRecord.fresh
        .change(activeLevel: 19, highestUnlocked: 19)
        .encode();
    final lives = LivesService(SaveService(store), FakeClock(origin));
    await lives.initialize();
    expect(lives.activeLevel, 19);
    expect(lives.highestUnlocked, 19);
    await lives.finishAttempt(won: true);
    expect(lives.highestUnlocked, 19);
    final restored = LivesService(SaveService(store), FakeClock(origin));
    await restored.initialize();
    expect(restored.highestUnlocked, 19);
  });

  test(
    'legacy unlocked stage twenty starts at one without losing unlocks',
    () async {
      final old = jsonDecode(
        SaveRecord.fresh.change(highestUnlocked: 19).encode(),
      ) as Map<String, dynamic>;
      old['schemaVersion'] = 3;
      (old['progression'] as Map<String, dynamic>).remove('currentLevel');
      final store = MemoryStore()..value = jsonEncode(old);
      final lives = LivesService(SaveService(store), FakeClock(origin));
      await lives.initialize();
      expect(lives.currentLevel, 0);
      expect(lives.highestUnlocked, 19);
      expect(jsonDecode(store.value!)['schemaVersion'], 4);
    },
  );

  test('played stage and next stage survive closing the app', () async {
    final store = MemoryStore()
      ..value = SaveRecord.fresh.change(highestUnlocked: 9).encode();
    final first = LivesService(SaveService(store), FakeClock(origin));
    await first.initialize();
    expect(await first.startAttempt(9), SessionResult.ok);
    final reopened = LivesService(SaveService(store), FakeClock(origin));
    await reopened.initialize();
    expect(reopened.activeLevel, 9);
    expect(reopened.currentLevel, 9);
    await reopened.finishAttempt(won: true);
    final afterWin = LivesService(SaveService(store), FakeClock(origin));
    await afterWin.initialize();
    expect(afterWin.activeLevel, isNull);
    expect(afterWin.currentLevel, 10);
    expect(afterWin.highestUnlocked, 10);
  });

  test(
    'fresh 3, atomic start, double click opens once without spending',
    () async {
      final store = MemoryStore();
      final clock = FakeClock(origin);
      final lives = LivesService(SaveService(store), clock);
      await lives.initialize();
      expect(lives.lives, 3);
      expect(lives.untilNextRefill, isNull);

      final gate = Completer<void>();
      store.writeGate = gate;
      final first = lives.startAttempt(0);
      expect(await lives.startAttempt(0), SessionResult.busy);
      expect(
        lives.lives,
        3,
      ); // Save has not completed; gameplay must stay closed.
      gate.complete();
      expect(await first, SessionResult.ok);
      expect(lives.lives, 3);
      expect(lives.activeLevel, 0);
      expect(lives.untilNextRefill, isNull);
      expect(await lives.startAttempt(0), SessionResult.alreadyActive);
    },
  );

  test('refresh restores free attempt and win resets lives to three', () async {
    final store = MemoryStore()
      ..value = SaveRecord.fresh.change(highestUnlocked: 1).encode();
    final clock = FakeClock(origin);
    final first = LivesService(SaveService(store), clock);
    await first.initialize();
    expect(await first.startAttempt(1), SessionResult.ok);

    final reloaded = LivesService(SaveService(store), clock);
    await reloaded.initialize();
    expect(reloaded.lives, 3);
    expect(reloaded.activeLevel, 1);
    await reloaded.finishAttempt(won: true);
    expect(reloaded.lives, 3);
    expect(reloaded.highestUnlocked, 2);
    final afterResult = LivesService(SaveService(store), clock);
    await afterResult.initialize();
    expect(afterResult.activeLevel, isNull);
    expect(await afterResult.startAttempt(2), SessionResult.ok);
    expect(afterResult.lives, 3);
  });

  test('30/60/90 minute refill, cap, and backward clock', () async {
    final store = MemoryStore();
    final clock = FakeClock(origin);
    final lives = LivesService(SaveService(store), clock);
    await lives.initialize();
    for (var loss = 0; loss < 3; loss++) {
      expect(await lives.startAttempt(0), SessionResult.ok);
      await lives.finishAttempt(won: false);
    }
    expect(lives.lives, 0);
    expect(await lives.startAttempt(0), SessionResult.noLives);
    clock.current = origin.subtract(const Duration(hours: 2));
    await lives.refresh();
    expect(lives.lives, 0);
    expect(lives.untilNextRefill, const Duration(minutes: 30));
    for (var halfHour = 1; halfHour <= 3; halfHour++) {
      clock.current = origin.add(Duration(minutes: halfHour * 30));
      await lives.refresh();
      expect(lives.lives, halfHour);
    }
    expect(lives.untilNextRefill, isNull);
    clock.advance(const Duration(hours: 5));
    await lives.refresh();
    expect(lives.lives, 3);
  });

  test(
    'only a saved failure consumes one life; duplicate finish is harmless',
    () async {
      final store = MemoryStore();
      final lives = LivesService(SaveService(store), FakeClock(origin));
      await lives.initialize();
      expect(await lives.startAttempt(0), SessionResult.ok);
      expect(lives.lives, 3);
      store.failWrite = true;
      await expectLater(
        lives.finishAttempt(won: false),
        throwsA(isA<SaveFailure>()),
      );
      expect(lives.lives, 3);
      expect(lives.activeLevel, 0);
      store.failWrite = false;
      await lives.finishAttempt(won: false);
      await lives.finishAttempt(won: false);
      expect(lives.lives, 2);
      expect(lives.untilNextRefill, const Duration(minutes: 30));
      expect(await lives.startAttempt(0), SessionResult.ok);
      expect(lives.lives, 2);
      await lives.finishAttempt(won: true);
      expect(lives.lives, 3);
      expect(lives.untilNextRefill, isNull);
    },
  );

  test(
    'v1 active paid attempt is refunded once during durable migration',
    () async {
      final store = MemoryStore();
      final old = jsonDecode(
        SaveRecord.fresh
            .change(
              lives: 2,
              activeLevel: 1,
              nextRefillAtMs:
                  origin.millisecondsSinceEpoch + LivesService.refillMs,
            )
            .encode(),
      ) as Map<String, dynamic>;
      old['schemaVersion'] = 1;
      store.value = jsonEncode(old);
      final first = LivesService(SaveService(store), FakeClock(origin));
      await first.initialize();
      expect(first.lives, 3);
      expect(first.activeLevel, 1);
      expect(first.untilNextRefill, isNull);
      expect(jsonDecode(store.value!)['schemaVersion'], 4);
      final again = LivesService(SaveService(store), FakeClock(origin));
      await again.initialize();
      expect(again.lives, 3);
      expect(again.activeLevel, 1);
    },
  );

  test('failed v1 migration does not open a session or refund twice', () async {
    final store = MemoryStore();
    final old = jsonDecode(
      SaveRecord.fresh.change(lives: 1, activeLevel: 0).encode(),
    ) as Map<String, dynamic>;
    old['schemaVersion'] = 1;
    store.value = jsonEncode(old);
    store.failWrite = true;
    final lives = LivesService(SaveService(store), FakeClock(origin));
    await expectLater(lives.initialize(), throwsA(isA<SaveFailure>()));
    expect(lives.isReady, false);
    store.failWrite = false;
    await lives.initialize();
    expect(lives.lives, 2);
    expect(jsonDecode(store.value!)['schemaVersion'], 4);
  });

  test('reward ID is durable and duplicate callback earns once', () async {
    final store = MemoryStore();
    final clock = FakeClock(origin);
    final lives = LivesService(SaveService(store), clock);
    await lives.initialize();
    await lives.startAttempt(0);
    await lives.finishAttempt(won: false);
    final ad = FakeAd((earned) async {
      await Future.wait([
        earned(FakeIds('reward-7').nextId()),
        earned('reward-7'),
      ]);
      await earned('reward-7');
      return AdOutcome.earned;
    });
    final flow = RewardedAdCoordinator(ad, lives);
    expect(await flow.watch(), AdOutcome.earned);
    expect(lives.lives, 3);
    expect(await lives.grantReward('reward-7'), SessionResult.duplicate);
    final reloaded = LivesService(SaveService(store), clock);
    await reloaded.initialize();
    expect(await reloaded.grantReward('reward-7'), SessionResult.duplicate);
    expect(reloaded.lives, 3);
  });

  testWidgets('cancel during reward save reports the committed reward', (
    tester,
  ) async {
    final store = MemoryStore();
    final lives = LivesService(SaveService(store), FakeClock(origin));
    await lives.initialize();
    await lives.startAttempt(0);
    await lives.finishAttempt(won: false);
    final gate = Completer<void>();
    store.writeGate = gate;
    final ad = MockRewardedAds(FakeIds('reward-saving'));
    addTearDown(ad.dispose);
    final flow = RewardedAdCoordinator(ad, lives);
    final result = flow.watch();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(ad.progress, 1);
    ad.cancel();
    gate.complete();
    await tester.pump();
    expect(await result, AdOutcome.earned);
    expect(lives.lives, 3);
  });

  test('cancel/error and failed reward save grant zero', () async {
    final store = MemoryStore();
    final lives = LivesService(SaveService(store), FakeClock(origin));
    await lives.initialize();
    await lives.startAttempt(0);
    await lives.finishAttempt(won: false);
    for (final outcome in [AdOutcome.cancelled, AdOutcome.error]) {
      final flow = RewardedAdCoordinator(FakeAd((_) async => outcome), lives);
      expect(await flow.watch(), outcome);
      expect(lives.lives, 2);
    }
    store.failWrite = true;
    await expectLater(
      lives.grantReward('reward-failed'),
      throwsA(isA<SaveFailure>()),
    );
    expect(lives.lives, 2);
    expect(SaveRecord.decode(store.value!).processedRewardIds, isEmpty);
  });

  test('reward preserves refill schedule unless it fills to three', () async {
    final store = MemoryStore();
    final clock = FakeClock(origin);
    final lives = LivesService(SaveService(store), clock);
    await lives.initialize();
    await lives.startAttempt(0);
    await lives.finishAttempt(won: false);
    await lives.startAttempt(0);
    await lives.finishAttempt(won: false);
    clock.advance(const Duration(minutes: 10));
    expect(await lives.grantReward('first'), SessionResult.ok);
    expect(lives.lives, 2);
    expect(lives.untilNextRefill, const Duration(minutes: 20));
    expect(await lives.grantReward('second'), SessionResult.ok);
    expect(lives.lives, 3);
    expect(lives.untilNextRefill, isNull);
  });

  test('write failure cannot open game or discard active attempt', () async {
    final store = MemoryStore();
    final lives = LivesService(SaveService(store), FakeClock(origin));
    await lives.initialize();
    store.failWrite = true;
    await expectLater(lives.startAttempt(0), throwsA(isA<SaveFailure>()));
    expect(lives.lives, 3);
    expect(lives.activeLevel, isNull);
    store.failWrite = false;
    await lives.startAttempt(0);
    store.failWrite = true;
    await expectLater(
      lives.finishAttempt(won: true),
      throwsA(isA<SaveFailure>()),
    );
    expect(lives.activeLevel, 0);
    expect(lives.highestUnlocked, 0);
  });

  test(
    'corrupt save blocks start; explicit recovery and read-only tab',
    () async {
      final store = MemoryStore()..value = '{broken';
      final clock = FakeClock(origin);
      final lives = LivesService(SaveService(store), clock);
      await expectLater(lives.initialize(), throwsA(isA<SaveFailure>()));
      expect(lives.isReady, false);
      await lives.resetCorruptSave();
      expect(lives.lives, 3);
      final secondTab = LivesService(SaveService(store), clock);
      await secondTab.initialize(readOnly: true);
      expect(await secondTab.startAttempt(0), SessionResult.readOnly);
      expect(await secondTab.grantReward('other'), SessionResult.readOnly);
      expect(secondTab.lives, 3);
    },
  );
}
