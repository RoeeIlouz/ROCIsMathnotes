import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathnotes/core/theme/font_awesome4_icons.dart';
import 'package:mathnotes/l10n/app_localizations.dart';

import '../../../note_editor/presentation/pages/note_editor_page.dart';
import '../../data/models/note_model.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  dynamic _viewMode = 'ViewMode.grid';
  dynamic _filter = 'NoteFilter.all';
  dynamic _sort = 'NoteSort.dateModified';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesProvider.notifier).loadNotes();
    });
  }



  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == 'ViewMode.grid' ? 'ViewMode.list' : 'ViewMode.grid';
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  void _onSortChanged(String sort) {
    setState(() {
      _sort = sort;
    });
  }

  void _createNewNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteEditorPage(),
      ),
    );
  }



  

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_viewMode == 'ViewMode.grid' ? Icons.list : Icons.grid_view),
            onPressed: _toggleViewMode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _filter,
                  onChanged: (filter) => _onFilterChanged(filter!),
                  items: ['NoteFilter.all', 'NoteFilter.favorites', 'NoteFilter.recent'].map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(_getFilterDisplayName(filter)),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _sort,
                  onChanged: (sort) => _onSortChanged(sort!),
                  items: ['NoteSort.dateCreated', 'NoteSort.dateModified', 'NoteSort.title'].map((sort) {
                    return DropdownMenuItem(
                      value: sort,
                      child: Text(_getSortDisplayName(sort)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Notes Content
          Expanded(
            child: notesState.when(
              data: (notes) {
                final filteredNotes = _filterNotes(notes);
                final sortedNotes = _sortNotes(filteredNotes);

                if (sortedNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesome4.sticky_note_o,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first note',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _createNewNote,
                          child: Text('Create Note'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _viewMode == 'ViewMode.grid'
                      ? _buildGridView(sortedNotes)
                      : _buildListView(sortedNotes),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
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
                      'Error loading notes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.read(notesProvider.notifier).loadNotes(),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "notes_fab",
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(notesProvider.notifier).loadNotes();
  }

  Widget _buildGridView(List<NoteModel> notes) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: notes[index],
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
      padding: const EdgeInsets.all(16),
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

  void _editNote(NoteModel note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(noteId: note.id),
      ),
    );
  }

  void _deleteNote(NoteModel note) async {
    final success = await ref.read(notesProvider.notifier).deleteNote(note.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noteDeleted),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _toggleFavorite(NoteModel note) async {
    await ref.read(notesProvider.notifier).toggleFavorite(note.id);
  }

  List<NoteModel> _filterNotes(List<NoteModel> notes) {
    switch (_filter.toString()) {
      case 'NoteFilter.all':
        return notes;
      case 'NoteFilter.favorites':
        return notes.where((note) => note.isFavorite).toList();
      case 'NoteFilter.recent':
        final now = DateTime.now();
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        return notes.where((note) => note.updatedAt.isAfter(sevenDaysAgo)).toList();
      default:
        return notes;
    }
  }

  List<NoteModel> _sortNotes(List<NoteModel> notes) {
    final sortedNotes = List<NoteModel>.from(notes);
    
    switch (_sort.toString()) {
      case 'NoteSort.dateCreated':
        sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'NoteSort.dateModified':
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'NoteSort.title':
        sortedNotes.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    
    return sortedNotes;
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'NoteFilter.all':
        return 'All Notes';
      case 'NoteFilter.favorites':
        return 'Favorites';
      case 'NoteFilter.recent':
        return 'Recent';
      default:
        return 'All Notes';
    }
  }

  String _getSortDisplayName(String sort) {
    switch (sort) {
      case 'NoteSort.dateCreated':
        return 'Date Created';
      case 'NoteSort.dateModified':
        return 'Date Modified';
      case 'NoteSort.title':
        return 'Title';
      default:
        return 'Date Modified';
    }
  }
}