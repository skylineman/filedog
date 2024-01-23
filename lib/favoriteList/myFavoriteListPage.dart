import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;
import 'package:share_plus/share_plus.dart';

import '../defClassandGlobal.dart';
import '../customWidgets.dart';

class MyFavoriteListPage extends StatefulWidget {
  MyFavoriteListPage({Key? key }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyFavoriteListPageState createState() => _MyFavoriteListPageState();
}

class _MyFavoriteListPageState extends State<MyFavoriteListPage> {

  late HiveList favItemList;
  late var favItemDateBase;

  @override
  void initState(){
    super.initState();
    //
    favItemDateBase = Hive.openBox( keyValueFavoriteBoxName );
  }

  @override
  void dispose(){
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      //body:

    );

    throw UnimplementedError();
  }
}