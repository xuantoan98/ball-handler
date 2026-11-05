import '../services/save_service.dart';

/// Coalesces timer updates while preserving the order before a terminal save.
class AttemptTimerSaveQueue {
  AttemptTimerSaveQueue(this._save, this._onFailure);

  final Future<void> Function(int remainingMs) _save;
  final void Function(SaveFailure failure) _onFailure;
  Future<void>? _inFlight;
  int? _pendingMs;
  bool _disposed = false;

  void queue(int remainingMs) {
    if (_disposed) return;
    _pendingMs = remainingMs;
    if (_inFlight != null) return;
    _start();
  }

  void _start() {
    _inFlight = _drain().whenComplete(() {
      _inFlight = null;
      if (_pendingMs != null && !_disposed) _start();
    });
  }

  Future<void> _drain() async {
    while (_pendingMs != null && !_disposed) {
      final value = _pendingMs!;
      _pendingMs = null;
      try {
        await _save(value);
      } on SaveFailure catch (error) {
        _onFailure(error);
        break;
      }
    }
  }

  Future<void> flush() async {
    while (_inFlight != null) {
      await _inFlight;
    }
  }

  void dispose() {
    _disposed = true;
    _pendingMs = null;
  }
}
