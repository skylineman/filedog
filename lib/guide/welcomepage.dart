import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';

import 'package:filedog/guide/sendSmsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../guide/sendEmailPage.dart';
import '../pinCode/pinCodePage.dart';
import '../customWidgets.dart';
import '../defClassandGlobal.dart';
import '../generated/l10n.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key, }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks.

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".

class _WelcomePageState extends State<WelcomePage> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration( milliseconds: 10 ), () {
      try {
        PrivacyPolicyBottomSheet( context ).then(( value ) {
          if ( !value )
            exit( 0 );
          else
            Get.offAll( SendSmsPage( mode: 1 ) );

        });
      } catch (e) {}
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      //backgroundColor: Theme.of(context).primaryColor,

      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.zero,
        color: Color.fromARGB( 0xff, 0x2a, 0x7f, 0xff ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //SizedBox( height: 64.0,),
            Image.asset( 'images/guide-1.png'),
            SizedBox( height: 64.0,),
            /*
            Container(
              color: Theme.of(context).primaryColor,
              width: ScreenSize(context).width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  SizedBox( height: 128.0,),
                  Text( S.of(context).WelcomeFirstUse , style: TextStyle( color: Colors.white, fontSize: 20.0) ),
                  SizedBox( height: 16.0,),
                  Text( S.of(context).Next + S.of(context).Setting + S.of(context).Pincode,  style: TextStyle( color: Colors.white, fontSize: 16.0) ),
                  SizedBox( height: 64.0,),
                  MyCustomButton(
                    label: Text( S.of(context).Next ),
                    height: 56.0,
                    width: ( ScreenSize(context).width - 64.0) / 2.0,
                    onPressed: () => Get.offAll( SendSmsPage( mode: 1 ) ),//Get.to( MyPincodePage( ) )
                  ),
                  SizedBox( height: 64.0,),
                ],

              )


            ),

             */
          ],
        ),//Text( '欢迎首次使用', style: TextStyle( fontSize: 24.0) ),
      ),
    );
    throw UnimplementedError();
  }
}