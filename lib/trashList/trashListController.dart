import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;
import 'package:get/get.dart';

import '../hiveDataTable/defTrashFileClass.dart';
import '../hiveDataTable/defImageInfomationClass.dart';
import '../defClassandGlobal.dart';

class MyTrashListController extends GetxController {
  MyTrashListController( { required this.trashBox } );

  final Box trashBox;
  final vaultDirectoriesFiles = <String>[].obs;
  List<String> selectedPath = [];
  List<bool> onSelectedFile = [];
  var selectedState = false.obs;
  var selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('Init MyTrashListController');
  }

  @override
  void onReady() {}

  @override
  void onClose() {}

  void addVaultDirectories(String value) {
    vaultDirectoriesFiles.add(value);
  }

  void listVaultDirectories ()  {
    vaultDirectoriesFiles.clear();
    int _trashKeyNumbers = trashBox.length;
    debugPrint( ' KEYS: ' + trashBox.length.toString() );
    TrashFileInfo _tempTrashFileInfo;

    for ( int i = 0; i < _trashKeyNumbers; i++ ) {
      if ( !( trashBox.getAt( i ) is int )) {
        _tempTrashFileInfo = trashBox.getAt(i);
        //debugPrint('Tfile KEY: ' + _tempTrashFileInfo.tParentPath ); ;
        vaultDirectoriesFiles.add( _tempTrashFileInfo.tParentPath );
      }
    }
    //update(['Page']);
  }

  void clearSelectedState() {
    selectedState.value = false;
    for ( int i=0; i< onSelectedFile.length; i++ )
      onSelectedFile[i] = false;
    selectedCount.value = 0;
  }

  void getSelectedCount() {
    int _count = 0;
    int _index = 0;
    selectedPath.clear();
    onSelectedFile.forEach((ele) {
      if ( ele ) {
        _count++;
        selectedPath.add(vaultDirectoriesFiles [ _index ]);
      }
      _index++;
    });
    selectedCount.value = _count;
  }

  void selectAll( bool status ){
    for ( int i = 0; i < onSelectedFile.length; i++ )
      onSelectedFile[i] = status;
    getSelectedCount();
  }

  // 彻底删除回收站文件，需要做以下工作：
  // 1. 删除源文件
  // 2. 删除原Hive数据库中的记录，删除Trash.Hive中的记录
  // 3. 更新controller中的vaultDirectoriesFiles

  Future sweepFilesFromTrash () async {

    return Future.forEach( selectedPath, ( _filePath ) async {
      debugPrint('Selected File:' + _filePath.toString() );

      await Directory ( _filePath as String ).delete( recursive: true );
      await Hive.openBox( Path.basename( Path.dirname( _filePath )) ).then(( _box ) {
        _box.delete( Path.basename( _filePath ));
      });
      await trashBox.delete( Path.basename( _filePath ) );
    });
  }

  // 恢复文件从回收站到原目录，需要做以下工作：
  // 1. 删除trashBox中的相关记录
  // 2. 更改HiveBox相关记录中的"isDeleted"字段
  // 3. 更改HiveBox中的文件数量记录

  Future recoveryFilesFromTrash () async {
    Completer _completer = Completer();
    List<Future> _futureList = [];

    selectedPath.forEach( ( _filePath ) {
      ///storage/emulated/0/Android/data/com.skylineman.filedog/files/.Document/1075FA32520C33C7E9146CB140041720A9013DD5
      debugPrint('Selected File:' + _filePath );

      String _tarBoxName = '';

      TrashFileInfo _tfileInfo = trashBox.get( Path.basename( _filePath ));
      switch ( _tfileInfo.fileType ) {
        case 0x10:
          _tarBoxName = stringToBase64Url.encode(keyValueAudioFolderName);
          break;
        case 0x20:
          _tarBoxName = stringToBase64Url.encode(keyValueDocumentFolderName);
          break;
        case 0x30:
        case 0x40:
          _tarBoxName = stringToBase64Url.encode( Path.basename( Path.dirname(_filePath) ));
          break;
        default:
          break;
      }

      debugPrint('tarBoxName: ' + _tarBoxName );
      if ( _tarBoxName != '' ) {
        Hive.openBox( _tarBoxName ).then(( _tarBox ) {
          ImageFileInfo _fileInfo = _tarBox.get( Path.basename( _filePath ));
          int _fileCounts = _tarBox.get( keyValueFolderFiles ) + 1;
          _fileInfo.isDeleted = 0;
          Future _future1 = _tarBox.putAll( { keyValueFolderFiles : _fileCounts, Path.basename(_filePath) : _fileInfo } );
          _futureList.add( _future1 );
        });
      }

      Future _future2 = trashBox.delete( Path.basename( _filePath )); // 删除trashBox中的相关记录
      _futureList.add( _future2 );
      /*
      int _fileCounts = trashBox.get( keyValueFolderFiles ) - 1;
      int _folderSize = trashBox.get( keyValueFolderSize ) - _fileInfo.fileSize!;
      await trashBox.putAll( { keyValueFolderFiles: _fileCounts, keyValueFolderSize: _folderSize });

       */
      //await trashBox.putAll(entries)

    });

    Future.wait( _futureList ).whenComplete(() => _completer.complete());
    return _completer.future;
  }

  void listTrashBox(){
    debugPrint('Trash Box Length: ' + trashBox.length.toString() );
    for(int i = 0; i < trashBox.length; i++){
      debugPrint( trashBox.keyAt(i).toString() );
    }
  }
}