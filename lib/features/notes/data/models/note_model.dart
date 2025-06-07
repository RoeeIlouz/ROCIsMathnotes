import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final String? notebookId;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime updatedAt;
  
  @HiveField(6)
  final bool isFavorite;
  
  @HiveField(7)
  final bool isDeleted;
  
  @HiveField(8)
  final bool hasDrawing;
  
  @HiveField(9)
  final bool hasHandwriting;
  
  @HiveField(10)
  final bool hasMath;
  
  @HiveField(11)
  final String? drawingData;
  
  @HiveField(12)
  final String? handwritingData;
  
  @HiveField(13)
  final String? mathData;
  
  @HiveField(14)
  final String? aiSummary;
  
  @HiveField(15)
  final List<String> tagIds;
  
  @HiveField(16)
  final int? color;
  
  @HiveField(17)
  final String? thumbnailPath;
  
  @HiveField(18)
  final Map<String, dynamic>? metadata;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.notebookId,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isDeleted = false,
    this.hasDrawing = false,
    this.hasHandwriting = false,
    this.hasMath = false,
    this.drawingData,
    this.handwritingData,
    this.mathData,
    this.aiSummary,
    this.tagIds = const [],
    this.color,
    this.thumbnailPath,
    this.metadata,
  });

  // Factory constructor for creating a new note
  factory NoteModel.create({
    required String title,
    String content = '',
    String? notebookId,
    List<String> tagIds = const [],
    int? color,
    bool hasDrawing = false,
    String? drawingData,
  }) {
    final now = DateTime.now();
    return NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      notebookId: notebookId,
      createdAt: now,
      updatedAt: now,
      tagIds: tagIds,
      color: color,
      hasDrawing: hasDrawing,
      drawingData: drawingData,
    );
  }

  // Copy with method for immutable updates
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? notebookId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isDeleted,
    bool? hasDrawing,
    bool? hasHandwriting,
    bool? hasMath,
    String? drawingData,
    String? handwritingData,
    String? mathData,
    String? aiSummary,
    List<String>? tagIds,
    int? color,
    String? thumbnailPath,
    Map<String, dynamic>? metadata,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      notebookId: notebookId ?? this.notebookId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      hasDrawing: hasDrawing ?? this.hasDrawing,
      hasHandwriting: hasHandwriting ?? this.hasHandwriting,
      hasMath: hasMath ?? this.hasMath,
      drawingData: drawingData ?? this.drawingData,
      handwritingData: handwritingData ?? this.handwritingData,
      mathData: mathData ?? this.mathData,
      aiSummary: aiSummary ?? this.aiSummary,
      tagIds: tagIds ?? this.tagIds,
      color: color ?? this.color,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization for cloud sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'notebookId': notebookId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'hasDrawing': hasDrawing,
      'hasHandwriting': hasHandwriting,
      'hasMath': hasMath,
      'drawingData': drawingData,
      'handwritingData': handwritingData,
      'mathData': mathData,
      'aiSummary': aiSummary,
      'tagIds': tagIds,
      'color': color,
      'thumbnailPath': thumbnailPath,
      'metadata': metadata,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      notebookId: json['notebookId'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      hasDrawing: json['hasDrawing'] as bool? ?? false,
      hasHandwriting: json['hasHandwriting'] as bool? ?? false,
      hasMath: json['hasMath'] as bool? ?? false,
      drawingData: json['drawingData'] as String?,
      handwritingData: json['handwritingData'] as String?,
      mathData: json['mathData'] as String?,
      aiSummary: json['aiSummary'] as String?,
      tagIds: (json['tagIds'] as List<dynamic>?)?.cast<String>() ?? [],
      color: json['color'] as int?,
      thumbnailPath: json['thumbnailPath'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Database conversion methods
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'notebook_id': notebookId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'has_drawing': hasDrawing ? 1 : 0,
      'has_handwriting': hasHandwriting ? 1 : 0,
      'has_math': hasMath ? 1 : 0,
      'drawing_data': drawingData,
      'handwriting_data': handwritingData,
      'math_data': mathData,
      'ai_summary': aiSummary,
    };
  }

  factory NoteModel.fromDatabase(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String? ?? '',
      notebookId: map['notebook_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      isFavorite: (map['is_favorite'] as int?) == 1,
      isDeleted: (map['is_deleted'] as int?) == 1,
      hasDrawing: (map['has_drawing'] as int?) == 1,
      hasHandwriting: (map['has_handwriting'] as int?) == 1,
      hasMath: (map['has_math'] as int?) == 1,
      drawingData: map['drawing_data'] as String?,
      handwritingData: map['handwriting_data'] as String?,
      mathData: map['math_data'] as String?,
      aiSummary: map['ai_summary'] as String?,
    );
  }

  // Utility methods
  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;
  
  bool get hasContent => !isEmpty || hasDrawing || hasHandwriting || hasMath;
  
  String get displayTitle => title.trim().isEmpty ? 'Untitled Note' : title;
  
  String get previewContent {
    if (content.trim().isNotEmpty) {
      return content.length > 100 ? '${content.substring(0, 100)}...' : content;
    }
    if (hasDrawing) return 'Drawing';
    if (hasHandwriting) return 'Handwriting';
    if (hasMath) return 'Math';
    return 'Empty note';
  }
  
  Duration get age => DateTime.now().difference(createdAt);
  
  Duration get timeSinceUpdate => DateTime.now().difference(updatedAt);
  
  bool get isRecent => age.inDays < 7;
  
  bool get isModifiedRecently => timeSinceUpdate.inHours < 24;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, createdAt: $createdAt)';
  }
}