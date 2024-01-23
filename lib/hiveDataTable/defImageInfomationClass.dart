import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'defImageInfomationClass.g.dart';

@HiveType(typeId: 1)
class ImageFileInfo {
  @HiveField(0)
  String realBaseName;
  @HiveField(1)
  String tParentPath;
  @HiveField(2)
  DateTime? createDate;
  @HiveField(3)
  DateTime? modifyDate;
  @HiveField(4)
  int? imageWidth;
  @HiveField(5)
  int? imageHeight;
  @HiveField(6)
  int? fileSize;
  @HiveField(7)
  int? duration;
  @HiveField(8)
  int? isDeleted;

  ImageFileInfo( this.realBaseName, this.tParentPath, this.createDate, this.modifyDate, this.imageWidth, this.imageHeight, this.fileSize, this.duration, this.isDeleted );
}
