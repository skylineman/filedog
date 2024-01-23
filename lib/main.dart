import 'dart:io';
import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import './cloudbase_ce/cloudbase_ce.dart';

import 'defClassandGlobal.dart';
import 'hiveDataTable/defImageInfomationClass.dart';
import 'hiveDataTable/defTrashFileClass.dart';
import 'crypto/cryptoGraphy.dart';
import 'guide/welcomepage.dart';
import 'pinCode/pinCodePage.dart';
import 'generated/l10n.dart';


/*
    --primary-100:#0077C2;
    --primary-200:#59a5f5;
    --primary-300:#c8ffff;
    --accent-100:#00BFFF;
    --accent-200:#00619a;
    --text-100:#333333;
    --text-200:#5c5c5c;
    --bg-100:#FFFFFF;
    --bg-200:#f5f5f5;
    --bg-300:#cccccc;

 */

/*
    --primary-100:#0085ff;
    --primary-200:#69b4ff;
    --primary-300:#e0ffff;
    --accent-100:#006fff;
    --accent-200:#e1ffff;
    --text-100:#FFFFFF;
    --text-200:#9e9e9e;
    --bg-100:#1E1E1E;
    --bg-200:#2d2d2d;
    --bg-300:#454545;

 */

void main() async {

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter( ImageFileInfoAdapter() );
  Hive.registerAdapter( TrashFileInfoAdapter() );

  Init.instance.initialize().then((_) => runApp(MyApp()) );
  // 隐藏顶部状态栏及底部虚拟按键
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white12,
    //systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode( SystemUiMode.leanBack, overlays: [ SystemUiOverlay.top ] );
  AssetPicker.registerObserve();

  WidgetsBinding.instance.addPostFrameCallback((call) {
    // 执行你的代码
  });

}

// 主程序入口
class MyApp extends StatelessWidget {
  const MyApp ({Key? key}) : super(key: key);
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      /*
      onGenerateTitle: () {
        // 初始化
        debugPrint('Init GetMaterialApp');
        showAboutDialog(
          context: context,
          applicationName: 'FileDOG',
          applicationVersion: '1.0.0',
          applicationIcon: Image.asset('assets/logo.png'),
        );
      },
      */
      key: mainAppKey, //GlobalKey( debugLabel: 'MyApp' ),
      //navigatorKey: GlobalKey( debugLabel: 'MyApp' ),
      title: '',    // 显示在操作系统的任务切换器中
      // 设置语言
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      // 讲zh设置为第一项,没有适配语言时，英语为首选项
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'zh') {
          return Locale('zh');
        }
        if (locale?.languageCode == 'en') {
          return Locale('en');
        }
        return Locale('en');
      },
      onGenerateTitle: (context) {
        // 此时context在Localizations的子树中
        return S.of(context).appName;
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        primaryColor: Color.fromRGBO(0x42, 0xa5, 0xf5, 1.0),
        primaryColorLight: Color.fromRGBO(0x52, 0xb5, 0xff, 1.0),
        primaryColorDark: Color.fromRGBO(0x32, 0x85, 0xe5, 1.0),
        splashColor: Color.fromRGBO(0x52, 0xb5, 0xff, 0.4),
        highlightColor: Color.fromRGBO(0x52, 0xb5, 0xff, 0.2),
        scaffoldBackgroundColor: Colors.grey[50],
        //toggleableActiveColor: Colors.grey[500],
        canvasColor: Colors.grey[50],
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          foregroundColor: Colors.grey[900],
          elevation: 0.0,
        ),
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0.3)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: Color.fromRGBO( 0x42, 0xa5, 0xf5, 1.0 ),
        primaryColorLight: Color.fromRGBO( 0x52, 0xb5, 0xff, 1.0 ),
        primaryColorDark: Color.fromRGBO( 0x32, 0x85, 0xe5, 1.0 ),
        splashColor: Color.fromRGBO( 0x52, 0xb5, 0xff, 0.4 ),
        highlightColor: Color.fromRGBO( 0x52, 0xb5, 0xff, 0.2 ),
        //backgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0.0,
        )
      ),
      themeMode: ( curAppSetting.themeIndex == 0 ) ? ThemeMode.system : ( ( curAppSetting.themeIndex == 1 ) ? ThemeMode.light : ThemeMode.dark ),
      home: ( firstRunAPP ) ? WelcomePage() : MyPincodePage( mode: 2 ), //MyPincodePage( mode: 2 ), //MyHomePage(title: ''),
      //MyPinSettingPage(), //MyHomePage( title: 'Photo Vault',),
      builder: EasyLoading.init(),
    );
  }
}

class MySplashPage extends StatelessWidget {
  const MySplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool lightMode =
      MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor:
      lightMode ? const Color(0xffe1f5fe) : const Color(0xff042a49),
      body: Center(
        child: lightMode
          ? Image.asset('images/calclock.png')
          : Image.asset('images/calclock.png')),
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!

    curCloudBaseCore = CloudBaseCore.init({
      'env': 'filedog-6gnso174b58b00c2',
      'appAccess': {
        'key': '04debb21bb1b1935e74db6ab72eb5d21',
        'version':  '1',
      }
    });

    return Future.wait( [

      getAppSetting().then((_) => ( firstRunAPP ) ? initAesKey().then((_) => writeAESKeyToKeychain() ) : readAESKeyFromKeyChain() ),

      // 国际版使用 FireBase
      /*
      Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyCjoV2e_IscUgKRZiZIlNnF4WG-35m10YI',
          appId: '1:455263632627:android:4051fb79487dcfc00ecb86',
          messagingSenderId: '',
          projectId: 'file-dog',
        ),
      ).then((value) => null),

      */

      // 国内版使用腾讯 Cloudbase

      //_auth.signInAnonymously(),

      availableCameras().then(( value ) => cameraList = value ),
      LocalAuthentication().canCheckBiometrics.then((value) => canCheckBiometrics = value ),
      getExternalStorageDirectory().then((value) => appDocDir = value! ),
      getTemporaryDirectory().then((value) => appCacheDir = value ),
      rootBundle.load('images/unknow-photo-118.png').then((value) => unknownImageData = value.buffer.asUint8List()),
      rootBundle.load('images/photofolder-1.png').then((value) => defaultImageData = value.buffer.asUint8List()),

    ]).catchError( (onError) => debugPrint( onError.toString()) );
  }
}
