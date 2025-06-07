import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../note_editor/presentation/pages/note_editor_page.dart';
import '../../data/models/note_model.dart';

class NoteCard extends ConsumerWidget {
  final NoteModel note;
  final bool isGridView;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const NoteCard({
    super.key,
    required this.note,
    this.isGridView = true,
    this.onTap,
    this.onDelete,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textDirection = ref.watch(textDirectionProvider);
    
    return RepaintBoundary(
      child: Directionality(
        textDirection: textDirection,
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showNoteOptions(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: isGridView 
                  ? const BoxConstraints(minHeight: 120)
                  : const BoxConstraints(minHeight: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: isGridView ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Favorite button
                      InkWell(
                        onTap: onToggleFavorite,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            note.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: note.isFavorite 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Content preview
                  if (_hasContent()) ...[
                    const SizedBox(height: 8),
                    Text(
                      _getPreviewContent(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: isGridView ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Footer with date, tags, and icons
                  Row(
                    children: [
                      Text(
                        _getDateText(l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_hasTags()) ...[
                        const SizedBox(width: 8),
                        _buildTagsPreview(context),
                      ],
                      const SizedBox(width: 8),
                      _buildNoteIcons(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    return note.title.trim().isEmpty
        ? 'Untitled Note'
        : note.title;
  }

  bool _hasContent() {
    return note.content.trim().isNotEmpty;
  }

  String _getPreviewContent() {
    return note.content.trim();
  }

  bool _hasTags() {
    return note.tagIds.isNotEmpty;
  }

  String _getDateText(AppLocalizations l10n) {
    final updatedAt = note.updatedAt;
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inDays > 7) {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? l10n.dayAgo : l10n.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? l10n.hourAgo : l10n.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? l10n.minuteAgo : l10n.minutesAgo}';
    } else {
      return l10n.justNow;
    }
  }

  Widget _buildNoteIcons() {
    final icons = <Widget>[];
    
    if (note.drawingData != null && note.drawingData!.isNotEmpty) {
      icons.add(Icon(
        MdiIcons.draw,
        size: 16,
        color: Colors.blue,
      ));
    }
    
    if (note.handwritingData != null && note.handwritingData!.isNotEmpty) {
      icons.add(Icon(
        MdiIcons.pencil,
        size: 16,
        color: Colors.green,
      ));
    }
    
    if (note.mathData != null && note.mathData!.isNotEmpty) {
      icons.add(Icon(
        MdiIcons.mathIntegral,
        size: 16,
        color: Colors.orange,
      ));
    }
    
    if (icons.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons.map((icon) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: icon,
      )).toList(),
    );
  }

  Widget _buildTagsPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${note.tagIds.length}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 10,
        ),
      ),
    );
  }

  void _openNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(
          noteId: note.id,
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _NoteOptionsSheet(
        note: note,
        onEdit: () {
          Navigator.pop(context);
          _openNote(context);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmation(context);
        },
        onToggleFavorite: () {
          Navigator.pop(context);
          if (onToggleFavorite != null) {
            onToggleFavorite!();
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _NoteOptionsSheet extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _NoteOptionsSheet({
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.edit),
            onTap: onEdit,
          ),
          ListTile(
            leading: Icon(
              note.isFavorite ? Icons.favorite_border : Icons.favorite,
            ),
            title: Text(
              note.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
            ),
            onTap: onToggleFavorite,
          ),
          ListTile(
            leading: Icon(
              Icons.delete,
              color: theme.colorScheme.error,
            ),
            title: Text(
              l10n.delete,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}