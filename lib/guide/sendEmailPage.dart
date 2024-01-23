
import 'dart:async';

//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';


import '../customWidgets.dart';
import '../defClassandGlobal.dart';
import '../generated/l10n.dart';
import '../guide/verifyEmailPage.dart';
import '../homePage.dart';

class SendEmailPage extends StatefulWidget {
  @override
  _SendEmailPageState createState() => _SendEmailPageState();
}

class _SendEmailPageState extends State<SendEmailPage> {

  //final _signinKey = GlobalKey<FormState>();
  //final _signupKey = GlobalKey<FormState>();

  TextEditingController _emailCtrl = TextEditingController();
  var _emailAddress = ''.obs;
  var _checkUserDeal = false.obs;
  //TextEditingController _passwordCtrl = TextEditingController();
  //ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    //
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
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},  //=> Get.offAll( () => MyHomePage(title: '')),
            child: Text( S.of(context).Skip))
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              child: Text('请输入电子邮件地址', style: TextStyle( fontSize: 24.0),),
            ),

            SizedBox( height: 16.0 ),

            CustomTextForm(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.allow( RegExp("^[A-Za-z0-9@.!#\$\%&'*+-_~]+\$") ),
              ],
              prefixIcon: Icon( Icons.email, color: Theme.of(context).primaryColor,),
              onChanged: ( value ) {
                _emailAddress.value = value;
              },
            ),
            //SizedBox( height: 16.0,),

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

            SizedBox( height: 32.0,),

            Obx(() => MyCustomButton(
              isEnable: ( _emailAddress.value.isEmail && _emailAddress.value.isNotEmpty ),
              height: 56.0,
              width: ScreenSize( context ).width - 32.0,
              icon: Icon( Icons.login ),
              label: Text( S.current.Verify + S.current.Email ),
              colorStyle: CustomButtonColorStyle.confirm,
              onPressed: () async {
                EasyLoading.showInfo( '正在发送验证邮件', duration: Duration(seconds: 3) );
                //debugPrint('Email: ${_emailCtrl.text}');

                // 国内版本不能使用
                /*
                await FirebaseAuth.instance.sendSignInLinkToEmail( //email: email, actionCodeSettings: actionCodeSettings).createUserWithEmailAndPassword(
                  email: _emailCtrl.text,
                  //password: '123456',

                  actionCodeSettings:  ActionCodeSettings(
                    // URL you want to redirect back to. The domain (www.example.com) for this
                    // URL must be whitelisted in the Firebase Console.
                    url: 'https://file-dog.firebaseapp.com/', // /__/auth/action?mode=action&oobCode=code',
                    // This must be true
                    handleCodeInApp: true,
                    iOSBundleId: '',
                    androidPackageName: 'com.skylineman.filedog',
                    // installIfNotAvailable
                    //androidInstallApp: true,
                    // minimumVersion
                    androidMinimumVersion: '1'
                  ),

                ).then((value) {
                  debugPrint('Successfully sent email verification! ');
                  EasyLoading.showInfo('邮件已发送', duration: Duration(seconds: 2) );
                  Get.to(()=> VerifyEmailPage( email: _emailCtrl.text) );
                } )
                .catchError( (onError) {
                  debugPrint('onError: ' + onError.toString() );
                  EasyLoading.showInfo( '邮件发送失败', duration: Duration(seconds: 2) );
                });

                 */

                //Get.to(  );

                //.then((_) => print('Successfully sent email verification'));
              }
            )),

            //Expanded(child: Container()),

            SizedBox( height: 300.0,),

            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0.0),
              child: Text('此邮件地址用于找回数字密码', style: TextStyle( fontSize: 16.0),),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0.0),
              child: Text('如暂不需要此功能，请点击左上角跳过', style: TextStyle( fontSize: 16.0),),
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
      ),
    );
  }
}