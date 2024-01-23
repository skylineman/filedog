import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../hiveDataTable/defImageInfomationClass.dart';
import '../defClassandGlobal.dart';
import '../customWidgets.dart';
import '../foldersAndFiles.dart';
import '../generated/l10n.dart';
import '../permissionProcess.dart';
import '../showPhoto/shareFiles.dart';
import 'audioListController.dart';
import 'audioPlayPage.dart';

class AudioListPage extends StatefulWidget {
  AudioListPage({Key? key, required this.audioBox }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Box audioBox;

  @override
  _AudioListPageState createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {

  List<FileSystemEntity> currentDirectoryFileList = [];
  late String audioFolderPath;
  //late StreamController _streamCtrl;
  late final AudioListController controller;

  @override
  void initState() {
    super.initState();
    audioFolderPath = Path.join( appDocDir.path, keyValueAudioFolderName );
    //_streamCtrl = StreamController();
    controller = Get.put( AudioListController() );
    //controller.listVaultDirectories( audioFolderPath, widget.audioBox );
  }

  @override
  void dispose() {
    /* User Code */
    //if ( !_streamCtrl.isClosed )
    //  _streamCtrl.close();
    if ( !controller.isClosed )
      controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: CustomTitle( ),
        actions: CustomActions( ),
      ),

      body: FutureBuilder(
        future: Future.delayed( Duration( milliseconds: 50 ), (){
          controller.listVaultDirectories( audioFolderPath, widget.audioBox );
        }),
        builder: ( BuildContext context, AsyncSnapshot snapdata ) {
          if ( snapdata.connectionState == ConnectionState.done )
            return MyAudioListBody( audioBox: widget.audioBox );
          else
            return Center( child: CircularProgressIndicator( ) );
        },),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(() => customFloatBT( )),
    );
  }

  // FloatButton Option 2
  Widget customFloatBT( ) {
    if ( controller.selectedState.value )
      return Container();
    else
      return FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColorDark,
        shape: CircleBorder(),
        child: Icon( Icons.add ),
        onPressed: () => pickAndImportAudio( ),
      );
  }

  Widget CustomTitle( ) {
    return Obx(() {
      if ( controller.selectedState.value )
        if ( controller.selectedCount.value == 0 )
          return Text( S.of(context).Select + ' ' + S.of(context).Item );
        else
          return Text( controller.selectedCount.toString() );
      else
        return Text( S.of(context).Audio );
    });
  }

  List<Widget> CustomActions ( ) {
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
                  ShareSelectedFiles( controller.selectedPath, widget.audioBox ).then((_) {
                    // mimeTypes: ['pdf', 'docx', 'xlsx']
                    //debugPrint( 'Share Result:' + value.toString());
                    controller.clearSelectedState();
                    controller.update(['Page']);
                  });
                },
              ),
              IconButton(
                icon: Icon( CupertinoIcons.delete ),
                onPressed: (){
                  MoveToTrashBottomSheet( context ).then(( value ) {
                    if ( value ) {
                      EasyLoading.show( status: S.of( context ).Movingto + ' ' + S.of( context ).Trash +'...',);
                      trashSelectedPVFiles( widget.audioBox, controller.selectedPath ).then((_) {
                        controller.clearSelectedState();
                        controller.listVaultDirectories( audioFolderPath, widget.audioBox );
                        controller.update(['Page']);
                        EasyLoading.dismiss();
                      });
                    }
                  });
                },
              ),
            ],
          )
          //alignment: Alignment.center,
          //child: Text( 'Selected: ' + controller.selectedCount.toString(), style: TextStyle( fontSize: 18.0), ),
        )
      )),

      Obx(() => Offstage(
        offstage: !controller.selectedState.value,
        child: IconButton(
          icon: ( controller.selectedCount.value == 0 ) ? ImageIcon( AssetImage( 'images/icons/selectall.png'), size: 24.0,) : ImageIcon( AssetImage( 'images/icons/unselectall.png'), size: 24.0,),
          onPressed: () {
            debugPrint( '已经选择：' + controller.selectedCount.value.toString());
            debugPrint( controller.onSelectedFile.length.toString());
            debugPrint( controller.vaultDirectoriesFiles.length.toString());

            if ( controller.selectedCount.value == 0 ) {
              controller.selectAll(true);
              debugPrint('Select ALL');
            }
            else
              controller.selectAll( false );

            controller.update(['CheckBox']);
          },
        ),
      )),

      Obx(() => Offstage(
          offstage: ( controller.vaultDirectoriesFiles.length == 0 ),
          child: IconButton(
            icon: ( controller.selectedState.value ) ? Icon( Icons.close ) : Icon( Icons.check_box_outlined ),
            color: ( controller.selectedState.value ) ? Colors.green : null,
            onPressed: () {
              if ( controller.selectedState.value )
                controller.clearSelectedState();
              else
                controller.selectedState.value = true;
              controller.update(['Page']);
            },
          )
      )),
    ];
  }

  // 导入音频
  void pickAndImportAudio( ) {

    debugPrint( 'Press Import Audio Button' );
    StreamController _streamCtrl = StreamController();

    checkAudioPermission().then(( value ) {
      if ( value ) {
        PickAudioAssets( context ).then(( results ) {
          if ( results == null || results.length == 0 ) {
            debugPrint( 'Picked Files Nothing or Failed!' );
            return;
          }

          int _processNumber = 0;
          results.forEach(( _fileEntity ) async {
            var _file = await _fileEntity.file;
            _processNumber += _file!.lengthSync() ~/ CyperBlocksSize + 1;
          });

          debugPrint( 'Import Audio Files: ' + _processNumber.toString() );

          ImportBottomSheet( _streamCtrl,
            S.of(context).Import + S.of(context).Space + S.of(context).Audio,
            S.of(context).Audio + S.of(context).Space + S.of(context).Import + S.of(context).Space + S.of(context).Completed,
            results.length, _processNumber, true ).then(( v ) {

            if ( v!= null && v )
              DeleteMediaAsset( results );

            _streamCtrl.close();
            debugPrint( '_streamCtrl Closed!' );
          });

          importAudio(context, results, widget.audioBox, _streamCtrl).then((v) {
            controller.listVaultDirectories(  audioFolderPath, widget.audioBox );
            controller.update(['Page']);
            //debugPrint('Import Result: ' + v.toString());
          });
        });
      }
      else
        EasyLoading.showInfo( 'Permission Denied', duration: Duration( seconds: 3 ));
    });
  }



}

class MyAudioListBody extends GetView<AudioListController> {

  MyAudioListBody({Key? key, required this.audioBox }) : super(key: key);

  final Box audioBox;
  final audioFolderPath = Path.join( appDocDir.path, keyValueAudioFolderName );

  // TODO: implement controller
  //AudioListController get controller => super.controller;

  Widget selectTrailing( int index, ImageFileInfo _fileInfo ){

    if ( controller.selectedState.value )
      return Checkbox(
        value: controller.onSelectedFile[index],
        fillColor: ( controller.onSelectedFile[index] )
            ? MaterialStateProperty.all( Colors.green)
            : MaterialStateProperty.all( Colors.white ),
        side: BorderSide(
            color: ( Get.isDarkMode ) ? Colors.white : Colors.black
        ),
        shape: CircleBorder(),
        onChanged: (bool? value) {
          if ( value!= null )
            controller.onSelectedFile[index] = value;
          controller.getSelectedCount();
          controller.update(['CheckBox']);
        },
      );
    else {
      return myShowDateTime( _fileInfo.createDate!, 'en');
    }
  }

  @override
  Widget build(BuildContext context) {

    //controller.listVaultDirectories( audioFolderPath, audioBox );

    return GetBuilder<AudioListController>(
      id: 'Page',
      init: controller,
      builder: ( _controller ) {
        //debugPrint('Files Count:' + controller.vaultDirectoriesFiles.length.toString());
        if ( _controller.vaultDirectoriesFiles.length > 0)
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only( bottom: 48.0 ),
            itemCount: _controller.vaultDirectoriesFiles.length,
            itemBuilder: (context, index) {

              ImageFileInfo _fileInfo = audioBox.get( Path.basename( _controller.vaultDirectoriesFiles[index]), defaultValue: null ) as ImageFileInfo;
              return ListTile(
                enabled: !_controller.selectedState.value,
                contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                leading: ImageOfFileType(Path.extension( _fileInfo.realBaseName )),
                title: Text( _fileInfo.realBaseName , style: TextStyle( fontSize: 16.0, fontWeight: FontWeight.bold), ),
                subtitle: Text( fileSizeToString( _fileInfo.fileSize! )),
                trailing: GetBuilder<AudioListController>(
                  id: 'CheckBox',
                  builder: ( controller ) {
                    return selectTrailing( index, _fileInfo );
                  }
                ),
                onTap: ( _controller.selectedState.value )
                  ? null
                  : (){
                    String _filePath = Path.join( _controller.vaultDirectoriesFiles[index], Path.basename( _controller.vaultDirectoriesFiles[index]) );
                    Get.to( () => AudioPlayPage( audioFilePath: _filePath, fileInfo: _fileInfo, ));

                },
              );
            },
          );
        else
          return MyEmptyFolder();
      }
    );
  }
}

