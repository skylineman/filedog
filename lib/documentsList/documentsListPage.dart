import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;

import 'package:share_plus/share_plus.dart';

import 'documentsViewPage.dart';
import 'documentsListController.dart';
import '../defClassandGlobal.dart';
import '../customWidgets.dart';
import '../hiveDataTable/defImageInfomationClass.dart';
import '../foldersAndFiles.dart';
import '../generated/l10n.dart' as L10n;
import '../notepad/editNotepadPage.dart';
import '../showPhoto/shareFiles.dart';

class MyDocumentsListPage extends StatefulWidget {
  MyDocumentsListPage( {Key? key, required this.docBox }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Box docBox;

  @override
  _MyDocumentsListPageState createState() => _MyDocumentsListPageState();
}

class _MyDocumentsListPageState extends State<MyDocumentsListPage> {

  late final String documentFolderPath;
  late final MyDocumentsListController controller;

  @override
  void initState() {
    super.initState();
    /* User Code */
    documentFolderPath = Path.join( appDocDir.path, keyValueDocumentFolderName );
    controller = Get.put( MyDocumentsListController() );
  }

  @override
  void dispose() {
    /* User Code */
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
          controller.listVaultDirectories( documentFolderPath, widget.docBox );
        }),
        builder: ( BuildContext context, AsyncSnapshot snapdata ) {
          if ( snapdata.connectionState == ConnectionState.done )
            return MyDocumentsListBody( docBox: widget.docBox );
          else
            return Center( child: CircularProgressIndicator( ) );
        },),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(() => customFloatBT1( )),
    );
  }

  // FloatButton Option 2
  Widget customFloatBT2( ) {
    if ( controller.selectedState.value )
      return Container();
    else
      return FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColorDark,
        shape: CircleBorder(),
        child: Icon( Icons.add ),
        onPressed: () => pickAndImportDocuments( ),
      );
  }

  // FloatButton Option 1
  Widget customFloatBT1(){
    if ( controller.selectedState.value )
      return Container();
    else
      return SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.grey,
        overlayOpacity: 0.5,
        spacing: 12.0,
        childrenButtonSize: Size.fromRadius( 32.0 ),
        children: [
          SpeedDialChild(
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            labelBackgroundColor: Colors.blue[100],
            label: L10n.S.of(context).Import + L10n.S.of(context).Document,
            child: Icon( Icons.file_copy ),
            onTap: () => pickAndImportDocuments( ),
          ),
          SpeedDialChild(
            backgroundColor: Theme.of(context).primaryColorDark,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            labelBackgroundColor: Colors.blue[100],
            label: L10n.S.of(context).Created + L10n.S.of(context).Document ,
            child: Icon( Icons.edit ),
            onTap: (){
              String notepadName = formatDate( DateTime.now(), [yyyy,'-',mm,'-',dd,' ',HH,':',nn,':',ss]) + '.pad';
              var _file = File( Path.join( documentFolderPath, notepadName));
              if ( !_file.existsSync() ) _file.createSync();
              Get.to( EditNotepadPage( curNotepadFile: _file ) )?.then((value) {
                controller.listVaultDirectories( documentFolderPath, widget.docBox );
                controller.update(['Page']);
              });
            }
          ),
        ],
      );

  }

  // Custom Title Display
  Widget CustomTitle(  ) {
    return Obx(() {
      if ( controller.selectedState.value )
        if ( controller.selectedCount.value == 0 )
          return Text( 'Select Item' );
        else
          return Text( controller.selectedCount.toString() );
      else
        return Text( L10n.S.of( context ).Document );
    });
  }

  // Custom
  List<Widget> CustomActions () {
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
                  ShareSelectedFiles( controller.selectedPath, widget.docBox ).then((_) {
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
                      EasyLoading.show( status: L10n.S.of( context ).Movingto + ' ' + L10n.S.of( context ).Trash +'...',);
                      trashSelectedPVFiles( widget.docBox, controller.selectedPath ).then((_) {
                        controller.clearSelectedState();
                        controller.listVaultDirectories( documentFolderPath, widget.docBox );
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

  void pickAndImportDocuments( ) {

    StreamController _streamCtrl = StreamController();
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['docx','xlsx', 'pdf', 'txt', 'html', 'md'],
    ).then(( results ) {
      if ( results != null ) {
        int _processNumber = 0;
        results.files.forEach(( _file ) {
          _processNumber += _file.size ~/ CyperBlocksSize + 1;
        });

        ImportBottomSheet( _streamCtrl, '导入文档', '文档导入完成', results.files.length, _processNumber, false ).then(( v ) {

          _streamCtrl.close();
          debugPrint('Stream Controller Closed! and Result is ' + v.toString());

          //controller.listVaultDirectories(  documentFolderPath, widget.docBox );
          //controller.update(['Page']);
        });

        importDocuments( results, widget.docBox, _streamCtrl ).then((_) {
          controller.listVaultDirectories(documentFolderPath, widget.docBox);
          controller.update(['Page']);
        });
      }
    });
  }
}

// Body
class MyDocumentsListBody extends GetView<MyDocumentsListController> {

  MyDocumentsListBody({Key? key, required this.docBox }) : super(key: key);

  final Box docBox;
  final String documentFolderPath = Path.join( appDocDir.path, keyValueDocumentFolderName );


  Widget selectTrailing( int index, ImageFileInfo info ){

    if (  controller.selectedState.value )
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
    else
      return myShowDateTime( info.createDate!, 'en');
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<MyDocumentsListController>(
      id: 'Page',
      init: controller,
      builder: ( controller ) {
        if (controller.vaultDirectoriesFiles.length > 0)
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only( bottom: 48.0 ),
            itemCount: controller.vaultDirectoriesFiles.length,
            itemBuilder: (context, index) {
              //debugPrint( 'List File [' + index.toString() + ']:' + controller.vaultDirectoriesFiles[index] );
              ImageFileInfo _fileInfo = docBox.get( Path.basename( controller.vaultDirectoriesFiles[index]), defaultValue: null ) as ImageFileInfo;
              //debugPrint( 'File Info:' + _fileInfo.realBaseName.toString() );
              return ListTile(
                enabled: !controller.selectedState.value,
                contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                leading: ImageOfFileType( Path.extension( _fileInfo.realBaseName )),
                title: Text( _fileInfo.realBaseName , style: TextStyle( fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                subtitle: Text( fileSizeToString( _fileInfo.fileSize! )),
                trailing: GetBuilder<MyDocumentsListController>(
                  id: 'CheckBox',
                  builder: ( controller ) {
                    return selectTrailing( index, _fileInfo);
                  }
                ),
                onTap: ( controller.selectedState.value )
                ? null
                : (){
                    String _filebasename = Path.basename( controller.vaultDirectoriesFiles[index]);
                    //if ( Path.extension( _filePath ) == '.pad' )
                    //  Get.to(() => EditNotepadPage( curNotepadFile: File( _filePath ) ));
                    //else
                      Get.to(() => MyDocumentsViewPage(
                        documentFilePath: Path.join( controller.vaultDirectoriesFiles[index], _filebasename ),
                        fileInfo: _fileInfo
                      ));
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


