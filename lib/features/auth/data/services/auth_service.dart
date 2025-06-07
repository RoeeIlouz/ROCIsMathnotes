import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1011854802210-jbasnrc5tlp07rbhr4j5fonr50apt47p.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Use alternative authentication for Windows
      return await _signInWithBrowserAuth();
    } else {
      // Use existing Google Sign-In for supported platforms
      return await _signInWithGoogleSDK();
    }
  }
  
  Future<UserCredential?> _signInWithGoogleSDK() async {
    // Your existing Google Sign-In implementation
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      developer.log('Error signing in with Google: $e', name: 'AuthService');
      rethrow;
    }
  }
  
  Future<UserCredential?> _signInWithBrowserAuth() async {
    // Implement browser-based OAuth for Windows
    // You can use packages like 'oauth2' or 'googleapis_auth'
    throw UnimplementedError('Windows authentication not yet implemented');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      developer.log('Error signing out: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Get Google Drive API client
  Future<drive.DriveApi?> getDriveApi() async {
    try {
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final authClient = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            googleAuth.accessToken!,
            DateTime.now().add(const Duration(hours: 1)).toUtc(),
          ),
          googleAuth.idToken,
          ['https://www.googleapis.com/auth/drive.file'],
        ),
      );

      return drive.DriveApi(authClient);
    } catch (e) {
      developer.log('Error getting Drive API: $e', name: 'AuthService');
      return null;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Get user display name
  String? get userDisplayName => currentUser?.displayName;

  // Get user email
  String? get userEmail => currentUser?.email;

  // Get user photo URL
  String? get userPhotoURL => currentUser?.photoURL;
}