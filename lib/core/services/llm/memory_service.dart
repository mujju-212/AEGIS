import 'package:privacy_ai/features/memory/data/models/memory_entry.dart';
import 'package:privacy_ai/features/memory/data/repositories/memory_repository.dart';

/// Orchestrates all memory operations for the LLM layer.
///
/// Two core responsibilities:
///  1. INJECTION  — builds a memory-enriched system prompt prefix so the
///                  LLM "knows" facts about the user across sessions.
///  2. EXTRACTION — after each user message, quickly scans for personal
///                  facts worth remembering (pattern-based, no LLM call needed).
class MemoryService {
  final MemoryRepository _repo;

  /// How many memories to inject per LLM call.
  /// Pinned memories are always included; remaining slots go to most-recently-used.
  static const int _maxInjected = 15;

  /// How many memories to hold total before pruning low-confidence old ones.
  static const int _maxTotal = 200;

  MemoryService(this._repo);

  // ─── INJECTION ──────────────────────────────────────────────────────

  /// Returns a system prompt prefix block containing the user's memories.
  /// Returns empty string if no memories exist.
  String buildMemoryBlock() {
    final all = _repo.getAll();
    if (all.isEmpty) return '';

    // Pinned always in, rest ordered by lastUsedAt
    final pinned = all.where((e) => e.isPinned).toList();
    final unpinned = all.where((e) => !e.isPinned).toList();

    final selected = <MemoryEntry>[
      ...pinned,
      ...unpinned.take((_maxInjected - pinned.length).clamp(0, _maxInjected)),
    ];

    // Update lastUsedAt for all selected
    for (final entry in selected) {
      _repo.markUsed(entry.id);
    }

    final buffer = StringBuffer();
    buffer.writeln('## What I know about you (remembered from past conversations)');
    buffer.writeln('');
    for (final entry in selected) {
      buffer.writeln('- ${entry.content}');
    }
    buffer.writeln('');
    buffer.writeln('(You can ask me to forget anything above at any time.)');
    buffer.writeln('');
    return buffer.toString();
  }

  /// Full system prompt for a conversation = memory block + base instructions.
  String buildSystemPrompt(String basePrompt) {
    final memBlock = buildMemoryBlock();
    if (memBlock.isEmpty) return basePrompt;
    return '$memBlock$basePrompt';
  }

  // ─── EXTRACTION ─────────────────────────────────────────────────────

  /// Scans a user message for personal facts and returns discovered memories.
  /// Caller decides whether to auto-save or ask the user first.
  Future<List<MemoryEntry>> extractFromMessage(String userMessage) async {
    final discovered = <MemoryEntry>[];
    final msg = userMessage.toLowerCase().trim();

    // ── Name patterns ─────
    _tryExtract(msg, userMessage, [
      RegExp(r"my name(?:'s| is) ([A-Z][a-z]+(?: [A-Z][a-z]+)*)", caseSensitive: false),
      RegExp(r"i(?:'m| am) called ([A-Z][a-z]+)", caseSensitive: false),
      RegExp(r"call me ([A-Z][a-z]+)", caseSensitive: false),
    ], MemoryCategory.personal, 'User\'s name is', discovered);

    // ── Age ───────────────
    _tryExtract(msg, userMessage, [
      RegExp(r"i(?:'m| am) (\d{1,2}) years? old", caseSensitive: false),
      RegExp(r"my age is (\d{1,2})", caseSensitive: false),
      RegExp(r"i(?:'m| am) (\d{1,2})", caseSensitive: false),
    ], MemoryCategory.personal, 'User is', discovered, suffix: 'years old');

    // ── Location ─────────
    _tryExtract(msg, userMessage, [
      RegExp(r"i(?:'m| am) from ([A-Z][a-z]+(?: [A-Z][a-z]+)*)", caseSensitive: false),
      RegExp(r"i live in ([A-Z][a-z]+(?: [A-Z][a-z]+)*)", caseSensitive: false),
      RegExp(r"based in ([A-Z][a-z]+(?: [A-Z][a-z]+)*)", caseSensitive: false),
    ], MemoryCategory.personal, 'User is from', discovered);

    // ── Job/Work ─────────
    _tryExtract(msg, userMessage, [
      RegExp(r"i(?:'m| am) a(?:n)? ([a-z]+(?: [a-z]+){0,3})", caseSensitive: false),
      RegExp(r"i work as a(?:n)? ([a-z]+(?: [a-z]+){0,2})", caseSensitive: false),
      RegExp(r"my job is ([a-z]+(?: [a-z]+){0,2})", caseSensitive: false),
    ], MemoryCategory.work, 'User works as', discovered,
        excludeWords: ['sure', 'not', 'trying', 'going', 'thinking', 'looking', 'wondering', 'planning', 'busy', 'happy', 'sad']);

    // ── Health ───────────
    _tryHealthPatterns(msg, userMessage, discovered);

    // ── Preferences ──────
    _tryPreferencePatterns(msg, userMessage, discovered);

    // ── Projects/Goals ───
    _tryGoalPatterns(userMessage, discovered);

    // Remove near-duplicates before returning
    return _deduplicate(discovered);
  }

  /// Convenience: extract AND auto-save (for low-risk facts with high confidence).
  Future<List<MemoryEntry>> extractAndSave(String userMessage) async {
    final extracted = await extractFromMessage(userMessage);
    for (final entry in extracted) {
      // Check it's not already stored (content similarity check)
      final existing = _repo.getAll();
      final isDuplicate = existing.any((e) =>
          _similarity(e.content.toLowerCase(), entry.content.toLowerCase()) > 0.75);
      if (!isDuplicate) {
        await _repo.save(entry);
      }
    }
    // Prune if over limit
    await _pruneIfNeeded();
    return extracted;
  }

  // ─── FORGET / COMMANDS ──────────────────────────────────────────────

  /// Handle natural language forget commands from the user.
  /// e.g. "forget my name", "forget everything about health"
  /// Returns number of memories deleted.
  Future<int> handleForgetCommand(String userMessage) async {
    final msg = userMessage.toLowerCase();
    int deleted = 0;

    if (msg.contains('forget everything') || msg.contains('forget all')) {
      deleted = _repo.count;
      await _repo.deleteAll();
      return deleted;
    }

    for (final cat in MemoryCategory.values) {
      if (msg.contains(cat.name.toLowerCase()) ||
          msg.contains(cat.displayName.toLowerCase())) {
        final entries = _repo.getByCategory(cat);
        for (final e in entries) {
          await _repo.delete(e.id);
          deleted++;
        }
      }
    }

    // Try to match specific content
    if (deleted == 0) {
      final all = _repo.getAll();
      for (final entry in all) {
        final words = entry.content.toLowerCase().split(' ');
        final matchCount = words.where((w) => w.length > 4 && msg.contains(w)).length;
        if (matchCount >= 2) {
          await _repo.delete(entry.id);
          deleted++;
        }
      }
    }

    return deleted;
  }

  /// Check if the user's message is a forget command.
  bool isForgetCommand(String userMessage) {
    final msg = userMessage.toLowerCase();
    return msg.contains('forget') &&
        (msg.contains('my') ||
            msg.contains('that') ||
            msg.contains('everything') ||
            msg.contains('all'));
  }

  // ─── STATS ──────────────────────────────────────────────────────────

  int get totalMemories => _repo.count;

  Map<MemoryCategory, int> get memoriesByCategory {
    final all = _repo.getAll();
    final result = <MemoryCategory, int>{};
    for (final cat in MemoryCategory.values) {
      result[cat] = all.where((e) => e.category == cat).length;
    }
    return result;
  }

  // ─── Private helpers ────────────────────────────────────────────────

  void _tryExtract(
    String msgLower,
    String msgOriginal,
    List<RegExp> patterns,
    MemoryCategory category,
    String prefix,
    List<MemoryEntry> results, {
    String? suffix,
    List<String>? excludeWords,
  }) {
    for (final re in patterns) {
      final match = re.firstMatch(msgOriginal);
      if (match != null && match.groupCount >= 1) {
        final captured = match.group(1)?.trim() ?? '';
        if (captured.isEmpty) continue;
        if (excludeWords != null &&
            excludeWords.any((w) => captured.toLowerCase().contains(w))) continue;
        final content = suffix != null
            ? '$prefix $captured $suffix'.trim()
            : '$prefix $captured'.trim();
        results.add(MemoryEntry(
          content: content,
          category: category,
          source: MemorySource.autoExtracted,
          confidence: 0.75,
        ));
        return; // Only first match per pattern group
      }
    }
  }

  void _tryHealthPatterns(
      String msgLower, String msgOriginal, List<MemoryEntry> results) {
    final healthKeywords = [
      'diabetes', 'hypertension', 'asthma', 'depression', 'anxiety',
      'allergy', 'migraine', 'arthritis', 'cholesterol', 'thyroid',
    ];
    for (final kw in healthKeywords) {
      if (msgLower.contains(kw)) {
        results.add(MemoryEntry(
          content: 'User has/mentioned $kw',
          category: MemoryCategory.health,
          source: MemorySource.autoExtracted,
          confidence: 0.70,
        ));
      }
    }
    // Medication pattern: "I take X"
    final medRe = RegExp(r"i take ([a-zA-Z]+(?: [a-zA-Z]+)?)(?: for| to| daily)?",
        caseSensitive: false);
    final medMatch = medRe.firstMatch(msgOriginal);
    if (medMatch != null) {
      results.add(MemoryEntry(
        content: 'User takes ${medMatch.group(1)?.trim()}',
        category: MemoryCategory.health,
        source: MemorySource.autoExtracted,
        confidence: 0.70,
      ));
    }
  }

  void _tryPreferencePatterns(
      String msgLower, String msgOriginal, List<MemoryEntry> results) {
    final prefRe = RegExp(
        r"i (?:prefer|like|love|hate|dislike|want) (.{5,60}?)(?:\.|,|$)",
        caseSensitive: false);
    final matches = prefRe.allMatches(msgOriginal).take(2);
    for (final m in matches) {
      final pref = m.group(1)?.trim();
      if (pref != null && pref.isNotEmpty) {
        results.add(MemoryEntry(
          content: 'User preference: ${m.group(0)?.trim()}',
          category: MemoryCategory.preference,
          source: MemorySource.autoExtracted,
          confidence: 0.65,
        ));
      }
    }
  }

  void _tryGoalPatterns(String msgOriginal, List<MemoryEntry> results) {
    final goalRe = RegExp(
        r"i(?:'m| am) (?:currently |actively )?(?:building|working on|learning|developing|creating|making) (.{5,80}?)(?:\.|,|$)",
        caseSensitive: false);
    final match = goalRe.firstMatch(msgOriginal);
    if (match != null) {
      results.add(MemoryEntry(
        content: 'User is working on: ${match.group(1)?.trim()}',
        category: MemoryCategory.context,
        source: MemorySource.autoExtracted,
        confidence: 0.70,
      ));
    }
  }

  List<MemoryEntry> _deduplicate(List<MemoryEntry> entries) {
    final seen = <String>[];
    return entries.where((e) {
      for (final s in seen) {
        if (_similarity(e.content.toLowerCase(), s) > 0.8) return false;
      }
      seen.add(e.content.toLowerCase());
      return true;
    }).toList();
  }

  Future<void> _pruneIfNeeded() async {
    final all = _repo.getAll();
    if (all.length <= _maxTotal) return;

    // Delete unpinned, low-confidence, oldest entries first
    final prunable = all
        .where((e) => !e.isPinned && e.confidence < 0.7)
        .toList()
      ..sort((a, b) => a.lastUsedAt.compareTo(b.lastUsedAt));

    final toDelete = prunable.take(all.length - _maxTotal);
    for (final e in toDelete) {
      await _repo.delete(e.id);
    }
  }

  /// Very lightweight Jaccard-like word similarity (0.0–1.0).
  double _similarity(String a, String b) {
    final setA = a.split(' ').toSet();
    final setB = b.split(' ').toSet();
    if (setA.isEmpty || setB.isEmpty) return 0.0;
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return intersection / union;
  }
}
