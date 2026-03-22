import 'dart:convert';
import 'package:privacy_ai/core/services/database/database_service.dart';
import 'package:privacy_ai/core/services/encryption/encryption_service.dart';
import 'package:privacy_ai/features/memory/data/models/memory_entry.dart';

/// Low-level CRUD for memory entries.
/// All data is encrypted via EncryptionService before touching Hive.
class MemoryRepository {
  final DatabaseService _db;
  final EncryptionService _encryption;

  MemoryRepository(this._db, this._encryption);

  // ─── Box key prefix ─────────────────────────────────────

  static const String _prefix = 'mem_';

  String _key(String id) => '$_prefix$id';

  // ─── Write ──────────────────────────────────────────────

  /// Save or update a memory entry (encrypted).
  Future<void> save(MemoryEntry entry) async {
    final json = jsonEncode(entry.toJson());
    final encrypted = _encryption.encrypt(json);
    await _db.saveMemory(_key(entry.id), encrypted);
  }

  /// Save multiple entries at once (e.g. during import).
  Future<void> saveAll(List<MemoryEntry> entries) async {
    for (final entry in entries) {
      await save(entry);
    }
  }

  // ─── Read ───────────────────────────────────────────────

  /// Load a single memory entry by ID. Returns null if not found.
  MemoryEntry? getById(String id) {
    final encrypted = _db.readMemory(_key(id));
    if (encrypted == null) return null;
    try {
      final json = _encryption.decrypt(encrypted);
      return MemoryEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Load all memory entries, sorted by pinned first, then most recently used.
  List<MemoryEntry> getAll() {
    final keys = _db.getAllMemoryKeys();
    final entries = <MemoryEntry>[];

    for (final key in keys) {
      final encrypted = _db.readMemory(key);
      if (encrypted == null) continue;
      try {
        final json = _encryption.decrypt(encrypted);
        entries.add(MemoryEntry.fromJson(jsonDecode(json) as Map<String, dynamic>));
      } catch (_) {
        // Corrupted entry — skip silently
      }
    }

    // Sort: pinned first, then by lastUsedAt descending
    entries.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.lastUsedAt.compareTo(a.lastUsedAt);
    });

    return entries;
  }

  /// Get all entries for a specific category.
  List<MemoryEntry> getByCategory(MemoryCategory category) =>
      getAll().where((e) => e.category == category).toList();

  /// Count total memories.
  int get count => _db.getAllMemoryKeys().length;

  // ─── Update convenience ─────────────────────────────────

  /// Toggle pin state.
  Future<void> togglePin(String id) async {
    final entry = getById(id);
    if (entry == null) return;
    entry.isPinned = !entry.isPinned;
    await save(entry);
  }

  /// Update the lastUsedAt timestamp (called when memory is injected into prompt).
  Future<void> markUsed(String id) async {
    final entry = getById(id);
    if (entry == null) return;
    entry.lastUsedAt = DateTime.now();
    await save(entry);
  }

  // ─── Delete ─────────────────────────────────────────────

  /// Delete a single memory entry by ID.
  Future<void> delete(String id) async {
    await _db.deleteMemory(_key(id));
  }

  /// Delete all memories of a given category.
  Future<void> deleteByCategory(MemoryCategory category) async {
    final entries = getByCategory(category);
    for (final entry in entries) {
      await delete(entry.id);
    }
  }

  /// Wipe all memories.
  Future<void> deleteAll() async {
    final keys = _db.getAllMemoryKeys();
    for (final key in keys) {
      await _db.deleteMemory(key);
    }
  }

  // ─── Import ─────────────────────────────────────────────

  /// Import from ChatGPT memory export JSON.
  /// ChatGPT exports an array like: [{"title": "...", "content": "..."}]
  /// We flatten into MemoryEntry with source = imported.
  Future<int> importFromChatGptJson(String jsonString) async {
    int count = 0;
    try {
      final decoded = jsonDecode(jsonString);
      List<dynamic> items;

      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map && decoded.containsKey('memories')) {
        items = decoded['memories'] as List<dynamic>;
      } else {
        return 0;
      }

      for (final item in items) {
        String? text;
        if (item is Map) {
          text = (item['content'] ?? item['text'] ?? item['memory'] ?? item['title'])?.toString();
        } else if (item is String) {
          text = item;
        }

        if (text == null || text.trim().isEmpty) continue;

        final entry = MemoryEntry(
          content: text.trim(),
          category: _inferCategory(text),
          source: MemorySource.imported,
          confidence: 0.85,
        );
        await save(entry);
        count++;
      }
    } catch (_) {
      // Invalid JSON — caller should show error
    }
    return count;
  }

  /// Import from plain text — one memory per line.
  Future<int> importFromPlainText(String text) async {
    int count = 0;
    final lines = text.split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && l.length > 5)
        .toList();

    for (final line in lines) {
      final entry = MemoryEntry(
        content: line,
        category: _inferCategory(line),
        source: MemorySource.imported,
        confidence: 0.80,
      );
      await save(entry);
      count++;
    }
    return count;
  }

  // ─── Helpers ────────────────────────────────────────────

  /// Naive keyword-based category guesser for imported/auto memories.
  MemoryCategory _inferCategory(String text) {
    final lower = text.toLowerCase();
    if (_matchesAny(lower, ['sick', 'doctor', 'medicine', 'diabetes', 'blood', 'health', 'allergy', 'anxiety', 'medication', 'hospital'])) {
      return MemoryCategory.health;
    }
    if (_matchesAny(lower, ['job', 'work', 'project', 'company', 'engineer', 'developer', 'role', 'team', 'manager', 'office'])) {
      return MemoryCategory.work;
    }
    if (_matchesAny(lower, ['prefer', 'like', 'love', 'hate', 'dislike', 'want', 'favorite', 'favourite', 'style', 'tone', 'language'])) {
      return MemoryCategory.preference;
    }
    if (_matchesAny(lower, ['goal', 'trying', 'learning', 'building', 'task', 'currently', 'working on', 'focus'])) {
      return MemoryCategory.context;
    }
    if (_matchesAny(lower, ['name is', 'live', 'from', 'age', 'years old', 'birthday', 'city', 'country', 'family', 'wife', 'husband', 'kids', 'parents'])) {
      return MemoryCategory.personal;
    }
    return MemoryCategory.custom;
  }

  bool _matchesAny(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw));
}
