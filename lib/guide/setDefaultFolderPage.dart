
import 'dart:async';

import 'package:filedog/homePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../customWidgets.dart';
import '../defClassandGlobal.dart';
import '../foldersAndFiles.dart';
import '../generated/l10n.dart';

class SetDefaultFolderPage extends StatefulWidget {
  @override
  _SetDefaultFolderPageState createState() => _SetDefaultFolderPageState();
}


class _SetDefaultFolderPageState extends State<SetDefaultFolderPage> {

  TextEditingController _textEditingController = TextEditingController();
  //Completer initDirectory = Completer();

  @override
  void initState() {
    super.initState();
    //_textEditingController.text = S.of(context).Default;


  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textEditingController.text = S.of(context).Default;
    return Scaffold(

      appBar: AppBar(
        title: Text('给默认文件夹起名'),
      ),

      body: SafeArea( child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB( 32.0, 0.0, 32.0, 0.0 ),

        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox( height: 64.0,),
            Container(
              padding: EdgeInsets.all( 0.0 ),
              width: ScreenSize(context).width - 64.0,
              height: ScreenSize(context).width - 64.0,
              child: Image.asset( 'images/defaultfoldernaming.png' ),
            ),
            Container(
              padding: EdgeInsets.all( 8.0 ),
              alignment: Alignment.centerLeft,
              child: Text( '给第一个文件夹起个好听的名字吧' , textAlign: TextAlign.start, style: TextStyle( fontSize: 16.0),),
            ),

            CustomTextForm(
              controller: _textEditingController,
              keyboardType: TextInputType.text,
              inputText: S.of(context).Default,
            ),
            SizedBox( height: 32.0,),

            MyCustomButton(
              colorStyle: CustomButtonColorStyle.confirm,
              label: Text( S.of(context).Next ),
              height: 56.0,
              width: ScreenSize(context).width - 64.0,
              onPressed: () {
                if ( _textEditingController.text.isNotEmpty ) {
                  Get.offAll( MyHomePage( defaultFolderName: _textEditingController.text ));
                }
                else {
                  Get.snackbar( '文件夹名字不能为空', '请输入文件夹名字' );
                }

              },
            )
          ],
        ),
      )),
    );
  }

}

