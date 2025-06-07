import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 2)
class TagModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int? color;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final int usageCount;
  
  @HiveField(5)
  final Map<String, dynamic>? metadata;

  TagModel({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
    this.usageCount = 0,
    this.metadata,
  });

  // Factory constructor for creating a new tag
  factory TagModel.create({
    required String name,
    int? color,
  }) {
    return TagModel(
      id: const Uuid().v4(),
      name: name.trim(),
      color: color ?? Colors.grey.value,
      createdAt: DateTime.now(),
    );
  }

  // Copy with method for immutable updates
  TagModel copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
    int? usageCount,
    Map<String, dynamic>? metadata,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization for cloud sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'usageCount': usageCount,
      'metadata': metadata,
    };
  }

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      usageCount: json['usageCount'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Database conversion methods
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TagModel.fromDatabase(Map<String, dynamic> map) {
    return TagModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Utility methods
  Color get colorValue => Color(color ?? Colors.grey.value);
  
  String get displayName => name.trim().isEmpty ? 'Unnamed Tag' : name;
  
  Duration get age => DateTime.now().difference(createdAt);
  
  bool get isRecent => age.inDays < 7;
  
  bool get isPopular => usageCount > 5;
  
  String get usageText {
    if (usageCount == 0) return 'Not used';
    if (usageCount == 1) return 'Used once';
    return 'Used $usageCount times';
  }
  
  // Predefined tag colors
  static List<Color> get availableColors => [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];
  
  // Common tag suggestions
  static List<String> get commonTags => [
    'Important',
    'Todo',
    'Work',
    'Personal',
    'Study',
    'Math',
    'Science',
    'Notes',
    'Ideas',
    'Research',
    'Project',
    'Meeting',
    'Homework',
    'Exam',
    'Formula',
    'Graph',
    'Calculation',
    'Theory',
    'Practice',
    'Review',
  ];
  
  // Tag validation
  static bool isValidTagName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && 
           trimmed.length <= 50 && 
           !trimmed.contains(RegExp(r'[<>"&]'));
  }
  
  static String sanitizeTagName(String name) {
    return name.trim()
        .replaceAll(RegExp(r'[<>"&]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
  
  // Tag chip widget properties
  Widget buildChip({
    VoidCallback? onDeleted,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return Chip(
      label: Text(
        displayName,
        style: TextStyle(
          color: selected ? Colors.white : colorValue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: selected ? colorValue : colorValue.withOpacity(0.1),
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 16) : null,
      onDeleted: onDeleted,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorValue, width: 1),
    );
  }
  
  Widget buildFilterChip({
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(
        displayName,
        style: TextStyle(
          color: selected ? Colors.white : colorValue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: colorValue.withOpacity(0.1),
      selectedColor: colorValue,
      checkmarkColor: Colors.white,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorValue, width: 1),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TagModel(id: $id, name: $name, usageCount: $usageCount)';
  }
}