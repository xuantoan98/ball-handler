import 'dart:async';

import 'package:flutter/foundation.dart';

import 'lives_service.dart';

enum AdPhase { idle, loading, showing, saving, earned, cancelled, error }

enum AdOutcome { earned, cancelled, error, busy, full }

abstract interface class RewardIdFactory {
  String nextId();
}

class MockRewardIdFactory implements RewardIdFactory {
  int _sequence = 0;

  @override
  String nextId() =>
      'mock-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
}

abstract interface class RewardedAdSource {
  AdPhase get phase;
  double get progress;
  Future<AdOutcome> show(Future<void> Function(String rewardId) onEarned);
  void cancel();
}

/// Mock only: closing before five seconds or a load error grants nothing.
/// Once the earned callback starts, cancellation waits for the save result.
class MockRewardedAds extends ChangeNotifier implements RewardedAdSource {
  MockRewardedAds(this._ids);
  final RewardIdFactory _ids;
  Timer? _timer;
  Completer<AdOutcome>? _completion;
  int _ticks = 0;
  bool _disposed = false;

  @override
  AdPhase phase = AdPhase.idle;
  @override
  double get progress => _ticks / 50;

  @override
  Future<AdOutcome> show(Future<void> Function(String rewardId) onEarned) {
    if (_completion != null) return Future.value(AdOutcome.busy);
    final completion = Completer<AdOutcome>();
    _completion = completion;
    _ticks = 0;
    phase = AdPhase.loading;
    notifyListeners();
    scheduleMicrotask(() {
      if (_completion != completion) return;
      phase = AdPhase.showing;
      notifyListeners();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (_completion != completion) return;
        _ticks++;
        notifyListeners();
        if (_ticks < 50) return;
        timer.cancel();
        phase = AdPhase.saving;
        notifyListeners();
        try {
          await onEarned(_ids.nextId());
          _complete(completion, AdOutcome.earned, AdPhase.earned);
        } catch (_) {
          _complete(completion, AdOutcome.error, AdPhase.error);
        }
      });
    });
    return completion.future;
  }

  @override
  void cancel() {
    if (phase == AdPhase.saving) return;
    final completion = _completion;
    if (completion != null) {
      _complete(completion, AdOutcome.cancelled, AdPhase.cancelled);
    }
  }

  /// Development control. No production ad SDK is connected.
  void failForDebug() {
    if (phase == AdPhase.saving) return;
    final completion = _completion;
    if (completion != null) {
      _complete(completion, AdOutcome.error, AdPhase.error);
    }
  }

  void _complete(
    Completer<AdOutcome> completion,
    AdOutcome result,
    AdPhase end,
  ) {
    if (_completion != completion) return;
    _timer?.cancel();
    _timer = null;
    _completion = null;
    phase = end;
    if (!_disposed) notifyListeners();
    completion.complete(result);
  }

  @override
  void dispose() {
    _disposed = true;
    cancel();
    super.dispose();
  }
}

class RewardedAdCoordinator {
  RewardedAdCoordinator(this._source, this._lives);
  final RewardedAdSource _source;
  final LivesService _lives;
  bool _busy = false;

  Future<AdOutcome> watch() async {
    if (_busy) return AdOutcome.busy;
    if (_lives.lives >= LivesService.maxLives) return AdOutcome.full;
    _busy = true;
    final pendingIds = <String>{};
    try {
      return await _source.show((id) async {
        if (!pendingIds.add(id)) return;
        final result = await _lives.grantReward(id);
        if (result != SessionResult.ok && result != SessionResult.duplicate) {
          throw StateError('Reward could not be saved: $result');
        }
      });
    } finally {
      _busy = false;
    }
  }

  void cancel() => _source.cancel();
}
