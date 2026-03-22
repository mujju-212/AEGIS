import 'package:flutter/material.dart';
import 'package:privacy_ai/features/memory/data/models/memory_entry.dart';

/// A single memory card — shown in the memory management screen.
class MemoryTile extends StatelessWidget {
  final MemoryEntry entry;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MemoryTile({
    super.key,
    required this.entry,
    required this.onPin,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: entry.isPinned
            ? colorScheme.primaryContainer.withOpacity(0.25)
            : colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: entry.isPinned
            ? Border.all(color: colorScheme.primary.withOpacity(0.4), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _CategoryBadge(category: entry.category),
        title: Text(
          entry.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _SourceChip(source: entry.source),
              const SizedBox(width: 8),
              if (entry.isPinned) ...[
                Icon(Icons.push_pin_rounded,
                    size: 12, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Pinned',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: colorScheme.primary),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _formatDate(entry.lastUsedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        trailing: _ActionMenu(
          isPinned: entry.isPinned,
          onPin: onPin,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _CategoryBadge extends StatelessWidget {
  final MemoryCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _color(category).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          category.emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Color _color(MemoryCategory cat) {
    switch (cat) {
      case MemoryCategory.personal:   return Colors.blue;
      case MemoryCategory.health:     return Colors.red;
      case MemoryCategory.preference: return Colors.amber;
      case MemoryCategory.work:       return Colors.indigo;
      case MemoryCategory.context:    return Colors.teal;
      case MemoryCategory.custom:     return Colors.grey;
    }
  }
}

class _SourceChip extends StatelessWidget {
  final MemorySource source;
  const _SourceChip({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label;
    Color color;
    switch (source) {
      case MemorySource.autoExtracted:
        label = 'Auto';
        color = Colors.green;
        break;
      case MemorySource.userAdded:
        label = 'Manual';
        color = Colors.blue;
        break;
      case MemorySource.imported:
        label = 'Imported';
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final bool isPinned;
  final VoidCallback onPin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionMenu({
    required this.isPinned,
    required this.onPin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'pin',
          child: Row(children: [
            Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                size: 16),
            const SizedBox(width: 8),
            Text(isPinned ? 'Unpin' : 'Pin (always include)'),
          ]),
        ),
        PopupMenuItem(
          value: 'edit',
          child: const Row(children: [
            Icon(Icons.edit_outlined, size: 16),
            SizedBox(width: 8),
            Text('Edit'),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Text('Forget this', style: TextStyle(color: Colors.red.shade400)),
          ]),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'pin':
            onPin();
            break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
    );
  }
}
