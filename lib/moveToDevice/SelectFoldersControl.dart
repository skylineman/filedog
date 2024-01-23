import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;

import '../defClassandGlobal.dart';

class SelectFoldersController extends GetxController {

  final vaultFoldersPath = <String>[].obs;
  List<String> selectedPath = [];
  List<bool> onSelectedFile = [];
  var selectedState = false.obs;
  var selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('Init SelectFoldersController');
  }

  @override
  void onReady() {}

  @override
  void onClose() {}

  void addVaultFoldersPath(String value) {
    vaultFoldersPath.add(value);
  }

  Future<void> listVaultFoldersPath ( Directory _directory )  {
    Completer _complete = Completer();

    //int _count = 0;
    vaultFoldersPath.clear();
    onSelectedFile.clear();

    vaultFoldersPath.add( Path.join( appDocDir.path, keyValueDocumentFolderName ));
    onSelectedFile.add(false);
    vaultFoldersPath.add( Path.join( appDocDir.path, keyValueAudioFolderName ));
    onSelectedFile.add(false);

    _directory.list().listen(( _file ) {
        String _filenameString = Path.basename(_file.path);
        if (!(_filenameString.startsWith('_')) && !(_filenameString.startsWith('.'))) {
          //_count++;
          vaultFoldersPath.add( _file.path );
          onSelectedFile.add(false);
          //Hive.openBox( _filenameString ).then(( _box ) {
        }
      },
      onDone: () {
        update(['Page']);
        _complete.complete( true );
      },
      onError: ( err ) => _complete.complete( err ),
    );
    return _complete.future;
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
      if ( ele ) {
        _count++;
        selectedPath.add(vaultFoldersPath [ _index ]);
      }
      _index++;
    });
    selectedCount.value = _count;
    if ( _count > 0 ) selectedState.value = true;
  }

  void selectAll( bool status ){
    for ( int i = 0; i < onSelectedFile.length; i++ )
      onSelectedFile[i] = status;
    getSelectedCount();
  }

}