import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as Img;
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;

import '../defClassandGlobal.dart';
import '../hiveDataTable/defImageInfomationClass.dart';
import '../customWidgets.dart';
import '../crypto/cryptoGraphy.dart';
import '../foldersAndFiles.dart';
import '../crypto/cipher_xor.dart';
import '../camera/cameraPage.dart';
import '../showPhoto/shareFiles.dart';
import '../showPhoto/showPhotoPage.dart';
import '../generated/l10n.dart';
import 'imagePickProcess.dart';
import 'imageListController.dart';

enum CameraPickerViewType { image, video }

class MyImageListPage extends StatefulWidget {
  MyImageListPage({Key? key, required this.curDirectory, required this.thumbDbase }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Directory curDirectory;
  final Box thumbDbase;

  @override
  _MyImageListPageState createState() => _MyImageListPageState();
}

class _MyImageListPageState extends State<MyImageListPage> {

  List<FileSystemEntity> currentDirectoryFileList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    /* User Code */
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
    final MyImageListController controller = Get.put(MyImageListController());

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.white,
        //foregroundColor: Colors.black87,
        //elevation: 0.0,
        //leading: IconButton(
        //    icon: Icon(Icons.arrow_back_ios),
        //    onPressed: () => Get.back(),
        //  ),
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          stretchModes: [ StretchMode.blurBackground ],
          background: Opacity( opacity: 0.3, child: Image.memory( widget.thumbDbase.get( keyValueFolderCover ), fit: BoxFit.cover )),
        ),
        title: CustomTitle( controller ), //Text( widget.thumbdb.get( keyValueFolderNickname )),
        actions: CustomActions( controller ),
        //centerTitle: false,
        //elevation: 0,
      ),

      body: MyImageListBody( curDirectory: widget.curDirectory, thumbDbase: widget.thumbDbase ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(() => SpeedDial(
        visible: !controller.selectedState.value,
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.white,
        activeForegroundColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12.0,
        childrenButtonSize: Size.fromRadius( 32.0 ),
        direction: SpeedDialDirection.up,
        children: [
          SpeedDialChild(
            label: S.of(context).Camera,
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            child: Icon(Icons.camera),
            onTap: () {
              pickCamera( context, Path.join(appDocDir.path, keyValueDefaultFolderName ), widget.thumbDbase ).then(( _asset ) {
                if ( _asset != null )
                  debugPrint( 'Camera: ' + _asset.relativePath.toString() );
                else
                  debugPrint( 'Camera: NULL!!!!');
                controller.listVaultDirectories( widget.curDirectory, widget.thumbDbase );
                controller.update(['Page']);
              });
            },
          ),
          SpeedDialChild(
            label: S.of(context).ImportImages,
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            child: Icon(Icons.image),
            onTap: () => importPVAssets( context, controller ),
          ),
        ],
      )),
    );
  }

  // 显示文件夹名
  Widget CustomTitle( MyImageListController _ctrl ) => Obx(() {

    if ( _ctrl.selectedState.value )
      if ( _ctrl.selectedCount.value == 0 )
        return Text( S.of(context).Select + ' ' + S.of(context).Item );
      else
        return Text( _ctrl.selectedCount.toString() );
    else
      return Text( widget.thumbDbase.get( keyValueFolderNickname ));
  });


  List<Widget> CustomActions ( MyImageListController controller ) {

    return [
      Obx(() => Offstage(
        offstage: ( !controller.selectedState.value || controller.selectedCount.value == 0 ),
        child: Container(
          alignment: Alignment.center,
          child: Row(
            children: [
              IconButton(
                icon: Icon( Icons.share ),
                onPressed: (){
                  ShareSelectedFiles( controller.selectedPath, widget.thumbDbase ).then((value) {
                    debugPrint( 'Share Result:' + value.toString());
                    controller.clearSelectedState();
                  });
                },
              ),

              IconButton(
                //color: Colors.white,
                //iconSize: 32.0,
                icon: Icon( Icons.file_download ), //ImageIcon( AssetImage( 'images/icons/download.png' )),   //
                onPressed: (){

                  EasyLoading.show( status: S.of( context ).Preparing, dismissOnTap: false,);
                  SaveSelectedPVFiles( controller.selectedPath, widget.thumbDbase )
                      .then((_) {
                    EasyLoading.showInfo( '成功保存到相册', duration: Duration( seconds: 3 ));
                    controller.clearSelectedState();
                    controller.update(['Page']);
                    debugPrint( 'Export is done!!!' );

                  });
                },
              ),

              // 移动选中文件
              IconButton(
                icon: Icon( Icons.move_up_outlined ),
                onPressed: ( vaultDirectoriesPath.length > 1 ) ? (){

                  SelectPVFolder( context, widget.curDirectory.path ).then(( _selectedFolder ) {
                    debugPrint( 'Select PV Folder Index: ' + _selectedFolder.toString() );
                    if ( _selectedFolder != null) {
                      EasyLoading.show(status: S.of(context).Moving );
                      MoveSelectedPVFiles( widget.thumbDbase, controller.selectedPath, _selectedFolder as String).then((_) {
                        EasyLoading.dismiss();
                        controller.clearSelectedState();
                        controller.listVaultDirectories( widget.curDirectory, widget.thumbDbase );
                        controller.update(['Page']);
                      });
                    }
                  });
                } : null,
              ),

              // 删除选中文件
              IconButton(
                icon: Icon( Icons.delete ), //Icons.delete_outline ),
                onPressed: (){
                  MoveToTrashBottomSheet( context ).then(( value ) {
                    if ( value!=null && value ) {
                      EasyLoading.show(status: S.of(context).Movingto + ' ' + S.of(context).Trash );
                      trashSelectedPVFiles( widget.thumbDbase, controller.selectedPath ).then((_) {

                        controller.clearSelectedState();
                        controller.listVaultDirectories( widget.curDirectory, widget.thumbDbase ).then((_) => EasyLoading.dismiss() );
                        controller.update(['Page']);
                      });
                    }
                  });
                },
              ),
            ],
          ),
          //alignment: Alignment.center,
          //child: Text( 'Selected: ' + controller.selectedCount.toString(), style: TextStyle( fontSize: 18.0), ),
        ),
      )),
      Obx(() => Offstage(
        offstage: !controller.selectedState.value,
        child: IconButton(
          icon: ( controller.selectedCount.value == 0 ) ? ImageIcon( AssetImage( 'images/icons/selectall.png'), size: 24.0,) : ImageIcon( AssetImage( 'images/icons/unselectall.png'), size: 24.0,),
          onPressed: () {
            if ( controller.selectedCount.value == 0 )
              controller.selectAll( true );
            else
              controller.selectAll( false );

            controller.update(['CheckBox']);
          },
        ),
      )),
      Obx(() => IconButton(
        icon: ( controller.selectedState.value ) ? Icon( Icons.close) : Icon( Icons.check_box_outlined ),
        color: ( controller.selectedState.value ) ? Colors.green : null,
        onPressed: () {
          if ( controller.selectedState.value )
            controller.clearSelectedState();
          else
            controller.selectedState.value = true;
          controller.update(['CheckBox']);
        },
      )),
    ];
  }

  // ADD Other Widgrt

  void importPVAssets( BuildContext context, MyImageListController _ctrl ) async {
    // 调用 PickImageAssets ,弹出新页面
    StreamController _streamCtrlProcessImg = StreamController();

    var status = await Permission.photos.status;
    if ( status.isDenied ) {
      await Permission.photos.request();
    }

    var status2 = await Permission.accessMediaLocation.status;
    if ( status2.isDenied ) {
      await Permission.accessMediaLocation.request();
    }

    // 经测试，在Android 14上，只需用请求 Photos 权限即可
    /*
    status = await Permission.videos.request();
    if ( status.isDenied ) {
      _streamCtrlProcessImg.close();
      return;
    }

    */

    PickImageAssets( context ).then(( assetsList ) {
      if ( assetsList != null ) {
        getAssetsTotalCounter( assetsList ).then(( _processNumber ) {

          debugPrint( 'Process Number:' + _processNumber.toString() );

          ImportBottomSheet( _streamCtrlProcessImg, S.of( context ).ImportImages, '媒体文件导入完成', assetsList.length, _processNumber, true ).then(( v ) {
            _streamCtrlProcessImg.close();
            debugPrint('Stream Controller Closed! and Result is ' + v.toString());
            if ( v!= null && v )
              DeleteMediaAsset( assetsList );

            _ctrl.listVaultDirectories(  widget.curDirectory, widget.thumbDbase );
            _ctrl.update(['Page']);
          });
          Future.delayed(
            Duration( milliseconds: 50 ),
            () => ProcessPickImage2( assetsList, widget.curDirectory, widget.thumbDbase, ScreenSize(context).thumbSize, _streamCtrlProcessImg )
          );
        });
      }
      else {
        _streamCtrlProcessImg.close();
        debugPrint('Pick Nothing!!!');
      }
    });
  }
  // End of Page
}

// Body

class MyImageListBody extends GetView<MyImageListController> {

  MyImageListBody({Key? key, required this.curDirectory, required this.thumbDbase }) : super(key: key);

  final Directory curDirectory;
  final Box<dynamic> thumbDbase;
  List<int> _thumbData = [];

  @override
  Widget build(BuildContext context) {

    controller.listVaultDirectories( curDirectory, thumbDbase );
    return GetBuilder<MyImageListController>(
      id: 'Page',
      init: controller,
      builder: (controller) {
        debugPrint('Files Count:' + controller.vaultDirectoriesFiles.length.toString());
        if ( controller.vaultDirectoriesFiles.length > 0 )
          return GridView.builder(
            //controller: ScrollController(),
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB( 0.0,3.0,0.0, 48.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 3.0, //水平间距
              mainAxisSpacing: 3.0, //垂直间距
              childAspectRatio: 1.0, //宽高比
            ),
            itemCount: controller.vaultDirectoriesFiles.length,
            itemBuilder: (context, index) {
              ImageFileInfo _fileInfo = thumbDbase.get( Path.basename( controller.vaultDirectoriesFiles[index] ));
              debugPrint( 'Get fileInfo from BOX:' + _fileInfo.tParentPath.toString() );
              _thumbData = CipherXor.xor( File( Path.join( controller.vaultDirectoriesFiles[ index ], coverFileName )).readAsBytesSync(), aesKey );
              return imageThumbCard( context, _thumbData, index, _fileInfo );
            }
          );

          else
        // 文件夹为空
            return MyEmptyFolder();
      }
    );
  }

  Widget imageThumbCard( BuildContext context, List<int> data, int index, ImageFileInfo _fileInfo ) => Container(

    child: GestureDetector(

      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(
            Uint8List.fromList( data ),
            width: ScreenSize(context).thumbSize.toDouble() / 3.0,
            height: ScreenSize(context).thumbSize.toDouble() / 3.0,
            fit: BoxFit.cover,
          ),
          Offstage(
            offstage: ( _fileInfo.duration == 0 ),
            child: Icon ( Icons.play_circle_outline, size: 36.0, color: Colors.white, )
          ),
          Positioned(
            bottom: 4.0,
            child:  Offstage(
              offstage: ( _fileInfo.duration == 0 ),
              child: Text( SecondsToString( _fileInfo.duration!) , style: TextStyle( color: Colors.white ),)
            ),
          ),

          GetBuilder<MyImageListController>(
            id: 'CheckBox',
            builder: ( controller ) => Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Offstage(
                offstage: !controller.selectedState.value,
                child:  Checkbox(
                  value: controller.onSelectedFile[ index ],
                  fillColor: ( controller.onSelectedFile[ index ] ) ? MaterialStateProperty.all( Colors.green) : MaterialStateProperty.all( Colors.transparent ),
                  side: BorderSide(
                    color: Colors.white,
                  ),
                  shape: CircleBorder(),
                  onChanged: ( v ) {
                    controller.onSelectedFile[ index] = v!;
                    controller.getSelectedCount();
                    controller.update(['CheckBox']);
                  }
                )
              )
            ),
          ),

        ],
      ),
      onTap: () {
        if ( !controller.selectedState.value ) {
          debugPrint('Tap!' + controller.vaultDirectoriesFiles[index]);
          Get.to(() => MyShowPhotoPage(
            pickedPVPathList: controller.vaultDirectoriesFiles,
            index: index,
            thumbDbase: thumbDbase,
          )
          )?.whenComplete(() => controller.update(['Page']));
        }
      },
      onLongPress: () {
        if ( !controller.selectedState.value ) {
          debugPrint('LongPress!' + controller.vaultDirectoriesFiles[index]);
          controller.selectedState.value = true;
          controller.onSelectedFile[ index ] = true;
          controller.getSelectedCount();
          controller.update(['CheckBox']);
        }
      }
    )
  );
}
