import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import './cloudbase_ce/cloudbase_ce.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as Img;
import 'package:path/path.dart'as Path;

import 'foldersAndFiles.dart';

const bool favoriteFun = false;
const int MaxPickAssets = 99;           // 每次最多能够选取的图片数量
const int ThumbnailQuality = 90;
const int CyperBlocksNumber = 2;
const int CyperBlocksSize = 65536;

List<int> aesKey =   [];
List<int> aesNonce = [];
late String keyPath;
late String keyInfoPath;

const String keyValuePinCodeSha1 = 'PinCodeSha1';
const String keyValueAes = 'FileDogAesKey';
const String keyValueFolderFiles = '.Files';
const String keyValueFolderCover = '.Cover';
const String keyValueFolderSize = '.Size';
const String keyValueFolderNickname = '.Nickname';
const String keyValueDefaultFolderName = 'Default';
const String keyValueAudioFolderName = '.Audio';
const String keyValueDocumentFolderName = '.Document';
const String keyValueHiveFolderName = '.HiveBox';
const String keyValueFavoriteBoxName = '.Favorite';
//const String keyValueAudioBoxName = 'Audio';
//const String keyValueDocumentBoxName = 'Document';
const String keyValueTrashBoxName = 'Trash';
const String coverFileName = '.cover.jpg';
const String thumbFileName = '.thumbnail.jpg';
const String bingMapsKey = 'AlPQGrLqd67g6xpT3--R_38Qn7c0hzzVh3hjamyF1YXlI2LGFPKdSS5jeLUKdzP5';
const String policyUrl = 'https://www.bing.com/policy';
const String privacyUrl = 'https://www.bing.com/privacy';
const List<String> UserAgreementContent =
  [ '在使用我们的服务前，请通过',
    '《用户协议》','和',
    '《隐私政策》',
    '了解我们对于个人信息的使用情况与您所享有的相关权利。',
    '我们将严格按照法律要求为你提供服务，并保证您的个人信息安全。',
    '请您在仔细阅读完整协议之后，如同意，请点击“同意”开始使用文件狗',
  ];

const String regValueFolderName = ''; //'!@#%^&*,;:+=<>/|?\~\`()[]{}+';
const List languagesCode = ['OS', 'de', 'en', 'es', 'fr', 'zh'];
const List<String> themeMode = ['Follow OS', 'Light Theme', 'Dark Theme'];

//const List<String> fileTypeCanPreview = ['pdf'];
//final keyStorage = FlutterSecureStorage();
//final _authFirebase = FirebaseAuth.instance;

late final CloudBaseCore curCloudBaseCore;

class AppSetting {
  String userPhoneNumber = '';
  String userEmail = '';
  int agreementVersion = 0;
  int languageIndex = 0;
  int themeIndex = 0;
  bool isPincode = false;
  bool isBiometrics = false;
  bool isCyptoImage = true;
  bool isCyptoAudio = true;
  bool isCyptoVideo = true;
  bool isCyptoDocument = true;

  AppSetting( String s, String t, int i, int j, int k, bool bool1, bool bool2, bool bool3, bool bool4, bool bool5, bool bool6 );
}

class ScreenSize {
  late final double width;
  late final double height;
  late final int thumbSize;

  ScreenSize( context ){
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    thumbSize = width.toInt();
  }
}

enum CustomButtonColorStyle {
  normal,
  confirm,
  alert,
  delete
}

// 响应式全局变量定义
List<String> vaultDirectoriesPath = <String>[].obs;   // 文件目录
//List<int> vaultDirectoriesNumber = <int>[];       // 每个目录下的文件数量

// 普通全局变量定义
GlobalKey mainAppKey = GlobalKey( debugLabel: 'MainAppKey' );
bool firstRunAPP = true;               // 判断是否是首次安装运行
String pinSha1 = '';
List supportedLanguages = ['','Deutsch', 'English', 'Español','Francais', '简体中文'];

Directory appDocDir = Directory('');    // APP Files Directory
Directory appCacheDir = Directory('');
AppSetting curAppSetting = AppSetting(  '', '', 0, 0, 0, false, false, true, true, true, true );
//late User currentUser;

List<CameraDescription> cameraList = [];
late Uint8List unknownImageData;
late Uint8List defaultImageData;
bool canCheckBiometrics = false;
bool initState = false;
//
//  自定义函数区域
//

// String <==> Base64Url
Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);

// 把整数数组转成16进制字符串
String intListToHexString( List<int>? bytes, bool _space ) {

  if (bytes == null) throw new ArgumentError('The list is null');

  var result = StringBuffer();
  for (var i = 0; i < bytes.length; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16).toUpperCase()}');
    if ( _space ) result.write(' ');
  }
  return result.toString();
}

// 把16进制字符串转化为整数数组
List<int> hexStringToIntList(String s) {
  s = s.replaceAll(' ', '').replaceAll('\n', '');
  return List<int>.generate(s.length ~/ 2, (i) {
    var byteInHex = s.substring(2 * i, 2 * i + 2);
    if (byteInHex.startsWith('0')) {
      byteInHex = byteInHex.substring(1);
    }
    final result = int.tryParse(byteInHex, radix: 16);
    if (result == null) {
      throw StateError('Not valid hexadecimal bytes: $s');
    }
    return result;
  });
}

// 字符串String转为List<int>
List<int> StringToListInt( String _string ){


  return utf8.encode( _string );
}


// 文件大小转为格式化的字符串
String fileSizeToString ( int size ) {

  if ( size < 1024 )
    return ( size.toString() + ' Byte' );
  else if ( size < 1024 * 1024 )
    return ( (size / 1024).toStringAsFixed(2) + ' KB');
  else if ( size < 1024 * 1024 * 1024 )
    return ( (size / (1024*1024)).toStringAsFixed(2) + ' MB');
  else
    return ( ( size / ( 1024*1024*1024)).toStringAsFixed(2) + ' GB');

}

String SecondsToString ( int secs ){
  List<String> _parts = Duration( seconds: secs ).toString().split(':');
  if ( secs >= 3600 )
    return '${_parts[0]}:${_parts[1]}:${_parts[2].substring(0,2)}';
  else
    return '${_parts[1]}:${_parts[2].substring(0,2)}';
}

// 返回文件是否是视频文件，只对扩展名进行判断
bool getFileTypeIsVideo ( String _path ) {

  String _temp = Path.extension( _path ).toLowerCase();
  if ( _temp == '.mp4' || _temp == '.mkv' || _temp == '.mov' || _temp == '.avi' || _temp == '.webm' ) return true;
  else return false;
}

// 返回文件是否是图片文件，只对扩展名进行判断
bool getFileTypeIsImage ( String _path ) {

  String _temp = Path.extension( _path ).toLowerCase();
  if ( _temp == '.jpg' || _temp == '.jpeg' || _temp == '.webp' || _temp == '.png' || _temp == '.heic' ) return true;
  else return false;
}


Future getAppSetting() async {

  Completer _completer = Completer();
  SharedPreferences.getInstance().then(( _prefs ) {
    if ( _prefs.getBool('appSetting') != null ) {
      // not first run
      curAppSetting.userPhoneNumber = _prefs.getString('userPhoneNumber') ?? '';
      curAppSetting.userEmail = _prefs.getString( 'userEmail') ?? '';
      curAppSetting.agreementVersion = _prefs.getInt('agreementVersion') ?? 0;
      curAppSetting.languageIndex = _prefs.getInt('languageIndex') ?? 0;
      curAppSetting.themeIndex = _prefs.getInt('themeIndex') ?? 0;
      curAppSetting.isBiometrics = _prefs.getBool('isBiometrics') ?? false;
      curAppSetting.isCyptoVideo = _prefs.getBool('isCyptoVideo') ?? false;
      debugPrint('Reading App Setting and SHA1 at booting');
      debugPrint( 'Theme:' + curAppSetting.themeIndex.toString());
      firstRunAPP = false;
      _completer.complete();
    }
    else {
      firstRunAPP = true;
      //InitAppSetting();
      _completer.complete();
    }

  });
  return _completer.future;
}

void InitAppSetting() async {
  SharedPreferences.getInstance().then(( _prefs ) {
    Future.wait([
      _prefs.setString('userPhoneNumber', curAppSetting.userPhoneNumber),
      _prefs.setInt('agreementVersion', 0),
      _prefs.setInt('languageIndex', curAppSetting.languageIndex),
      _prefs.setInt('themeIndex', curAppSetting.themeIndex),
      _prefs.setBool('isBiometrics', curAppSetting.isBiometrics ),
      _prefs.setBool('isCyptoVideo', curAppSetting.isCyptoVideo ),
      _prefs.setBool('appSetting', true),

    ]).then((_) => debugPrint( 'InitAPPSetting for First Run!!!') );
  });
}

void setAppSetting( String key ) async {

  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  switch ( key ) {
    case 'isBiometrics':
      await _prefs.setBool('isBiometrics', curAppSetting.isBiometrics );
      break;
    case 'languageIndex':
      await _prefs.setInt('languageIndex', curAppSetting.languageIndex);
      break;
    case 'themeIndex':
      await _prefs.setInt('themeIndex', curAppSetting.themeIndex);
      break;
    case 'agreementVersion':
      await _prefs.setInt('agreementVersion', curAppSetting.agreementVersion);
      break;
    case 'userEmail':
      await _prefs.setString('userEmail', curAppSetting.userEmail);
      break;
    case 'userPhoneNumber':
      await _prefs.setString('userPhoneNumber', curAppSetting.userPhoneNumber );
      break;

    default:
      break;
  }
}
//
