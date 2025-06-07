// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/notes_repository.dart';
import '../../../../core/services/cache_service.dart';

// Notes repository provider
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

// Notes state notifier
class NotesNotifier extends StateNotifier<AsyncValue<List<NoteModel>>> {
  final NotesRepository _repository;
  static const String _cacheKey = 'all_notes';

  NotesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  // Load all notes with caching
  Future<void> loadNotes({bool forceRefresh = false}) async {
    try {
      // Try to get from cache first if not forcing refresh
      if (!forceRefresh) {
        final cached = NotesCache.getNotesList<NoteModel>(_cacheKey);
        if (cached != null && cached.isNotEmpty) {
          state = AsyncValue.data(cached);
          return;
        }
      }
      
      state = const AsyncValue.loading();
      final notes = await _repository.getAllNotes();
      
      // Cache the results
      NotesCache.cacheNotesList(_cacheKey, notes);
      
      state = AsyncValue.data(notes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Create a new note with optimized cache update
  Future<String?> createNote({
    required String title,
    String content = '',
    String? notebookId,
    List<String> tagIds = const [],
    int? color,
    String? drawingData,
    String? handwritingData,
    String? mathData,
  }) async {
    try {
      final note = NoteModel.create(
        title: title,
        content: content,
        notebookId: notebookId,
        tagIds: tagIds,
        color: color,
        hasDrawing: drawingData != null,
        drawingData: drawingData,
      );
      
      final noteId = await _repository.createNote(note);
      
      // Clear cache and reload to get the new note
      NotesCache.clearNotesCache();
      await loadNotes(forceRefresh: true);
      
      return noteId;
    } catch (e) {
      return null;
    }
  }

  // Update an existing note with optimized cache update
  Future<bool> updateNote(NoteModel note) async {
    try {
      await _repository.updateNote(note);
      
      // Clear cache and reload to get updated data
      NotesCache.clearNotesCache();
      await loadNotes(forceRefresh: true);
      
      return true;
    } catch (error) {
      print('Error updating note: $error');
      return false;
    }
  }

  // Delete a note with optimized cache update
  Future<bool> deleteNote(String noteId) async {
    try {
      await _repository.deleteNote(noteId);
      
      // Clear cache and reload to reflect deletion
      NotesCache.clearNotesCache();
      await loadNotes(forceRefresh: true);
      
      return true;
    } catch (error) {
      print('Error deleting note: $error');
      return false;
    }
  }
  
  // Search notes
  Future<void> searchNotes(String query) async {
    if (query.isEmpty) {
      await loadNotes();
      return;
    }

    try {
      state = const AsyncValue.loading();
      final notes = await _repository.searchNotes(query);
      state = AsyncValue.data(notes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Search notes by tags
  Future<void> searchNotesByTags(List<String> tagIds) async {
    try {
      state = const AsyncValue.loading();
      final notes = await _repository.searchNotesByTags(tagIds);
      state = AsyncValue.data(notes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Advanced search with text and tags
  Future<void> searchNotesAdvanced(String? textQuery, List<String>? tagIds) async {
    if ((textQuery == null || textQuery.isEmpty) && (tagIds == null || tagIds.isEmpty)) {
      await loadNotes();
      return;
    }

    try {
      state = const AsyncValue.loading();
      final notes = await _repository.searchNotesAdvanced(textQuery, tagIds);
      state = AsyncValue.data(notes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Get notes by notebook
  Future<void> loadNotesByNotebook(String notebookId) async {
    try {
      state = const AsyncValue.loading();
      final notes = await _repository.getNotesByNotebook(notebookId);
      state = AsyncValue.data(notes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(String noteId) async {
    try {
      final note = await _repository.getNoteById(noteId);
      if (note != null) {
        final updatedNote = note.copyWith(
          isFavorite: !note.isFavorite,
          updatedAt: DateTime.now(),
        );
        await _repository.updateNote(updatedNote);
        
        // Optimistic update - update the note in the state directly
        state.whenData((notes) {
          final index = notes.indexWhere((n) => n.id == noteId);
          if (index >= 0) {
            final updatedNotes = List<NoteModel>.from(notes);
            updatedNotes[index] = updatedNote;
            state = AsyncValue.data(updatedNotes);
          }
        });
        
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}

// Notes provider
final notesProvider = StateNotifierProvider<NotesNotifier, AsyncValue<List<NoteModel>>>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return NotesNotifier(repository);
});

// Single note provider
final noteProvider = FutureProvider.family<NoteModel?, String>((ref, noteId) async {
  final repository = ref.watch(notesRepositoryProvider);
  return await repository.getNoteById(noteId);
});

// Filtered notes provider
final filteredNotesProvider = Provider.family<AsyncValue<List<NoteModel>>, String>((ref, filter) {
  final notesAsync = ref.watch(notesProvider);
  
  return notesAsync.when(
    data: (notes) {
      List<NoteModel> filteredNotes;
      
      switch (filter) {
        case 'favorites':
          filteredNotes = notes.where((note) => note.isFavorite).toList();
          break;
        case 'recent':
          filteredNotes = notes.where((note) => note.isRecent).toList();
          break;
        case 'all':
        default:
          filteredNotes = notes;
          break;
      }
      
      return AsyncValue.data(filteredNotes);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Sorted notes provider
final sortedNotesProvider = Provider.family<AsyncValue<List<NoteModel>>, String>((ref, sortBy) {
  final notesAsync = ref.watch(notesProvider);
  
  return notesAsync.when(
    data: (notes) {
      final sortedNotes = List<NoteModel>.from(notes);
      
      switch (sortBy) {
        case 'title':
          sortedNotes.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'created':
          sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'modified':
        default:
          sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
      }
      
      return AsyncValue.data(sortedNotes);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});