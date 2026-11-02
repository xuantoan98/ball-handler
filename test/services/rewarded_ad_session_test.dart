import 'dart:async';

import 'package:ball_handler/services/rewarded_ad_session.dart';
import 'package:ball_handler/services/rewarded_ads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dismiss before reward is cancelled', () async {
    final session = RewardedAdSession('ad-1', (_) async {});
    session.dismiss();
    expect(await session.result, AdOutcome.cancelled);
  });

  test('load or show error grants nothing', () async {
    final session = RewardedAdSession('ad-2', (_) async {});
    session.fail();
    expect(await session.result, AdOutcome.error);
  });

  test('duplicate earned callback saves exactly once before dismiss', () async {
    final gate = Completer<void>();
    final ids = <String>[];
    final session = RewardedAdSession('ad-3', (id) async {
      ids.add(id);
      await gate.future;
    });
    session.earn();
    session.earn();
    session.dismiss();
    expect(ids, ['ad-3']);
    gate.complete();
    expect(await session.result, AdOutcome.earned);
  });

  test('failed reward save reports error', () async {
    final session = RewardedAdSession('ad-4', (_) async {
      throw StateError('save failed');
    });
    session.earn();
    session.dismiss();
    expect(await session.result, AdOutcome.error);
  });
}
