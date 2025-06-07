import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/tag_model.dart';

class TagsRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  static const String _tableName = 'tags';
  
  // Create a new tag
  Future<String?> createTag({
    required String name,
    int? color,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tag = TagModel(
        id: const Uuid().v4(),
        name: name,
        color: color,
        createdAt: DateTime.now(),
        usageCount: 0,
        metadata: metadata,
      );
      
      // Save to local database
      await _databaseService.insert(_tableName, tag.toDatabase());
      
      // Sync to Firebase if user is signed in
      final user = _firebaseService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tags')
            .doc(tag.id)
            .set(tag.toDatabase());
      }
      
      return tag.id;
    } catch (e) {
      print('Error creating tag: $e');
      return null;
    }
  }
  
  // Update an existing tag
  Future<bool> updateTag(TagModel tag) async {
    try {
      // Update in local database
      await _databaseService.update(
        _tableName,
        tag.toDatabase(),
        where: 'id = ?',
        whereArgs: [tag.id],
      );
      
      // Sync to Firebase if user is signed in
      final user = _firebaseService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tags')
            .doc(tag.id)
            .update(tag.toDatabase());
      }
      
      return true;
    } catch (e) {
      print('Error updating tag: $e');
      return false;
    }
  }
  
  // Get all tags
  Future<List<TagModel>> getAllTags() async {
    try {
      final maps = await _databaseService.query(_tableName);
      return maps.map((map) => TagModel.fromDatabase(map)).toList();
    } catch (e) {
      print('Error getting tags: $e');
      return [];
    }
  }
  
  // Get tag by ID
  Future<TagModel?> getTagById(String id) async {
    try {
      final maps = await _databaseService.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return TagModel.fromDatabase(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting tag by ID: $e');
      return null;
    }
  }
  
  // Search tags by name
  Future<List<TagModel>> searchTags(String query) async {
    try {
      final maps = await _databaseService.query(
        _tableName,
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
      return maps.map((map) => TagModel.fromDatabase(map)).toList();
    } catch (e) {
      print('Error searching tags: $e');
      return [];
    }
  }
  
  // Delete a tag (soft delete)
  Future<bool> deleteTag(String id) async {
    try {
      // Delete from local database
      await _databaseService.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Delete from Firebase if user is signed in
      final user = _firebaseService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tags')
            .doc(id)
            .delete();
      }
      
      return true;
    } catch (e) {
      print('Error deleting tag: $e');
      return false;
    }
  }
  
  // Increment usage count for a tag
  Future<bool> incrementUsageCount(String tagId) async {
    try {
      final tag = await getTagById(tagId);
      if (tag != null) {
        final updatedTag = tag.copyWith(
          usageCount: tag.usageCount + 1,
        );
        return await updateTag(updatedTag);
      }
      return false;
    } catch (e) {
      print('Error incrementing usage count: $e');
      return false;
    }
  }
  
  // Get tags sorted by usage count
  Future<List<TagModel>> getTagsByUsage({int limit = 10}) async {
    try {
      final maps = await _databaseService.query(
        _tableName,
        orderBy: 'usageCount DESC',
        limit: limit,
      );
      return maps.map((map) => TagModel.fromDatabase(map)).toList();
    } catch (e) {
      print('Error getting tags by usage: $e');
      return [];
    }
  }
  
  // Sync tags from Firebase
  Future<void> syncFromFirebase() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) return;
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tags')
          .get();
      
      for (final doc in snapshot.docs) {
        final tagData = doc.data();
        final tag = TagModel.fromJson(tagData);
        
        // Check if tag exists locally
        final existingTag = await getTagById(tag.id);
        if (existingTag == null) {
          // Insert new tag
          await _databaseService.insert(_tableName, tag.toDatabase());
        } else {
          // Update existing tag if Firebase version is newer
          if (tag.createdAt.isAfter(existingTag.createdAt)) {
            await _databaseService.update(
              _tableName,
              tag.toDatabase(),
              where: 'id = ?',
              whereArgs: [tag.id],
            );
          }
        }
      }
    } catch (e) {
      print('Error syncing tags from Firebase: $e');
    }
  }
}