import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tag_model.dart';
import '../../data/repositories/tags_repository.dart';

// Tags repository provider
final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  return TagsRepository();
});

// Tags state notifier
class TagsNotifier extends StateNotifier<AsyncValue<List<TagModel>>> {
  final TagsRepository _repository;

  TagsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTags();
  }

  // Load all tags
  Future<void> loadTags() async {
    try {
      state = const AsyncValue.loading();
      final tags = await _repository.getAllTags();
      state = AsyncValue.data(tags);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Create a new tag
  Future<String?> createTag({
    required String name,
    int? color,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tagId = await _repository.createTag(
        name: name,
        color: color,
        metadata: metadata,
      );
      
      if (tagId != null) {
        // Reload tags to update the UI
        await loadTags();
      }
      
      return tagId;
    } catch (error) {
      print('Error creating tag: $error');
      return null;
    }
  }

  // Update an existing tag
  Future<bool> updateTag(TagModel tag) async {
    try {
      final success = await _repository.updateTag(tag);
      
      if (success) {
        // Update the state with the modified tag
        state.whenData((tags) {
          final updatedTags = tags.map((t) => t.id == tag.id ? tag : t).toList();
          state = AsyncValue.data(updatedTags);
        });
      }
      
      return success;
    } catch (error) {
      print('Error updating tag: $error');
      return false;
    }
  }

  // Delete a tag
  Future<bool> deleteTag(String tagId) async {
    try {
      final success = await _repository.deleteTag(tagId);
      
      if (success) {
        // Remove the tag from the state
        state.whenData((tags) {
          final updatedTags = tags.where((tag) => tag.id != tagId).toList();
          state = AsyncValue.data(updatedTags);
        });
      }
      
      return success;
    } catch (error) {
      print('Error deleting tag: $error');
      return false;
    }
  }

  // Search tags
  Future<List<TagModel>> searchTags(String query) async {
    try {
      return await _repository.searchTags(query);
    } catch (error) {
      print('Error searching tags: $error');
      return [];
    }
  }

  // Increment usage count
  Future<bool> incrementUsageCount(String tagId) async {
    try {
      final success = await _repository.incrementUsageCount(tagId);
      
      if (success) {
        // Reload tags to update usage counts
        await loadTags();
      }
      
      return success;
    } catch (error) {
      print('Error incrementing usage count: $error');
      return false;
    }
  }

  // Get tags by usage
  Future<List<TagModel>> getTagsByUsage({int limit = 10}) async {
    try {
      return await _repository.getTagsByUsage(limit: limit);
    } catch (error) {
      print('Error getting tags by usage: $error');
      return [];
    }
  }

  // Sync from Firebase
  Future<void> syncFromFirebase() async {
    try {
      await _repository.syncFromFirebase();
      await loadTags(); // Reload after sync
    } catch (error) {
      print('Error syncing from Firebase: $error');
    }
  }
}

// Tags provider
final tagsProvider = StateNotifierProvider<TagsNotifier, AsyncValue<List<TagModel>>>((ref) {
  final repository = ref.watch(tagsRepositoryProvider);
  return TagsNotifier(repository);
});

// Search tags provider
final searchTagsProvider = FutureProvider.family<List<TagModel>, String>((ref, query) async {
  final repository = ref.watch(tagsRepositoryProvider);
  return repository.searchTags(query);
});

// Popular tags provider
final popularTagsProvider = FutureProvider.family<List<TagModel>, int>((ref, limit) async {
  final repository = ref.watch(tagsRepositoryProvider);
  return repository.getTagsByUsage(limit: limit);
});