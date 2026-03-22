import 'package:uuid/uuid.dart';

/// Categories for memory entries — helps with display and filtering.
enum MemoryCategory {
  personal,    // Name, age, location, relationships
  health,      // Medical conditions, medications, fitness
  preference,  // Communication style, likes/dislikes
  work,        // Job, projects, skills
  context,     // Current goals, ongoing tasks
  custom,      // User-added manually
}

extension MemoryCategoryExtension on MemoryCategory {
  String get displayName {
    switch (this) {
      case MemoryCategory.personal:   return 'Personal';
      case MemoryCategory.health:     return 'Health';
      case MemoryCategory.preference: return 'Preference';
      case MemoryCategory.work:       return 'Work';
      case MemoryCategory.context:    return 'Context';
      case MemoryCategory.custom:     return 'Custom';
    }
  }

  String get emoji {
    switch (this) {
      case MemoryCategory.personal:   return '👤';
      case MemoryCategory.health:     return '🏥';
      case MemoryCategory.preference: return '⭐';
      case MemoryCategory.work:       return '💼';
      case MemoryCategory.context:    return '🎯';
      case MemoryCategory.custom:     return '📝';
    }
  }
}

/// How the memory was created.
enum MemorySource {
  autoExtracted,  // AI extracted it from a conversation automatically
  userAdded,      // User added it manually
  imported,       // Imported from ChatGPT or another AI tool
}

/// A single memory fact about the user.
/// Stored encrypted in Hive, injected into LLM system prompt.
class MemoryEntry {
  final String id;
  final String content;         // e.g. "User's name is Rahul"
  final MemoryCategory category;
  final MemorySource source;
  final DateTime createdAt;
  DateTime lastUsedAt;          // Updated each time it's injected into a prompt
  bool isPinned;                // Pinned memories are always included in context
  double confidence;            // 0.0–1.0, auto-extracted memories start lower

  MemoryEntry({
    String? id,
    required this.content,
    required this.category,
    this.source = MemorySource.userAdded,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    this.isPinned = false,
    this.confidence = 1.0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastUsedAt = lastUsedAt ?? DateTime.now();

  /// Serialise to Map for Hive storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'category': category.name,
        'source': source.name,
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt.toIso8601String(),
        'isPinned': isPinned,
        'confidence': confidence,
      };

  /// Deserialise from Hive storage.
  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
        id: json['id'] as String,
        content: json['content'] as String,
        category: MemoryCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => MemoryCategory.custom,
        ),
        source: MemorySource.values.firstWhere(
          (e) => e.name == json['source'],
          orElse: () => MemorySource.userAdded,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
        isPinned: json['isPinned'] as bool? ?? false,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      );

  MemoryEntry copyWith({
    String? content,
    MemoryCategory? category,
    bool? isPinned,
    double? confidence,
  }) =>
      MemoryEntry(
        id: id,
        content: content ?? this.content,
        category: category ?? this.category,
        source: source,
        createdAt: createdAt,
        lastUsedAt: lastUsedAt,
        isPinned: isPinned ?? this.isPinned,
        confidence: confidence ?? this.confidence,
      );

  @override
  String toString() => 'MemoryEntry($category: $content)';
}
