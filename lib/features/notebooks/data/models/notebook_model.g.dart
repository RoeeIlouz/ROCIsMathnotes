// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebook_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotebookModelAdapter extends TypeAdapter<NotebookModel> {
  @override
  final int typeId = 1;

  @override
  NotebookModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotebookModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      color: fields[3] as int?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      isFavorite: fields[6] as bool,
      isDeleted: fields[7] as bool,
      iconName: fields[8] as String?,
      noteCount: fields[9] as int,
      metadata: (fields[10] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotebookModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.iconName)
      ..writeByte(9)
      ..write(obj.noteCount)
      ..writeByte(10)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
