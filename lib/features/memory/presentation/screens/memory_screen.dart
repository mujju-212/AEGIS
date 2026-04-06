import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';
import 'package:privacy_ai/core/providers.dart';
import 'package:privacy_ai/features/memory/data/models/memory_entry.dart';
import 'package:privacy_ai/features/memory/presentation/providers/memory_provider.dart';
import 'package:privacy_ai/features/memory/presentation/widgets/memory_tile.dart';

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedMemoryCategoryProvider);
    final memories = ref.watch(memoriesByCategoryProvider(selectedCategory));
    final memoryCount = ref.watch(memoryCountProvider);
    final isMemoryEnabled = ref.watch(isMemoryEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          IconButton(
            tooltip: 'Add memory',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddMemoryDialog(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context, ref),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'import', child: Text('Import memories')),
              PopupMenuItem(value: 'delete_all', child: Text('Delete all')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _MemoryHeader(
            isEnabled: isMemoryEnabled,
            memoryCount: memoryCount,
            onToggle: (value) {
              ref.read(isMemoryEnabledProvider.notifier).state = value;
              ref.read(databaseServiceProvider).saveSetting('memory_enabled', value);
            },
          ),
          _CategoryChips(
            selected: selectedCategory,
            onSelected: (category) {
              ref.read(selectedMemoryCategoryProvider.notifier).state = category;
            },
          ),
          Expanded(
            child: memories.isEmpty
                ? _EmptyState(isMemoryEnabled: isMemoryEnabled)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final entry = memories[index];
                      return MemoryTile(
                        entry: entry,
                        onPin: () => ref.read(memoryListProvider.notifier).togglePin(entry.id),
                        onEdit: () => _showEditDialog(context, ref, entry),
                        onDelete: () => _confirmDelete(context, ref, entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'import':
        _showImportDialog(context, ref);
        break;
      case 'delete_all':
        _confirmDeleteAll(context, ref);
        break;
    }
  }

  Future<void> _showAddMemoryDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    MemoryCategory selected = MemoryCategory.personal;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add memory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. I prefer short replies',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MemoryCategory>(
              value: selected,
              decoration: const InputDecoration(labelText: 'Category'),
              items: MemoryCategory.values.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.displayName));
              }).toList(),
              onChanged: (value) {
                if (value != null) selected = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        await ref.read(memoryListProvider.notifier).addMemory(text, selected);
      }
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    MemoryEntry entry,
  ) async {
    final controller = TextEditingController(text: entry.content);
    MemoryCategory selected = entry.category;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit memory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Update memory content',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MemoryCategory>(
              value: selected,
              decoration: const InputDecoration(labelText: 'Category'),
              items: MemoryCategory.values.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.displayName));
              }).toList(),
              onChanged: (value) {
                if (value != null) selected = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        await ref.read(memoryListProvider.notifier).updateMemory(
              entry.copyWith(content: text, category: selected),
            );
      }
    }
  }

  Future<void> _showImportDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    bool isJson = true;

    final imported = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import memories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('JSON')),
                ButtonSegment(value: false, label: Text('Plain text')),
              ],
              selected: {isJson},
              onSelectionChanged: (value) => isJson = value.first,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: isJson
                    ? 'Paste JSON export here'
                    : 'One memory per line',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (imported == true) {
      final text = controller.text.trim();
      if (text.isEmpty) return;
      int count = 0;
      if (isJson) {
        count = await ref.read(memoryListProvider.notifier).importFromChatGptJson(text);
      } else {
        count = await ref.read(memoryListProvider.notifier).importFromPlainText(text);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported $count memories')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forget this memory?'),
        content: const Text(
          'This will permanently remove the memory from your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(memoryListProvider.notifier).deleteMemory(id);
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all memories?'),
        content: const Text(
          'This will permanently remove all memories stored on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(memoryListProvider.notifier).deleteAll();
    }
  }
}

class _MemoryHeader extends StatelessWidget {
  final bool isEnabled;
  final int memoryCount;
  final ValueChanged<bool> onToggle;

  const _MemoryHeader({
    required this.isEnabled,
    required this.memoryCount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.memory_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Memory is ${isEnabled ? 'on' : 'off'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$memoryCount saved memories',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final MemoryCategory? selected;
  final ValueChanged<MemoryCategory?> onSelected;

  const _CategoryChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <MemoryCategory?>[null, ...MemoryCategory.values];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = chips[index];
          final isSelected = category == selected;
          final label = category == null ? 'All' : category.displayName;
          return ChoiceChip(
            selected: isSelected,
            label: Text(label),
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isMemoryEnabled;

  const _EmptyState({required this.isMemoryEnabled});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              isMemoryEnabled
                  ? 'No memories yet'
                  : 'Memory is disabled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              isMemoryEnabled
                  ? 'Add a memory or chat to let the AI learn.'
                  : 'Turn memory on to let the AI remember key details.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
