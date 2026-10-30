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
    required this.soundEnabled,
    required this.lastObservedAtMs,
    this.sourceVersion = schemaVersion,
  });

  static const schemaVersion = 2;
  static const fresh = SaveRecord(
    lives: 3,
    nextRefillAtMs: null,
    activeLevel: null,
    processedRewardIds: {},
    highestUnlocked: 0,
    soundEnabled: true,
    lastObservedAtMs: 0,
  );

  final int lives;
  final int? nextRefillAtMs;
  final int? activeLevel;
  final Set<String> processedRewardIds;
  final int highestUnlocked;
  final bool soundEnabled;
  final int lastObservedAtMs;

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
    bool? soundEnabled,
    int? lastObservedAtMs,
  }) => SaveRecord(
    lives: lives ?? this.lives,
    nextRefillAtMs: clearRefill ? null : nextRefillAtMs ?? this.nextRefillAtMs,
    activeLevel: clearAttempt ? null : activeLevel ?? this.activeLevel,
    processedRewardIds: processedRewardIds ?? this.processedRewardIds,
    highestUnlocked: highestUnlocked ?? this.highestUnlocked,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    lastObservedAtMs: lastObservedAtMs ?? this.lastObservedAtMs,
    sourceVersion: sourceVersion,
  );

  String encode() => jsonEncode({
    'schemaVersion': schemaVersion,
    'lives': lives,
    'nextRefillAt': nextRefillAtMs,
    'activeAttempt': activeLevel,
    'processedRewardIds': processedRewardIds.toList()..sort(),
    'progression': {'highestUnlocked': highestUnlocked},
    'settings': {'soundEnabled': soundEnabled},
    'lastObservedAt': lastObservedAtMs,
  });

  static SaveRecord decode(String source) {
    try {
      final data = jsonDecode(source);
      if (data is! Map<String, dynamic> ||
          (data['schemaVersion'] != 1 &&
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
      if (lives is! int ||
          next != null && next is! int ||
          active != null && active is! int ||
          rewards is! List ||
          rewards.any((item) => item is! String || item.isEmpty) ||
          progression is! Map ||
          progression['highestUnlocked'] is! int ||
          settings is! Map ||
          settings['soundEnabled'] is! bool ||
          observed is! int ||
          observed < 0 ||
          next != null && next < 0 ||
          active != null && (active < 0 || active > 19)) {
        throw const SaveFailure('Dữ liệu lưu bị lỗi.');
      }
      final oldActive = data['schemaVersion'] == 1 && active != null;
      final migratedLives = oldActive ? (lives + 1).clamp(0, 3) : lives;
      return SaveRecord(
        lives: migratedLives,
        nextRefillAtMs: oldActive && migratedLives == 3 ? null : next,
        activeLevel: active,
        processedRewardIds: rewards.cast<String>().toSet(),
        highestUnlocked: progression['highestUnlocked'] as int,
        soundEnabled: settings['soundEnabled'] as bool,
        lastObservedAtMs: observed,
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
