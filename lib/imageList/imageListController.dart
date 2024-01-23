import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../hiveDataTable/defImageInfomationClass.dart';

class MyImageListController extends GetxController {

  final vaultDirectoriesFiles = <String>[].obs;
  List<String> selectedPath = [];
  List<bool> onSelectedFile = [];
  var selectedState = false.obs;
  var selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('Init MyImageListController');
  }

  @override
  void onReady() {}

  @override
  void onClose() {}

  void addVaultDirectories(String value) {
    vaultDirectoriesFiles.add(value);
  }

  Future<void> listVaultDirectories ( Directory _directory, Box _thumbDbSource ) async {
    int _count = 0;
    vaultDirectoriesFiles.clear();
    onSelectedFile.clear();

    _directory.list().listen(
      ( _file ) {
        String _filenameString = Path.basename( _file.path );
        ImageFileInfo _imageFileInfo = _thumbDbSource.get( _filenameString ) ?? ImageFileInfo(
          '', '', DateTime( 2022, 1, 1, 0, 0, 0), DateTime( 2022, 1, 1, 0, 0, 0), 0, 0, 0, 0, 1
        );
        if ( !(_filenameString.startsWith('_')) && !(_filenameString.startsWith('.')) && _imageFileInfo.isDeleted == 0 ) {
          _count++;
          vaultDirectoriesFiles.add( _file.path );
          onSelectedFile.add(false);
          debugPrint( _file.path );
        }
      },
      onDone: () {
        update(['Page']);
      },
      onError: ( err ) => debugPrint('Folder: ' + err.toString()),
    );
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
    for ( int i=0; i< onSelectedFile.length; i++ )
      onSelectedFile[i] = status;
    getSelectedCount();
  }

  // 收藏夹操作，收藏夹数据库的key是采用全路径的Base64
  /*
  Future setSelectedFilesFavorite(Box _thumbDbSource) async {
    Box _thumbDbFavorite = await Hive.openBox( keyValueFavoriteBoxName);
    return Future.forEach( selectedPath, ( String _filePath ) async {
      if ( _thumbDbFavorite.get((stringToBase64Url.encode( _filePath ))) == null ) {
        ImageFileInfo _fileInfo = _thumbDbSource.get(Path.basenameWithoutExtension( _filePath ));
        await _thumbDbFavorite.put(stringToBase64Url.encode( _filePath ), _fileInfo);
      }
    }).whenComplete(() => _thumbDbFavorite.close());
  }
  */

}