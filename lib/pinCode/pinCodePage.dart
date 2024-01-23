import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:filedog/customWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../defClassandGlobal.dart';
import '../guide/sendSmsPage.dart';
import '../guide/setDefaultFolderPage.dart';
import '../homePage.dart';
import '../generated/l10n.dart';
import '../guide/sendEmailPage.dart';

class MyPincodePage extends StatefulWidget {
  MyPincodePage({Key? key, this.mode = 0, this.retry = 3 }) : super(key: key);

  // Mode: 0: Setting,   1: Repeat Confirm,    2: Verify with Storage
  final int mode;
  final int retry;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyPincodePageState createState() => _MyPincodePageState();
}

class _MyPincodePageState extends State<MyPincodePage> {

  // 0: First Setting,   1: Repeat Confirm,    2: Verify
  // 4: Modify
  //int pinInputMode = 0;

  List<String> _pinTitle = [
    S.current.EnterNewPasscode,
    S.current.VerifyNewPasscode,
    S.current.EnterPasscode,
    '',
    S.current.EnterCurrentPasscode,
    S.current.EnterNewPasscode,
    S.current.VerifyNewPasscode,
  ];

  late FlutterSecureStorage keyStorage;
  late StreamController<ErrorAnimationType> errorController;
  late TextEditingController _pinPutController;
  late String pinCode;
  late int pinInputMode;
  //late RxBool isSixPincode;

  @override
  void initState()  {
    super.initState();
    keyStorage = FlutterSecureStorage();
    _pinPutController = TextEditingController();
    errorController = StreamController<ErrorAnimationType>();
    pinInputMode = widget.mode;
    //isSixPincode = false.obs;
    debugPrint( 'Pin Code Mode is:' + pinInputMode.toString() );

    if ( curAppSetting.isBiometrics && widget.mode == 2 ) {
      Future.delayed( Duration( milliseconds: 500 ), () {
        AuthFingerPrint(context, S.of(context).UsingPincodeforLogin ).then(( value ) {
          if ( value ) Get.offAll( MyHomePage( defaultFolderName : '') );
        });
      });
    }
  }

  @override
  void dispose(){
    errorController.close();
    try { _pinPutController.dispose(); } catch (e) { debugPrint( e.toString() );}
    //_pinPutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //errorController = StreamController<ErrorAnimationType>();
    return Scaffold(
      //backgroundColor: getPincodePageBackbroundColor( pinInputMode ),
      //extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //backgroundColor: getPincodePageBackbroundColor( pinInputMode ),
        //foregroundColor: Colors.white,
        toolbarOpacity: 1.0,
        leading: ( pinInputMode == 1 ) ? IconButton(
          icon: Icon( Icons.arrow_back ),
          onPressed: (){
            setState(() {
              pinInputMode = 0;
              _pinPutController.clear();
              Get.back();
              //errorController.reactive();
              //pinCode = '';
            });

          },
        ) : null,
        actions: ( pinInputMode == 2 ) ? [
          TextButton(
            child: Text(
              S.of(context).ForgotPassword,
              style: TextStyle( fontSize: 18.0, color: ( Get.isDarkMode ) ? Colors.white : Colors.black ),),
            onPressed: (){},
          )
        ] : null,
        //title: Text( _pinTitle[ pinInputMode ] ),
        //centerTitle: ( pinInputMode < 3 ),
      ),

      body: Column(
        children: [
          SizedBox( height: 128.0,),

          Container(
            alignment: Alignment.center,
            child: Text( _pinTitle[ pinInputMode ] , style: TextStyle( fontSize: 24.0, color: ( Get.isDarkMode ) ? Colors.white : Colors.black  ),),
          ),

          Container(
            padding: EdgeInsets.fromLTRB( 64.0, 48.0, 64.0, 16.0 ),
            child: PinCodeTextField(
              appContext: context,
              length: 4,
              obscureText: true,
              obscuringCharacter: ' ',
              blinkWhenObscuring: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular( 8.0 ),
                fieldHeight: 16.0,
                fieldWidth: 16.0,
                activeFillColor: ( Get.isDarkMode ) ? Colors.white : Colors.black  ,
                inactiveFillColor: getPincodePageBackbroundColor( pinInputMode ),
                inactiveColor: ( Get.isDarkMode ) ? Colors.white : Colors.black,
                activeColor: ( Get.isDarkMode ) ? Colors.white : Colors.black,
              ),
              //cursorColor: Colors.black,
              useHapticFeedback: true,
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              errorAnimationController: errorController,
              controller: _pinPutController,
              keyboardType: TextInputType.none,
              onCompleted: ( v ) {
                switch ( pinInputMode ) {
                  case 0:
                    pinCode = v;
                    pinInputMode = 1;
                    debugPrint('First Completed' + v );
                    setState(() {
                      _pinPutController.clear();
                    });
                    break;
                  case 1:
                    if ( pinCode == v ) {
                      Sha1().hash( utf8.encode( v ) ).then(( value ) {
                        keyStorage.write(key: keyValuePinCodeSha1, value: value.bytes.toString() ).then((_) {
                          debugPrint(' Pin Code Setting Successfully!');

                          Get.defaultDialog(
                            title: S.of(context).UsingFingerprintforLogin,
                            content: Text( '是否设置指纹作为登录方法'),

                            confirm: TextButton(
                              child: Text(S.of(context).Confirm),
                              onPressed: () {
                                Get.back( result: true );
                              }
                            ),

                            cancel: TextButton(
                              child: Text(S.of(context).Cancel),
                              onPressed: () {
                                Get.back( result: false );
                              }
                            ),
                            onWillPop: () {
                              debugPrint( ' onWillPop' );
                              return Future.value( false );
                            }  // onWillPop

                          ).then(( value ) {
                            if ( value == true ) {
                              AuthFingerPrint(context, '').then(( value ) => curAppSetting.isBiometrics = true );
                            }
                          });

                          // 初始化 App Setting
                          InitAppSetting();

                          Get.offAll( SetDefaultFolderPage(), duration: Duration( milliseconds: 300 ));
                        }).onError((error, stackTrace) {
                          debugPrint( error.toString());
                        });
                      });
                    }
                    else{
                      errorController.add(ErrorAnimationType.shake);
                      _pinPutController.clear();
                    }
                    break;

                  // 验证Pincode
                  case 2:
                    pinCode = v;
                    Sha1().hash( utf8.encode( v ) ).then(( value ) {
                      keyStorage.read(key: keyValuePinCodeSha1 ).then(( _pin ) {
                        if ( value.bytes.toString() == _pin )
                          Get.offAll( MyHomePage( defaultFolderName: ' ' ) );
                        else {
                          errorController.add(ErrorAnimationType.shake);
                          _pinPutController.clear();
                        }

                      });
                    });
                    break;
                  case 4:
                    pinCode = v;
                    Sha1().hash( utf8.encode( v ) ).then(( value ) {
                      keyStorage.read(key: keyValuePinCodeSha1).then(( v ) {
                        if ( value.bytes.toString() == v )
                          setState((){
                            pinInputMode = 5;
                            _pinPutController.clear();
                          });
                        else {
                          errorController.add(ErrorAnimationType.shake);
                          _pinPutController.clear();
                        }

                      });
                    });
                    break;
                  case 5:
                    pinCode = v;
                    pinInputMode = 6;
                    debugPrint('First Completed' + v );
                    setState(() {
                      _pinPutController.clear();
                    });
                    break;
                  case 6:
                    if ( pinCode == v ) {
                      Sha1().hash( utf8.encode( v ) ).then(( value ) {
                        keyStorage.write(key: keyValuePinCodeSha1, value: value.bytes.toString() ).then((_) {
                          EasyLoading.showSuccess(' Pin Code Modified Successfully', duration: Duration( seconds: 3 ));
                          Get.back( result: true );
                        }).onError((error, stackTrace) {
                          debugPrint( error.toString());
                        });
                      });
                    }
                    else{
                      errorController.add(ErrorAnimationType.shake);
                      _pinPutController.clear();
                    }
                    break;

                  default:
                    break;
                }
              },

              onChanged: ( value ) {
                setState(() {
                });
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),
          ),

          Expanded(child: SizedBox( )),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 40.0,
            mainAxisSpacing: 40.0,
            padding: const EdgeInsets.only( top: 32.0, left: 64.0, right: 64.0),
            physics: NeverScrollableScrollPhysics(),
            children: [
              ...[1, 2, 3, 4, 5, 6, 7, 8, 9, 0].map( (e) {
                return TextButton(
                  child: Text('$e',
                    style: TextStyle( color: ( Get.isDarkMode ) ? Colors.grey[50] : Colors.black, fontSize: 24.0),
                  ),
                  style: ButtonStyle(
                    //fixedSize: MaterialStateProperty.all ( Size (60.0, 45.0 )),
                    side: MaterialStateProperty.all( BorderSide(color: ( Get.isDarkMode ) ? Colors.white70 : Colors.black, width: 1) ),
                    shape: MaterialStateProperty.all( CircleBorder() ),
                    overlayColor: MaterialStateProperty.all( Colors.white30 ),
                  ),
                  onPressed: () {
                    if (_pinPutController.text.length >= 5) return;

                    _pinPutController.text = '${_pinPutController.text}$e';
                    _pinPutController.selection = TextSelection.collapsed(
                        offset: _pinPutController.text.length);
                  },
                );
              }),
              IconButton(
                icon: Icon(Icons.backspace, color: ( Get.isDarkMode ) ? Colors.grey[50] : Colors.black, size: 24.0,),
                onPressed: () {
                  if (_pinPutController.text.isNotEmpty) {
                    _pinPutController.text = _pinPutController.text
                        .substring(0, _pinPutController.text.length - 1);
                    _pinPutController.selection = TextSelection.collapsed(
                        offset: _pinPutController.text.length);
                  }
                },
              ),
            ],
          ),



          /*
          if ( pinInputMode == 0)
            Container(
              padding: EdgeInsets.fromLTRB( 64.0, 48.0, 48.0, 0.0 ),
              alignment: Alignment.centerLeft,
              child: Text( 'If you want more security' ),
            ),
          if ( pinInputMode == 0 )
            Container(
              //color: Colors.amberAccent,
              padding: EdgeInsets.fromLTRB( 48.0, 0.0, 48.0, 0.0 ),
              alignment: Alignment.centerLeft,
              child: SwitchListTile(
                title: Text( '6 Digit Pin Code' ),
                value: isSixPincode.value,
                onChanged: ( value ) {
                  isSixPincode.value = value;
                  setState(() {

                  });

                },
              ),
            ),

           */

          SizedBox( height:  64.0 ),
        ],
      ),

    );
  }

  // 根据不同的模式，返回背景色
  Color getPincodePageBackbroundColor( int mode ){
    Color _color;
    switch ( mode ) {
      case 0:
        _color = ( Theme.of(context).brightness != Brightness.dark ) ? Colors.white : Colors.black87;
        break;
      case 1:
        _color = ( Theme.of(context).brightness != Brightness.dark ) ? Colors.white : Colors.black87;
        break;
      case 2:
        _color = ( Theme.of(context).brightness != Brightness.dark ) ? Colors.white : Colors.black87;
        break;
      default:
        _color = ( Theme.of(context).brightness != Brightness.dark ) ? Colors.white : Colors.black87;
        break;
    }
    return _color;
  }
}

/*
class MyEmailSeetingPage extends StatefulWidget {
  MyEmailSeetingPage({Key? key}) : super(key: key);


// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks.

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".

@override
_MyEmailSettingPageState createState() => _MyEmailSettingPageState();
}

class _MyEmailSettingPageState extends State<MyEmailSeetingPage> {




}

*/