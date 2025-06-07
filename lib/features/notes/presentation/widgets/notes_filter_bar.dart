import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';

class NotesFilterBar extends ConsumerWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const NotesFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = ref.watch(textDirectionProvider);
    
    final filters = _getFilters(l10n);
    
    return Directionality(
      textDirection: textDirection,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onFilterChanged(filter['value'] as String);
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: Theme.of(context).colorScheme.primary,
                checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                side: BorderSide(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilters(AppLocalizations l10n) {
    return [
      {
        'value': 'all',
        'label': l10n.allNotes,
        'icon': Icons.notes,
      },
      {
        'value': 'favorites',
        'label': l10n.favorites,
        'icon': Icons.favorite,
      },
      {
        'value': 'recent',
        'label': l10n.recent,
        'icon': Icons.access_time,
      },
      {
        'value': 'drawing',
        'label': l10n.drawing,
        'icon': Icons.draw,
      },
      {
        'value': 'handwriting',
        'label': l10n.handwriting,
        'icon': Icons.edit,
      },
      {
        'value': 'math',
        'label': l10n.math,
        'icon': MdiIcons.mathCompass,
      },
      {
        'value': 'archived',
        'label': l10n.archived,
        'icon': Icons.archive,
      },
    ];
  }
}