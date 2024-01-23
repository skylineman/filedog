
import 'dart:async';

//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

//import 'package:cloudbase_ce/cloudbase_ce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../cloudbase_ce/cloudbase_ce.dart';
import '../customWidgets.dart';
import '../defClassandGlobal.dart';
import '../generated/l10n.dart';
import '../guide/verifyEmailPage.dart';
import '../homePage.dart';
import '../pinCode/pinCodePage.dart';

class SendSmsPage extends StatefulWidget {
  SendSmsPage({Key? key, required this.mode }) : super(key: key);

  final int mode;

  @override
  _SendSmsPageState createState() => _SendSmsPageState();
}

class _SendSmsPageState extends State<SendSmsPage> {

  //final _signinKey = GlobalKey<FormState>();
  //final _signupKey = GlobalKey<FormState>();

  late Timer _timer60s;
  late TextEditingController _phoneNumberCtrl;
  late TextEditingController _verifyCodeCtrl;
  var _phoneNumber = ''.obs;
  var _verifyCode = ''.obs;
  var _checkUserDeal = false.obs;
  var _checkSmsMode = false.obs;
  var _count = 60.obs;// false: 初始状态， true：倒计时状态

  //TextEditingController _passwordCtrl = TextEditingController();
  //ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    //

    _phoneNumberCtrl = TextEditingController( );
    _verifyCodeCtrl = TextEditingController();

    /*
    FirebaseDynamicLinks.instance.onLink.listen( (pendingDynamicLinkData) {
      // Set up the `onLink` event listener next as it may be received here
      final Uri deepLink = pendingDynamicLinkData.link;
      // Example of using the dynamic link to push the user to a different screen
      //Navigator.pushNamed(context, deepLink.path);
      debugPrint( 'Get Deep Link: ' + deepLink.toString() );
      Get.to( () => VerifyEmailPage(email: _emailCtrl.text, emailLink: deepLink.toString() ));
    });

     */
  }

  @override
  void dispose() {
    _phoneNumberCtrl.dispose();
    _verifyCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        //centerTitle: true,
        title: Text( '验证您的手机号' ),
        actions: [
          ( widget.mode == 1 )
            ? TextButton(
                onPressed: () {
                  var _auth =CloudBaseAuth( curCloudBaseCore );
                  _auth.signInAnonymously().then((value) => debugPrint( value.toString() ));
                  Get.to( MyPincodePage( ) );
                },
                child: Text( S.of(context).Skip)
              )
            : Container(),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox( height: 16.0 ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 4.0),
              child: Text('手机号', style: TextStyle( fontSize: 18.0),),
            ),

            //SizedBox( height: 4.0 ),

            CustomTextForm(
              controller: _phoneNumberCtrl,
              keyboardType: TextInputType.phone,
              hintText: '输入手机号',
              inputFormatters: [
                FilteringTextInputFormatter.allow( RegExp(r'^\d{1,11}$') ),
              ],
              prefixIcon: Icon( Icons.phone_android, color: Theme.of(context).primaryColor,),
              onChanged: ( value ) {
                _phoneNumber.value = value;
              },
            ),

            SizedBox( height: 16.0,),

            Row(
              children: [
                Expanded(
                  child: CustomTextForm(
                    controller: _verifyCodeCtrl,
                    keyboardType: TextInputType.number,
                    hintText: '输入验证码',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow( RegExp(r'^[0-9]+') ),
                    ],
                    prefixIcon: Icon( Icons.phone_android, color: Theme.of(context).primaryColor,),
                    onChanged: ( value ) {
                      _verifyCode.value = value;
                      if ( value.length == 6 ){

                        var _auth = CloudBaseAuth( curCloudBaseCore );
                        _auth.signUpWithPhoneCode( phoneNumber: '+86'+ _phoneNumberCtrl.text, phoneCode: value ).then(( value ) {

                          if ( value.refreshToken != null ) {
                            debugPrint('Sign Up RefreshToken: ' + value.refreshToken!); // 55bde67d2fdf46c38e39933670264aa1 实际测试有响应这个字段
                            EasyLoading.showInfo( '注册成功', duration: Duration( seconds: 2 ));
                            curAppSetting.userPhoneNumber = _phoneNumberCtrl.text;
                            setAppSetting('userPhoneNumber');
                            if ( widget.mode == 0 )
                              Get.back( result: _phoneNumberCtrl.text );
                            if ( widget.mode == 1 )
                              Get.offAll( Get.to( MyPincodePage( ) )); //MyHomePage( title: '' ));
                          }
                        }).onError((error, stackTrace) {
                          debugPrint( '!!!!!!!!!ERR: ' + error.toString() + '//' + stackTrace.toString() );
                        });
                      }
                    },
                  ),
                ),
                SizedBox( width: 16.0,),
                Obx(() => ElevatedButton(
                  onPressed: ( _checkSmsMode.value )
                    ? null
                    : () {
                      var _phoneNumber =  _phoneNumberCtrl.text;

                      if ( _phoneNumber.length == 11 && RegExp(r'^([1][3|4|5|6|7|8|9]\d{9}$)').hasMatch( _phoneNumber )){
                        _phoneNumber = '+86' + _phoneNumber;
                      }
                      else{
                        EasyLoading.showError( '请输入正确的手机号' );
                      }

                      if ( _phoneNumber.length == 14 && RegExp(r'^([+]86[1][3|4|5|6|7|8|9]\d{9}$)').hasMatch( _phoneNumber )) {
                        var _auth = CloudBaseAuth(curCloudBaseCore);
                        _auth.sendPhoneCode( _phoneNumber ).then(( value ) {
                          if ( value ) {
                            debugPrint('Get Verify Code: ' + value.toString());
                            _checkSmsMode.value = true;
                            _count.value = 60;
                            Timer.periodic( Duration(seconds: 1 ), ( _timer ) {

                              _count.value --;
                              if ( _count.value == 0 ){
                                _checkSmsMode.value = false;
                                _timer.cancel();
                              }
                            });
                          }
                        }).onError((error, stackTrace) {
                          debugPrint('!!!!!!!!!ERR: ' + error.toString());
                        });
                      }
                      else{
                        EasyLoading.showError( '请输入正确的手机号' );
                      }
                    },
                  child: (_checkSmsMode.value) ? Obx(() => Text( _count.value.toString() )) : Text( ' 获取验证码 ' ),
                ))
              ]
            ),
            /*
            Container(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Obx(() => Checkbox(
                    value: _checkUserDeal.value,
                    onChanged: ( newValue ){
                      _checkUserDeal.value = newValue!;
                    }
                  )),
                  TextButton(
                    child: Text( '查看用户协议和隐私政策' ),
                    onPressed: (){},
                  ),
                ],
              ),
            ),

             */

            Expanded(child: Container( width: 100.0, )),

            Divider( height: 32.0, thickness: 1.0, color: Theme.of(context).primaryColor,),

            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0.0),
              child: Text('输入的手机号用于忘记数字密码、重新设置时使用', style: TextStyle( fontSize: 16.0),),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0.0),
              child: Text('如不需要此功能，可以跳过此步。但数字密码将无法找回！', style: TextStyle( fontSize: 16.0),),
            ),
            /*
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0.0),
              child: Text('后续可以随时在设置中再次设定', style: TextStyle( fontSize: 16.0),),
            ),

           */

            SizedBox( height: 16.0,),
            /*
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0.0),
              child: Text('或者', style: TextStyle( fontSize: 16.0), ),
            ),

             */
            SizedBox( height: 32.0,),
          ]
        )
      )
    );
  }
}