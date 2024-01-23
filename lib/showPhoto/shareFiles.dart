import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:filedog/ffmpegTools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;

import 'package:share_plus/share_plus.dart';

import '../defClassandGlobal.dart';
import '../customWidgets.dart';
import '../generated/l10n.dart';
import '../hiveDataTable/defImageInfomationClass.dart';
import '../foldersAndFiles.dart';

// 分享图片
Future ShareSelectedFiles( List<String> filePaths, Box _folderBox ) {

  List<Future> futures = [];
  List<XFile> _tFiles = [];
  Completer _complete = Completer();
  StreamController _stream = StreamController();

  String _fileRealBaseName;

  /*
  EasyLoading.show(
    status: '正在准备',
    dismissOnTap: false,
  );

   */

  getApplicationCacheDirectory().then(( _cacheDir ) {

    filePaths.forEach(( _filePath ) {

      File _sFile, _tFile;

      ImageFileInfo _fileInfo = _folderBox.get( Path.basename( _filePath ));
      _fileRealBaseName = _fileInfo.realBaseName;
      debugPrint('Real File Name:' + _fileRealBaseName );
      _tFile = File( Path.join( _cacheDir.path, _fileRealBaseName ));

      if ( !( _tFile.existsSync()) ) _tFile.createSync();

      Future _future;
      switch ( Path.extension( _fileRealBaseName )) {
        case '.jpg':
        case '.jpeg':
        case '.heic':
        case '.png':
        case '.webp':
          _sFile = File( Path.join( _filePath, Path.basename( _filePath )) );
          _future = ReadCyptoFile( _sFile ).then(( value ) {
            _tFile.writeAsBytesSync( value );
            _tFiles.add( XFile( _tFile.path ));
          });
        break;
        case '.pdf':
        case '.docx':
        case '.xlsx':
        case '.pptx':
        case '.mp3':
        case '.m4a':
        case '.aac':
          _sFile = File( _filePath );
          _future = ReadCyptoFile( _sFile ).then(( value ) {
            _tFile.writeAsBytesSync( value );
            _tFiles.add( XFile( _tFile.path ));
          });
          break;
        case '.mp4':
        case '.mkv':
        case '.mov':
        case '.avi':
        case '.wmv':
          _sFile = File( Path.join( _filePath, 'playlist.m3u8') );
          _future = FfmpegM3u82Video( _sFile.path, _tFile.path ).then((_) => _tFiles.add( XFile( _tFile.path ) ));
          break;
        default:
          _future = Future( () => null );
          break;
      }

      futures.add( _future );
    });

    Future.wait( futures ).then( ( v ) {

      //EasyLoading.dismiss();
      Share.shareXFiles( _tFiles ).then((value) {
        debugPrint( 'Share Result: ' + value.status.toString() );

        // 分享完毕后，删除cche中的残留
        _tFiles.forEach(( _file ) {
          File( _file.path ).deleteSync();
        });
        _complete.complete( );

      });
    });
  });

  return _complete.future;
}

// 保存选中的文件到系统相册，参数为源文件的路径(是源文件的存储目录路径，不是最终的路径
Future SaveSelectedPVFiles( List<String> sFilePathList, Box _folderBox ) {

  List<Future> futures = [];
  List<File> _tFileList = [];
  Completer _completer = Completer();
  StreamController _stream = StreamController();

  String _fileBaseName;

  getApplicationCacheDirectory().then(( _cacheDir ) {
    sFilePathList.forEach(( _sFilePath ) async {
      _fileBaseName = _folderBox.get( Path.basename( _sFilePath ) ).realBaseName ?? Path.basename( _sFilePath );
      debugPrint('Real File Name:' + _fileBaseName + ' ' + _sFilePath );
      File _tFile = File( Path.join( _cacheDir.path, _fileBaseName ));

      if ( !( _tFile.existsSync()) ) _tFile.createSync();

      Future _future;

      switch ( Path.extension( _fileBaseName )) {
        case '.jpg':
        case '.jpeg':
        case '.heic':
        case '.png':
        case '.webp':
          _future = ReadCyptoFile( File( Path.join( _sFilePath, Path.basename( _sFilePath )) ) ).then(( value ) {
            ImageGallerySaver.saveImage( Uint8List.fromList( value ), quality: 100, name: _fileBaseName );
          });
          break;
        case '.mp4':
        case '.mkv':
        case '.mov':
        case '.avi':
        case '.wmv':
          await FfmpegM3u82Video( Path.join( _sFilePath, 'playlist.m3u8'), _tFile.path ).then((value) => debugPrint( 'Video File Covert Result: ' + _tFile.path ) );
          _future = ImageGallerySaver.saveFile( _tFile.path );
          _tFileList.add( _tFile );
          break;
        default:
          _future = Future(() => null);
          break;
      }

      futures.add( _future );
    });

    Future.wait( futures ).then( ( v ) {

      // 分享完毕后，删除cche中的残留
      _tFileList.forEach(( _file ) {
        _file.deleteSync();
      });
      _completer.complete( true );
    });
  });
  return _completer.future;
}

// 选择PV文件夹
//传递参数：currentDir: 当前文件夹，在列表中不显示
Future<dynamic> SelectPVFolder( context, String currentDir ) => CustomBottomSheet(
  context,
  height: ( vaultDirectoriesPath.length < 7 ) ? ( vaultDirectoriesPath.length )  * 64.0 + 32.0 : 480.0,
  headLable: Text( S.of(context).Select + S.of(context).Space + S.of(context).Folder, style: TextStyle( fontSize: 18.0, fontWeight: FontWeight.bold ),),
  body: Container(
    //height: vaultDirectoriesPath.length * 64.0 + 132.0,
    child: ListView.builder(
    //physics: ,
      shrinkWrap: true,
      itemCount: vaultDirectoriesPath.length,
      scrollDirection: Axis.vertical,
      itemBuilder: ( context, index ){

        debugPrint( '!!DIR1!!' + currentDir + ' ' + vaultDirectoriesPath[index] );
        if ( currentDir != vaultDirectoriesPath[index] ) {
          return FutureBuilder(
            future: Hive.openBox( stringToBase64Url.encode( Path.basename( vaultDirectoriesPath[index])) ),
            builder: ( context, AsyncSnapshot<Box> snapshot ) {
              if ( snapshot.connectionState == ConnectionState.done && snapshot.data != null ) {
                Box _folderBox = snapshot.data!;
                return ListTile(
                  leading: Container(
                    height: 52.0,
                    width: 52.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular( 8.0 )),
                      image: DecorationImage(
                        image: MemoryImage( _folderBox.get( keyValueFolderCover, defaultValue: defaultImageData )),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                  title: Text( _folderBox.get( keyValueFolderNickname, defaultValue: 'No Name'), style: TextStyle( fontSize: 16.0 )),
                  onTap: () => Get.back( result: vaultDirectoriesPath[ index ] ),
                );
              }
              else return Container();
            }
          );
        }
        else return Container();
      }
    )
  )
);