import '../../../../core/services/database_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/note_model.dart';

class NotesRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final FirebaseService _firebaseService = FirebaseService.instance;

  // Create a new note
  Future<String> createNote(NoteModel note) async {
    try {
      print('Creating note with drawing data: ${note.drawingData}');
      print('Has drawing: ${note.hasDrawing}');
      
      // Save to local database
      await _databaseService.insert('notes', {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'notebook_id': note.notebookId,
        'created_at': note.createdAt.millisecondsSinceEpoch,
        'updated_at': note.updatedAt.millisecondsSinceEpoch,
        'is_favorite': note.isFavorite ? 1 : 0,
        'is_deleted': note.isDeleted ? 1 : 0,
        'has_drawing': note.hasDrawing ? 1 : 0,
        'has_handwriting': note.hasHandwriting ? 1 : 0,
        'has_math': note.hasMath ? 1 : 0,
        'drawing_data': note.drawingData,
        'handwriting_data': note.handwritingData,
        'math_data': note.mathData,
        'ai_summary': note.aiSummary,
        'color': note.color,
        'thumbnail_path': note.thumbnailPath,
      });

      // Save tags if any
      if (note.tagIds.isNotEmpty) {
        for (final tagId in note.tagIds) {
          await _databaseService.insert('note_tags', {
            'note_id': note.id,
            'tag_id': tagId,
          });
        }
      }

      // Sync to cloud if user is signed in
      if (_firebaseService.isSignedIn) {
        await _firebaseService.syncNote(note);
      }

      return note.id;
    } catch (e) {
      print('Error creating note: $e');
      throw Exception('Failed to create note: $e');
    }
  }

  // Update an existing note
  Future<void> updateNote(NoteModel note) async {
    try {
      print('Updating note with drawing data: ${note.drawingData}');
      print('Has drawing: ${note.hasDrawing}');
      
      // Update in local database
      await _databaseService.update(
        'notes',
        {
          'title': note.title,
          'content': note.content,
          'notebook_id': note.notebookId,
          'updated_at': note.updatedAt.millisecondsSinceEpoch,
          'is_favorite': note.isFavorite ? 1 : 0,
          'is_deleted': note.isDeleted ? 1 : 0,
          'has_drawing': note.hasDrawing ? 1 : 0,
          'has_handwriting': note.hasHandwriting ? 1 : 0,
          'has_math': note.hasMath ? 1 : 0,
          'drawing_data': note.drawingData,
          'handwriting_data': note.handwritingData,
          'math_data': note.mathData,
          'ai_summary': note.aiSummary,
          'color': note.color,
          'thumbnail_path': note.thumbnailPath,
        },
        where: 'id = ?',
        whereArgs: [note.id],
      );

      // Update tags
      await _databaseService.delete('note_tags', where: 'note_id = ?', whereArgs: [note.id]);
      if (note.tagIds.isNotEmpty) {
        for (final tagId in note.tagIds) {
          await _databaseService.insert('note_tags', {
            'note_id': note.id,
            'tag_id': tagId,
          });
        }
      }

      // Sync to cloud if user is signed in
      if (_firebaseService.isSignedIn) {
        await _firebaseService.syncNote(note);
      }
    } catch (e) {
      print('Error updating note: $e');
      throw Exception('Failed to update note: $e');
    }
  }

  // Get all notes
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        'notes',
        where: 'is_deleted = ?',
        whereArgs: [0],
        orderBy: 'updated_at DESC',
      );

      final List<NoteModel> notes = [];
      for (final map in maps) {
        final note = await _mapToNoteModel(map);
        notes.add(note);
      }

      return notes;
    } catch (e) {
      print('Error getting all notes: $e');
      throw Exception('Failed to get notes: $e');
    }
  }

  // Get notes with pagination
  Future<List<NoteModel>> getNotesPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? filterBy,
    String? sortBy,
  }) async {
    try {
      String whereClause = 'is_deleted = ?';
      List<dynamic> whereArgs = [0];
      
      // Add search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause += ' AND (title LIKE ? OR content LIKE ?)';
        whereArgs.addAll(['%$searchQuery%', '%$searchQuery%']);
      }
      
      // Add additional filters
      if (filterBy != null) {
        switch (filterBy) {
          case 'favorites':
            whereClause += ' AND is_favorite = ?';
            whereArgs.add(1);
            break;
          case 'recent':
            final weekAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
            whereClause += ' AND updated_at > ?';
            whereArgs.add(weekAgo);
            break;
        }
      }
      
      // Determine sort order
      String orderBy = 'updated_at DESC';
      if (sortBy != null) {
        switch (sortBy) {
          case 'title':
            orderBy = 'title ASC';
            break;
          case 'created':
            orderBy = 'created_at DESC';
            break;
          case 'modified':
          default:
            orderBy = 'updated_at DESC';
            break;
        }
      }
      
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        'notes',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: pageSize,
        offset: page * pageSize,
      );

      final List<NoteModel> notes = [];
      for (final map in maps) {
        final note = await _mapToNoteModel(map);
        notes.add(note);
      }

      return notes;
    } catch (e) {
      print('Error getting paginated notes: $e');
      throw Exception('Failed to get notes: $e');
    }
  }

  // Get notes by notebook
  Future<List<NoteModel>> getNotesByNotebook(String notebookId) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        'notes',
        where: 'notebook_id = ? AND is_deleted = ?',
        whereArgs: [notebookId, 0],
        orderBy: 'updated_at DESC',
      );

      final List<NoteModel> notes = [];
      for (final map in maps) {
        final note = await _mapToNoteModel(map);
        notes.add(note);
      }

      return notes;
    } catch (e) {
      print('Error getting notes by notebook: $e');
      throw Exception('Failed to get notes by notebook: $e');
    }
  }

  // Get notes by notebook with pagination
  Future<List<NoteModel>> getNotesByNotebookPaginated({
    required String notebookId,
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      String whereClause = 'notebook_id = ? AND is_deleted = ?';
      List<dynamic> whereArgs = [notebookId, 0];
      
      // Add search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause += ' AND (title LIKE ? OR content LIKE ?)';
        whereArgs.addAll(['%$searchQuery%', '%$searchQuery%']);
      }
      
      // Determine sort order
      String orderBy = 'updated_at DESC';
      if (sortBy != null) {
        switch (sortBy) {
          case 'title':
            orderBy = 'title ASC';
            break;
          case 'created':
            orderBy = 'created_at DESC';
            break;
          case 'modified':
          default:
            orderBy = 'updated_at DESC';
            break;
        }
      }
      
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        'notes',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: pageSize,
        offset: page * pageSize,
      );

      final List<NoteModel> notes = [];
      for (final map in maps) {
        final note = await _mapToNoteModel(map);
        notes.add(note);
      }

      return notes;
    } catch (e) {
      print('Error getting paginated notes by notebook: $e');
      throw Exception('Failed to get notes by notebook: $e');
    }
  }

  // Get a single note by ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final notesData = await _databaseService.query(
        'notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );

      if (notesData.isEmpty) return null;

      final noteData = notesData.first;
      
      // Get tags for this note
      final tagsData = await _databaseService.query(
        'note_tags',
        where: 'note_id = ?',
        whereArgs: [noteId],
      );
      final tagIds = tagsData.map((tag) => tag['tag_id'] as String).toList();

      return NoteModel.fromDatabase({...noteData, 'tagIds': tagIds});
    } catch (e) {
      throw Exception('Failed to get note by ID: $e');
    }
  }

  // Delete a note (soft delete)
  Future<void> deleteNote(String noteId) async {
    try {
      await _databaseService.update(
        'notes',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [noteId],
      );

      // Sync to cloud if user is signed in
      if (_firebaseService.isSignedIn) {
        await _firebaseService.deleteNote(noteId);
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Search notes (deprecated - use getNotesPaginated instead)
  Future<List<NoteModel>> searchNotes(String query) async {
    return getNotesPaginated(
      page: 0,
      pageSize: 1000, // Large page size for backward compatibility
      searchQuery: query,
    );
  }

  // Search notes by tags
  Future<List<NoteModel>> searchNotesByTags(List<String> tagIds) async {
    try {
      if (tagIds.isEmpty) {
        return getAllNotes();
      }

      // Create placeholders for the IN clause
      final placeholders = tagIds.map((_) => '?').join(',');
      
      final notesData = await _databaseService.query(
        'notes',
        where: '''id IN (
          SELECT DISTINCT note_id FROM note_tags 
          WHERE tag_id IN ($placeholders)
        ) AND is_deleted = ?''',
        whereArgs: [...tagIds, 0],
        orderBy: 'updated_at DESC',
      );

      final notes = <NoteModel>[];
      for (final noteData in notesData) {
        // Get tags for this note
        final tagsData = await _databaseService.query(
          'note_tags',
          where: 'note_id = ?',
          whereArgs: [noteData['id']],
        );
        final noteTagIds = tagsData.map((tag) => tag['tag_id'] as String).toList();

        final note = NoteModel.fromDatabase({...noteData, 'tagIds': noteTagIds});
        notes.add(note);
      }

      return notes;
    } catch (e) {
      throw Exception('Failed to search notes by tags: $e');
    }
  }

  // Search notes by text and tags combined
  Future<List<NoteModel>> searchNotesAdvanced(String? textQuery, List<String>? tagIds) async {
    try {
      if ((textQuery == null || textQuery.isEmpty) && (tagIds == null || tagIds.isEmpty)) {
        return getAllNotes();
      }

      String whereClause = 'is_deleted = ?';
      List<dynamic> whereArgs = [0];

      // Add text search condition
      if (textQuery != null && textQuery.isNotEmpty) {
        whereClause += ' AND (title LIKE ? OR content LIKE ?)';
        whereArgs.addAll(['%$textQuery%', '%$textQuery%']);
      }

      // Add tag search condition
      if (tagIds != null && tagIds.isNotEmpty) {
        final placeholders = tagIds.map((_) => '?').join(',');
        whereClause += ''' AND id IN (
          SELECT DISTINCT note_id FROM note_tags 
          WHERE tag_id IN ($placeholders)
        )''';
        whereArgs.addAll(tagIds);
      }

      final notesData = await _databaseService.query(
        'notes',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'updated_at DESC',
      );

      final notes = <NoteModel>[];
      for (final noteData in notesData) {
        final note = await _mapToNoteModel(noteData);
        notes.add(note);
      }

      return notes;
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }

  // Get favorite notes (deprecated - use getNotesPaginated with filterBy: 'favorites' instead)
  Future<List<NoteModel>> getFavoriteNotes() async {
    return getNotesPaginated(
      page: 0,
      pageSize: 1000, // Large page size for backward compatibility
      filterBy: 'favorites',
    );
  }

  // Helper method to map database row to NoteModel
  Future<NoteModel> _mapToNoteModel(Map<String, dynamic> noteData) async {
    // Get tags for this note
    final tagsData = await _databaseService.query(
      'note_tags',
      where: 'note_id = ?',
      whereArgs: [noteData['id']],
    );
    final tagIds = tagsData.map((tag) => tag['tag_id'] as String).toList();

    return NoteModel.fromDatabase({...noteData, 'tagIds': tagIds});
  }
}