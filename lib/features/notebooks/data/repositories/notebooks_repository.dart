import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/notebook_model.dart';

class NotebooksRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  static const String _tableName = 'notebooks';
  
  // Create a new notebook
  Future<String?> createNotebook({
    required String name,
    String? description,
    int? color,
    String? iconName,
    bool isFavorite = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notebook = NotebookModel.create(
        name: name,
        description: description,
        color: color,
        iconName: iconName,
        isFavorite: isFavorite,
      );
      
      // Save to local database
      await _databaseService.insert(_tableName, notebook.toDatabase());
      
      // Sync to Firebase if user is signed in
      final user = _firebaseService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notebooks')
            .doc(notebook.id)
            .set(notebook.toDatabase());
      }
      
      return notebook.id;
    } catch (e) {
      print('Error creating notebook: $e');
      return null;
    }
  }
  
  // Update an existing notebook
  Future<bool> updateNotebook(NotebookModel notebook) async {
    try {
      // Update in local database
      await _databaseService.update(
        _tableName,
        notebook.toDatabase(),
        where: 'id = ?',
        whereArgs: [notebook.id],
      );
      
      // Sync to Firebase if user is signed in
      final user = _firebaseService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notebooks')
            .doc(notebook.id)
            .update(notebook.toDatabase());
      }
      
      return true;
    } catch (e) {
      print('Error updating notebook: $e');
      return false;
    }
  }
  
  // Get all notebooks
  Future<List<NotebookModel>> getAllNotebooks() async {
    try {
      final maps = await _databaseService.query(
        _tableName,
        where: 'is_deleted = ?',
        whereArgs: [0], // Only get non-deleted notebooks
      );
      return maps.map((map) => NotebookModel.fromDatabase(map)).toList();
    } catch (e) {
      print('Error getting notebooks: $e');
      return [];
    }
  }
  
  // Get notebook by ID
  Future<NotebookModel?> getNotebookById(String id) async {
    try {
      final maps = await _databaseService.query(
        _tableName,
        where: 'id = ? AND is_deleted = ?',
        whereArgs: [id, 0],
      );
      
      if (maps.isNotEmpty) {
        return NotebookModel.fromDatabase(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting notebook by ID: $e');
      return null;
    }
  }
  
  // Search notebooks by name
  Future<List<NotebookModel>> searchNotebooks(String query) async {
    try {
      final maps = await _databaseService.query(
        _tableName,
        where: 'name LIKE ? AND is_deleted = ?',
        whereArgs: ['%$query%', 0],
      );
      return maps.map((map) => NotebookModel.fromDatabase(map)).toList();
    } catch (e) {
      print('Error searching notebooks: $e');
      return [];
    }
  }
  
  // Delete a notebook (soft delete)
  Future<bool> deleteNotebook(String id) async {
    try {
      // Soft delete - mark as deleted
      await _databaseService.update(
        _tableName,
        {'isDeleted': 1, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Update in Firebase if user is signed in
      final user = _firebaseService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notebooks')
            .doc(id)
            .update({
              'isDeleted': true,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            });
      }
      
      return true;
    } catch (e) {
      print('Error deleting notebook: $e');
      return false;
    }
  }
  
  // Get favorite notebooks
  Future<List<NotebookModel>> getFavoriteNotebooks() async {
    try {
      final maps = await _databaseService.query(
        _tableName,
        where: 'is_favorite = ? AND is_deleted = ?',
        whereArgs: [1, 0],
      );
      return maps.map((map) => NotebookModel.fromDatabase(map)).toList();
    } catch (e) {
      print('Error getting favorite notebooks: $e');
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
      return await updateNotebook(updatedNotebook);
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
  
  // Update note count for a notebook
  Future<bool> updateNoteCount(String notebookId, int noteCount) async {
    try {
      final notebook = await getNotebookById(notebookId);
      if (notebook != null) {
        final updatedNotebook = notebook.copyWith(
          noteCount: noteCount,
          updatedAt: DateTime.now(),
        );
        return await updateNotebook(updatedNotebook);
      }
      return false;
    } catch (e) {
      print('Error updating note count: $e');
      return false;
    }
  }
  
  // Get notebooks sorted by various criteria
  Future<List<NotebookModel>> getNotebooksSorted({
    String sortBy = 'name', // name, created, updated, noteCount
    bool ascending = true,
  }) async {
    try {
      String orderBy;
      switch (sortBy) {
        case 'created':
          orderBy = 'createdAt';
          break;
        case 'updated':
          orderBy = 'updatedAt';
          break;
        case 'noteCount':
          orderBy = 'noteCount';
          break;
        default:
          orderBy = 'name';
      }
      
      orderBy += ascending ? ' ASC' : ' DESC';
      
      final maps = await _databaseService.query(
        _tableName,
        where: 'is_deleted = ?',
        whereArgs: [0],
        orderBy: orderBy,
      );
      return maps.map((map) => NotebookModel.fromDatabase(map)).toList();
    } catch (e) {
      print('Error getting sorted notebooks: $e');
      return [];
    }
  }
  
  // Sync notebooks from Firebase
  Future<void> syncFromFirebase() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) return;
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notebooks')
          .get();
      
      for (final doc in snapshot.docs) {
        final notebookData = doc.data();
        final notebook = NotebookModel.fromJson(notebookData);
        
        // Check if notebook exists locally
        final existingNotebook = await getNotebookById(notebook.id);
        if (existingNotebook == null) {
          // Insert new notebook
          await _databaseService.insert(_tableName, notebook.toDatabase());
        } else {
          // Update existing notebook if Firebase version is newer
          if (notebook.updatedAt.isAfter(existingNotebook.updatedAt)) {
            await _databaseService.update(
              _tableName,
              notebook.toDatabase(),
              where: 'id = ?',
              whereArgs: [notebook.id],
            );
          }
        }
      }
    } catch (e) {
      print('Error syncing notebooks from Firebase: $e');
    }
  }
}