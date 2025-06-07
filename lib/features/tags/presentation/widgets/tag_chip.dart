import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/tag_model.dart';

class TagChipWidget extends ConsumerWidget {
  final TagModel tag;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool selected;

  const TagChipWidget({
    super.key,
    required this.tag,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textDirection = ref.watch(textDirectionProvider);
    
    return Directionality(
      textDirection: textDirection,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          onLongPress: showActions ? () => _showTagOptions(context, l10n) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Tag color indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: tag.colorValue,
                    shape: BoxShape.circle,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Tag info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.notes,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tag.usageText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getAgeText(l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tag indicators
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tag.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.popular,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    
                    if (tag.isRecent) ...[
                      if (tag.isPopular) const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.new_,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    
                    if (showActions) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 12),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.delete,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAgeText(AppLocalizations l10n) {
    final age = tag.age;
    
    if (age.inDays > 30) {
      final months = (age.inDays / 30).floor();
      return months == 1 ? l10n.monthAgo : l10n.monthsAgo(months);
    } else if (age.inDays > 0) {
      return age.inDays == 1 ? l10n.dayAgo : l10n.daysAgo(age.inDays);
    } else if (age.inHours > 0) {
      return age.inHours == 1 ? l10n.hourAgo : l10n.hoursAgo(age.inHours);
    } else if (age.inMinutes > 0) {
      return age.inMinutes == 1 ? l10n.minuteAgo : l10n.minutesAgo(age.inMinutes);
    } else {
      return l10n.justNow;
    }
  }

  void _showTagOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Tag preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: tag.colorValue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tag.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Options
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text(l10n.viewNotes),
              onTap: () {
                Navigator.pop(context);
                onTap?.call();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editTag),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.deleteTag,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Simple tag chip for use in other widgets
class SimpleTagChip extends StatelessWidget {
  final TagModel tag;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const SimpleTagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return tag.buildChip(
      onTap: onTap,
      onDeleted: onDeleted,
      selected: selected,
    );
  }
}

// Filter chip for tag filtering
class TagFilterChip extends StatelessWidget {
  final TagModel tag;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const TagFilterChip({
    super.key,
    required this.tag,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return tag.buildFilterChip(
      selected: selected,
      onSelected: onSelected,
    );
  }
}