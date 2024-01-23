// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defImageInfomationClass.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageFileInfoAdapter extends TypeAdapter<ImageFileInfo> {
  @override
  final int typeId = 1;

  @override
  ImageFileInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageFileInfo(
      fields[0] as String,
      fields[1] as String,
      fields[2] as DateTime?,
      fields[3] as DateTime?,
      fields[4] as int?,
      fields[5] as int?,
      fields[6] as int?,
      fields[7] as int?,
      fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageFileInfo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.realBaseName)
      ..writeByte(1)
      ..write(obj.tParentPath)
      ..writeByte(2)
      ..write(obj.createDate)
      ..writeByte(3)
      ..write(obj.modifyDate)
      ..writeByte(4)
      ..write(obj.imageWidth)
      ..writeByte(5)
      ..write(obj.imageHeight)
      ..writeByte(6)
      ..write(obj.fileSize)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageFileInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
