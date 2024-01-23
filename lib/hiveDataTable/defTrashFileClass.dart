import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'defTrashFileClass.g.dart';

@HiveType(typeId: 2)
class TrashFileInfo {
  @HiveField(0)
  String realBaseName;
  @HiveField(1)
  String tParentPath;
  @HiveField(2)
  int? fileSize;
  @HiveField(3)
  int? fileType;
  @HiveField(4)
  DateTime? deleteTime;

  TrashFileInfo( this.realBaseName, this.tParentPath, this.fileSize, this.fileType, this.deleteTime );
}

/*

fileType:

0x00 ~ 0x10: reverse
0x10 ~ 0x1f: audio file
0x20 ~ 0x2f: document file
0x30 ~ 0x3f: Picture File
0x40 ~ 0x4f: Video File

*/