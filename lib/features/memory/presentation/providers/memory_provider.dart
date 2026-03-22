import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacy_ai/core/providers.dart';
import 'package:privacy_ai/core/services/encryption/encryption_service.dart';
import 'package:privacy_ai/core/services/llm/memory_service.dart';
import 'package:privacy_ai/features/memory/data/models/memory_entry.dart';
import 'package:privacy_ai/features/memory/data/repositories/memory_repository.dart';

// ─── Repository ──────────────────────────────────────────────────────

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final encryption = ref.watch(encryptionServiceProvider);
  return MemoryRepository(db, encryption);
});

// ─── Service ─────────────────────────────────────────────────────────

final memoryServiceProvider = Provider<MemoryService>((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  return MemoryService(repo);
});

// ─── State: all memories (refreshable list) ──────────────────────────

class MemoryListNotifier extends StateNotifier<List<MemoryEntry>> {
  final MemoryRepository _repo;

  MemoryListNotifier(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  void refresh() => _load();

  Future<void> addMemory(String content, MemoryCategory category) async {
    final entry = MemoryEntry(
      content: content.trim(),
      category: category,
      source: MemorySource.userAdded,
    );
    await _repo.save(entry);
    _load();
  }

  Future<void> updateMemory(MemoryEntry updated) async {
    await _repo.save(updated);
    _load();
  }

  Future<void> togglePin(String id) async {
    await _repo.togglePin(id);
    _load();
  }

  Future<void> deleteMemory(String id) async {
    await _repo.delete(id);
    _load();
  }

  Future<void> deleteAll() async {
    await _repo.deleteAll();
    _load();
  }

  Future<int> importFromChatGptJson(String jsonString) async {
    final count = await _repo.importFromChatGptJson(jsonString);
    _load();
    return count;
  }

  Future<int> importFromPlainText(String text) async {
    final count = await _repo.importFromPlainText(text);
    _load();
    return count;
  }
}

final memoryListProvider =
    StateNotifierProvider<MemoryListNotifier, List<MemoryEntry>>((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  return MemoryListNotifier(repo);
});

// ─── Filtered by category ─────────────────────────────────────────────

final memoriesByCategoryProvider =
    Provider.family<List<MemoryEntry>, MemoryCategory?>((ref, category) {
  final all = ref.watch(memoryListProvider);
  if (category == null) return all;
  return all.where((e) => e.category == category).toList();
});

// ─── Selected category filter ─────────────────────────────────────────

final selectedMemoryCategoryProvider =
    StateProvider<MemoryCategory?>((ref) => null);

// ─── Memory count ─────────────────────────────────────────────────────

final memoryCountProvider = Provider<int>((ref) {
  return ref.watch(memoryListProvider).length;
});

// ─── Is memory enabled setting ────────────────────────────────────────

final isMemoryEnabledProvider = StateProvider<bool>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.readSetting<bool>('memory_enabled') ?? true;
});
