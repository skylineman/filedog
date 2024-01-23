import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../hiveDataTable/defImageInfomationClass.dart';
import '../defClassandGlobal.dart';

class AudioListController extends GetxController {

  final vaultDirectoriesFiles = <String>[].obs;
  List<String> selectedPath = [];
  List<bool> onSelectedFile = [];
  var selectedState = false.obs;
  var selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void addVaultDirectories(String value) =>
    vaultDirectoriesFiles.add(value);

  void listVaultDirectories ( String _directoryPath, Box audioBox ) {

    vaultDirectoriesFiles.clear();
    onSelectedFile.clear();

    for ( int i = 2; i < audioBox.length; i++ ) {
      debugPrint( audioBox.keyAt( i ).toString() + ' ' + audioBox.get( audioBox.keyAt( i ) ).realBaseName + ' ' + audioBox.get( audioBox.keyAt( i ) ).isDeleted.toString() );
    }

    Directory( _directoryPath ).listSync().forEach(( _file ) {
      String _filenameString = Path.basename( _file.path );

      //debugPrint( 'Audio Fild: ' + _filenameString + 'Name:' + audioBox.get(_filenameString).realBaseName + ' isDelete: ' + audioBox.get(_filenameString).isDeleted.toString() );
      debugPrint( 'Audio File: ' + _filenameString + ' ' + audioBox.length.toString() );

      if (!(_filenameString.startsWith('_')) && !(_filenameString.startsWith('.'))) {
        ImageFileInfo? _fileInfo = audioBox.get( _filenameString );
        if ( _fileInfo != null )
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
}