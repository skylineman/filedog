
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


import '../customWidgets.dart';
import '../defClassandGlobal.dart';
import '../generated/l10n.dart';
import '../guide/logInPage.dart';
import '../guide/sendEmailPage.dart';

class LogSignEntryPage extends StatefulWidget {

  LogSignEntryPage({Key? key }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _LogSignEntryPageState createState() => _LogSignEntryPageState();
}

class _LogSignEntryPageState extends State<LogSignEntryPage>  {

  final _signinKey = GlobalKey<FormState>();
  final _signupKey = GlobalKey<FormState>();

  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _passwordCtrl = TextEditingController();
  ScrollController _scrollCtrl = ScrollController();
  //late UserCredential userInfo;

  @override
  void initState() {
    super.initState();
    //
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //extendBody: true,
      //extendBodyBehindAppBar: false,
      /*
      appBar: AppBar(
        //title: Text( S.current.Signin ),
        actions: [
          Text('不注册亦可使用文件狗'),
          TextButton( onPressed: () {  }, child: Text( S.current.Skip ), ),
        ],
      ),
      */

      body: Container(
        padding: EdgeInsets.fromLTRB( 16.0, 0.0, 16.0, 0.0),
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.center,
          controller: _scrollCtrl,
          children: [
            Container(
              padding: EdgeInsets.only( bottom: 16.0),
              child: Image.asset( 'images/login.png' ),
              //child: Lottie.asset('images/lottie/sign-in-green.json', width: 128.0, height: 128.0),
            ),

            //Spacer(),

            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text( '欢迎使用文件狗，全域加密隐私文件',style: TextStyle( fontSize: 16.0 ),),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: MyCustomButton(
                height: 56.0,
                width: ScreenSize( context ).width - 32.0,
                icon: Icon( Icons.login ),
                label: Text( S.of(context).Signin ),
                colorStyle: CustomButtonColorStyle.confirm,
                onPressed: () {
                  Get.to( () => LoginPage() );
                }
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: MyCustomButton(
                height: 56.0,
                width: ScreenSize( context ).width - 32.0,
                icon: Icon( Icons.app_registration ),
                label: Text( S.of(context).Signup ),
                colorStyle: CustomButtonColorStyle.normal,
                onPressed: () {
                  Get.to( SendEmailPage() );
                }
              ),
            ),

            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(64.0),
                    child: Image.asset( 'images/google_logo.png', width: 40.0, height: 40.0, ) ,
                    onTap: () {
                      EasyLoading.show(
                        indicator: CircularProgressIndicator( )
                      );

                      /*
                      SigninWithGoogle().then((value) {
                        //if (value) Get.back(result: true);
                      });

                       */
                    }
                  ),

                  SizedBox( width: 32.0,),

                  InkWell(
                    borderRadius: BorderRadius.circular(64.0),
                    child: Image.asset( 'images/facebook_logo.png', width: 40.0, height: 40.0, ) ,
                    onTap: (){},
                  ),
                ],
              ),
            ),
            SizedBox( height: 32.0,),
          ],
        ),
      ),
    );
  }

  // Sign In with Email BottomSheet

  Future<dynamic> MySigninEmailBottomSheet( BuildContext context ) =>
    Get.bottomSheet( Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only( topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
      ),
      child: Form(
        key: _signinKey,
        child: Container( padding: EdgeInsets.all(16.0),child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text( S.of(context).SigninEmail, style: TextStyle( fontSize: 18.0, fontWeight: FontWeight.bold ),),
            ),
            Divider( height: 32.0, thickness: 1.0),
            CustomTextForm(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.allow( RegExp("^[A-Za-z0-9@.!#\$\%&'*+-_~]+\$") ),
              ],
              prefixIcon: Icon( Icons.email, color: Theme.of(context).primaryColor,),
            ),
            SizedBox( height: 16.0,),
            CustomTextForm(
              controller: _passwordCtrl,
              keyboardType: TextInputType.visiblePassword,
              inputFormatters: [],
              prefixIcon: Icon( Icons.password, color: Theme.of(context).primaryColor,),
            ),
            SizedBox( height: 16.0,),
            TextButton(
              child: Text( S.of(context).ForgotPassword ),
              onPressed: (){},
            ),
            SizedBox( height: 16.0,),
            MyCustomButton(
              height: 56.0,
              width: ScreenSize( context ).width - 32.0,
              icon: Icon( Icons.login ),
              label: Text( S.of(context).Signin ),
              colorStyle: CustomButtonColorStyle.confirm,
              onPressed: () {
                if ( _signinKey.currentState!.validate() ) {
                  EasyLoading.show( dismissOnTap: true );

                  /*
                  CustomSinginWithEmail(_signinKey, _emailCtrl.text, _passwordCtrl.text ).then(( value ) {
                    if ( value ) Get.back( result: true );
                  });

                   */

                }
              }
            ),
            SizedBox( height: 16.0,),
          ]
        ))
      ),
    ),
      isScrollControlled: true,
    );

  // Sign Up with Email BottomSheet

  Future<dynamic> MySignUpEmailBottomSheet( BuildContext context ) =>
      Get.bottomSheet( Material(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only( topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
        ),
        child: Form(
            key: _signupKey,
            child: Container( padding: EdgeInsets.all(16.0),child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text( S.of(context).SignupEmail, style: TextStyle( fontSize: 18.0, fontWeight: FontWeight.bold ),),
                  ),
                  Divider( height: 32.0, thickness: 1.0),
                  CustomTextForm(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow( RegExp("^[A-Za-z0-9@.!#\$\%&'*+-_~]+\$") ),
                    ],
                    prefixIcon: Icon( Icons.email, color: Theme.of(context).primaryColor,),
                  ),
                  SizedBox( height: 16.0,),
                  CustomTextForm(
                    controller: _passwordCtrl,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: [],
                    prefixIcon: Icon( Icons.password, color: Theme.of(context).primaryColor,),
                  ),
                  SizedBox( height: 16.0,),
                  MyCustomButton(
                      height: 56.0,
                      width: ScreenSize( context ).width - 32.0,
                      icon: Icon( Icons.app_registration ),
                      label: Text( S.of(context).Signup ),
                      colorStyle: CustomButtonColorStyle.confirm,
                      onPressed: () {
                        if ( _signinKey.currentState!.validate() ) {

                          /*
                          CustomSinginWithEmail(_signupKey, _emailCtrl.text, _passwordCtrl.text ).then(( value ) {
                            if ( value ) Get.back( result: true );
                          });

                           */
                        }
                      }
                  ),
                  SizedBox( height: 16.0,),
                ]
            ))
        ),
      ),
        isScrollControlled: true,
      );

}

