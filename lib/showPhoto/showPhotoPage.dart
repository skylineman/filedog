import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as Path;
import 'package:extended_image/extended_image.dart';
import 'package:date_format/date_format.dart' as DateFormat;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import './shareFiles.dart';
import '../customWidgets.dart';
import '../defClassandGlobal.dart';
import '../foldersAndFiles.dart';
import '../crypto/cipher_xor.dart';
import '../crypto/cryptoGraphy.dart';
import '../hiveDataTable/defImageInfomationClass.dart';
import '../generated/l10n.dart';
import 'videoPlayerPage.dart';

class MyShowPhotoPage extends StatefulWidget {

  MyShowPhotoPage({Key? key, required this.index, required this.pickedPVPathList, required this.thumbDbase }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final int index;
  final List<String> pickedPVPathList;
  final Box thumbDbase;

  @override
  _MyShowPhotoPageState createState() => _MyShowPhotoPageState();
}

class _MyShowPhotoPageState extends State<MyShowPhotoPage> with SingleTickerProviderStateMixin {

  late AnimationController _pageController;
  late ExtendedPageController _extendedPageController;

  var imgScale = 1.0.obs;
  bool _appBarDispear = false;
  bool imageRotateStatus = false;
  bool _fileIsVideo = false;
  bool _fileIsDeleted = false;
  int slidDirection = 0;   // -1: slide left,  +1: slide right

  var _rotate = 0.obs;
  late String _tFilePath;
  late var _realFileBaseName;
  late ImageFileInfo imgFileInfo;


  List<Uint8List> imageData = List.generate(3, (index) => Uint8List.fromList([]));
  List<bool> imageDataIsVideo = [ false, false, false ];
  late int currentIndex;
  Completer imagePreRead = Completer();

  @override
  void initState(){
    super.initState();

    currentIndex = widget.index;

    imgFileInfo = widget.thumbDbase.get( Path.basename( widget.pickedPVPathList[ widget.index] ));
    _fileIsVideo = ( imgFileInfo.duration != 0 );
    _fileIsDeleted = ( imgFileInfo.isDeleted != 0 );
    _realFileBaseName = imgFileInfo.realBaseName.obs;//getFileTypeIsVideo( widget.pickedPhotoList[ currentIndex ] );

    _pageController = AnimationController(
      value: 0.0,
      debugLabel: 'debug',
      duration: const Duration( milliseconds: 200 ),
      vsync: this
    );

    _extendedPageController = ExtendedPageController(
      initialPage: currentIndex,
      keepPage: false,
      pageSpacing: 0.0,
      viewportFraction: 1.0,
    );

    // 如果文件不是视频，则解密读入imageData[1]
    if ( !_fileIsVideo ) {

      _tFilePath = Path.join( widget.pickedPVPathList[widget.index], Path.basename( widget.pickedPVPathList[widget.index] ));
      debugPrint('target file: ' + _tFilePath );
      //File( _tFilePath ).readAsBytes().then((value) {
      //  imageData[1] = value;
      ReadCyptoFile( File( _tFilePath ) ).then(( value ) {
        imageData[1] = Uint8List.fromList( value as List<int> );
        imageDataIsVideo[1] = false;
        imagePreRead.complete( widget.index );
      });

    }
    // 如果文件是视频，则解密读入Cover File到imageData[1]
    else {
      _tFilePath = Path.join( widget.pickedPVPathList[widget.index],  coverFileName );
      File( _tFilePath ).readAsBytes().then((value) {
        imageData[1] = Uint8List.fromList( CipherXor.xor( value, aesKey ));
        imageDataIsVideo[1] = true;
        imagePreRead.complete( widget.index );
      });
    }

    // 不是首图，则预读取前一幅图
    if ( widget.index > 0 ) {
      _tFilePath = Path.join( widget.pickedPVPathList[ widget.index - 1], Path.basename( widget.pickedPVPathList[widget.index - 1]));
      if ( Path.basename( widget.pickedPVPathList[ widget.index - 1] ).substring( 0, 1 ) == 'P' )
        ReadCyptoFile( File( _tFilePath ) ).then((value) {
          imageData[0] = Uint8List.fromList( value );
          imageDataIsVideo[0] = false;
          debugPrint('Read ImageData[0]');
          //imagePreRead.complete();
        });
      else {
        File( Path.join( widget.pickedPVPathList[ widget.index - 1 ],  coverFileName )).readAsBytes().then(( value ) {
          imageData[0] = Uint8List.fromList( CipherXor.xor( value, aesKey ));
          imageDataIsVideo[0] = true;
          debugPrint('Read ImageData[0] Cover');
        });
      }
    }

    //  不是末图，则预读取后一幅图
    if ( ( widget.index + 1 ) < widget.pickedPVPathList.length ) {
      _tFilePath = Path.join( widget.pickedPVPathList[ widget.index + 1 ], Path.basename( widget.pickedPVPathList[widget.index + 1 ]));// + Path.extension( widget.imgFileInfo.sfileName);
      if (  Path.basename( widget.pickedPVPathList[ widget.index + 1] ).substring( 0, 1 ) == 'P' )
        ReadCyptoFile( File( _tFilePath ) ).then((value) {
          imageData[2] = Uint8List.fromList( value );
          imageDataIsVideo[2] = false;
          debugPrint('Read ImageData[2]');
        });
      else {
        File( Path.join( widget.pickedPVPathList[ widget.index +1 ],  coverFileName )).readAsBytes().then(( value ) {
          imageData[2] = Uint8List.fromList( CipherXor.xor( value, aesKey ));
          imageDataIsVideo[2] = true;
          debugPrint('Read ImageData[2] Cover');
        });
      }
    }
  }

  @override
  void dispose(){
    _pageController.dispose();
    //_videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
// This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AnimatedBuilder(
      animation: _pageController,
      builder: ( BuildContext context, child) => Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.3),
          foregroundColor: Colors.white,
          elevation: 0.0,
          toolbarHeight: 56 * _pageController.value,
          title: Obx( () => Text( _realFileBaseName.value )),
          //leading: IconButton( Icons.arrow_back_ios ),
          actions: [
            IconButton(
              icon: Icon( Icons.info_rounded ),
              onPressed: () => showPhotoInfoBottomSheet( imageData[1] ),
            )
          ],
          //title: Text( Path.basename( widget.imgFileInfo.fileName )),
        ),
        body: GestureDetector(
          child: myImageVideoSlide(),
          onTap: (){
            if ( _appBarDispear ) {
              _pageController.reverse();
            }
            else {
              _pageController.forward();
            }
            _appBarDispear = !_appBarDispear;
          },
        ),
        bottomSheet: photoBottomSheet(),
      )
    );
  }

  Widget myImageVideoSlide() => ExtendedImageGesturePageView.builder(

    itemCount: widget.pickedPVPathList.length,
    pageSnapping: true,
    //allowImplicitScrolling: false,        // 控制PageView是否有缓存

    onPageChanged: (int index) {

      slidDirection = index - currentIndex;
      currentIndex = index;
      imgFileInfo = widget.thumbDbase.get( Path.basename( widget.pickedPVPathList[index]));
      _realFileBaseName.value = imgFileInfo.realBaseName;

      debugPrint('PageChanged!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + index.toString() );

      setState(() {
        imageRotateStatus = false;
      });
    },

    controller: _extendedPageController,

    itemBuilder: ( BuildContext cxt, int index ) {

      return FutureBuilder(
        future: imagePreRead.future,
        builder: ( cxt, AsyncSnapshot snapshot ){
          if ( snapshot.connectionState == ConnectionState.done ) {
            //debugPrint('ShowPhoto Index: ' + index.toString() + ' currentIndex:' + currentIndex.toString() + ' Direction:' + slidDirection.toString());
            return Stack(
              alignment: Alignment.center,
              children: [
                myImageVideoShowbox( index ),
                Offstage(
                  offstage: !imageDataIsVideo[ index - currentIndex + 1 + slidDirection ],
                  child: IconButton(
                    icon: Icon( Icons.play_circle_fill ),
                    iconSize: 72.0,
                    color: Colors.white,
                    onPressed: (){
                      String _videoPath = Path.join ( widget.pickedPVPathList[ index ], Path.basename( widget.pickedPVPathList[ index ]) );
                      Directory( widget.pickedPVPathList[ index ]).listSync().forEach((element) {

                        if ( Path.extension( element.path ) == '.m3u8' )
                          _videoPath = element.path;

                      });
                      // 传入视频路径
                      Get.to( () => MyPlayVideoPage( videoPath: _videoPath, videoRealName: _realFileBaseName.value ) );
                      //setState(() {});
                    },
                  ),
                )
              ]
            );
          }
          else
            return Container();
        },
      );
    },
  );

  Widget myImageVideoShowbox ( int index ) =>
    Obx(() => RotatedBox(
      quarterTurns: _rotate.value,
      child: ExtendedImage.memory(
        imageData[ index - currentIndex + 1 + slidDirection ],
        fit: BoxFit.contain,
        scale: imgScale.value,
        width: ScreenSize(context).width * 3.0,
        //cacheWidth: imgWidth.toInt(),
        mode: ExtendedImageMode.gesture,
        //extendedImageGestureKey: imageKey,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
        initGestureConfigHandler: (state) => GestureConfig(
          minScale: 1.0,
          animationMinScale: 0.8,
          maxScale: 5.0,
          animationMaxScale: 6.0,
          speed: 1.0,
          inertialSpeed: 100.0,
          initialScale: 1.0,
          inPageView: false,
          initialAlignment: InitialAlignment.center,
        ),

        loadStateChanged: (_imageState) {
          switch (_imageState.extendedImageLoadState) {
            case LoadState.completed:
              break;
            case LoadState.loading:
              return Image.asset( 'images/loading.gif' );
              break;
            case LoadState.failed:
              return Image.asset( 'images/unknown.png' );
            default:
              break;
          }
          return null;
        },

        onDoubleTap: (ExtendedImageGestureState state) {
          state.reset();
        },

        afterPaintImage: (Canvas canvas, Rect rect, ui.Image image, Paint paint) {

          // 向左滑
          if ( index == currentIndex && slidDirection < 0 ) {
            imageData[2] = imageData[1];
            imageData[1] = imageData[0];
            imageDataIsVideo[2] = imageDataIsVideo[1];
            imageDataIsVideo[1] = imageDataIsVideo[0];

            if ( index > 0 ) {
              _tFilePath = Path.join( widget.pickedPVPathList[ index - 1 ], Path.basename( widget.pickedPVPathList[ index - 1 ]));
              if ( Path.basename( widget.pickedPVPathList[ index - 1 ]).substring( 0,1 ) == 'P' )
                ReadCyptoFile( File( _tFilePath ) ).then((value) {
                  imageData[0] = Uint8List.fromList(value);
                  imageDataIsVideo[0] = false;
                  debugPrint('Read ImageData[0]');
                });
              else
                File( Path.join( widget.pickedPVPathList[ index - 1 ],  coverFileName )).readAsBytes().then(( value ) {
                  imageData[0] = Uint8List.fromList(CipherXor.xor(value, aesKey));
                  imageDataIsVideo[0] = true;
                  debugPrint('Read ImageData[0] Cover');
                });
            }
            debugPrint( 'LEFT::AfterPaintImage!!!  Index:' + index.toString() + ' CurrentIndex:' + currentIndex.toString() + ' Direction:' + slidDirection.toString());
            slidDirection = 0;
            //else
            //imagePreRead.add( index );
          }

          // 向右滑
          if ( index == currentIndex && slidDirection > 0) {
            //imagePreRead = Completer();
            imageData[0] = imageData[1];
            imageData[1] = imageData[2];
            imageDataIsVideo[0] = imageDataIsVideo[1];
            imageDataIsVideo[1] = imageDataIsVideo[2];

            if (index < (widget.pickedPVPathList.length - 1)) {
              _tFilePath = Path.join( widget.pickedPVPathList[ index + 1 ], Path.basename( widget.pickedPVPathList[ index + 1 ]));// + Path.extension( widget.imgFileInfo.sfileName);
              if ( Path.basename( widget.pickedPVPathList[ index + 1 ]).substring( 0,1 ) == 'P' )
                ReadCyptoFile( File( _tFilePath ) ).then((value) {
                  imageData[2] = Uint8List.fromList(value);
                  imageDataIsVideo[2] = false;
                  debugPrint('Read ImageData[2]');
                  //imagePreRead.add( index );
                });
              else
                File( Path.join( widget.pickedPVPathList[ index + 1 ],  coverFileName )).readAsBytes().then(( value ) {
                  imageData[2] = Uint8List.fromList( CipherXor.xor(value, aesKey) );
                  imageDataIsVideo[2] = true;
                  debugPrint('Read ImageData[2] Cover');
                  //imagePreRead.add( index );
                });
            }
            //else
            //imagePreRead.add( index );
            debugPrint( 'RIGHT::AfterPaintImage!!!  Index:' + index.toString() + ' CurrentIndex:' + currentIndex.toString() + ' Direction:' + slidDirection.toString());
            slidDirection = 0;
          }

          _fileIsVideo = imageDataIsVideo[ index - currentIndex + 1 + slidDirection ];
          //imagePreRead.add( index );
        },
      )),
    );

  // 底部按钮，图片模式
  //
  Widget photoBottomSheet() => Container(
    alignment: Alignment.center,
    height: 80 * _pageController.value,
    //color: Colors.transparent,

    decoration: BoxDecoration(
      color:  Colors.transparent,
    ),

    child: ( _pageController.value == 1.0 )
    ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          color: Colors.white,
          iconSize: 32.0,
          icon: Icon( Icons.share ),
          onPressed: (){
            ShareSelectedFiles( [ widget.pickedPVPathList[widget.index] ], widget.thumbDbase )
              .then((value) => debugPrint( 'Share is done!!!' ));
            },
        ),

        // 保存到相册
        IconButton(
          color: Colors.white,
          iconSize: 32.0,
          icon: Icon( Icons.file_download ), //ImageIcon( AssetImage( 'images/icons/download.png' )),   //
          onPressed: (){

            EasyLoading.show( status: S.of( context ).Preparing, dismissOnTap: false,);
            SaveSelectedPVFiles( [ widget.pickedPVPathList[widget.index] ], widget.thumbDbase )
              .then((value) {
                EasyLoading.showInfo( '成功保存到相册', duration: Duration( seconds: 3 ));
                debugPrint( 'Export is done!!!' );
              });
          },
        ),

        // 移动到另一个文件夹
        IconButton(
          color: Colors.white,
          iconSize: 32.0,
          icon: Icon( Icons.move_up_outlined ), //ImageIcon( AssetImage( 'images/icons/move.png' )),   //Icon( Icons.copy )
          onPressed:  ( vaultDirectoriesPath.length > 1 ) ? (){
            debugPrint('Select PV File: ' + Path.dirname( widget.pickedPVPathList[widget.index] ));
            SelectPVFolder( context, Path.dirname( widget.pickedPVPathList[widget.index] ) ).then(( _selectedFolder ) {
              //debugPrint( 'Select PV Folder Index: ' + _selectedFolder.toString() );
              if ( _selectedFolder != null) {
                EasyLoading.show(status: 'Moving...');
                MoveSelectedPVFiles(widget.thumbDbase, [ widget.pickedPVPathList[widget.index] ], _selectedFolder as String).then((_) {
                  EasyLoading.dismiss();
                  // 从文件路径数组中删除该文件路径，避免在Slide时再次出现；
                  widget.pickedPVPathList.removeAt(widget.index);

                  if ( currentIndex > 0 )
                    _extendedPageController.jumpToPage( currentIndex - 1 );
                  else if ( widget.pickedPVPathList.length > 1 )
                    _extendedPageController.jumpToPage(  1 );
                  else
                    Get.back(result: true);

                  debugPrint('Moving is done!!!');
                })
                .catchError((error, stackTrace) {
                  EasyLoading.dismiss();
                  debugPrint( error.toString() );}
                );
              }
            });
          } : null,
        ),

        IconButton(
          color: Colors.white,
          iconSize: 32.0,
          icon: Icon( Icons.delete ),
          onPressed: (){

            MoveToTrashBottomSheet( context ).then(( value ) {
              if ( value!= null && value ) {
                EasyLoading.show( status: 'Trashing...');
                trashSelectedPVFiles( widget.thumbDbase, [ widget.pickedPVPathList[widget.index ]] ).then((_) {
                  EasyLoading.dismiss();
                  // 从文件路径数组中删除该文件路径，避免在Slide时再次出现；
                  widget.pickedPVPathList.removeAt( widget.index );

                  if ( currentIndex > 0 )
                    _extendedPageController.jumpToPage( currentIndex - 1);
                  else
                  if ( widget.pickedPVPathList.length > 1 )
                    _extendedPageController.jumpToPage( 1 );
                  else
                    Get.back( result: true );

                  debugPrint( 'Trashing is done!!!' );
                });
              }
            });
          }, //required double iconSize
        ),
        if ( !_fileIsVideo )
         IconButton(
          color: Colors.white,
          iconSize: 32.0,
          icon: Icon( Icons.crop_rotate ),
          onPressed: (){
            _rotate++;
            if ( _rotate.value > 3 ) _rotate.value = 0;
          },
        ),
      ],
    )
    : null,
  );


  // Photo Infomaton BottomSheet

  Future showPhotoInfoBottomSheet ( List<int> imageData ){
    Future<Map<String, dynamic>> getExifInfo;

    getExifInfo = readExifFromBytes(  imageData ); //File ( Path.join( widget.pickedPhotoList[ currentIndex ], Path.basename( widget.pickedPhotoList[ currentIndex ]) )));

    return Get.bottomSheet(
      SafeArea(
        top: true,
        bottom: true,
        child: Container(

          padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              FutureBuilder(
                future: getExifInfo,
                builder: ( BuildContext cxt, AsyncSnapshot<Map<String, dynamic>> snapshot ){
                  if ( snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                    snapshot.data?.forEach((key, value) {
                      debugPrint(key.toString() + ':' + value.toString().toString());
                    });
                    return showExifInfo( snapshot.data!, imgFileInfo );
                  }
                  else
                    return Container();
                },
              ),
            ],
          ),
        )
      ),
      backgroundColor: ( Get.theme.brightness == Brightness.dark ) ? Color.fromRGBO( 0x1d, 0x1b, 0x20, 1.0 ) : Color.fromRGBO( 0xf7, 0xf2, 0xfa, 1.0 ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular( 28.0 ),
            topRight: Radius.circular( 28.0 )
        ),
      ),
    );
  }
}

// 显示Exif信息部件

Widget showExifInfo( Map<String, dynamic> exifData, ImageFileInfo _info ){

  String imageDateTime = 'Unknown';
  String imageModel = 'Unknown Camera';
  String _address = '';
  bool _hadGPSData = true;
  double latitude = 0.0;
  double longitude = 0.0;

  Future<dynamic> _getAddressFromBingMaps;

  var _latitude = exifData['GPS GPSLatitude'];
  var _longitude = exifData['GPS GPSLongitude'];

  if ( _latitude == null || _longitude == null )
    _hadGPSData = false;
  else {
    latitude = _latitude.values.ratios[0].numerator +
        _latitude.values.ratios[1].numerator / 60.0 +
        _latitude.values.ratios[2].numerator / 1.0 /
            _latitude.values.ratios[2].denominator / 3600.0;

    longitude = _longitude.values.ratios[0].numerator +
        _longitude.values.ratios[1].numerator / 60.0 +
        _longitude.values.ratios[2].numerator / 1.0 /
            _longitude.values.ratios[2].denominator / 3600.0;

    if ( exifData['GPS GPSLatitudeRef'] == 'S' )
      latitude = -latitude;
    if ( exifData['GPS GPSLongitudeRef'] == 'W' )
      longitude = -longitude;

    if ( latitude == 0.0 || longitude == 0.0 || latitude.isNaN || longitude.isNaN ) _hadGPSData = false;
  }

  debugPrint( '!!GPS Info: ' + latitude.toString() + ', ' + longitude.toString() );

  // 如果有GPS数据，则发起REST API to Bing Maps
  if ( _hadGPSData ) {
    var uri = Uri.https('dev.virtualearth.net',
      '/REST/v1/LocationRecog/' + latitude.toStringAsFixed(4) + ',' + longitude.toStringAsFixed(4),
      {
        'includeEntityTypes': 'address',
        'key': 'AlPQGrLqd67g6xpT3--R_38Qn7c0hzzVh3hjamyF1YXlI2LGFPKdSS5jeLUKdzP5'
      }
    );
    _getAddressFromBingMaps = http.get(uri);
  }
  else
    _getAddressFromBingMaps = Future(() => null);

  if ( exifData['Image DateTime'] != null ) {
    imageDateTime = exifData['Image DateTime'].toString();
    String _date = imageDateTime.substring(0,10);
    String _time = imageDateTime.substring(11);
    imageDateTime = DateFormat.formatDate( DateTime.parse( _date.replaceAll(':', '-') + ' ' + _time ), [ DateFormat.yyyy, '年', DateFormat.mm, '月', DateFormat.dd, '日', ' ', DateFormat.HH, ':', DateFormat.nn, ':', DateFormat.ss ] );
  }
  else
    imageDateTime = DateFormat.formatDate( _info.createDate!, [ DateFormat.yyyy, '年', DateFormat.mm, '月', DateFormat.dd, '日', ' ', DateFormat.HH, ':', DateFormat.nn, ':', DateFormat.ss ]);

  if ( exifData['Image Model'] != null || exifData['Image Make'] != null ) {
    imageModel = exifData['Image Make'].toString() ?? '';
    imageModel += ' ';
    imageModel += exifData['Image Model'].toString() ?? '';
  }

  return Container(
    alignment: Alignment.center,
    height: 256.0,
    child: ListView(
     children: [
       ListTile(
         leading: Icon ( Icons.date_range),
         title: Text( imageDateTime ),
         //trailing: Icon ( Icons.wallpaper),
       ),
       ListTile(
         leading: Icon ( ( _info.duration! > 0 ) ? Icons.videocam : Icons.camera_alt ),
         title: Text( ( _info.duration! > 0 ) ? _info.duration.toString() + 's' : imageModel ),
         subtitle: Text( _info.imageWidth.toString() + ' x ' + _info.imageHeight.toString() ),
         //trailing: Icon ( Icons.wallpaper),
       ),
       ( _hadGPSData ) ? FutureBuilder(
         future: _getAddressFromBingMaps,
         builder: ( context, snapshot ){
           if ( snapshot.connectionState == ConnectionState.done && snapshot.hasData ) {

             var _data = jsonDecode( ( snapshot.data as http.Response ).body );
             //debugPrint( 'BINGMAP:' + _data.toString() );
             if ( _data['resourceSets'].length > 0 && _data['resourceSets'][0]['resources'].length > 0 )
              _address = _data['resourceSets'][0]['resources'][0]['addressOfLocation'][0]['formattedAddress'];

             return ( _address != '' )
               ? ListTile(
                 leading: Icon(Icons.location_on),
                 title: Text( _address ),
                )
               : Container();

           }
           else
             return Container();
         }) : Container(),

       ListTile(
         leading: Icon( Icons.attach_file ),
         title: Text( fileSizeToString ( _info.fileSize! ) ),
       )
     ],
    ),
  );
}


