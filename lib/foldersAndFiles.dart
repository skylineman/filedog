import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as Path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'crypto/cryptoGraphy.dart';
import 'defClassandGlobal.dart';
import 'hiveDataTable/defImageInfomationClass.dart';
import 'hiveDataTable/defTrashFileClass.dart';

// 同一文件夹文件改名
Future<File> FileRenameOnly( File fileSource, String newname ){
  return fileSource.rename( Path.join( Path.dirname( fileSource.path ), newname ) );
}

// 初始化文件夹数组
// 获取资料文件夹，并遍历子目录，如果为空，则创建默认文件夹，以及根目录 HIVE 库

Future InitVaultDirectoriesAndroid( String defaultFolderName ) {

  debugPrint('Get APP Document Folder:' + appDocDir.path );
  vaultDirectoriesPath.clear();

  // 回收站文件夹，如果不存在则创建
  /*
  String _trashFile = Path.join( appDocDir.path, '.trash' );
  if ( !Directory ( _trashFile ).existsSync() )
    Directory( _trashFile ).createSync();

   */

  // 文档文件夹，如果不存在则创建
  String _docomentsFile = Path.join( appDocDir.path, keyValueDocumentFolderName );
  if ( !Directory ( _docomentsFile ).existsSync() )
    Directory( _docomentsFile ).createSync();

  // 音频文件夹，如果不存在则创建
  String _audioFile = Path.join( appDocDir.path, keyValueAudioFolderName );
  if ( !Directory ( _audioFile ).existsSync() )
    Directory( _audioFile ).createSync();

  // 默认文件夹
  String _defaultFolder = Path.join( appDocDir.path,keyValueDefaultFolderName );
  if ( !Directory( _defaultFolder ).existsSync() ) {

    MyCreateFolder( Directory( _defaultFolder )).then( (_) {
      debugPrint( 'First Run App, create default folder!');
    });
  }

  initKeyFile4Ffmpeg().then((_) {
    debugPrint('Init key file for ffmpeg');
  });

  // 创建Hive数据库：
  // Trash.hive, Document.hive, Audio.hive, default.hive

  // Hive数据库文件名（实质上是一个文件夹）
  String _dbPath = Path.join( appDocDir.path, keyValueHiveFolderName );

  if ( Directory( _dbPath ).existsSync() ) {
    // 初始化Hive数据库
    return Hive.initFlutter( _dbPath ).then((_) {
      debugPrint( 'Init Hive DataBox' );
    });
  }
  else {
    // 没有发现Hive Box的目录，在Files目录下创建HIVE子目录，并初始化第一个BOX
    Completer _complete1 = Completer();
    Completer _complete2 = Completer();
    Completer _complete3 = Completer();
    Completer _complete4 = Completer();

    Hive.initFlutter( _dbPath ).then((_) {

      Future.wait([
        Hive.openBox( stringToBase64Url.encode( keyValueDocumentFolderName )).then(( _box ) {
          _box.putAll( { keyValueFolderFiles : 0, keyValueFolderSize: 0 } ).then((_) {
            _box.close();
            _complete1.complete( 0 ); });
        }),
        Hive.openBox( stringToBase64Url.encode( keyValueAudioFolderName )).then(( _box ) {
          _box.putAll( { keyValueFolderFiles : 0, keyValueFolderSize: 0 } ).then((_) {
            _box.close();
            _complete2.complete( 0 ); });
        } ),
        Hive.openBox( stringToBase64Url.encode( keyValueDefaultFolderName )).then(( _box ) {
          _box.putAll( { keyValueFolderFiles : 0, keyValueFolderSize: 0, keyValueFolderCover: defaultImageData,
            keyValueFolderNickname: ( defaultFolderName != '' ) ? defaultFolderName : keyValueFolderNickname } ).then((_) {
            _box.close();
            _complete3.complete( 0 );
          });
        }),
        Hive.openBox( stringToBase64Url.encode( keyValueTrashBoxName )).then(( _box ) {
          _box.close();
          _complete4.complete( 0 );
        } ),

      ]).then(( _ ) {
        debugPrint( 'First Run App, Create and Init Hive Database!' );
      });
    });
    return Future.wait([ _complete1.future, _complete2.future, _complete3.future, _complete4.future ]);
  }
}

// 创建文件夹
Future MyCreateFolder  ( Directory folder ) {
  Completer _complete = Completer();
  try {
    folder.create().then((value) {
      //debugPrint( 'Create Successful!' + value.path );
      vaultDirectoriesPath.add( folder.path );
      _complete.complete( 0 );
    });
  } catch (e) {
    debugPrint( 'ERR in MyCreateFolder:' + e.toString() );
    _complete.complete( 1 );
  }
  return _complete.future;
}

// 分块读取大文件，并传递进度

Future<dynamic> ReadFileByBlock ( File _sfile, File _tfile, int fileCounter, StreamController _streamCtlr ) {

  Completer _complete =  Completer();

  _sfile.openRead().listen(( event ) {
    _tfile.writeAsBytesSync( event, mode: FileMode.append );
    _streamCtlr.sink.add( -1 );

  }).onDone(() {
    _complete.complete();
  });
  return _complete.future;
}

Future<dynamic> CopyFileByBlockCypto ( File _sfile, File _tfile, StreamController _streamCtlr ) {

  Completer _complete =  Completer();
  List<Future> futures = [];
  final _cipher = AesCbc.with128bits( macAlgorithm: MacAlgorithm.empty, paddingAlgorithm: PaddingAlgorithm.zero );

  _sfile.openRead().listen(( _dataBlock ) {

    Future _future = _cipher.encrypt( _dataBlock, nonce: aesNonce, secretKey: SecretKey( aesKey )).then(( _cyptoResult ) {
      _tfile.writeAsBytesSync( _cyptoResult.cipherText, mode: FileMode.append );
      _streamCtlr.sink.add( -1 );
    });
    futures.add( _future );

  }).onDone(() {
    Future.wait( futures ).then((_) {
      _complete.complete();
    });
  });

  return _complete.future;
}

// 读取加密文件
Future<Uint8List> ReadCyptoFile ( File _file ) {

  final _cipher = AesCbc.with128bits( macAlgorithm: MacAlgorithm.empty, paddingAlgorithm: PaddingAlgorithm.zero );
  List<int> _clearData1 = [];

  Completer<Uint8List> _completer = Completer();
  List<Future> _futures = [];

  _file.openRead().listen( (event) {

    Future _future = _cipher.decrypt( SecretBox( event, nonce: aesNonce, mac: Mac.empty ), secretKey: SecretKey( aesKey )).then(( _dataBlock ) {
      _clearData1.addAll( _dataBlock );
      //debugPrint( 'Read Cypto Block: ' + _blockCounter.toString());
    });
    _futures.add( _future );

  }).onDone(() {
    Future.wait( _futures ).then((_) {
      //_clearData1.addAll( _clearData2 );
      _completer.complete( Uint8List.fromList( _clearData1 ));
      //debugPrint( 'Read AES File Done: ' + _blockCounter.toString() + ' ' + _clearData1.length.toString() );
    });
  });
  return _completer.future;
}



// 移动选择的PV文件，因为PV文件是一个文件夹中多个文件组成，所以移动方法和文档文件、音频文件不同。
// 源文件和目标文件都需要分别在相同的文件夹，
// 参数：
// _thumbDbSource:  源目录的数据库对象
// selectedPaths: 选中的文件路径，指存储文件及其附加微缩图所在的文件夹路径
// targetDirectoryPath：目标路径
// !=== 需要补充错误处理 ===!

Future MoveSelectedPVFiles ( Box _thumbDbSource,  List<String> selectedPaths, String targetDirectoryPath ) {

  Completer _complete = Completer();
  List<Future> _futures = [];
  debugPrint( 'Target Directory: ' + targetDirectoryPath );

  Hive.openBox( stringToBase64Url.encode( Path.basename( targetDirectoryPath ))).then(( _thumbDbTarget ) {

    selectedPaths.forEach( ( String _filesPath ) async {
      // 这里的路径是全路径
      debugPrint('1 Selected File:' + _filesPath );

      ImageFileInfo _fileInfo = _thumbDbSource.get( Path.basename( _filesPath ) );
      _fileInfo.tParentPath = Path.join( targetDirectoryPath, Path.basename( _filesPath ));
      debugPrint( '2 File Info Real Name: ' + _fileInfo.realBaseName );

      Future _future = Future.wait([
        _thumbDbTarget.put( Path.basename( _filesPath ), _fileInfo ),
        _thumbDbSource.delete(Path.basename(_filesPath)),
      ]).then((_) {

        debugPrint( '3 Move File: ' + _filesPath );

        if ( !( Directory( Path.join( targetDirectoryPath, Path.basename( _filesPath ))).existsSync() ) )
          Directory( Path.join( targetDirectoryPath, Path.basename( _filesPath ))).createSync();

        Directory( _filesPath ).listSync().forEach(( _file ) {
          File( _file.path ).copySync( Path.join( targetDirectoryPath, Path.basename( _filesPath ), Path.basename( _file.path )) );
          _file.deleteSync();
        });
        Directory( _filesPath ).deleteSync();

        debugPrint( '4 Move Completed: ' + _filesPath );
      });
      _futures.add( _future );
    });
    Future.wait( _futures ).then( (_) => _complete.complete() );
  });
  return _complete.future;
}

// 回收站机制：删除文件到回收站，并未真正的删除或移动
// 仅仅在FileInfo中进行了标记，并将文件信息复制到TrashBox中，
// 参数：
// _thumbDbSource:  源目录的数据库对象
// selectedPaths: 选中的文件路径，指存储文件及其附加微缩图所在的文件夹路径
// !=== 需要补充错误处理 ===!

Future trashSelectedPVFiles (Box _thumbDbSource,  List<String> selectedPaths ) {

  Completer _complete = Completer();
  List<Future> _futures = [];
  int _fileCount = 0, _folderSize = 0;

  Hive.openBox( stringToBase64Url.encode( keyValueTrashBoxName ) ).then(( trashBox ) {

    _fileCount = trashBox.get ( keyValueFolderFiles, defaultValue: 0 );
    _folderSize = trashBox.get ( keyValueFolderSize, defaultValue: 0 );

    selectedPaths.forEach(( _filePath )  {
      debugPrint('Selected File:' + _filePath );
      ImageFileInfo _fileInfo = _thumbDbSource.get( Path.basename( _filePath ));
      _fileInfo.isDeleted = 1;
      _folderSize = _fileInfo.fileSize! + _folderSize;
      _fileCount ++;
      int _fileType = getFileTypeByExtension( _fileInfo.realBaseName );

      TrashFileInfo _trashFileInfo = TrashFileInfo( _fileInfo.realBaseName, _fileInfo.tParentPath, _fileInfo.fileSize, _fileType, DateTime.now());
      _futures.add ( Future.wait( [
        trashBox.put( Path.basename( _filePath ), _trashFileInfo ),
        _thumbDbSource.put( Path.basename( _filePath ), _fileInfo ),
      ] ) );
    });

    Future.wait( _futures ).whenComplete(() {
      int _sFiles = _thumbDbSource.get( keyValueFolderFiles );
      int _sFileSize = _thumbDbSource.get( keyValueFolderSize );
      Future.wait([
        _thumbDbSource.putAll( {keyValueFolderFiles : _sFiles - selectedPaths.length, keyValueFolderSize : _sFileSize - _folderSize }),
        //trashBox.putAll( {keyValueFolderFiles : _fileCount, keyValueFolderSize : _folderSize } )

      ]).then((_) => _complete.complete( ) );
    });
  });

  return  _complete.future;
}

// 删除指定的文件夹，直接全部删除，不放入回收站
// 删除文件夹所有的文件、以及文件夹；
// 删除对应HIVE数据库
// folderPath是真正的文件夹全路径

Future<bool?> DeleteFolderProcess( String folderPath ) {

  if ( Path.basename( folderPath ) == keyValueDefaultFolderName ) {

    if (Directory( folderPath ).existsSync()) {

      Directory( folderPath ).listSync().forEach(( _path ) {
        debugPrint( 'Delete Folder:' + _path.path );
        try {
          _path.deleteSync( recursive: true );
        }
        on FileSystemException {
          debugPrint( 'Failed to delete folder:' + _path.path );
        }

        //_path.deleteSync( recursive: true );
      });
    }

    Hive.openBox( stringToBase64Url.encode( Path.basename( folderPath ))).then(( _thumbDbTarget ) async {
      String _nickname = await _thumbDbTarget.get( keyValueFolderNickname );

      await _thumbDbTarget.clear();
      await _thumbDbTarget.put( keyValueFolderNickname, _nickname );
      await _thumbDbTarget.put( keyValueFolderFiles, 0 );
      await _thumbDbTarget.put( keyValueFolderSize, 0 );
      await _thumbDbTarget.put( keyValueFolderCover, defaultImageData );

      //await _thumbDbTarget.close();
    });
    return Future.value( true );
  }

  else {
    if (Directory(folderPath).existsSync())
      return Future.wait([
        Directory(folderPath).delete(recursive: true),
        Hive.deleteBoxFromDisk(stringToBase64Url.encode(Path.basename(folderPath))),
      ]).then((values) => true);

    else
      return Future.value(false);
  }
}


// 音频文件选择器
Future<bool> importAudio( BuildContext context,List<AssetEntity>? results, Box audioBox, StreamController<dynamic> _streamCtrl )  {  //BuildContext context, AudioListController _ctrl ){

  List<Future> _futures = [];
  Completer<bool> _complete = Completer();
  final String audioFolderPath = Path.join( appDocDir.path, keyValueAudioFolderName );


    if ( results != null ) {
      debugPrint( 'Picked Files:' + results.length.toString() );

      results.forEach(( _assetEntity ) {

        ImageFileInfo _fileInfo = ImageFileInfo( '','', DateTime( 2022, 1, 1, 0, 0, 0), DateTime( 2022, 1, 1, 0, 0, 0), 0, 0, 0, 0, 0 );
        Completer _completeInside = Completer();
        _futures.add( _completeInside.future );

        _assetEntity.file.then(( _assetFile ) {
          if ( _assetFile != null ) {

            _fileInfo.isDeleted = 0;
            _fileInfo.createDate = _assetEntity.createDateTime;
            _fileInfo.realBaseName = Path.basename( _assetFile.path );
            _fileInfo.fileSize = _assetFile.lengthSync();

            String _newShaFileName = intListToHexString( sha1.convert( utf8.encode( _fileInfo.fileSize.toString() + _fileInfo.realBaseName )).bytes, false );

            _fileInfo.tParentPath = Path.join( audioFolderPath, _newShaFileName );

            if ( !Directory( _fileInfo.tParentPath ).existsSync() )
              Directory( _fileInfo.tParentPath ).createSync();

            CopyFileByBlockCypto( _assetFile, File( Path.join( audioFolderPath, _newShaFileName, _newShaFileName )), _streamCtrl ).then((_) {
              int _filesCount = audioBox.get( keyValueFolderFiles, defaultValue: 0 ) + 1;
              int _filesSize = audioBox.get( keyValueFolderSize, defaultValue: 0 ) + _fileInfo.fileSize;
              audioBox.putAll( { _newShaFileName : _fileInfo, keyValueFolderFiles : _filesCount, keyValueFolderSize: _filesSize } );
              _completeInside.complete( true );
            });

          }
          else
            debugPrint('Asset File Error');
        });
      });
      Future.wait( _futures ).then(( value ) { _complete.complete( true );  });
    }
    else {
      _complete.complete( false );
      debugPrint('Pick Nothing');
    }

  return _complete.future;
}


//
// 文档文件导入
Future<bool> importDocuments( FilePickerResult results, Box _docBox, StreamController _streamCtrl ) {

  List<Future> _futures = [];
  Completer<bool> _complete = Completer();
  String documentFolderPath = Path.join( appDocDir.path, keyValueDocumentFolderName );

  results.files.forEach(( _file ) {
    ImageFileInfo _fileInfo = ImageFileInfo( '','', DateTime( 2022, 1, 1, 0, 0, 0), DateTime( 2022, 1, 1, 0, 0, 0), 0, 0, 0, 0, 0 );
    String _newShaFileName = intListToHexString( sha1.convert( utf8.encode( _file.size.toString() + _file.name )).bytes, false );

    _fileInfo.realBaseName = _file.name;
    _fileInfo.tParentPath = Path.join( documentFolderPath, _newShaFileName );
    _fileInfo.isDeleted = 0;
    _fileInfo.createDate = File( _file.path! ).statSync().changed;
    _fileInfo.fileSize = _file.size;

    if ( !Directory( Path.join( documentFolderPath, _newShaFileName )).existsSync())
      Directory( Path.join( documentFolderPath, _newShaFileName )).createSync();

    Future _future = CopyFileByBlockCypto( File( _file.path! ), File( Path.join( documentFolderPath, _newShaFileName, _newShaFileName )), _streamCtrl ).then((value) {
      int _filesCount = _docBox.get( keyValueFolderFiles, defaultValue: 0 ) + 1;
      int _filesSize = _docBox.get( keyValueFolderSize, defaultValue: 0 ) + _file.size;
      _docBox.putAll( { _newShaFileName : _fileInfo, keyValueFolderFiles : _filesCount, keyValueFolderSize: _filesSize } );
    });
    _futures.add( _future );

  });

  Future.wait( _futures ).then(( value ) { _complete.complete( true ); });
  return _complete.future;
}

// 获取文件夹中的文件数量（不包括标记删除的文件）

int getFolderFilesCount( String folderPath, Box _folderBox ) {

  int _count = 0;
  Directory( folderPath ).listSync().forEach(( _filePath ) {
    ImageFileInfo _fileInfo = _folderBox.get( Path.basename( _filePath.path ) )
      ?? ImageFileInfo( '','', DateTime( 2022, 1, 1, 0, 0, 0), DateTime( 2022, 1, 1, 0, 0, 0), 0, 0, 0, 0, 0 );
    if ( _fileInfo.isDeleted == 0 && _fileInfo.realBaseName != '' ) _count++;
  });
  return _count;
}

// 删除列表的媒体资源文件

void DeleteMediaAsset( List<AssetEntity> assetList ){
  List<String> ids = [];
  assetList.forEach(( element ) {
    ids.add( element.id );
  });
  PhotoManager.editor.deleteWithIds( ids );
}

// 获取文件类型

int getFileTypeByExtension( String realBaseName ){

  if ( realBaseName.endsWith('.mp3') || realBaseName.endsWith('.wma') || realBaseName.endsWith('.wav') )
    return 0x10;

  else if ( realBaseName.endsWith('.pdf') || realBaseName.endsWith('.doc') || realBaseName.endsWith('.docx')
    || realBaseName.endsWith('.ppt') || realBaseName.endsWith('.pptx') || realBaseName.endsWith('.xls')
    || realBaseName.endsWith('.xlsx') || realBaseName.endsWith('.txt') )
    return 0x20;

  else if ( realBaseName.endsWith('.jpg') || realBaseName.endsWith('.jpeg') || realBaseName.endsWith('.png')
    || realBaseName.endsWith('.bmp') || realBaseName.endsWith('.gif') || realBaseName.endsWith('.webp')
    || realBaseName.endsWith('.tiff') || realBaseName.endsWith('.psd') || realBaseName.endsWith('.heic') )
    return 0x30;


  else if ( realBaseName.endsWith('.mp4') || realBaseName.endsWith('.mov') || realBaseName.endsWith('.mkv') )
    return 0x40;

  else
    return 0x00;
}