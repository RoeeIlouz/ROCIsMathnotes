import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../pages/notebook_notes_page.dart';
import '../../data/models/notebook_model.dart';
import '../../data/repositories/notebooks_repository.dart';
import '../providers/notebooks_provider.dart';

class NotebookCard extends ConsumerWidget {
  final NotebookModel notebook;
  final bool isGridView;

  const NotebookCard({
    super.key,
    required this.notebook,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _openNotebook(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and options
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotebookColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotebookIcon(),
                      color: _getNotebookColor(),
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showNotebookOptions(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                _getTitle(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Description (if available)
              if (_hasDescription()) ...[
                const SizedBox(height: 4),
                Text(
                  _getDescription(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Footer with note count and date
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getNoteCountText(l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  if (notebook.isFavorite)
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              
              // Date
              if (_getDateText(l10n).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _getDateText(l10n),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    return notebook.name.trim().isEmpty
        ? 'Untitled Notebook'
        : notebook.name;
  }

  bool _hasDescription() {
    final description = notebook.description ?? '';
    return description.trim().isNotEmpty;
  }

  String _getDescription() {
    final description = notebook.description ?? '';
    return description.trim();
  }

  Color _getNotebookColor() {
    final colorValue = notebook.color;
    if (colorValue != null) {
      return Color(colorValue);
    }
    return Colors.blue;
  }

  IconData _getNotebookIcon() {
    final iconName = notebook.iconName;
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'science':
        return Icons.science;
      case 'math':
        return MdiIcons.mathCompass;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      case 'travel':
        return Icons.flight;
      case 'food':
        return Icons.restaurant;
      case 'health':
        return Icons.favorite;
      case 'finance':
        return Icons.attach_money;
      default:
        return Icons.book;
    }
  }

  String _getNoteCountText(AppLocalizations l10n) {
    final noteCount = notebook.noteCount;
    if (noteCount == 0) {
      return l10n.noNotes;
    } else if (noteCount == 1) {
      return l10n.oneNote;
    } else {
      return l10n.notesCount(noteCount);
    }
  }

  String _getDateText(AppLocalizations l10n) {
    final updatedAt = notebook.updatedAt;
    
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

  void _openNotebook(BuildContext context) {
    // Navigate to notebook-specific notes page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotebookNotesPage(
          notebookId: notebook.id,
          notebookName: notebook.name,
        ),
      ),
    );
  }

  void _showNotebookOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => _NotebookOptionsSheet(
        notebook: notebook,
        l10n: l10n,
      ),
    );
  }
}

class _NotebookOptionsSheet extends StatelessWidget {
  final NotebookModel notebook;
  final AppLocalizations l10n;

  const _NotebookOptionsSheet({
    required this.notebook,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Options
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.editNotebook),
            onTap: () {
              Navigator.pop(context);
              // TODO: Edit notebook
            },
          ),
          
          ListTile(
            leading: Icon(
              notebook.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            title: Text(
              notebook.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Toggle favorite
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.copy),
            title: Text(l10n.duplicate),
            onTap: () {
              Navigator.pop(context);
              // TODO: Duplicate notebook
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(l10n.share),
            onTap: () {
              Navigator.pop(context);
              // TODO: Share notebook
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.delete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNotebook),
        content: Text(l10n.deleteNotebookConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNotebook(context);
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

  Future<void> _deleteNotebook(BuildContext context) async {
    try {
      final notebooksRepository = NotebooksRepository();
      final success = await notebooksRepository.deleteNotebook(notebook.id);
      
      if (success && context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notebookDeleted),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        // Refresh the notebooks list
        if (context.mounted) {
          // Find the nearest ConsumerWidget to refresh the provider
          final container = ProviderScope.containerOf(context);
          container.read(notebooksProvider.notifier).loadNotebooks();
        }
      } else if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingNotebook),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingNotebook),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}