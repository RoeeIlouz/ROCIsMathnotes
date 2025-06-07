import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../note_editor/presentation/pages/note_editor_page.dart';
import '../../../notes/presentation/providers/notes_provider.dart';

class NotesSearchDelegate extends SearchDelegate<NoteModel?> {
  @override
  String get searchFieldLabel => 'Search notes...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchResults(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _SearchSuggestions();
    }
    return _SearchResults(query: query);
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notesState = ref.watch(notesProvider);
    
    return notesState.when(
      data: (notes) {
        final filteredNotes = notes.where((note) {
          final searchLower = query.toLowerCase();
          return note.title.toLowerCase().contains(searchLower) ||
                 note.content.toLowerCase().contains(searchLower);
        }).toList();
        
        if (filteredNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  query.isEmpty ? l10n.startTypingToSearch : l10n.noNotesFound,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                if (query.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"$query"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            return NoteCard(
              note: note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditorPage(noteId: note.id),
                  ),
                );
              },
              onDelete: () async {
                await ref.read(notesProvider.notifier).deleteNote(note.id);
              },
              onToggleFavorite: () async {
                await ref.read(notesProvider.notifier).toggleFavorite(note.id);
              },
            );
          },
        );
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
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSuggestions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final suggestions = [
      l10n.recentNotes,
      l10n.favorites,
        l10n.math,
      l10n.handwritingNotes,
      l10n.handwritingNotes,
    ];
    
    final searchFilters = [
      {'icon': Icons.access_time, 'label': l10n.recent, 'query': 'recent:'},
      {'icon': Icons.favorite, 'label': l10n.favorites, 'query': 'favorite:'},
      {'icon': Icons.functions, 'label': l10n.math, 'query': 'math:'},
      {'icon': Icons.draw, 'label': l10n.drawing, 'query': 'drawing:'},
      {'icon': Icons.edit, 'label': l10n.handwriting, 'query': 'handwriting:'},
      {'icon': Icons.label, 'label': l10n.tags, 'query': 'tag:'},
      {'icon': Icons.book, 'label': l10n.notebook, 'query': 'notebook:'},
    ];
    
    return ListView(
      children: [
        // Search tips
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.searchTips,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.searchTipsDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        
        // Search filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.searchFilters,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        ...searchFilters.map((filter) => ListTile(
          leading: Icon(
            filter['icon'] as IconData,
            color: theme.colorScheme.primary,
          ),
          title: Text(filter['label'] as String),
          subtitle: Text(
            'Use "${filter['query']}" to filter',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          onTap: () {
            // Set the query to the filter
            // This would be handled by the SearchDelegate
          },
        )),
        
        const Divider(),
        
        // Recent searches (placeholder)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.recentSearches,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        ListTile(
          leading: Icon(
            Icons.history,
            color: theme.colorScheme.outline,
          ),
          title: Text(
            l10n.noRecentSearches,
            style: TextStyle(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }
}