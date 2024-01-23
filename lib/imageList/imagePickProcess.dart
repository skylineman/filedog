import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:filedog/ffmpegTools.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:image/image.dart' as Img;

import '../crypto/cipher_xor.dart';
import '../defClassandGlobal.dart';
import '../hiveDataTable/defImageInfomationClass.dart';
import '../foldersAndFiles.dart';
import '../permissionProcess.dart';
import 'imageListController.dart';

// 导入图片，并复制到APP下的数据目录，提取略缩图写入数据库

Future<List<AssetEntity>?> PickImageAssets( BuildContext cxt ) => AssetPicker.pickAssets(
  cxt,
  pickerConfig: AssetPickerConfig(
    maxAssets: MaxPickAssets,
    previewThumbnailSize: ThumbnailSize( ScreenSize( cxt ).thumbSize, ScreenSize( cxt ).thumbSize ),
    requestType: RequestType.fromTypes( [ RequestType.image, RequestType.video ]),
  ),
);


// 对选取的资源文件进行处理，包括复制、获取略缩图等等

void ProcessPickImage2( List<AssetEntity> _assets, Directory curDirectory, Box<dynamic> thumbdb, int thumbSize, StreamController _streamCtrlImporting  ) {

  MyImageListController controller = Get.find<MyImageListController>();
  List<Future> _futures = [];
  //int _counter = 0;

  if ( _assets.isNotEmpty ) {

    // 获取选取的资源数量
    int _importNumber = _assets.length;

    _assets.forEach(( ele ) {

      Completer _complete = Completer();
      _futures.add( _complete.future );

      ele.file.then(( _sFile ) {
        if ( _sFile != null ) {

          String _sFilBaseName = Path.basename( _sFile.path );
          String extFlag = 'N';
          if ( getFileTypeIsImage( _sFilBaseName )) extFlag = 'P';
          if ( getFileTypeIsVideo( _sFilBaseName )) extFlag = 'V';

          // 创建子目录，子目录名为 文件类型标识 + ( 文件名 + 文件大小 + 文件最后一次修改时间）的 Sha1
          String newAssetName = extFlag + intListToHexString ( sha1.convert( ( _sFilBaseName + _sFile.lengthSync().toString() + _sFile.lastModifiedSync().toIso8601String() ).codeUnits ).bytes, false );
          debugPrint( 'New Asset Target Name: ' + newAssetName );
          String newAssetPath = Path.join( curDirectory.path, newAssetName );
          if ( !Directory ( newAssetPath ).existsSync() ) {
            // 如果没有重名，则创建
            Directory( newAssetPath ).createSync();

            // 创建目标文件, 文件名和路径名相同
            File _tFile = File( Path.join( newAssetPath, newAssetName ) );

            ImageFileInfo _fileInfo = ImageFileInfo( '','', DateTime( 2022, 1, 1, 0, 0, 0), DateTime( 2022, 1, 1, 0, 0, 0), 0, 0, 0, 0, 0 );

            _fileInfo.realBaseName = _sFilBaseName;
            _fileInfo.tParentPath = newAssetPath;
            _fileInfo.createDate = ele.createDateTime;
            _fileInfo.modifyDate = ele.modifiedDateTime;
            _fileInfo.duration = ele.videoDuration.inSeconds;
            _fileInfo.imageHeight = ele.height;
            _fileInfo.imageWidth = ele.width;
            _fileInfo.fileSize = _sFile.lengthSync();

            Future? _future = Future(() => null);
            // 处理图片文件
            if ( ele.type == AssetType.image ) {
              // 复制资源文件到新路径
              _future = CopyFileByBlockCypto( _sFile, _tFile, _streamCtrlImporting ).then((_) {
              });
            }
            else if ( ele.type == AssetType.video ) {
              _future = FfmpegVideo2m3u8( _sFile.path, newAssetPath, curAppSetting.isCyptoVideo, _streamCtrlImporting ).then((value) {
                debugPrint('ffmpegVideo2m3u8 is Completed!, return code: ' + value.toString());
              });
            }
            else
              _importNumber--;  //

            Future.wait([
              _future,
              // 写FileInfo
              thumbdb.put( newAssetName, _fileInfo ),
              // 写略缩图
              ele.thumbnailDataWithOption( ThumbnailOption( size: ThumbnailSize( thumbSize, thumbSize), quality: ThumbnailQuality ) ).then(( _thumbData ) {
                // 把Cover数据进行加密处理
                // 把Cover数据写入Cover文件
                File( Path.join( newAssetPath, coverFileName )).writeAsBytesSync( CipherXor.xor( _thumbData as List<int>, aesKey) );
                // 如果没有Cover，则选择一幅图片作为文件夹的Cover
                if ( thumbdb.get( keyValueFolderCover ) == null) {
                  thumbdb.put( keyValueFolderCover, _thumbData ).then((_) {
                    debugPrint('Cover Data is being put into Box!');
                  });
                }

              }),

            ]).then((_) {
              controller.addVaultDirectories( curDirectory.path + '/' + Path.basename( newAssetPath ));
              controller.onSelectedFile.add( false );

              _streamCtrlImporting.add( 0 );
              debugPrint(':' + _importNumber.toString() + ' ' + _tFile.path );
              _complete.complete( true );

            });
          }
          else{
            debugPrint('File Name Repeated: ' + _sFilBaseName );
            // 插入：如果存在重名的处理
          }
        }
        else {
          // 插入：如果_sfile为空的处理
        }
      });
    });

    Future.wait( _futures ).then((_) {
      int _files = thumbdb.get( keyValueFolderFiles ) ?? 0;
      thumbdb.put(keyValueFolderFiles, _files + _importNumber ).then((_) {
        debugPrint('Importing is Completed! ${ _files + _importNumber}');
        _streamCtrlImporting.close(); // 结束导入
      });
      //deleteKeyFile();
      // Update GetController, 刷新指定的Widget
      //controller.update(['Page']);
    });
  }
}




// 根据文件名的Base64Url编码，从图像文件中获取方形略缩图数据，并写入 Hive
// 如果略缩图获取失败，就填入unknownPhoto（资源文件已经被读入内存）
/*
List<int> putThumbnailToHive( String _path, int size,  Box _thumbdb ) {
  List<int> _thumbdata;

  Img.Image? _img = Img.decodeImage( File(_path).readAsBytesSync() );
  _thumbdata = Img.encodeNamedImage( Path.basename(_path), Img.copyResizeCropSquare(_img!, size: size ), )
      ?? Get.find<List<int>>( tag: 'unknowPhoto' );

  _thumbdb.put(stringToBase64Url.encode(Path.basename(_path)), _thumbdata).then((_) => debugPrint(_path + ': Put thumbData to Hive:' + _thumbdb.name ));
  return _thumbdata;
}

 */


// 返回文件大小（字节），如文件非法，返回-1；
/*
Future<int> getFilesSize ( AssetEntity asset ) {
  
  return asset.file.then( ( _file ) {
    if ( _file != null )
      return _file.lengthSync();
    else
      return -1;
  });
}

*/

// 返回资源文件计数总数，以每64KByte为单位，不到64KByte为1

Future<int> getAssetsTotalCounter ( List<AssetEntity> assetsList )  {
  int _counter = 0;
  List<Future> _futures = [];
  Completer<int> _complete = Completer();

  assetsList.forEach(( _assetFile ) {

    _futures.add( _assetFile.file.then( ( _file ) {
      if ( _file != null ) {

        if ( _assetFile.type == AssetType.video )
          _counter += _assetFile.videoDuration.inSeconds ~/ 10 + 2;
        else
          _counter += _file.lengthSync() ~/ 65536 + 1;
      }
    }));
  });
  
  Future.wait( _futures ).then((value) => _complete.complete( _counter ) );

  return _complete.future;
}