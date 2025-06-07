import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../utils/performance_utils.dart';

/// A generic cache service for optimizing data access
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static CacheService get instance => _instance;

  final Map<String, _CacheEntry> _cache = {};
  final Map<String, DateTime> _lastAccess = {};
  
  // Configuration
  int _maxCacheSize = 100;
  Duration _defaultTtl = const Duration(minutes: 5);
  Duration _maxIdleTime = const Duration(minutes: 10);

  /// Configure cache settings
  void configure({
    int? maxCacheSize,
    Duration? defaultTtl,
    Duration? maxIdleTime,
  }) {
    _maxCacheSize = maxCacheSize ?? _maxCacheSize;
    _defaultTtl = defaultTtl ?? _defaultTtl;
    _maxIdleTime = maxIdleTime ?? _maxIdleTime;
  }

  /// Get a value from cache
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      _lastAccess.remove(key);
      return null;
    }

    // Update last access time
    _lastAccess[key] = DateTime.now();
    
    if (kDebugMode) {
      debugPrint('Cache hit for key: $key');
    }
    
    return entry.value as T?;
  }

  /// Put a value in cache
  void put<T>(String key, T value, {Duration? ttl}) {
    // Clean up if cache is full
    if (_cache.length >= _maxCacheSize) {
      _evictOldest();
    }

    final expiry = DateTime.now().add(ttl ?? _defaultTtl);
    _cache[key] = _CacheEntry(value, expiry);
    _lastAccess[key] = DateTime.now();
    
    if (kDebugMode) {
      debugPrint('Cache put for key: $key, expires: $expiry');
    }
  }

  /// Remove a value from cache
  void remove(String key) {
    _cache.remove(key);
    _lastAccess.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _lastAccess.clear();
    if (kDebugMode) {
      debugPrint('Cache cleared');
    }
  }

  /// Check if key exists and is not expired
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    
    if (entry.isExpired) {
      _cache.remove(key);
      _lastAccess.remove(key);
      return false;
    }
    
    return true;
  }

  /// Get cache statistics
  CacheStats get stats {
    final now = DateTime.now();
    int expiredCount = 0;
    int idleCount = 0;
    
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredCount++;
      }
      
      final lastAccess = _lastAccess[entry.key];
      if (lastAccess != null && now.difference(lastAccess) > _maxIdleTime) {
        idleCount++;
      }
    }
    
    return CacheStats(
      totalEntries: _cache.length,
      expiredEntries: expiredCount,
      idleEntries: idleCount,
      maxSize: _maxCacheSize,
    );
  }

  /// Clean up expired and idle entries
  void cleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _cache.entries) {
      final key = entry.key;
      final cacheEntry = entry.value;
      
      // Remove expired entries
      if (cacheEntry.isExpired) {
        keysToRemove.add(key);
        continue;
      }
      
      // Remove idle entries
      final lastAccess = _lastAccess[key];
      if (lastAccess != null && now.difference(lastAccess) > _maxIdleTime) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _cache.remove(key);
      _lastAccess.remove(key);
    }
    
    if (kDebugMode && keysToRemove.isNotEmpty) {
      debugPrint('Cache cleanup removed ${keysToRemove.length} entries');
    }
  }

  /// Evict oldest entries when cache is full
  void _evictOldest() {
    if (_lastAccess.isEmpty) return;
    
    // Find the oldest accessed entry
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _lastAccess.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }
    
    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _lastAccess.remove(oldestKey);
      
      if (kDebugMode) {
        debugPrint('Cache evicted oldest entry: $oldestKey');
      }
    }
  }

  /// Get or compute a value with caching
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
  }) async {
    // Try to get from cache first
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }
    
    // Compute the value
    final value = await compute();
    
    // Store in cache
    put(key, value, ttl: ttl);
    
    return value;
  }
}

/// Cache entry with expiration
class _CacheEntry {
  final dynamic value;
  final DateTime expiry;
  
  _CacheEntry(this.value, this.expiry);
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Cache statistics
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int idleEntries;
  final int maxSize;
  
  const CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.idleEntries,
    required this.maxSize,
  });
  
  double get hitRatio {
    if (totalEntries == 0) return 0.0;
    return (totalEntries - expiredEntries) / totalEntries;
  }
  
  double get utilization => totalEntries / maxSize;
  
  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, expired: $expiredEntries, '
           'idle: $idleEntries, hitRatio: ${(hitRatio * 100).toStringAsFixed(1)}%, '
           'utilization: ${(utilization * 100).toStringAsFixed(1)}%)';
  }
}

/// Specialized cache for notes
class NotesCache {
  static const String _notePrefix = 'note_';
  static const String _notesListPrefix = 'notes_list_';
  static const String _searchPrefix = 'search_';
  
  static final CacheService _cache = CacheService.instance;
  
  /// Cache a single note
  static void cacheNote(String noteId, dynamic note) {
    _cache.put('$_notePrefix$noteId', note);
  }
  
  /// Get a cached note
  static T? getNote<T>(String noteId) {
    return _cache.get<T>('$_notePrefix$noteId');
  }
  
  /// Cache a list of notes
  static void cacheNotesList(String key, List<dynamic> notes) {
    _cache.put('$_notesListPrefix$key', notes);
  }
  
  /// Get cached notes list
  static List<T>? getNotesList<T>(String key) {
    final cached = _cache.get<List<dynamic>>('$_notesListPrefix$key');
    return cached?.cast<T>();
  }
  
  /// Cache search results
  static void cacheSearchResults(String query, List<dynamic> results) {
    _cache.put('$_searchPrefix${query.hashCode}', results);
  }
  
  /// Get cached search results
  static List<T>? getSearchResults<T>(String query) {
    final cached = _cache.get<List<dynamic>>('$_searchPrefix${query.hashCode}');
    return cached?.cast<T>();
  }
  
  /// Clear all notes cache
  static void clearNotesCache() {
    // This is a simplified implementation
    // In a real app, you'd iterate through keys and remove note-related ones
    _cache.clear();
  }
  
  /// Invalidate cache for a specific note
  static void invalidateNote(String noteId) {
    _cache.remove('$_notePrefix$noteId');
    // Also invalidate any lists that might contain this note
    // This is simplified - in a real app you'd track dependencies
  }
}