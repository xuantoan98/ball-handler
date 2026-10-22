import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'tab_ownership.dart';

TabOwnership createTabOwnership() => _WebTabOwnership();

/// The browser releases a held Web Lock automatically if its tab is closed.
/// A second tab gets a null lock immediately and stays read-only.
class _WebTabOwnership implements TabOwnership {
  Completer<JSAny?>? _release;

  @override
  Future<bool> acquire() async {
    final acquired = Completer<bool>();
    final release = Completer<JSAny?>();
    try {
      final callback = ((web.Lock? lock) {
        if (lock == null) {
          acquired.complete(false);
          return null;
        }
        _release = release;
        acquired.complete(true);
        return release.future.toJS;
      }).toJS;
      unawaited(
        web.window.navigator.locks
            .request(
              'shadow_theatre_save_writer_v1',
              web.LockOptions(mode: 'exclusive', ifAvailable: true),
              callback,
            )
            .toDart
            .then(
              (_) {
                if (!acquired.isCompleted) acquired.complete(false);
              },
              onError: (_) {
                if (!acquired.isCompleted) acquired.complete(false);
              },
            ),
      );
      return await acquired.future;
    } catch (_) {
      return false;
    }
  }

  @override
  void release() {
    final release = _release;
    if (release != null && !release.isCompleted) release.complete(null);
    _release = null;
  }
}
