import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';

class NotesSortMenu extends ConsumerWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  const NotesSortMenu({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = ref.watch(textDirectionProvider);
    
    final sortOptions = _getSortOptions(l10n);
    final selectedOption = sortOptions.firstWhere(
      (option) => option['value'] == selectedSort,
      orElse: () => sortOptions.first,
    );
    
    return Directionality(
      textDirection: textDirection,
      child: PopupMenuButton<String>(
        onSelected: onSortChanged,
        itemBuilder: (context) => sortOptions.map((option) {
          final isSelected = option['value'] == selectedSort;
          return PopupMenuItem<String>(
            value: option['value'] as String,
            child: Row(
              children: [
                Icon(
                  option['icon'] as IconData,
                  size: 20,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option['label'] as String,
                    style: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedOption['icon'] as IconData,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                selectedOption['label'] as String,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        tooltip: l10n.sortBy,
      ),
    );
  }

  List<Map<String, dynamic>> _getSortOptions(AppLocalizations l10n) {
    return [
      {
        'value': 'modified',
        'label': l10n.lastModified,
        'icon': Icons.schedule,
      },
      {
        'value': 'created',
        'label': l10n.dateCreated,
        'icon': Icons.calendar_today,
      },
      {
        'value': 'title',
        'label': l10n.title,
        'icon': Icons.sort_by_alpha,
      },
      {
        'value': 'size',
        'label': l10n.size,
        'icon': Icons.data_usage,
      },
    ];
  }
}