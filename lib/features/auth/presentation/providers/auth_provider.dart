import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/drive_backup_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  late final DriveBackupService _driveBackupService;
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService) {
    _driveBackupService = DriveBackupService(_authService);
    _user = _authService.currentUser;
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userDisplayName => _authService.userDisplayName;
  String? get userEmail => _authService.userEmail;
  String? get userPhotoURL => _authService.userPhotoURL;
  DriveBackupService get driveBackupService => _driveBackupService;

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        _user = userCredential.user;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Upload backup to Google Drive
  Future<bool> uploadBackup() async {
    if (!isSignedIn) {
      _setError('Please sign in to upload backup');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);
      
      final success = await _driveBackupService.uploadBackup();
      if (!success) {
        _setError('Failed to upload backup');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Download backup from Google Drive
  Future<bool> downloadBackup() async {
    if (!isSignedIn) {
      _setError('Please sign in to download backup');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);
      
      final success = await _driveBackupService.downloadBackup();
      if (!success) {
        _setError('Failed to download backup');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get backup info
  Future<Map<String, dynamic>?> getBackupInfo() async {
    if (!isSignedIn) {
      return null;
    }

    try {
      return await _driveBackupService.getBackupInfo();
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Auto backup (can be called periodically)
  Future<void> autoBackup() async {
    if (!isSignedIn) return;
    
    try {
      // Upload backup silently without showing loading state
      await _driveBackupService.uploadBackup();
    } catch (e) {
      // Silently fail for auto backup
      debugPrint('Auto backup failed: $e');
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}