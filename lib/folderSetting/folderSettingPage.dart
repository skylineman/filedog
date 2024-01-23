import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:hive/hive.dart';
import 'package:get/get.dart';


import '../crypto/cipher_xor.dart';
import '../crypto/cryptoGraphy.dart';
import '../defClassandGlobal.dart';
import '../customWidgets.dart';
import '../foldersAndFiles.dart';
import '../generated/l10n.dart';


class MyFolderSettingPage extends StatefulWidget {
  MyFolderSettingPage({Key? key, required this.folderPath, required this.thumbdb }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String folderPath;
  final Box thumbdb;

  @override
  _MyFolderSettingPageState createState() => _MyFolderSettingPageState();
}

class _MyFolderSettingPageState extends State<MyFolderSettingPage> {

  static const int coverPageCount = 16;
  static const int defaultCoverCount = 3;
  var _imageCover = [].obs;
  var _folderNickname = ''.obs;
  PageController _controller = PageController();
  ExpansionTileController _expansionTileController = ExpansionTileController();
  late var coverTileState;
  late List<FileSystemEntity> _fileList;
  var currentPageIndex = 0.obs;
  bool onCoverChanged = false;
  late String newCoverPath;
  List<Uint8List> _defaultFolderCover = [];
  late Future _future;

  @override
  void initState() {
    super.initState();
    // User Code
    _imageCover.value = widget.thumbdb.get( keyValueFolderCover ) ?? defaultImageData;
    _folderNickname.value = widget.thumbdb.get( keyValueFolderNickname );
    coverTileState = false.obs;
    _fileList = Directory( widget.folderPath ).listSync();
    _future = Future.wait([
      rootBundle.load('images/photofolder-1.png').then((value) =>  _defaultFolderCover.add(value.buffer.asUint8List())),
      rootBundle.load('images/photofolder-2.png').then((value) =>  _defaultFolderCover.add(value.buffer.asUint8List())),
      rootBundle.load('images/photofolder-3.png').then((value) =>  _defaultFolderCover.add(value.buffer.asUint8List())),

    ]);
  }

  @override
  void dispose() {
    // vv User Code vv

    // ^^ User Code ^^
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: true,
    // 返回健拦截
    onPopInvoked: ( didPop ) async {
      await widget.thumbdb.put( keyValueFolderCover, Uint8List.fromList( _imageCover.value as List<int> ));
      debugPrint('Write a new Image Cover');
      Get.back();
    },

    child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text( S.of( context ).FolderSetting ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon ( Icons.folder_outlined ),
            //title: Text ( stringToBase64Url.decode( Path.basename( widget.path ))),
            contentPadding: EdgeInsets.fromLTRB( 0.0, 8.0, 0.0, 8.0 ),
            title: Text( S.of(context).FolderName, style: TextStyle( fontSize: 16.0) ),
            trailing: Row (
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx( () => Text ( _folderNickname.value, style: TextStyle( fontSize: 16.0),)),
                Icon ( Icons.chevron_right ),
              ],
            ),
            onTap: _renameFolder
          ),
          //Divider(),

          //Divider( height: 48.0,),
          ExpansionTile(
            controller: _expansionTileController,
            initiallyExpanded: false,
            tilePadding: EdgeInsets.fromLTRB( 0.0, 16.0, 0.0, 16.0 ),
            leading: Icon( CupertinoIcons.photo_fill_on_rectangle_fill ),
            title: Text( S.of(context).Cover ),
            onExpansionChanged: ( _stat ){
              coverTileState.value = _stat;
              currentPageIndex.value = 0;
              debugPrint( _stat.toString());
            },
            trailing: SizedBox(
              width: 112.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx( () => Image.memory( Uint8List.fromList( _imageCover.value as List<int> ), height: 56.0, width: 56.0, fit: BoxFit.cover )),
                  SizedBox( width: 6.0,),
                  Obx( () => ( coverTileState.value ) ? Icon( Icons.keyboard_arrow_up ) : Icon( Icons.keyboard_arrow_down )),
                ],
              )
            ),
            childrenPadding: EdgeInsets.fromLTRB( 0.0, 0.0, 0.0, 16.0),
            children: [
              SizedBox( height: 376.0, child: FutureBuilder(
                future: _future,
                builder: ( context, snapshot ) {
                  if ( snapshot.connectionState == ConnectionState.done )
                    return PageView.builder(
                      allowImplicitScrolling: true,
                      controller: _controller,
                      onPageChanged: ( _page ) {
                        currentPageIndex.value = _page;
                      },
                      itemCount: ( ( _fileList.length + defaultCoverCount ).toDouble() / coverPageCount.toDouble() + 0.99999999 ).toInt(),
                      itemBuilder: (context, _pageIndex) {
                        return GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 2.0, //水平间距
                            mainAxisSpacing: 2.0, //垂直间距
                            childAspectRatio: 1.0, //宽高比
                          ),
                          itemCount: ( _pageIndex < ( ( _fileList.length + defaultCoverCount ) ~/ coverPageCount ))
                            ? coverPageCount
                            : ( _fileList.length + defaultCoverCount ) % coverPageCount,
                          itemBuilder: (context, _index) {
                            Uint8List _tempImageData;
                            if ( _index < defaultCoverCount && _pageIndex == 0 )
                              _tempImageData = _defaultFolderCover[ _index ];

                            else {
                              _tempImageData = Uint8List.fromList(
                                CipherXor.xor( File( Path.join( _fileList[ _pageIndex * coverPageCount + _index - defaultCoverCount ].path, coverFileName )).readAsBytesSync(), aesKey)
                              );
                            }

                            return InkWell(
                              child: Image.memory( _tempImageData, fit: BoxFit.cover,),
                              // 点击小图片，选择封面
                              onTap: () {
                                _expansionTileController.collapse();
                                _imageCover.value = _tempImageData;
                                onCoverChanged = true;
                                if ( _index < defaultCoverCount )
                                  newCoverPath = 'default${defaultCoverCount}';
                                else
                                  newCoverPath = _fileList[ _pageIndex * coverPageCount + _index - defaultCoverCount ].path;
                              },
                            );
                          }
                        );
                      }
                    );
                  else
                    return Container();
                }
              )),

              Obx( () => myStepIndicator( pageIndex: currentPageIndex, itemCount: ( ( _fileList.length + 3 ).toDouble() / coverPageCount.toDouble() + 0.99999999 ).toInt() )),
            ],
          ),

          // Rebuild
          ListTile(
            contentPadding: EdgeInsets.fromLTRB( 0.0, 8.0, 0.0, 8.0 ),
            leading: Icon( CupertinoIcons.scissors_alt ),
            title: Text( S.of(context).Scan + S.of(context).Space + S.of(context).And + S.of(context).Space +S.of(context).Fix ),
            trailing: Icon ( Icons.chevron_right ),
            //onTap: (){},
          ),

          SizedBox( height: 56.0,),

          MyCustomButton(
            isEnable: ( _fileList.length > 0 ),
            label: Text ( S.of(context).Delete + S.of(context).Space + S.of(context).Folder, style: TextStyle( fontSize: 18.0),),
            //icon: Icon( Icons.delete ),
            height: 56.0,
            width: ScreenSize(context).width - 32.0,
            colorStyle: CustomButtonColorStyle.delete,
            onPressed: ( _fileList.length == 0 ) ? null : _deleteFolder
          ),
        ],
      )
    ),
  );

    //return Container();
  void _renameFolder() => GetXInputDialogWithRegExp(
      title: S.of(context).Modify,
      defaultString: _folderNickname.value,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp( regValueFolderName )),
      ],
      regExpString: 'Please don\'t use any symbol',
    ).then(( value ) {
      // 修改文件夹名称（Nick Name）
      if ( value != null ) {
        _folderNickname.value = value;
        widget.thumbdb.put(keyValueFolderNickname, value).then((_) => debugPrint('New Folder Nick Name:' + value.toString()));
      }
    });

  void _deleteFolder() => CustomBottomSheet(
    context,
    headLable: Text( S.of(context).Delete + S.of(context).Space + S.of(context).Folder, style: TextStyle( fontSize: 18.0)),
    height: 360.0,
    body: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(24.0),
          child: Text( _folderNickname.value,
              style: TextStyle( fontSize: 20.0, color: Theme.of(context).primaryColorDark )
          ),
        ),
        Text( S.of(context).DeleteAllFiles ),
        SizedBox( height: 16.0 ),
        MyCustomButton(
          colorStyle: CustomButtonColorStyle.normal,
          label: Text ( S.of(context).Cancel, style: TextStyle( fontSize: 18.0),),
          height: 56.0,
          width: ScreenSize(context).width - 64.0,
          onPressed: () => Get.back( result: false ),
        ),
        SizedBox( height: 16.0 ),
        MyCustomButton(
          colorStyle: CustomButtonColorStyle.delete,
          label: Text ( S.of(context).Delete, style: TextStyle( fontSize: 18.0),),
          height: 56.0,
          width: ScreenSize(context).width - 64.0,
          onPressed: () => Get.back( result: true ),
        ),
        SizedBox( height: 16.0 ),
      ]
    ),
  ).then((value) {
    if ( value!= null && value == true ) {
      debugPrint('Delete Folder:' + widget.folderPath );
      DeleteFolderProcess( widget.folderPath ).then(( v ) {
        debugPrint( 'is:' + v.toString() );
        Get.back( result: v );
      });
    }
    else
      debugPrint('Cancel');
  });

}
