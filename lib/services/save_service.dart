import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SaveStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesSaveStore implements SaveStore {
  PreferencesSaveStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const key = 'shadow_theatre_save_v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read() => _preferences.getString(key);

  @override
  Future<void> write(String value) => _preferences.setString(key, value);
}

class SaveFailure implements Exception {
  const SaveFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class SaveRecord {
  const SaveRecord({
    required this.lives,
    required this.nextRefillAtMs,
    required this.activeLevel,
    required this.processedRewardIds,
    required this.highestUnlocked,
    required this.currentLevel,
    required this.soundEnabled,
    required this.lastObservedAtMs,
    required this.introSeen,
    required this.attemptRemainingMs,
    this.sourceVersion = schemaVersion,
  });

  static const schemaVersion = 4;
  static const fresh = SaveRecord(
    lives: 3,
    nextRefillAtMs: null,
    activeLevel: null,
    processedRewardIds: {},
    highestUnlocked: 0,
    currentLevel: 0,
    soundEnabled: true,
    lastObservedAtMs: 0,
    introSeen: false,
    attemptRemainingMs: null,
  );

  final int lives;
  final int? nextRefillAtMs;
  final int? activeLevel;
  final Set<String> processedRewardIds;
  final int highestUnlocked;

  /// Stage selected for the next launch; independent of unlocked progress.
  final int currentLevel;
  final bool soundEnabled;
  final int lastObservedAtMs;
  final bool introSeen;
  final int? attemptRemainingMs;

  /// Version read from storage; a v1 active attempt was charged at start.
  final int sourceVersion;

  SaveRecord change({
    int? lives,
    int? nextRefillAtMs,
    bool clearRefill = false,
    int? activeLevel,
    bool clearAttempt = false,
    Set<String>? processedRewardIds,
    int? highestUnlocked,
    int? currentLevel,
    bool? soundEnabled,
    int? lastObservedAtMs,
    bool? introSeen,
    int? attemptRemainingMs,
  }) => SaveRecord(
    lives: lives ?? this.lives,
    nextRefillAtMs: clearRefill ? null : nextRefillAtMs ?? this.nextRefillAtMs,
    activeLevel: clearAttempt ? null : activeLevel ?? this.activeLevel,
    processedRewardIds: processedRewardIds ?? this.processedRewardIds,
    highestUnlocked: highestUnlocked ?? this.highestUnlocked,
    currentLevel: currentLevel ?? this.currentLevel,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    lastObservedAtMs: lastObservedAtMs ?? this.lastObservedAtMs,
    introSeen: introSeen ?? this.introSeen,
    attemptRemainingMs: clearAttempt
        ? null
        : attemptRemainingMs ??
              (activeLevel != null && this.attemptRemainingMs == null
                  ? 60000
                  : this.attemptRemainingMs),
    sourceVersion: sourceVersion,
  );

  String encode() => jsonEncode({
    'schemaVersion': schemaVersion,
    'lives': lives,
    'nextRefillAt': nextRefillAtMs,
    'activeAttempt': activeLevel,
    'processedRewardIds': processedRewardIds.toList()..sort(),
    'progression': {
      'highestUnlocked': highestUnlocked,
      'currentLevel': currentLevel,
    },
    'settings': {'soundEnabled': soundEnabled},
    'lastObservedAt': lastObservedAtMs,
    'introSeen': introSeen,
    'attemptRemainingMs': attemptRemainingMs,
  });

  static SaveRecord decode(String source) {
    try {
      final data = jsonDecode(source);
      if (data is! Map<String, dynamic> ||
          (data['schemaVersion'] != 1 &&
              data['schemaVersion'] != 2 &&
              data['schemaVersion'] != 3 &&
              data['schemaVersion'] != schemaVersion)) {
        throw const SaveFailure('Phiên bản dữ liệu lưu không được hỗ trợ.');
      }
      final rewards = data['processedRewardIds'];
      final progression = data['progression'];
      final settings = data['settings'];
      final lives = data['lives'];
      final next = data['nextRefillAt'];
      final active = data['activeAttempt'];
      final observed = data['lastObservedAt'];
      final v3 = (data['schemaVersion'] as int) >= 3;
      final intro = v3 ? data['introSeen'] : true;
      final remaining = v3
          ? data['attemptRemainingMs']
          : active == null
          ? null
          : 60000;
      if (lives is! int ||
          next != null && next is! int ||
          active != null && active is! int ||
          rewards is! List ||
          rewards.any((item) => item is! String || item.isEmpty) ||
          progression is! Map ||
          progression['highestUnlocked'] is! int ||
          data['schemaVersion'] == schemaVersion &&
              progression['currentLevel'] is! int ||
          settings is! Map ||
          settings['soundEnabled'] is! bool ||
          observed is! int ||
          observed < 0 ||
          next != null && next < 0 ||
          active != null && (active < 0 || active > 19)) {
        throw const SaveFailure('Dữ liệu lưu bị lỗi.');
      }
      if (intro is! bool ||
          remaining != null && remaining is! int ||
          active != null &&
              (remaining == null || remaining < 0 || remaining > 60000) ||
          active == null && remaining != null) {
        throw const SaveFailure('Dữ liệu lưu bị lỗi.');
      }
      final oldActive = data['schemaVersion'] == 1 && active != null;
      final currentLevel = data['schemaVersion'] == schemaVersion
          ? progression['currentLevel'] as int
          : active ?? 0;
      if (currentLevel < 0 || currentLevel > 19) {
        throw const SaveFailure('Dữ liệu lưu bị lỗi.');
      }
      final migratedLives = oldActive ? (lives + 1).clamp(0, 3) : lives;
      return SaveRecord(
        lives: migratedLives,
        nextRefillAtMs: oldActive && migratedLives == 3 ? null : next,
        activeLevel: active,
        processedRewardIds: rewards.cast<String>().toSet(),
        highestUnlocked: progression['highestUnlocked'] as int,
        currentLevel: currentLevel,
        soundEnabled: settings['soundEnabled'] as bool,
        lastObservedAtMs: observed,
        introSeen: intro,
        attemptRemainingMs: remaining,
        sourceVersion: data['schemaVersion'] as int,
      );
    } on SaveFailure {
      rethrow;
    } catch (_) {
      throw const SaveFailure('Dữ liệu lưu bị lỗi.');
    }
  }
}

class SaveService {
  const SaveService(this.store);
  final SaveStore store;

  Future<SaveRecord?> load() async {
    try {
      final raw = await store.read();
      return raw == null ? null : SaveRecord.decode(raw);
    } on SaveFailure {
      rethrow;
    } catch (_) {
      throw const SaveFailure('Không đọc được dữ liệu lưu.');
    }
  }

  Future<void> save(SaveRecord record) async {
    try {
      await store.write(record.encode());
    } catch (_) {
      throw const SaveFailure('Không lưu được dữ liệu. Vui lòng thử lại.');
    }
  }
}
