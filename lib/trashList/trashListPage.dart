import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;

import 'package:share_plus/share_plus.dart';

import '../crypto/cipher_xor.dart';
import '../defClassandGlobal.dart';
import '../customWidgets.dart';
import '../hiveDataTable/defImageInfomationClass.dart';
import '../hiveDataTable/defTrashFileClass.dart';
import 'trashListController.dart';
import '../generated/l10n.dart';
//import 'documentsListController.dart';

class MyTrashListPage extends StatefulWidget {
  MyTrashListPage({Key? key, required this.curDirectory }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Directory curDirectory;

  @override
  _MyTrashListPageState createState() => _MyTrashListPageState();
}

class _MyTrashListPageState extends State<MyTrashListPage> {

  List<FileSystemEntity> currentDirectoryFileList = [];
  StreamController _streamCtrlProcessImg = StreamController();
  late Box trashBox;

  @override
  void initState() {
    super.initState();
    //debugPrint('Trash Directory:' + widget.curDirectory.path);
  }

  @override
  void dispose() {
    /* User Code */
    _streamCtrlProcessImg.close();
    trashBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement buil

    return FutureBuilder(
      future: Hive.openBox( stringToBase64Url.encode( keyValueTrashBoxName )),
      builder: ( context, AsyncSnapshot<Box<dynamic>>snapshot ) {
        if (snapshot.connectionState == ConnectionState.done) {
          trashBox = snapshot.data!;
          final MyTrashListController controller = Get.put( MyTrashListController( trashBox: trashBox ));

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon( Icons.arrow_back_ios ),
                onPressed: () => Get.back(),
              ),
              title: Text( S.of( context ).Recycled ),
              actions: [
                //ListStyleButton( controller ),
                SelectCtrlButton( controller ),
              ],
            ),
            body: MyTrashListBody( trashBox: trashBox ),
            floatingActionButton: Obx( () => BottomButtons( controller )),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
        }
        else
          return Container();
      }
    );
  }

  Widget SelectCtrlButton( MyTrashListController _ctrl ) {
    return Obx(() => IconButton(
      icon: ( _ctrl.selectedCount.value == 0 )
        ? ImageIcon( AssetImage( 'images/icons/selectall.png'), size: 24.0,)
        : ImageIcon( AssetImage( 'images/icons/unselectall.png'), size: 24.0,),
      onPressed: (){
        _ctrl.selectAll( ( _ctrl.selectedCount.value == 0 ) );
        _ctrl.update(['CheckBox']);
      },
    ));
  }

  Widget BottomButtons( MyTrashListController _ctrl ){
    if ( _ctrl.selectedCount.value > 0 )
      return Container(
        height: 64.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyCustomButton(
              colorStyle: CustomButtonColorStyle.confirm,
              label: Text( S.of(context).Recovery ),
              height: 56.0,
              width: (ScreenSize(context).width - 64.0) / 2.0,
              onPressed: (){
                EasyLoading.showInfo( 'Recovering ... ');
                _ctrl.recoveryFilesFromTrash().then((_) {
                  EasyLoading.dismiss();
                  _ctrl.listVaultDirectories( );
                  _ctrl.clearSelectedState();
                  _ctrl.update( ['Page'] );
                });
              },
            ),
            SizedBox( width: 16.0,),
            MyCustomButton(
              colorStyle: CustomButtonColorStyle.delete,
              label: Text( S.of(context).Sweep ),
              height: 56.0,
              width: (ScreenSize( context ).width - 64.0 ) / 2.0,
              onPressed: (){
                _ctrl.sweepFilesFromTrash().then((_) {
                  _ctrl.listVaultDirectories( );
                  _ctrl.clearSelectedState();
                  _ctrl.update( ['Page'] );
                });
              },
            ),
          ],
        ),
      );
      else
        return Container();

  }
}

class MyTrashListBody extends GetView<MyTrashListController> {

  MyTrashListBody({Key? key, required this.trashBox }) : super(key: key);

  //final Future<List<FileSystemEntity>> futureFileList;
  final Box trashBox;

  @override
  Widget build(BuildContext context) {
    controller.listVaultDirectories();
    controller.listTrashBox();
    return GetBuilder<MyTrashListController>(
      id: 'Page',
      init: controller,
      builder: (controller) {
        //debugPrint('Files Count:' + controller.vaultDirectoriesFiles.length.toString());
        if ( controller.vaultDirectoriesFiles.length > 0 )
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 48.0),
            itemCount: controller.vaultDirectoriesFiles.length,
            itemBuilder: (context, index) {
              controller.onSelectedFile.add(false);
              return ListTile(
                contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                leading: GetThumbImage( index ),
                title: Text( getFileRealName ( index ),
                  style: TextStyle( fontSize: 14.0, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                ),
                subtitle: Text( fileSizeToString( getTrashFileSize( index )! )),
                trailing: GetBuilder<MyTrashListController>(
                  id: 'CheckBox',
                  builder: ( controller ) => Checkbox(
                    value: controller.onSelectedFile[index],
                    fillColor: ( controller.onSelectedFile[index] )
                        ? MaterialStateProperty.all( Colors.green)
                        : MaterialStateProperty.all( Colors.white ),
                    side: BorderSide(
                        color: ( Get.isDarkMode ) ? Colors.white : Colors.black
                    ),
                    shape: CircleBorder(),
                    onChanged: (bool? value) {
                      controller.onSelectedFile[index] = value!;
                      controller.getSelectedCount();
                      controller.update(['CheckBox']);
                    },
                  ),
                ),
                onTap: (){
                  //Get.to(() => MyDocumentsViewPage(documentFilePath: controller.vaultDirectoriesFiles[index]));
                },
              );
            },
          );
        else
          return MyEmptyFolder();
      }
    );
  }

  Widget GetThumbImage( int index ){

    String _path = controller.vaultDirectoriesFiles[index];
    TrashFileInfo _trashFileInfo = trashBox.get( Path.basename( _path) );

    if ( _trashFileInfo.fileType! >= 0x30 ) {
      if (File( Path.join(_path, coverFileName)).existsSync() )
        return Image.memory(
          Uint8List.fromList(CipherXor.xor(
              File(Path.join(_path, coverFileName)).readAsBytesSync(), aesKey)),
          height: 64.0,
          width: 64.0,
          fit: BoxFit.cover,
        );
      else
        // 如果指定路径不存在，返回默认图片
        return Image.memory(
          defaultImageData,
          height: 64.0,
          width: 64.0,
        );
    }
    // 如果是其他文件类型
    else
    if ( File ( _path ).existsSync() )
      return Image.memory(
        defaultImageData,
        height: 64.0,
        width: 64.0,
      );
    else
      return Image.memory(
        defaultImageData,
        height: 64.0,
        width: 64.0,
      );
  }

  // 根据文件类型，返回文件名
  String getFileRealName ( int index ) {
    String _path = controller.vaultDirectoriesFiles[index];
    TrashFileInfo _trashFileInfo = trashBox.get( Path.basename( _path) );
    return _trashFileInfo.realBaseName;

  }

  // 根据索引，返回文件大小

  int? getTrashFileSize ( int index ) {
    String _path = controller.vaultDirectoriesFiles[index];
    TrashFileInfo _tempFileInfo = trashBox.get( Path.basename( _path) );
    return _tempFileInfo.fileSize;
  }

}
