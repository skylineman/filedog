import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart'as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:get/get.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'audioList/audioListPage.dart';
import 'camera/cameraPage.dart';
import 'defClassandGlobal.dart';
import 'generated/l10n.dart';
import 'customWidgets.dart';
import 'foldersAndFiles.dart';
import 'permissionProcess.dart';
import 'imageList/imageListPage.dart';
import 'documentsList/documentsListPage.dart';
import 'appSetting/appSettingPage.dart';
import 'folderSetting/folderSettingPage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.defaultFolderName }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String defaultFolderName;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<AssetEntity> assetsPvFiles = [];
  Completer initDirectory = Completer();

  //FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    // 国内版本无法使用
    /*
    if ( _auth.currentUser == null ) {
      _auth.signInAnonymously().then((value) {
        debugPrint( 'UserID 2:' + value.user!.uid );
      });
    }
    else {
      debugPrint('UserID 1:' + _auth.currentUser!.uid);
    }


     */

    InitVaultDirectoriesAndroid( widget.defaultFolderName ).then((_) {
      debugPrint('Init Vault Directories of Android is OK! ');
      initDirectory.complete();
      Get.changeThemeMode(ThemeMode.light);
    });


    // 初始化Hive数据库
    /*
    String _dbPath = Path.join( appDocDir.path, keyValueHiveFolderName );

    if ( Directory( _dbPath ).existsSync() ) {
      // 初始化Hive数据库
      Hive.initFlutter( _dbPath ).then((_) {
        InitVaultDirectoriesAndroid( widget.defaultFolderName ).then((_) {
          debugPrint('Init Vault Directories of Android is OK! ');
          initDirectory.complete();
        });
      });
    }

     */
  }

  @override
  void dispose() {
    Hive.close();
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

    vaultDirectoriesPath.clear();
    appDocDir.listSync().forEach(( _ele ) {
      String _filenameString = Path.basename( _ele.path );
      debugPrint('Find Sub Folder:' + _ele.path);
      // 忽略隐藏文件及文件夹
      if (!(_filenameString.startsWith('_')) && !(_filenameString.startsWith('.'))) {
        vaultDirectoriesPath.add(_ele.path);
      }
    });
    //debugPrint('Folder Numbers: ' + vaultDirectoriesPath.length.toString());

    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Get.to( AppSettingPage() ),
        ),
        title: Text( S.of(context).appName ),
        centerTitle: true,
        elevation: 0.0,
      ),

      body: FutureBuilder(
        future: initDirectory.future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return MyHomeBody();
          else
            return Center( child: CircularProgressIndicator() );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        activeBackgroundColor: Colors.white,
        activeForegroundColor: Theme.of(context).primaryColorDark,
        overlayOpacity: 0.5,
        spacing: 12.0,
        childrenButtonSize: Size.fromRadius(32.0),
        direction: SpeedDialDirection.up,
        children: [
          SpeedDialChild(
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            label: S.of(context).Camera,
            shape: CircleBorder(),
            child: Icon( CupertinoIcons.camera ),
            onTap: () {

              Hive.openBox( stringToBase64Url.encode(keyValueDefaultFolderName) ).then(( _box ) {
                pickCamera( context, Path.join(appDocDir.path, keyValueDefaultFolderName ), _box ).then(( _asset ) {
                  if ( _asset != null )
                    debugPrint( 'Camera: ' + _asset.relativePath.toString() );
                  else
                    debugPrint( 'Camera: NULL!!!!');
                  setState(() {});
                  _box.close();
                });
              });
            }
          ),

          SpeedDialChild(
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            label: S.of(context).NewFolder,
            shape: CircleBorder(),
            child: Icon(Icons.folder_outlined),
            onTap: _createNewPVFolder,
          ),
          //
          SpeedDialChild(
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            label: S.of(context).Import + S.of(context).Audio,
            shape: CircleBorder(),
            child: Icon(Icons.mic_outlined),
            onTap: _importAudio,
          ),
          //
          SpeedDialChild(
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            label: S.of(context).Import + S.of(context).Document,
            shape: CircleBorder(),
            child: Icon(Icons.folder_copy),
            onTap: _importDocument,
          ),
        ],
      ),
      //
      // floatingActionButton: MyFloatingButton(context, assetsPvFiles, mode: true, onTapPickFile: (){}, onTapPickImg: (){}),
    );
  }


  void _createNewPVFolder() {
    GetXInputDialogWithRegExp(
      title: S.of(context).NewFolder,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(regValueFolderName)),
      ],
      //regExpString: 'Please don\'t use any symbol',
    ).then((value) {
      if (value != null) {
        String _newPVFolder = Uuid().v4(); // 随机生成 UUID V4字符串，作为文件系统中实际的目录名
        MyCreateFolder(Directory(Path.join(appDocDir.path, _newPVFolder))).then((_) {
          // 创建目录后，接着创建Hive Box，为防止非法字符，进行Base64Url编码
          Hive.openBox(stringToBase64Url.encode(_newPVFolder)).then((_box) {
            _box.putAll({
              keyValueFolderFiles: 0,
              keyValueFolderSize: 0,
              keyValueFolderNickname: value as String,
              keyValueFolderCover: defaultImageData,
            }).then((_) => debugPrint('New Folder Created!'));
          });
        });
      }
    });
  }

  // 从 HomePage 进入音频导入
  void _importAudio() {
    StreamController _streamCtrl = StreamController();

    Hive.openBox(stringToBase64Url.encode(keyValueAudioFolderName)).then((audioBox) {
      checkAudioPermission().then((value) {

        PickAudioAssets( context ).then(( results ) {

          if ( results == null || results.length == 0 ) {
            debugPrint( 'Picked Nothing or Failed!' );
            return;
          }

          int _processNumber = 0;
          results.forEach(( _fileEntity ) async {
            var _file = await _fileEntity.file;
            _processNumber += _file!.lengthSync() ~/ CyperBlocksSize + 1;
          });

          ImportBottomSheet(
            _streamCtrl,
            S.of(context).Import + S.of(context).Space + S.of(context).Audio,
            S.of(context).Audio + S.of(context).Space + S.of(context).Import + S.of(context).Space + S.of(context).Completed,
            results.length, _processNumber, true )
          .then(( v ) {
            if ( v!= null && v )
              DeleteMediaAsset( results );

            setState(() {
              _streamCtrl.close();
            });
          });

          importAudio(context, results, audioBox, _streamCtrl).then((v) {
            debugPrint('Import Result: ' + v.toString());
          });
        });

      });
    });
  }

  // // 从 HomePage 进入文档导入
  void _importDocument() {
    StreamController _streamCtrl = StreamController();
    Hive.openBox(stringToBase64Url.encode(keyValueDocumentFolderName)).then((docBox) {
      FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['docx', 'xlsx', 'pdf', 'txt', 'html', 'md'],
      ).then((results) {
        if (results != null) {
          int _processNumber = 0;
          results.files.forEach((_file) {
            _processNumber += _file.size ~/ CyperBlocksSize + 1;
          });

          ImportBottomSheet(_streamCtrl, '导入文档', '文档导入完成', results.files.length, _processNumber, false).then((v) {
            _streamCtrl.close();
            setState(() {
              debugPrint('Stream Controller Closed! and Result is ' + v.toString());
            });
          });

          importDocuments(results, docBox, _streamCtrl);
        }
      });
    });
  }
}

class MyHomeBody extends StatefulWidget {

  MyHomeBody({Key? key} ) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomeBodyState createState() => _MyHomeBodyState();
}

class _MyHomeBodyState extends State<MyHomeBody> {

  _MyHomeBodyState();
  
  //late Future<Box> _folderBox;
  //late Future _future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    vaultDirectoriesPath.clear();
    appDocDir.listSync().forEach(( _ele ) {
      String _filenameString = Path.basename( _ele.path );
      debugPrint('Find Sub Folder:' + _ele.path);
      // 忽略隐藏文件及文件夹
      if (!(_filenameString.startsWith('_')) && !(_filenameString.startsWith('.'))) {
        vaultDirectoriesPath.add(_ele.path);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    //debugPrint( 'ScreenSize' + MediaQuery.of(context).size.toString());
    return Container(
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        children: [
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 2.8
            ),
            children: [
              FutureBuilder(
                future: Hive.openBox( stringToBase64Url.encode( keyValueDocumentFolderName )),
                builder: ( context, AsyncSnapshot<Box<dynamic>> snapshot ){
                  if ( snapshot.connectionState == ConnectionState.done && snapshot.data != null ) {

                    return MyOutlinedButton(
                      backgroundColor: Color.fromRGBO(218, 244, 254, 1.0),
                      foregroundColor: Color.fromRGBO(81, 117, 138, 1.0),
                      isBorder: false,
                      title: S.of(context).Document,
                      subTitle: snapshot.data?.get( keyValueFolderFiles ).toString(),
                      icon: Icons.file_copy,
                      onPressed: () {
                        Get.to(() => MyDocumentsListPage( docBox: snapshot.data! ))?.then((_) {
                          setState(() {});
                        });
                      }
                    );
                  }
                  else
                    return Container();
                }
              ),

              FutureBuilder(
                future: Hive.openBox( stringToBase64Url.encode( keyValueAudioFolderName )),
                builder: ( context, AsyncSnapshot<Box<dynamic>> snapshot ) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                    return MyOutlinedButton(
                      backgroundColor: Colors.lightGreen.shade100,
                      foregroundColor: Colors.green.shade800,
                      isBorder: false,
                      title: S.of(context).Audio,
                      subTitle: snapshot.data?.get( keyValueFolderFiles ).toString(),
                      icon: Icons.mic,
                      onPressed: () {
                        Get.to( AudioListPage( audioBox: snapshot.data! ) )?.then((_) {
                          setState(() {});
                        });
                      }
                    );
                  }
                  else
                    return Container();
                }
              ),
            ],
          ),
          SizedBox( height: 16.0,),
          Obx(() => GridView.builder(
            shrinkWrap:true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.811676, //宽高比
              crossAxisSpacing: 16.0, //水平间距
              mainAxisSpacing: 16.0, //垂直间距
              crossAxisCount: 2
            ),
            itemBuilder: pvFolderCard,
            itemCount: vaultDirectoriesPath.length,
            //delegate: SliverChildBuilderDelegate(
            //    ( context, index ) => myFolderCard(context, index),
            //    childCount: vaultDirectoriesPath.length,
            //),
          )),
        ],
      )
    );
  }

  Widget pvFolderCard( context, index) {
    return FutureBuilder(
      future: Hive.openBox( stringToBase64Url.encode( Path.basename( vaultDirectoriesPath[index])) ),
      builder: ( context, AsyncSnapshot<Box> snapshot ) {

        if ( snapshot.connectionState == ConnectionState.done ) {
          Uint8List folderCover = snapshot.data!.get( keyValueFolderCover, defaultValue: defaultImageData );
          int filesNumber = getFolderFilesCount( vaultDirectoriesPath[index], snapshot.data! );
          String folderNickname = snapshot.data!.get( keyValueFolderNickname, defaultValue: 'No Name' );

          return SizedBox(
            //type: MaterialType.canvas,
            child: Column(
              children: [
                GestureDetector(
                  //borderRadius: BorderRadius.circular( 16.0 ),
                  onTap: () {
                    Get.to( () => MyImageListPage(
                      curDirectory: Directory( vaultDirectoriesPath[index] ),
                      thumbDbase: snapshot.data!,
                    ))!.then((_) {
                      setState(() { });
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: ( ScreenSize( context ).width - 48.0 ) /2.0,
                    height: ( ScreenSize( context ).width - 48.0 ) /2.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      color: Color.fromRGBO( 0x00, 0xa8, 0xf3, 1.0),
                      image: DecorationImage(
                        image: MemoryImage( folderCover ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                CupListTile(
                  padding: EdgeInsets.fromLTRB( 0.0, 4.0, 0.0, 4.0),
                  title: Text( folderNickname, style: TextStyle(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                  subtitle: Text( filesNumber.toString()),
                  trailing: Icon( Icons.more_vert),
                  onTap: () {
                    Get.to(() => MyFolderSettingPage( folderPath: vaultDirectoriesPath[index], thumbdb: snapshot.data!,) )?.then(( v ) {
                      if ( v!= null && v ) {

                        // 文件夹可能会被删除，需要重新List
                        vaultDirectoriesPath.clear();
                        appDocDir.listSync().forEach(( _ele ) {
                          String _filenameString = Path.basename( _ele.path );
                          // 忽略隐藏文件及文件夹
                          if (!( _filenameString.startsWith('_') ) && !( _filenameString.startsWith('.') )) {
                            vaultDirectoriesPath.add( _ele.path );
                            debugPrint('Find PV Sub Folder:' + _ele.path);
                          }
                        });
                        debugPrint('PV Folder Numbers: ' + vaultDirectoriesPath.length.toString());
                      }
                      setState(() { });

                    });
                  },
                ),
              ],
            ),
          );
        }
        else
          return Container();
      }
    );
  }
}


