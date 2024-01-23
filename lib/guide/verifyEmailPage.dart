import 'dart:async';

//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../customWidgets.dart';
import '../homePage.dart';
import '../generated/l10n.dart';

class VerifyEmailPage extends StatefulWidget {
  VerifyEmailPage({Key? key, this.email = '', this.emailLink = ''}) : super(key: key);
  final String email;
  final String emailLink;

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {

  Completer _completer = Completer();
  Uri deepLink = Uri.parse('');

  @override
  void initState() {
    super.initState();
    //
    /*
    FirebaseDynamicLinks.instance.onLink.listen( (pendingDynamicLinkData) {
      // Set up the `onLink` event listener next as it may be received here
      deepLink = pendingDynamicLinkData.link;
      // Example of using the dynamic link to push the user to a different screen
      //Navigator.pushNamed(context, deepLink.path);
      debugPrint( 'Get Deep Link: ' + deepLink.toString() );
      _completer.complete( deepLink );
      //Get.to( () => VerifyEmailPage(email: _emailCtrl.text, emailLink: deepLink.toString() ));
    });

    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('验证邮箱'),
      ),
      //body: //verifyEmailBody(),

    );
  }

  // TODO: implement widget

  /*
  Widget verifyEmailBody(){
    return Container(
      //color: Colors.blue,
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder(
        future: _completer.future,
        builder: ( context, snapshot) {
          if ( snapshot.connectionState == ConnectionState.done )
            return FutureBuilder(
              future: confirmEmailLink( widget.email, deepLink.toString() ),
              builder: ( context, snapshot) {
                if ( snapshot.connectionState == ConnectionState.done ) {
                  if ( snapshot.data == true )
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center( child: Image.asset( 'images/authsuccess.png', ))//Text( '验证邮件成功', style: TextStyle( color: Colors.white, fontSize: 24.0),)),
                        ),
                        MyCustomButton(
                          height: 56.0,
                          width: 200.0,
                          label: Text( S.of(context).Next ),
                          onPressed: (){
                            // Next-Page
                            Get.to( () => MyHomePage(title: 'File Dog') );
                          }
                        ),
                        SizedBox( height: 64.0,),
                      ],
                    );
                  else
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center( child: Image.asset('images/authfail.png', )) //Text( '验证邮件失败', style: TextStyle( color: Colors.white, fontSize: 24.0),)),
                        ),
                        MyCustomButton(
                            height: 56.0,
                            width: 200.0,
                            label: Text( '重新发送' ),
                            onPressed: (){
                              // Next-Page
                              Get.back();
                            }
                        ),
                        SizedBox( height: 64.0,),
                      ],
                    );
                }
                else
                  return Center(
                    child: CircularPercentIndicator(
                      radius: 60.0,
                    )
                  );
              }
            );
          else
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('请使用本设备接收验证邮件，并点击邮件中的链接', style: TextStyle( color: Colors.white, fontSize: 16.0),),
                SizedBox( height: 16.0,),
                Text('请保持在这个界面，请勿退出App', style: TextStyle( color: Colors.white, fontSize: 16.0),),
              ],
            );
        }
      ),
    );
  }

   */


}