import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notebook_model.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/notebooks_repository.dart';

// Notebooks repository provider
final notebooksRepositoryProvider = Provider<NotebooksRepository>((ref) {
  return NotebooksRepository();
});

// Notebooks state notifier
class NotebooksNotifier extends StateNotifier<AsyncValue<List<NotebookModel>>> {
  final NotebooksRepository _repository;

  NotebooksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotebooks();
  }

  // Load all notebooks
  Future<void> loadNotebooks() async {
    try {
      state = const AsyncValue.loading();
      final notebooks = await _repository.getAllNotebooks();
      state = AsyncValue.data(notebooks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Create a new notebook
  Future<String?> createNotebook({
    required String name,
    String? description,
    required int color,
    required String iconName,
    bool isFavorite = false,
  }) async {
    try {
      final notebook = NotebookModel.create(
        name: name,
        description: description,
        color: color,
        iconName: iconName,
        isFavorite: isFavorite,
      );
      
      final notebookId = await _repository.createNotebook(
        name: name,
        description: description,
        color: color,
        iconName: iconName,
        isFavorite: isFavorite,
      );
      
      if (notebookId != null) {
        // Optimistic update - add the new notebook to the state
        state.whenData((notebooks) {
          final updatedNotebook = notebook.copyWith(id: notebookId);
          state = AsyncData([...notebooks, updatedNotebook]);
        });
      }
      
      return notebookId;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  // Update an existing notebook
  Future<bool> updateNotebook(NotebookModel notebook) async {
    try {
      final success = await _repository.updateNotebook(notebook);
      
      if (success) {
        // Optimistic update - update the notebook in the state
        state.whenData((notebooks) {
          final updatedNotebooks = notebooks.map((n) {
            return n.id == notebook.id ? notebook : n;
          }).toList();
          state = AsyncData(updatedNotebooks);
        });
      }
      
      return success;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  // Delete a notebook
  Future<bool> deleteNotebook(String notebookId) async {
    try {
      final success = await _repository.deleteNotebook(notebookId);
      
      if (success) {
        // Optimistic update - remove the notebook from the state
        state.whenData((notebooks) {
          final updatedNotebooks = notebooks.where((n) => n.id != notebookId).toList();
          state = AsyncData(updatedNotebooks);
        });
      }
      
      return success;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  // Search notebooks
  Future<List<NotebookModel>> searchNotebooks(String query) async {
    try {
      return await _repository.searchNotebooks(query);
    } catch (error) {
      print('Error searching notebooks: $error');
      return [];
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(NotebookModel notebook) async {
    try {
      final updatedNotebook = notebook.copyWith(
        isFavorite: !notebook.isFavorite,
        updatedAt: DateTime.now(),
      );
      
      final success = await _repository.updateNotebook(updatedNotebook);
      
      if (success) {
        // Optimistic update - update the notebook in the state
        state.whenData((notebooks) {
          final updatedNotebooks = notebooks.map((n) {
            return n.id == notebook.id ? updatedNotebook : n;
          }).toList();
          state = AsyncData(updatedNotebooks);
        });
      }
      
      return success;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  // Update note count
  Future<bool> updateNoteCount(String notebookId, int noteCount) async {
    try {
      final success = await _repository.updateNoteCount(notebookId, noteCount);
      
      if (success) {
        // Update the state
        state.whenData((notebooks) {
          final updatedNotebooks = notebooks.map((notebook) {
            if (notebook.id == notebookId) {
              return notebook.copyWith(
                noteCount: noteCount,
                updatedAt: DateTime.now(),
              );
            }
            return notebook;
          }).toList();
          state = AsyncValue.data(updatedNotebooks);
        });
      }
      
      return success;
    } catch (error) {
      print('Error updating note count: $error');
      return false;
    }
  }

  // Get notebooks sorted
  Future<List<NotebookModel>> getNotebooksSorted({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    try {
      return await _repository.getNotebooksSorted(
        sortBy: sortBy,
        ascending: ascending,
      );
    } catch (error) {
      print('Error getting sorted notebooks: $error');
      return [];
    }
  }

  // Sync from Firebase
  Future<void> syncFromFirebase() async {
    try {
      await _repository.syncFromFirebase();
      await loadNotebooks(); // Reload after sync
    } catch (error) {
      print('Error syncing from Firebase: $error');
    }
  }
}

// Notebooks provider
final notebooksProvider = StateNotifierProvider<NotebooksNotifier, AsyncValue<List<NotebookModel>>>((ref) {
  final repository = ref.watch(notebooksRepositoryProvider);
  return NotebooksNotifier(repository);
});

// Search notebooks provider
final searchNotebooksProvider = FutureProvider.family<List<NotebookModel>, String>((ref, query) async {
  final repository = ref.watch(notebooksRepositoryProvider);
  return repository.searchNotebooks(query);
});

// Favorite notebooks provider
final favoriteNotebooksProvider = FutureProvider<List<NotebookModel>>((ref) async {
  final repository = ref.watch(notebooksRepositoryProvider);
  return repository.getFavoriteNotebooks();
});

// Sorted notebooks provider
final sortedNotebooksProvider = FutureProvider.family<List<NotebookModel>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(notebooksRepositoryProvider);
  return repository.getNotebooksSorted(
    sortBy: params['sortBy'] ?? 'name',
    ascending: params['ascending'] ?? true,
  );
});