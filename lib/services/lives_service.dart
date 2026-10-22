import 'dart:math' as math;

import 'save_service.dart';

abstract interface class GameClock {
  DateTime now();
}

class SystemGameClock implements GameClock {
  const SystemGameClock();
  @override
  DateTime now() => DateTime.now();
}

enum SessionResult {
  ok,
  noLives,
  busy,
  alreadyActive,
  readOnly,
  duplicate,
  full,
}

/// Owns every change to lives, the active attempt, rewards and progression.
/// A candidate only becomes visible after its complete save record is written.
class LivesService {
  LivesService(this._save, this._clock);

  static const maxLives = 3;
  static const refillMs = 30 * 60 * 1000;
  final SaveService _save;
  final GameClock _clock;

  SaveRecord? _record;
  bool _busy = false;
  bool _readOnly = false;

  SaveRecord get record => _record ?? SaveRecord.fresh;
  bool get isReady => _record != null;
  bool get isBusy => _busy;
  bool get isReadOnly => _readOnly;
  int get lives => record.lives;
  int? get activeLevel => record.activeLevel;
  int get highestUnlocked => record.highestUnlocked;

  Duration? get untilNextRefill {
    final target = record.nextRefillAtMs;
    if (record.lives == maxLives || target == null) return null;
    final now = math.max(
      _clock.now().millisecondsSinceEpoch,
      record.lastObservedAtMs,
    );
    return Duration(milliseconds: math.max(0, target - now));
  }

  Future<void> initialize({bool readOnly = false}) async {
    _readOnly = readOnly;
    final loaded = await _save.load();
    if (loaded == null) {
      if (readOnly) {
        _record = SaveRecord.fresh;
        return;
      }
      await _commit(SaveRecord.fresh);
      return;
    }
    final normalized = _normalize(loaded);
    if (!readOnly &&
        (loaded.sourceVersion != SaveRecord.schemaVersion ||
            normalized.encode() != loaded.encode())) {
      await _commit(normalized);
    } else {
      _record = normalized;
    }
    if (!readOnly) await refresh();
  }

  /// Explicit recovery only, so a corrupt save never silently becomes 3 lives.
  Future<void> resetCorruptSave() async {
    if (_readOnly) throw const SaveFailure('Tab này chỉ đọc.');
    await _commit(SaveRecord.fresh);
  }

  Future<void> refresh() async {
    if (_readOnly || _busy || _record == null) return;
    final current = record;
    final now = _effectiveNow(current);
    final next = current.nextRefillAtMs;
    if (next == null || now < next || current.lives >= maxLives) return;
    final earned = 1 + (now - next) ~/ refillMs;
    final lives = math.min(maxLives, current.lives + earned);
    final candidate = current.change(
      lives: lives,
      nextRefillAtMs: next + earned * refillMs,
      clearRefill: lives == maxLives,
      lastObservedAtMs: now,
    );
    await _commit(candidate);
  }

  Future<SessionResult> startAttempt(int levelIndex) async {
    if (_readOnly) return SessionResult.readOnly;
    if (_busy) return SessionResult.busy;
    if (_record == null) throw const SaveFailure('Dữ liệu chưa sẵn sàng.');
    _busy = true;
    try {
      await _refillDuringTransaction();
      final current = record;
      if (current.activeLevel != null) return SessionResult.alreadyActive;
      if (current.lives == 0) return SessionResult.noLives;
      final now = _effectiveNow(current);
      final candidate = current.change(
        activeLevel: levelIndex,
        lastObservedAtMs: now,
      );
      await _commit(candidate);
      return SessionResult.ok;
    } finally {
      _busy = false;
    }
  }

  Future<void> finishAttempt({required bool won}) async {
    if (_readOnly) throw const SaveFailure('Tab này chỉ đọc.');
    if (_busy) throw const SaveFailure('Đang lưu lượt chơi.');
    if (record.activeLevel == null) return;
    _busy = true;
    try {
      final current = record;
      final now = _effectiveNow(current);
      final remaining = won ? maxLives : math.max(0, current.lives - 1);
      await _commit(
        current.change(
          lives: remaining,
          nextRefillAtMs: !won && current.lives == maxLives
              ? now + refillMs
              : current.nextRefillAtMs,
          clearRefill: won,
          clearAttempt: true,
          highestUnlocked: won
              ? math.min(
                  2,
                  math.max(current.highestUnlocked, current.activeLevel! + 1),
                )
              : current.highestUnlocked,
          lastObservedAtMs: now,
        ),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> abandonAttempt() async {
    if (_readOnly) throw const SaveFailure('Tab này chỉ đọc.');
    if (_busy) throw const SaveFailure('Đang lưu lượt chơi.');
    if (record.activeLevel == null) return;
    _busy = true;
    try {
      await _commit(
        record.change(
          clearAttempt: true,
          lastObservedAtMs: _effectiveNow(record),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  Future<SessionResult> grantReward(String rewardId) async {
    if (_readOnly) return SessionResult.readOnly;
    if (_busy) return SessionResult.busy;
    if (rewardId.isEmpty) throw const SaveFailure('Reward ID không hợp lệ.');
    _busy = true;
    try {
      await _refillDuringTransaction();
      final current = record;
      if (current.processedRewardIds.contains(rewardId)) {
        return SessionResult.duplicate;
      }
      if (current.lives == maxLives) return SessionResult.full;
      final newLives = current.lives + 1;
      await _commit(
        current.change(
          lives: newLives,
          clearRefill: newLives == maxLives,
          processedRewardIds: {...current.processedRewardIds, rewardId},
          lastObservedAtMs: _effectiveNow(current),
        ),
      );
      return SessionResult.ok;
    } finally {
      _busy = false;
    }
  }

  Future<void> setSoundEnabled(bool value) async {
    if (_readOnly) throw const SaveFailure('Tab này chỉ đọc.');
    if (_busy) throw const SaveFailure('Đang lưu.');
    _busy = true;
    try {
      await _commit(record.change(soundEnabled: value));
    } finally {
      _busy = false;
    }
  }

  Future<void> _refillDuringTransaction() async {
    final current = record;
    final now = _effectiveNow(current);
    final next = current.nextRefillAtMs;
    if (next == null || now < next || current.lives >= maxLives) return;
    final earned = 1 + (now - next) ~/ refillMs;
    final lives = math.min(maxLives, current.lives + earned);
    await _commit(
      current.change(
        lives: lives,
        nextRefillAtMs: next + earned * refillMs,
        clearRefill: lives == maxLives,
        lastObservedAtMs: now,
      ),
    );
  }

  int _effectiveNow(SaveRecord record) =>
      math.max(_clock.now().millisecondsSinceEpoch, record.lastObservedAtMs);

  SaveRecord _normalize(SaveRecord value) {
    final lives = value.lives.clamp(0, maxLives);
    final unlocked = value.highestUnlocked.clamp(0, 2);
    if (lives != value.lives || unlocked != value.highestUnlocked) {
      // Keep the original on disk until this repaired record is saved.
      assert(() {
        // ignore: avoid_print
        print('M3: repaired out-of-range save values.');
        return true;
      }());
    }
    return value.change(
      lives: lives,
      highestUnlocked: unlocked,
      clearRefill: lives == maxLives,
      nextRefillAtMs: lives < maxLives && value.nextRefillAtMs == null
          ? _effectiveNow(value) + refillMs
          : value.nextRefillAtMs,
    );
  }

  Future<void> _commit(SaveRecord candidate) async {
    await _save.save(candidate);
    _record = candidate;
  }
}
