import 'dart:io';

import 'package:filedog/guide/sendSmsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as Path;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../hiveDataTable/defTrashFileClass.dart';

import 'feedBackPage.dart';
import '../defClassandGlobal.dart';
import '../customWidgets.dart';
import '../generated/l10n.dart';
import '../trashList/trashListPage.dart';
import '../guide/logSignEntryPage.dart';
import '../pinCode/pinCodePage.dart';
import '../moveToDevice/moveToDevicePage.dart';


class AppSettingPage extends StatefulWidget {

  AppSettingPage({Key? key }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage>  {

  //final _auth = FirebaseAuth.instance;
  late Future<SharedPreferences> _prefs;
  var trashFilesCounts = 0.obs;
  var isPhoneValid = false.obs;
  late int trashFilesSize;
  var isSignin = false.obs;

  @override
  void initState(){
    super.initState();
    //var currUser = _auth.currentUser;
    _prefs = SharedPreferences.getInstance();

    if ( curAppSetting.userPhoneNumber == '' )
      isPhoneValid.value = false;
    else
      isPhoneValid.value = true;

    trashFilesSize = 0;
  }

  @override
  void dispose() {
    // Insert your code
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text( S.current.Setting ),
      ),
      body: ListView(
            //padding: EdgeInsets.only(top: 16.0),
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset('images/filedoglogo.png', width: 128.0, height: 128.0,),
          ),
          // User Login in
          //UserAccountSetting(),

          Container(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 8.0),
            color: ( Get.isDarkMode ) ? Colors.grey[500] : Colors.grey[200],
            alignment: Alignment.bottomLeft,
            height: 48,
            child: Text( S.of(context).PasswordReset ),
          ),

          Obx( () =>ListTile(
            leading: Icon( Icons.email, color: Colors.cyan, ),
            title: ( isPhoneValid.value ) ? Text( curAppSetting.userPhoneNumber, style: TextStyle( fontSize: 16.0 ),)
                                          : Text( S.of(context).NoSetting, style: TextStyle( fontSize: 16.0 )),
            trailing: Container(
              width: 96.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if ( isPhoneValid.value ) Text( S.of(context).Modify, style: TextStyle( fontSize: 16.0 ) ) ,
                  Icon( Icons.keyboard_arrow_right ),
                ],
              ),
            ),
            onTap: () => Get.to( () => SendSmsPage( mode: 0, ) ),
          )),
          // Files
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 8.0),
            color: ( Get.isDarkMode ) ? Colors.grey[500] : Colors.grey[200],
            alignment: Alignment.bottomLeft,
            height: 48,
            child: Text( S.current.Recycled ),
          ),

          FutureBuilder(
            future: Hive.openBox( stringToBase64Url.encode( keyValueTrashBoxName )),
            builder: ( context, AsyncSnapshot<Box> snapshot ) {

              if ( snapshot.connectionState == ConnectionState.done && snapshot.hasData ) {
                Box _trashBox = snapshot.data!;

                trashFilesSize = 0;
                trashFilesCounts.value = _trashBox.length;
                for ( var i = 0; i < _trashBox.length; i++ )
                  trashFilesSize += ( _trashBox.getAt( i ) as TrashFileInfo ).fileSize!;

                return Obx( () => CupListTile(
                  leading: Icon( CupertinoIcons.trash, color: ( Get.isDarkMode) ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark),
                  title: Text( trashFilesCounts.value.toString() + ' ' + S.of(context).Files ),
                  subtitle: Text ( fileSizeToString( trashFilesSize ) ),
                  trailing: Icon( Icons.keyboard_arrow_right ),
                  onTap: (){
                    Get.to( () => MyTrashListPage( curDirectory: Directory( Path.join(appDocDir.path, keyValueTrashBoxName ))))?.then((_) {
                      setState(() {
                        debugPrint(' Trash Folder Counts: ' + trashFilesCounts.value.toString() );
                      });
                    });
                  }
                ));
              }
              else
                return Container();
            }),

          // Secrety
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 8.0),
            color: ( Get.isDarkMode ) ? Colors.grey[500] : Colors.grey[200],
            alignment: Alignment.bottomLeft,
            height: 48,
            child: Text( S.current.Secrecy),
          ),

          ListTile(
            leading: Icon( Icons.password, color: ( Get.isDarkMode) ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark),
            title: Text( S.current.ModifyPincode ),
            trailing: Icon( Icons.keyboard_arrow_right ),
            onTap: () {
              Get.to( () => MyPincodePage( mode: 4 ) )?.then((value) {
                debugPrint( 'result:' + value.toString());
              });
            },
          ),
          Divider( height: 1.0,),

          if ( canCheckBiometrics ) SwitchListTile(
            activeColor: Theme.of(context).primaryColor,
            secondary: Icon(Icons.fingerprint, color: Colors.deepOrange,),
            title: Text( S.current.UsingFingerprintforLogin ),
            value: curAppSetting.isBiometrics,
            onChanged: ( _value ) {
              if ( _value ) {
                try {
                  debugPrint( '!!Biometrics is ' + canCheckBiometrics.toString() );
                  AuthFingerPrint( context, '' ).then((value) {
                    if ( value ) {
                      // 指纹认证通过
                      setState(() {
                        curAppSetting.isBiometrics = true;
                        setAppSetting('isBiometrics');
                      });
                    }
                    else
                      // 指纹认证失败
                      debugPrint('Fingerprint Verify Fail!');
                  });
                }
                catch ( _err ){
                  debugPrint ( '!ERROR!: ' + _err.toString() );
                }
              }
              else
                setState(() {
                  curAppSetting.isBiometrics = false;
                  setAppSetting('isBiometrics');
                });
              debugPrint( 'isBiometrics:' + curAppSetting.isBiometrics.toString() );
            }
          ),

          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,
            secondary: Icon(Icons.enhanced_encryption, color: Colors.blueAccent,),
            title: Text( S.current.EncryptVideo ),
            value: curAppSetting.isCyptoVideo,
            onChanged: ( v ) async {
              setState(() {
                curAppSetting.isCyptoVideo = v;
                setAppSetting('isCyptoVideo');
              });
              debugPrint( 'isCyptoVideo:' + curAppSetting.isCyptoVideo.toString() );
            }
          ),

          Divider( height: 1.0 ),

          ListTile(

            leading: Icon( Icons.phone_android, color: ( Get.isDarkMode) ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark),
            title: Text( 'Transfer Folders to Other Device' ),
            trailing: Icon( Icons.keyboard_arrow_right ),
            onTap: () {
              Get.to( () => MoveToDeviceHomePage() )?.then((value) {
                debugPrint( 'result:' + value.toString());
              });
            },

          ),

          Container(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 8.0),
            color: ( Get.isDarkMode ) ? Colors.grey[500] : Colors.grey[200],
            alignment: Alignment.bottomLeft,
            height: 48,
            child: Text( S.current.General ),
          ),
          CupListTile(
            leading: Icon( Icons.language, color: ( Get.isDarkMode) ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark),
            title: Text( S.of(context).Language ),
            subtitle: Text ( supportedLanguages[ curAppSetting.languageIndex ] ),
            trailing: Icon( Icons.keyboard_arrow_right ),
            onTap: () async {
              supportedLanguages[0] = S.of(context).FollowOS;
              MyListBottomSheet( context, S.of(context).Language, supportedLanguages, curAppSetting.languageIndex).then(( value ) async {
                if ( value!= null ) {
                  curAppSetting.languageIndex = value;
                  setAppSetting('languageIndex');
                  supportedLanguages[0] = S.of(context).FollowOS;
                  setState(() {
                    if ( curAppSetting.languageIndex != 0 )
                      S.load( Locale( languagesCode[curAppSetting.languageIndex]));
                    else {
                      S.load( Locale( WidgetsBinding.instance.window.locale.languageCode));
                    }
                  });
                }
              });
            },
          ),
          Divider( height: 1.0,),
          CupListTile(
            leading: Icon( CupertinoIcons.square_grid_2x2, color: Theme.of(context).primaryColor, ),
            title: Text( S.of(context).Theme ),
            subtitle: Text( themeMode[ curAppSetting.themeIndex ] ),

            onTap: (){
              MyListBottomSheet( context, S.of(context).Theme, themeMode, curAppSetting.themeIndex ).then((value) async {
                if ( value!= null ) {
                  curAppSetting.themeIndex = value;
                  setAppSetting('themeIndex');
                  //debugPrint('Value:' + value.toString());
                  setState(() {
                    if (value == 0)
                      Get.changeThemeMode(ThemeMode.system);
                    if (value == 1)
                      Get.changeThemeMode(ThemeMode.light);
                    if (value == 2)
                      Get.changeThemeMode(ThemeMode.dark);
                  });

                }
              });
            },
          ),
          Divider( height: 1.0,),
          ListTile(
            leading: Icon( Icons.feedback, color: Colors.green,),
            title: Text( S.of(context).Feedback ),
            trailing: Icon( Icons.keyboard_arrow_right ),
            onTap: () => Get.to( () => FeedBackPage()),
          ),
          Divider( height: 1.0,),
          ListTile(
            leading: Icon( Icons.contact_phone),
            title: Text( S.of(context).Agreement ),
            trailing: Icon( Icons.keyboard_arrow_right ),
          ),
          Divider( height: 1.0,),
          ListTile(
            leading: Icon( Icons.people),
            title: Text( S.of(context).Version ),
            trailing: Text( '1.0.185' ),
          ),
          Divider( height: 1.0,),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 16.0),
            child: Text('www.filedog.app'),
          )
        ],
      ),
    );
  }


  //  国内版本不能使用
  /*
  Widget UserAccountSetting4Firebase(){
    return Obx( () => Container(
      padding: EdgeInsets.all( 16.0 ),
      child: ListTile(
        contentPadding: EdgeInsets.all( 16.0 ),
        tileColor: Color.fromRGBO(218, 244, 254, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular( 16.0 )
        ),
        leading: ( isSignin.value )
          ? ( _auth.currentUser!.providerData[0].photoURL != null )
            ? ClipOval( child: Image.network( _auth.currentUser!.providerData[0].photoURL!, width: 48.0, height: 48.0 ))
            : Image.asset( 'images/default-image.png', width: 64.0, height: 64.0 )
          : Image.asset( 'images/default-image.png', width: 64.0, height: 64.0 ),
        title: ( isSignin.value )
          ? Text( _auth.currentUser!.email!, style: TextStyle( fontSize: 18.0, color: Colors.grey[800]),)
          : Text( S.of(context).Signin +'/' + S.of(context).Signup, textAlign: TextAlign.end,),
        trailing: Icon( Icons.chevron_right),
        onTap: (){
          if ( isSignin.value )
            MySignOutBottomSheet(context).then(( value ) {
              if ( value == true )
              isSignin.value = false;
            });
          else
            Get.to(() => LogSignEntryPage())?.then((value) {
              if ( value == true )
                isSignin.value = true;
            });
        },
      ),

    ));
  }
  */

  // Log Out Pop
  Future MySignOutBottomSheet( BuildContext context ) =>
    Get.bottomSheet( Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only( topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.0),
            //child: Lottie.asset('images/lottie/sign-out.json', height: 96.0 ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(16.0),
            child: Text('Do you want to sign out?', style: TextStyle(fontSize: 14.0),),
          ),
          Divider(height: 16.0,),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red,),
            title: Text( S.of( context ).Signout ),
            onTap: () {
              /*
              _auth.signOut().then((_) {
                debugPrint('Sign Out!');
                debugPrint( _auth.currentUser.toString() );
                _auth.signInAnonymously();
                Get.back( result: true );
              });

               */
            },
          ),
          Divider(height: 16.0,)
        ]
      ),
    ));
}