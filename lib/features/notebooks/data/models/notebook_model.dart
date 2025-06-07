import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

part 'notebook_model.g.dart';

@HiveType(typeId: 1)
class NotebookModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final int? color;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime updatedAt;
  
  @HiveField(6)
  final bool isFavorite;
  
  @HiveField(7)
  final bool isDeleted;
  
  @HiveField(8)
  final String? iconName;
  
  @HiveField(9)
  final int noteCount;
  
  @HiveField(10)
  final Map<String, dynamic>? metadata;

  NotebookModel({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isDeleted = false,
    this.iconName,
    this.noteCount = 0,
    this.metadata,
  });

  // Factory constructor for creating a new notebook
  factory NotebookModel.create({
    required String name,
    String? description,
    int? color,
    String? iconName,
    bool? isFavorite,
  }) {
    final now = DateTime.now();
    return NotebookModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color ?? Colors.blue.value,
      createdAt: now,
      updatedAt: now,
      iconName: iconName ?? 'book',
      isFavorite: isFavorite ?? false,
    );
  }

  // Copy with method for immutable updates
  NotebookModel copyWith({
    String? id,
    String? name,
    String? description,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isDeleted,
    String? iconName,
    int? noteCount,
    Map<String, dynamic>? metadata,
  }) {
    return NotebookModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      iconName: iconName ?? this.iconName,
      noteCount: noteCount ?? this.noteCount,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization for cloud sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'iconName': iconName,
      'noteCount': noteCount,
      'metadata': metadata,
    };
  }

  factory NotebookModel.fromJson(Map<String, dynamic> json) {
    return NotebookModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      iconName: json['iconName'] as String?,
      noteCount: json['noteCount'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Database conversion methods
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'icon_name': iconName,
    };
  }

  factory NotebookModel.fromDatabase(Map<String, dynamic> map) {
    return NotebookModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      isFavorite: (map['is_favorite'] as int?) == 1,
      isDeleted: (map['is_deleted'] as int?) == 1,
      iconName: map['icon_name'] as String?,
    );
  }

  // Utility methods
  Color get colorValue => Color(color ?? Colors.blue.value);
  
  String get displayName => name.trim().isEmpty ? 'Untitled Notebook' : name;
  
  String get displayDescription => description?.trim() ?? '';
  
  Duration get age => DateTime.now().difference(createdAt);
  
  Duration get timeSinceUpdate => DateTime.now().difference(updatedAt);
  
  bool get isRecent => age.inDays < 7;
  
  bool get isModifiedRecently => timeSinceUpdate.inHours < 24;
  
  bool get hasNotes => noteCount > 0;
  
  String get noteCountText {
    if (noteCount == 0) return 'No notes';
    if (noteCount == 1) return '1 note';
    return '$noteCount notes';
  }
  
  IconData get icon {
    switch (iconName) {
      case 'book':
        return Icons.book;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'folder':
        return Icons.folder;
      case 'science':
        return Icons.science;
      case 'calculate':
        return Icons.calculate;
      case 'functions':
        return Icons.functions;
      default:
        return Icons.book;
    }
  }
  
  static List<String> get availableIcons => [
    'book',
    'school',
    'work',
    'home',
    'favorite',
    'star',
    'folder',
    'science',
    'calculate',
    'functions',
  ];
  
  static List<Color> get availableColors => [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotebookModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotebookModel(id: $id, name: $name, noteCount: $noteCount)';
  }
}