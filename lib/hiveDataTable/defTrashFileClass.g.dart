// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defTrashFileClass.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrashFileInfoAdapter extends TypeAdapter<TrashFileInfo> {
  @override
  final int typeId = 2;

  @override
  TrashFileInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrashFileInfo(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int?,
      fields[3] as int?,
      fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TrashFileInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.realBaseName)
      ..writeByte(1)
      ..write(obj.tParentPath)
      ..writeByte(2)
      ..write(obj.fileSize)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.deleteTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrashFileInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
