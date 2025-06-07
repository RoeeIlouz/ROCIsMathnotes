import 'dart:convert';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'auth_service.dart';

class DriveBackupService {
  final AuthService _authService;
  static const String _backupFolderName = 'MathNotes Backup';
  static const String _backupFileName = 'mathnotes_backup.json';

  DriveBackupService(this._authService);

  // Create backup data from Hive boxes
  Future<Map<String, dynamic>> _createBackupData() async {
    final notebooksBox = await Hive.openBox('notebooks');
    final notesBox = await Hive.openBox('notes');
    final tagsBox = await Hive.openBox('tags');
    final settingsBox = await Hive.openBox('settings');

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
      'data': {
        'notebooks': notebooksBox.toMap(),
        'notes': notesBox.toMap(),
        'tags': tagsBox.toMap(),
        'settings': settingsBox.toMap(),
      },
    };
  }

  // Restore data to Hive boxes
  Future<void> _restoreBackupData(Map<String, dynamic> backupData) async {
    final data = backupData['data'] as Map<String, dynamic>;
    
    // Clear existing data
    final notebooksBox = await Hive.openBox('notebooks');
    final notesBox = await Hive.openBox('notes');
    final tagsBox = await Hive.openBox('tags');
    final settingsBox = await Hive.openBox('settings');

    await notebooksBox.clear();
    await notesBox.clear();
    await tagsBox.clear();
    await settingsBox.clear();

    // Restore data
    if (data['notebooks'] != null) {
      final notebooks = Map<String, dynamic>.from(data['notebooks']);
      for (final entry in notebooks.entries) {
        await notebooksBox.put(entry.key, entry.value);
      }
    }

    if (data['notes'] != null) {
      final notes = Map<String, dynamic>.from(data['notes']);
      for (final entry in notes.entries) {
        await notesBox.put(entry.key, entry.value);
      }
    }

    if (data['tags'] != null) {
      final tags = Map<String, dynamic>.from(data['tags']);
      for (final entry in tags.entries) {
        await tagsBox.put(entry.key, entry.value);
      }
    }

    if (data['settings'] != null) {
      final settings = Map<String, dynamic>.from(data['settings']);
      for (final entry in settings.entries) {
        await settingsBox.put(entry.key, entry.value);
      }
    }
  }

  // Find or create backup folder
  Future<String?> _findOrCreateBackupFolder(drive.DriveApi driveApi) async {
    try {
      // Search for existing backup folder
      final folderQuery = "name='$_backupFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final folderList = await driveApi.files.list(q: folderQuery);
      
      if (folderList.files != null && folderList.files!.isNotEmpty) {
        return folderList.files!.first.id;
      }

      // Create new backup folder
      final folder = drive.File()
        ..name = _backupFolderName
        ..mimeType = 'application/vnd.google-apps.folder';
      
      final createdFolder = await driveApi.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      print('Error finding/creating backup folder: $e');
      return null;
    }
  }

  // Upload backup to Google Drive
  Future<bool> uploadBackup() async {
    try {
      final driveApi = await _authService.getDriveApi();
      if (driveApi == null) {
        throw Exception('Failed to get Drive API client');
      }

      final folderId = await _findOrCreateBackupFolder(driveApi);
      if (folderId == null) {
        throw Exception('Failed to create backup folder');
      }

      // Create backup data
      final backupData = await _createBackupData();
      final backupJson = jsonEncode(backupData);

      // Check if backup file already exists
      final fileQuery = "name='$_backupFileName' and parents in '$folderId' and trashed=false";
      final fileList = await driveApi.files.list(q: fileQuery);
      
      final media = drive.Media(
        Stream.fromIterable([utf8.encode(backupJson)]),
        backupJson.length,
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing file
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File()..name = _backupFileName,
          fileId,
          uploadMedia: media,
        );
      } else {
        // Create new file
        final file = drive.File()
          ..name = _backupFileName
          ..parents = [folderId];
        
        await driveApi.files.create(file, uploadMedia: media);
      }

      return true;
    } catch (e) {
      print('Error uploading backup: $e');
      return false;
    }
  }

  // Download backup from Google Drive
  Future<bool> downloadBackup() async {
    try {
      final driveApi = await _authService.getDriveApi();
      if (driveApi == null) {
        throw Exception('Failed to get Drive API client');
      }

      final folderId = await _findOrCreateBackupFolder(driveApi);
      if (folderId == null) {
        throw Exception('Backup folder not found');
      }

      // Find backup file
      final fileQuery = "name='$_backupFileName' and parents in '$folderId' and trashed=false";
      final fileList = await driveApi.files.list(q: fileQuery);
      
      if (fileList.files == null || fileList.files!.isEmpty) {
        throw Exception('Backup file not found');
      }

      final fileId = fileList.files!.first.id!;
      
      // Download file content
      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final backupJson = utf8.decode(bytes);
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;

      // Restore backup data
      await _restoreBackupData(backupData);

      return true;
    } catch (e) {
      print('Error downloading backup: $e');
      return false;
    }
  }

  // Get backup info
  Future<Map<String, dynamic>?> getBackupInfo() async {
    try {
      final driveApi = await _authService.getDriveApi();
      if (driveApi == null) {
        return null;
      }

      final folderId = await _findOrCreateBackupFolder(driveApi);
      if (folderId == null) {
        return null;
      }

      // Find backup file
      final fileQuery = "name='$_backupFileName' and parents in '$folderId' and trashed=false";
      final fileList = await driveApi.files.list(
        q: fileQuery,
        $fields: 'files(id,name,modifiedTime,size)',
      );
      
      if (fileList.files == null || fileList.files!.isEmpty) {
        return null;
      }

      final file = fileList.files!.first;
      return {
        'name': file.name,
        'modifiedTime': file.modifiedTime?.toIso8601String(),
        'size': file.size,
      };
    } catch (e) {
      print('Error getting backup info: $e');
      return null;
    }
  }
}