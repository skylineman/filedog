import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../defClassandGlobal.dart';
import '../hiveDataTable/defImageInfomationClass.dart';

class MyDocumentsListController extends GetxController {

  final vaultDirectoriesFiles = <String>[].obs;
  List<String> selectedPath = [];
  List<bool> onSelectedFile = [];
  var selectedState = false.obs;
  var selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('Init MyDocumentsListController');
  }

  @override
  void onReady() {}

  @override
  void onClose() {}

  void addVaultDirectories( String value ) {
    vaultDirectoriesFiles.add(value);
  }

  void listVaultDirectories ( String _directoryPath, Box docBox ) {

    vaultDirectoriesFiles.clear();
    onSelectedFile.clear();
    Directory( _directoryPath ).listSync().forEach(( _file ) {
      String _filenameString = Path.basename( _file.path );
      debugPrint( 'Document Folder: ' + _filenameString );
      if (!(_filenameString.startsWith('_')) && !(_filenameString.startsWith('.'))) {

        ImageFileInfo _fileInfo = docBox.get( _filenameString );
        if ( _fileInfo.isDeleted == 0 ) {
          vaultDirectoriesFiles.add( _file.path );
          onSelectedFile.add( false );
        }
      }
    });
  }

  void clearSelectedState(){
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
      if (ele) {
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

  // 移动文件到回收站，需要做以下工作：
  // 1. 复制文件，删除源文件
  // 2. 更新controller中的vaultDirectoriesFiles

  /*
  Future moveSelectedFilesToTrash () async {

    return Future.forEach( selectedPath, ( _filePath ) async {
      debugPrint('Selected File:' + _filePath.toString() );
      await File( _filePath as String ).copy(Path.join(appDocDir.path, '.trash', Path.basename( _filePath )));
      await File( _filePath ).delete();
    });
  }

   */
}