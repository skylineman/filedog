
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../customWidgets.dart';
import '../defClassandGlobal.dart';
import '../generated/l10n.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _signinKey = GlobalKey<FormState>();
  final _signupKey = GlobalKey<FormState>();

  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _passwordCtrl = TextEditingController();
  //ScrollController _scrollCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(16.0),
        //alignment: Alignment.center,
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              child: Text('欢迎回来', style: TextStyle( fontSize: 24.0),),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0),
              child: Text('很高兴再次见到你', style: TextStyle( fontSize: 16.0),),
            ),

            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              child: Text('账户信息', style: TextStyle( fontSize: 16.0),),
            ),
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
            //SizedBox( height: 16.0,),
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text( S.of(context).ForgotPassword ),
                onPressed: (){},
              ),
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
        )
      ),
    );
  }
}