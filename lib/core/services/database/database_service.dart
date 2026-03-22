import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:privacy_ai/core/constants/app_constants.dart';
import 'package:privacy_ai/core/services/encryption/encryption_service.dart';

/// Privacy Vault — Encrypted local database.
/// Three separate encrypted stores as per architecture doc:
/// 1. Behavioural events store
/// 2. Learned patterns store  
/// 3. Settings and preferences store
class DatabaseService {
  final EncryptionService _encryption;

  Box? _mainBox;
  Box? _patternsBox;
  Box? _settingsBox;
  Box? _eventsBox;

  bool _initialized = false;

  DatabaseService(this._encryption);

  bool get isInitialized => _initialized;

  /// Initialize Hive and open encrypted boxes.
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Open all boxes
    _mainBox = await Hive.openBox(AppConstants.mainBoxName);
    _patternsBox = await Hive.openBox(AppConstants.patternsBoxName);
    _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
    _eventsBox = await Hive.openBox(AppConstants.eventsBoxName);

    _initialized = true;
  }

  // ─── Encrypted Read/Write ───────────────────────────────

  /// Store encrypted data in the events box.
  Future<void> storeEvent(String key, Map<String, dynamic> data) async {
    _ensureInitialized();
    final jsonStr = jsonEncode(data);
    final encrypted = _encryption.encrypt(jsonStr);
    await _eventsBox!.put(key, encrypted);

    // Enforce max events limit
    if (_eventsBox!.length > AppConstants.maxRawEvents) {
      await _eventsBox!.deleteAt(0); // Remove oldest
    }
  }

  /// Read and decrypt an event.
  Map<String, dynamic>? readEvent(String key) {
    _ensureInitialized();
    final encrypted = _eventsBox!.get(key);
    if (encrypted == null) return null;
    final jsonStr = _encryption.decrypt(encrypted as String);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  /// Store a learned pattern (encrypted).
  Future<void> storePattern(String key, Map<String, dynamic> data) async {
    _ensureInitialized();
    final jsonStr = jsonEncode(data);
    final encrypted = _encryption.encrypt(jsonStr);
    await _patternsBox!.put(key, encrypted);
  }

  /// Read a learned pattern.
  Map<String, dynamic>? readPattern(String key) {
    _ensureInitialized();
    final encrypted = _patternsBox!.get(key);
    if (encrypted == null) return null;
    final jsonStr = _encryption.decrypt(encrypted as String);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  /// Get all pattern keys.
  List<String> getAllPatternKeys() {
    _ensureInitialized();
    return _patternsBox!.keys.cast<String>().toList();
  }

  /// Get all event keys.
  List<String> getAllEventKeys() {
    _ensureInitialized();
    return _eventsBox!.keys.cast<String>().toList();
  }

  // ─── Settings (not encrypted — user preferences) ───────

  Future<void> saveSetting(String key, dynamic value) async {
    _ensureInitialized();
    await _settingsBox!.put(key, value);
  }

  T? readSetting<T>(String key) {
    _ensureInitialized();
    return _settingsBox!.get(key) as T?;
  }

  // ─── Deletion Controls (5 levels as per doc) ───────────

  /// Level 1: Delete single pattern.
  Future<void> deletePattern(String key) async {
    _ensureInitialized();
    await _patternsBox!.delete(key);
  }

  /// Level 2: Delete all data for a specific app hash.
  Future<void> deleteAppData(String appHash) async {
    _ensureInitialized();
    // Delete matching events
    final eventKeys = _eventsBox!.keys.where((k) {
      final data = readEvent(k as String);
      return data?['appHash'] == appHash;
    }).toList();
    for (final key in eventKeys) {
      await _eventsBox!.delete(key);
    }
    // Delete matching patterns
    final patternKeys = _patternsBox!.keys.where((k) {
      final data = readPattern(k as String);
      return data?['appHash'] == appHash;
    }).toList();
    for (final key in patternKeys) {
      await _patternsBox!.delete(key);
    }
  }

  /// Level 3: Delete data older than X days.
  Future<void> deleteOlderThan(int days) async {
    _ensureInitialized();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final keysToDelete = <dynamic>[];
    for (final key in _eventsBox!.keys) {
      final data = readEvent(key as String);
      if (data != null && data['timestamp'] != null) {
        final timestamp = DateTime.parse(data['timestamp'] as String);
        if (timestamp.isBefore(cutoff)) {
          keysToDelete.add(key);
        }
      }
    }
    for (final key in keysToDelete) {
      await _eventsBox!.delete(key);
    }
  }

  /// Level 5: Complete wipe — returns to Day 1.
  Future<void> wipeEverything() async {
    _ensureInitialized();
    await _eventsBox!.clear();
    await _patternsBox!.clear();
    await _settingsBox!.clear();
    await _mainBox!.clear();
  }

  /// Get storage stats for transparency dashboard.
  Map<String, dynamic> getStorageStats() {
    _ensureInitialized();
    return {
      'totalEvents': _eventsBox!.length,
      'totalPatterns': _patternsBox!.length,
      'totalSettings': _settingsBox!.length,
    };
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('DatabaseService not initialized. Call initialize() first.');
    }
  }

  Future<void> close() async {
    await _mainBox?.close();
    await _patternsBox?.close();
    await _settingsBox?.close();
    await _eventsBox?.close();
    _initialized = false;
  }
}
