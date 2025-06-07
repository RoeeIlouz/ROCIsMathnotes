import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../features/notes/data/models/note_model.dart';
import '../../features/notebooks/data/models/notebook_model.dart';
import '../../features/tags/data/models/tag_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  static DatabaseService get instance => _instance;
  
  Database? _database;
  
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite database is not supported on web. Use Hive instead.');
    }
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<void> initialize() async {
    if (kIsWeb) {
      // For web, only use Hive
      await _initHive();
    } else {
      // Initialize database factory for desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      // Android and iOS use the default SQLite implementation
      
      await _initDatabase();
      await _initHive();
    }
  }
  
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mathnotes.db');
    
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _initHive() async {
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NotebookModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TagModelAdapter());
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create notebooks table
    await db.execute('''
      CREATE TABLE notebooks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        icon_name TEXT
      )
    ''');
    
    // Create tags table
    await db.execute('''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');
    
    // Create notes table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        notebook_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        has_drawing INTEGER DEFAULT 0,
        has_handwriting INTEGER DEFAULT 0,
        has_math INTEGER DEFAULT 0,
        drawing_data TEXT,
        handwriting_data TEXT,
        math_data TEXT,
        ai_summary TEXT,
        color INTEGER,
        thumbnail_path TEXT,
        FOREIGN KEY (notebook_id) REFERENCES notebooks (id)
      )
    ''');
    
    // Create note_tags junction table
    await db.execute('''
      CREATE TABLE note_tags (
        note_id TEXT,
        tag_id TEXT,
        PRIMARY KEY (note_id, tag_id),
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');
    
    // Create drawing_strokes table for detailed drawing data
    await db.execute('''
      CREATE TABLE drawing_strokes (
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        stroke_data TEXT NOT NULL,
        color INTEGER NOT NULL,
        thickness REAL NOT NULL,
        opacity REAL NOT NULL,
        tool_type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');
    
    // Create handwriting_recognition table
    await db.execute('''
      CREATE TABLE handwriting_recognition (
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        original_stroke_data TEXT NOT NULL,
        recognized_text TEXT NOT NULL,
        confidence REAL NOT NULL,
        language TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_accepted INTEGER DEFAULT 0,
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');
    
    // Create math_expressions table
    await db.execute('''
      CREATE TABLE math_expressions (
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        expression TEXT NOT NULL,
        result TEXT,
        graph_data TEXT,
        graph_type TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');
    
    // Create sync_status table for cloud synchronization
    await db.execute('''
      CREATE TABLE sync_status (
        entity_id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        last_synced INTEGER,
        needs_sync INTEGER DEFAULT 1,
        sync_version INTEGER DEFAULT 1
      )
    ''');
    
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_notes_notebook_id ON notes(notebook_id)');
    await db.execute('CREATE INDEX idx_notes_created_at ON notes(created_at)');
    await db.execute('CREATE INDEX idx_notes_updated_at ON notes(updated_at)');
    await db.execute('CREATE INDEX idx_notes_is_deleted ON notes(is_deleted)');
    await db.execute('CREATE INDEX idx_notes_is_favorite ON notes(is_favorite)');
    await db.execute('CREATE INDEX idx_drawing_strokes_note_id ON drawing_strokes(note_id)');
    await db.execute('CREATE INDEX idx_handwriting_recognition_note_id ON handwriting_recognition(note_id)');
    await db.execute('CREATE INDEX idx_math_expressions_note_id ON math_expressions(note_id)');
    await db.execute('CREATE INDEX idx_sync_status_needs_sync ON sync_status(needs_sync)');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    if (oldVersion < 2) {
      // Add icon_name column to notebooks table
      await db.execute('ALTER TABLE notebooks ADD COLUMN icon_name TEXT');
    }
    if (oldVersion < 3) {
      // Add color column to notes table
      await db.execute('ALTER TABLE notes ADD COLUMN color INTEGER');
    }
    if (oldVersion < 4) {
      // Add thumbnail_path column to notes table
      await db.execute('ALTER TABLE notes ADD COLUMN thumbnail_path TEXT');
    }
  }
  
  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (kIsWeb) {
      // Use Hive for web platform
      try {
        print('Attempting to insert data to $table: $data');
        final box = await Hive.openBox(table);
        print('Successfully opened box for $table');
        
        final id = data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        // Ensure the data includes the ID
        final dataWithId = {...data, 'id': id};
        print('Inserting data with ID: $id');
        
        // Handle drawing data specifically
        if (table == 'notes' && dataWithId['drawing_data'] != null) {
          print('Inserting drawing data: ${dataWithId['drawing_data']}');
          dataWithId['has_drawing'] = 1;
        }
        
        await box.put(id, Map<String, dynamic>.from(dataWithId));
        print('Successfully inserted data to $table with id: $id');
        return 1; // Return success indicator
      } catch (e, stackTrace) {
        print('Error inserting data to $table: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      final db = await database;
      // Handle drawing data specifically
      if (table == 'notes' && data['drawing_data'] != null) {
        print('Inserting drawing data: ${data['drawing_data']}');
        data['has_drawing'] = 1;
      }
      return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
  
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (kIsWeb) {
      // Use Hive for web platform
      try {
        final box = await Hive.openBox(table);
        List<dynamic> rawValues;
        
        try {
          rawValues = box.values.toList();
        } catch (e) {
          // LinkedMap error at values.toList() - clear the box
          print('LinkedMap error detected in $table at values.toList(), clearing corrupted data: $e');
          await box.clear();
          return [];
        }
        
        // Convert LinkedMap to Map<String, dynamic> to avoid type casting issues
        List<Map<String, dynamic>> values = [];
        bool hasLinkedMapError = false;
        
        for (var item in rawValues) {
          try {
            if (item is Map) {
              values.add(Map<String, dynamic>.from(item));
            } else {
              print('Non-map item detected in $table: ${item.runtimeType}');
              hasLinkedMapError = true;
              break;
            }
          } catch (e) {
            // LinkedMap detected - clear the box and return empty list
            print('LinkedMap detected in $table during conversion, clearing corrupted data: $e');
            hasLinkedMapError = true;
            break;
          }
        }
        
        if (hasLinkedMapError) {
          await box.clear();
          return [];
        }
      
      // Apply filtering if where clause is provided
      List<Map<String, dynamic>> filteredValues = values;
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        filteredValues = values.where((item) {
          // Handle multiple conditions in where clause
          final conditions = where.split(' AND ');
          int argIndex = 0;
          
          for (final condition in conditions) {
            if (condition.trim().contains('is_deleted = ?')) {
              final expectedValue = whereArgs[argIndex] as int;
              final actualValue = item['is_deleted'] ?? 0;
              if (actualValue != expectedValue) return false;
              argIndex++;
            } else if (condition.trim().contains('is_favorite = ?')) {
              final expectedValue = whereArgs[argIndex] as int;
              final actualValue = item['is_favorite'] ?? 0;
              if (actualValue != expectedValue) return false;
              argIndex++;
            } else if (condition.trim().contains('id = ?')) {
              final expectedValue = whereArgs[argIndex] as String;
              if (item['id'] != expectedValue) return false;
              argIndex++;
            } else if (condition.trim().contains('notebook_id = ?')) {
              final expectedValue = whereArgs[argIndex] as String;
              if (item['notebook_id'] != expectedValue) return false;
              argIndex++;
            } else if (condition.trim().contains('name LIKE ?')) {
              final searchTerm = (whereArgs[argIndex] as String).replaceAll('%', '');
              final name = item['name'] as String? ?? '';
              if (!name.toLowerCase().contains(searchTerm.toLowerCase())) return false;
              argIndex++;
            }
          }
          return true;
        }).toList();
      }
      
      // Apply ordering
      if (orderBy != null) {
        if (orderBy.contains('updated_at DESC')) {
          filteredValues.sort((a, b) => (b['updated_at'] ?? 0).compareTo(a['updated_at'] ?? 0));
        } else if (orderBy.contains('created_at DESC')) {
          filteredValues.sort((a, b) => (b['created_at'] ?? 0).compareTo(a['created_at'] ?? 0));
        } else if (orderBy.contains('name ASC')) {
          filteredValues.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        }
      }
      
      // Apply limit
       if (limit != null && limit > 0) {
         filteredValues = filteredValues.take(limit).toList();
       }
       
       return filteredValues;
     } catch (e) {
       print('Error querying data from $table: $e');
       return [];
     }
    } else {
      final db = await database;
      return await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    }
  }
  
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (kIsWeb) {
      // Use Hive for web platform
      try {
        final box = await Hive.openBox(table);
        if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
          if (where.contains('id = ?')) {
            final id = whereArgs[0];
            // Get existing data and merge with new data
            final rawExistingData = box.get(id);
            final existingData = rawExistingData != null ? Map<String, dynamic>.from(rawExistingData) : <String, dynamic>{};
            final mergedData = {...existingData, ...data};
            
            // Handle drawing data specifically
            if (table == 'notes') {
              if (mergedData['drawing_data'] != null && mergedData['drawing_data'].toString().isNotEmpty) {
                print('Updating drawing data: ${mergedData['drawing_data']}');
                mergedData['has_drawing'] = 1;
              } else {
                mergedData['has_drawing'] = 0;
              }
            }
            
            await box.put(id, Map<String, dynamic>.from(mergedData));
            print('Successfully updated data in $table with id: $id');
            return 1;
          }
        }
        return 0;
      } catch (e) {
        print('Error updating data in $table: $e');
        return 0;
      }
    } else {
      final db = await database;
      // Handle drawing data specifically
      if (table == 'notes') {
        if (data['drawing_data'] != null && data['drawing_data'].toString().isNotEmpty) {
          print('Updating drawing data: ${data['drawing_data']}');
          data['has_drawing'] = 1;
        } else {
          data['has_drawing'] = 0;
        }
      }
      return await db.update(table, data, where: where, whereArgs: whereArgs);
    }
  }
  
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (kIsWeb) {
      // Use Hive for web platform
      final box = await Hive.openBox(table);
      if (where != null && where.contains('id = ?') && whereArgs != null && whereArgs.isNotEmpty) {
        final id = whereArgs[0];
        await box.delete(id);
        return 1;
      }
      return 0;
    } else {
      final db = await database;
      return await db.delete(table, where: where, whereArgs: whereArgs);
    }
  }
  
  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
  
  // Raw query support
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [List<dynamic>? arguments]
  ) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
  
  // Batch operations
  Future<List<dynamic>> batch(Function(Batch batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    return await batch.commit();
  }
  
  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('note_tags');
      await txn.delete('drawing_strokes');
      await txn.delete('handwriting_recognition');
      await txn.delete('math_expressions');
      await txn.delete('notes');
      await txn.delete('notebooks');
      await txn.delete('tags');
      await txn.delete('sync_status');
    });
  }
}