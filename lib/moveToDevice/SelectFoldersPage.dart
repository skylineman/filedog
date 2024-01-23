import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;

import '../generated/l10n.dart';
import '../defClassandGlobal.dart';
import './SelectFoldersControl.dart';

class SelectFoldersPage extends StatefulWidget {

  SelectFoldersPage({Key? key }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are

  // always marked "final".

  @override
  _SelectFoldersPageState createState() => _SelectFoldersPageState();
}

class _SelectFoldersPageState extends State<SelectFoldersPage> {

  late final SelectFoldersController controller;

  @override
  void initState() {
    super.initState();
    // Insert your code
    controller = Get.put( SelectFoldersController());
    // TODO: implement build
    controller.listVaultFoldersPath( appDocDir );
  }

  @override
  void dispose() {
    // Insert your code
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: CustomTitle( controller ),
      actions: CustomActions( controller ),
    ),
    body: selectFoldersBody(context),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Obx(() {
      if ( controller.selectedState.value )
        return TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue ),
            fixedSize: MaterialStateProperty.all<Size>(Size(128.0, 48.0)),
          ),
          child: Text( S.of(context).Next ),
          onPressed: () {

          }
        );
      else return Container();
    }),

  );

  Widget CustomTitle( SelectFoldersController _ctrl ) {
    return Obx(() {
      if ( _ctrl.selectedState.value )
        if ( _ctrl.selectedCount.value == 0 )
          return Text( 'Select Item' );
        else
          return Text( _ctrl.selectedCount.toString() );
      else
        return Text( S.of( context ).Select + S.of( context ).Folder );
    });
  }

  List<Widget> CustomActions ( SelectFoldersController controller ) {
    return [

      Obx(() => Offstage(
        offstage: !controller.selectedState.value,
        child: IconButton(
          icon: ( controller.selectedCount.value == 0 ) ? ImageIcon( AssetImage( 'images/icons/selectall.png'), size: 24.0,) : ImageIcon( AssetImage( 'images/icons/unselectall.png'), size: 24.0,),
          onPressed: () {
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
        offstage: ( controller.vaultFoldersPath.length == 0 ),
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

  Widget selectFoldersBody(BuildContext context) => GetBuilder<SelectFoldersController>(
    id: 'Page',
    init: controller,
    builder: ( controller ) => ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only( bottom: 48.0 ),
      itemCount: controller.vaultFoldersPath.length,
      itemBuilder: ( context, index ){

        if ( index < 2 ) {
          int _count = 0;
          int _size = 0;
          List<String> _showFolderName = [ S.of(context).Document, S.of(context).Audio ];
          Directory( controller.vaultFoldersPath[index] ).listSync().forEach(( _file ) {
            _count++;
            _size += _file.statSync().size;

          });

          return ListTile(
            leading: Image.asset( 'images/documents.png' ),
            title: Text( _showFolderName[ index ] ),
            subtitle: Text( _count.toString() + ' files'),
            trailing: GetBuilder<SelectFoldersController>(
              id: 'CheckBox',
              builder: ( controller ) => selectTrailing( controller, index)
            ),
          );
        }
        else {
          //debugPrint( '!!!!!!!!!! :::: ' + controller.vaultFoldersPath[index ]);
          return FutureBuilder(
            future: Hive.openBox( stringToBase64Url.encode( Path.basename( controller.vaultFoldersPath[index]) ) ),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data != null ) {

                Box _box = snapshot.data;

                return ListTile(
                  leading: Image.memory( _box.get(keyValueFolderCover) ?? defaultImageData ),
                  title: Text( _box.get( keyValueFolderNickname , defaultValue: 'No Name 1') ?? 'No Name 2' ),
                  subtitle: Text( _box.get(keyValueFolderFiles).toString() + ' files'),
                  trailing: GetBuilder<SelectFoldersController>(
                      id: 'CheckBox',
                      builder: (controller) => selectTrailing(controller, index)
                  ),
                );
              }
              else
                return CircularProgressIndicator();
            }
          );
        }
      },
    ),
  );

  Widget selectTrailing( SelectFoldersController _ctrl, int index ) => Checkbox(
    value: controller.onSelectedFile[index],
    fillColor: ( controller.onSelectedFile[index] ) ? MaterialStateProperty.all( Colors.green) : MaterialStateProperty.all( Colors.transparent ),
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
}

