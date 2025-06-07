import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../features/notes/data/models/note_model.dart';
import '../../features/notebooks/data/models/notebook_model.dart';
import '../../features/tags/data/models/tag_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  
  static FirebaseService get instance => _instance;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  String? get userId => currentUser?.uid;
  
  Future<void> initialize() async {
    // Set up auth state listener
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('User signed in: ${user.uid}');
      } else {
        debugPrint('User signed out');
      }
    });
  }
  
  // Authentication methods
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }
  
  Future<UserCredential?> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      return null;
    }
  }
  
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
    } catch (e) {
      debugPrint('Error creating user with email and password: $e');
      return null;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
  
  // Firestore methods for notes
  Future<void> syncNote(NoteModel note) async {
    if (!isSignedIn) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(note.id)
          .set(note.toJson());
    } catch (e) {
      debugPrint('Error syncing note: $e');
      rethrow;
    }
  }
  
  Future<List<NoteModel>> fetchNotes() async {
    if (!isSignedIn) return [];
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .where('isDeleted', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => NoteModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }
  
  Future<void> deleteNote(String noteId) async {
    if (!isSignedIn) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .update({'isDeleted': true, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }
  
  // Firestore methods for notebooks
  Future<void> syncNotebook(NotebookModel notebook) async {
    if (!isSignedIn) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notebooks')
          .doc(notebook.id)
          .set(notebook.toJson());
    } catch (e) {
      debugPrint('Error syncing notebook: $e');
      rethrow;
    }
  }
  
  Future<List<NotebookModel>> fetchNotebooks() async {
    if (!isSignedIn) return [];
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notebooks')
          .where('isDeleted', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => NotebookModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notebooks: $e');
      return [];
    }
  }
  
  Future<void> deleteNotebook(String notebookId) async {
    if (!isSignedIn) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notebooks')
          .doc(notebookId)
          .update({'isDeleted': true, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
    } catch (e) {
      debugPrint('Error deleting notebook: $e');
      rethrow;
    }
  }
  
  // Firestore methods for tags
  Future<void> syncTag(TagModel tag) async {
    if (!isSignedIn) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tags')
          .doc(tag.id)
          .set(tag.toJson());
    } catch (e) {
      debugPrint('Error syncing tag: $e');
      rethrow;
    }
  }
  
  Future<List<TagModel>> fetchTags() async {
    if (!isSignedIn) return [];
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tags')
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => TagModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching tags: $e');
      return [];
    }
  }
  
  // Storage methods for files (drawings, images, etc.)
  Future<String?> uploadFile(
    String path, 
    Uint8List data, 
    String contentType
  ) async {
    if (!isSignedIn) return null;
    
    try {
      final ref = _storage.ref().child('users/$userId/$path');
      final uploadTask = ref.putData(data, SettableMetadata(contentType: contentType));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }
  
  Future<Uint8List?> downloadFile(String path) async {
    if (!isSignedIn) return null;
    
    try {
      final ref = _storage.ref().child('users/$userId/$path');
      return await ref.getData();
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }
  
  Future<void> deleteFile(String path) async {
    if (!isSignedIn) return;
    
    try {
      final ref = _storage.ref().child('users/$userId/$path');
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }
  
  // Batch sync operations
  Future<void> syncAllData({
    List<NoteModel>? notes,
    List<NotebookModel>? notebooks,
    List<TagModel>? tags,
  }) async {
    if (!isSignedIn) return;
    
    try {
      final batch = _firestore.batch();
      
      if (notes != null) {
        for (final note in notes) {
          final docRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('notes')
              .doc(note.id);
          batch.set(docRef, note.toJson());
        }
      }
      
      if (notebooks != null) {
        for (final notebook in notebooks) {
          final docRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('notebooks')
              .doc(notebook.id);
          batch.set(docRef, notebook.toJson());
        }
      }
      
      if (tags != null) {
        for (final tag in tags) {
          final docRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('tags')
              .doc(tag.id);
          batch.set(docRef, tag.toJson());
        }
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error syncing all data: $e');
      rethrow;
    }
  }
  
  // Real-time listeners
  Stream<List<NoteModel>> notesStream() {
    if (!isSignedIn) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromJson(doc.data()))
            .toList());
  }
  
  Stream<List<NotebookModel>> notebooksStream() {
    if (!isSignedIn) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notebooks')
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotebookModel.fromJson(doc.data()))
            .toList());
  }
  
  Stream<List<TagModel>> tagsStream() {
    if (!isSignedIn) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TagModel.fromJson(doc.data()))
            .toList());
  }
}