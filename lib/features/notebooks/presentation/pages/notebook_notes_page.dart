import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../note_editor/presentation/pages/note_editor_page.dart';

class NotebookNotesPage extends ConsumerStatefulWidget {
  final String notebookId;
  final String notebookName;

  const NotebookNotesPage({
    super.key,
    required this.notebookId,
    required this.notebookName,
  });

  @override
  ConsumerState<NotebookNotesPage> createState() => _NotebookNotesPageState();
}

class _NotebookNotesPageState extends ConsumerState<NotebookNotesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Load notes for this specific notebook
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesProvider.notifier).loadNotesByNotebook(widget.notebookId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _createNewNote() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteEditorPage(),
      ),
    );
    // Refresh notes list when returning from note editor
    ref.read(notesProvider.notifier).loadNotesByNotebook(widget.notebookId);
  }

  void _editNote(NoteModel note) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(
          noteId: note.id,
        ),
      ),
    );
    // Refresh notes list when returning from note editor
    ref.read(notesProvider.notifier).loadNotesByNotebook(widget.notebookId);
  }

  void _deleteNote(NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteNote),
        content: Text(AppLocalizations.of(context)!.deleteNoteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(notesProvider.notifier).deleteNote(note.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.success),
                  ),
                );
                // Reload notes for this notebook
                ref.read(notesProvider.notifier).loadNotesByNotebook(widget.notebookId);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(NoteModel note) async {
    final success = await ref.read(notesProvider.notifier).toggleFavorite(note.id);
    if (success) {
      // Reload notes for this notebook
      ref.read(notesProvider.notifier).loadNotesByNotebook(widget.notebookId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = ref.watch(textDirectionProvider);
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.notebookName),
          actions: [
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.view_module,
              ),
              onPressed: _toggleViewMode,
              tooltip: _isGridView ? l10n.listView : l10n.gridView,
            ),
          ],
        ),
        body: _buildNotesContent(),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "notebook_notes_fab",
          onPressed: _createNewNote,
          icon: const Icon(Icons.add),
          label: Text(l10n.createNote),
        ),
      ),
    );
  }

  Widget _buildNotesContent() {
    final l10n = AppLocalizations.of(context)!;
    final notesState = ref.watch(notesProvider);
    
    return notesState.when(
      data: (notes) {
        if (notes.isEmpty) {
          return _buildEmptyState();
        }
        
        return _isGridView
            ? _buildGridView(notes)
            : _buildListView(notes);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notesProvider.notifier).loadNotesByNotebook(widget.notebookId),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 80,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noNotesYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first note in this notebook',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _createNewNote,
              icon: const Icon(Icons.add),
              label: Text(l10n.createNote),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<NoteModel> notes) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: _getCrossAxisCount(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: notes[index],
            isGridView: true,
            onTap: () => _editNote(notes[index]),
            onDelete: () => _deleteNote(notes[index]),
            onToggleFavorite: () => _toggleFavorite(notes[index]),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<NoteModel> notes) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return NoteCard(
          note: notes[index],
          isGridView: false,
          onTap: () => _editNote(notes[index]),
          onDelete: () => _deleteNote(notes[index]),
          onToggleFavorite: () => _toggleFavorite(notes[index]),
        );
      },
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}