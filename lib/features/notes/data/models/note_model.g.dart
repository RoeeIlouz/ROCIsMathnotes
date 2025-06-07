// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      notebookId: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      isFavorite: fields[6] as bool,
      isDeleted: fields[7] as bool,
      hasDrawing: fields[8] as bool,
      hasHandwriting: fields[9] as bool,
      hasMath: fields[10] as bool,
      drawingData: fields[11] as String?,
      handwritingData: fields[12] as String?,
      mathData: fields[13] as String?,
      aiSummary: fields[14] as String?,
      tagIds: (fields[15] as List).cast<String>(),
      color: fields[16] as int?,
      thumbnailPath: fields[17] as String?,
      metadata: (fields[18] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.notebookId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.hasDrawing)
      ..writeByte(9)
      ..write(obj.hasHandwriting)
      ..writeByte(10)
      ..write(obj.hasMath)
      ..writeByte(11)
      ..write(obj.drawingData)
      ..writeByte(12)
      ..write(obj.handwritingData)
      ..writeByte(13)
      ..write(obj.mathData)
      ..writeByte(14)
      ..write(obj.aiSummary)
      ..writeByte(15)
      ..write(obj.tagIds)
      ..writeByte(16)
      ..write(obj.color)
      ..writeByte(17)
      ..write(obj.thumbnailPath)
      ..writeByte(18)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
