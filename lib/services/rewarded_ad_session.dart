import 'dart:async';

import 'rewarded_ads.dart';

/// Resolves one native ad from SDK callbacks. Only earn() can grant a reward.
class RewardedAdSession {
  RewardedAdSession(this.rewardId, this._onEarned);

  final String rewardId;
  final Future<void> Function(String rewardId) _onEarned;
  final Completer<AdOutcome> _result = Completer<AdOutcome>();
  Future<void>? _save;
  bool _closed = false;

  Future<AdOutcome> get result => _result.future;

  void earn() {
    if (_closed || _save != null) return;
    _save = Future.sync(() => _onEarned(rewardId));
  }

  void dismiss() {
    if (_closed) return;
    _closed = true;
    final save = _save;
    if (save == null) {
      _result.complete(AdOutcome.cancelled);
    } else {
      save.then(
        (_) => _result.complete(AdOutcome.earned),
        onError: (Object _) => _result.complete(AdOutcome.error),
      );
    }
  }

  void fail() {
    if (_closed) return;
    _closed = true;
    final save = _save;
    if (save == null) {
      _result.complete(AdOutcome.error);
    } else {
      save.then(
        (_) => _result.complete(AdOutcome.earned),
        onError: (Object _) => _result.complete(AdOutcome.error),
      );
    }
  }
}
