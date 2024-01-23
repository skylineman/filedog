import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'SelectFoldersPage.dart';
import '../generated/l10n.dart';

class MoveToDeviceHomePage extends StatefulWidget {

  MoveToDeviceHomePage({Key? key }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MoveToDeviceHomePageState createState() => _MoveToDeviceHomePageState();
}

class _MoveToDeviceHomePageState extends State<MoveToDeviceHomePage> {

  @override
  void initState() {
    super.initState();
    // Insert your code
    //getLocalIpAddress();
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
        //title: Text( S.of(context).MoveToDevice ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Image(image: AssetImage('images/movefile.png'), width: 256.0, height: 256.0,)
            ),
            SizedBox(height: 32.0),
            TextButton(
              onPressed: () => Get.to( ()=> SelectFoldersPage()),
              child: Text('Transfer'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue ),
                fixedSize: MaterialStateProperty.all<Size>(Size(256.0, 48.0)),
              ),
            ),
            SizedBox( height: 32.0,),
            TextButton(
              onPressed: (){

              },
              child: Text('Recieve'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue ),
                fixedSize: MaterialStateProperty.all<Size>(Size(256.0, 48.0)),
              ),

            ),
            SizedBox( height: 64.0 ,),

            FutureBuilder(
              future: getLocalIpAddress(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text( 'IP:' + snapshot!.data! );
                }
                else {
                  return CircularProgressIndicator();
                }
              }
            )
          ]
        ),
      )
    );
  }
}


Future<String> getLocalIpAddress() {

  Completer<String> _completer = Completer();

  NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: true).then(( interfaces ) {

    try {
      // Try VPN connection first
      NetworkInterface vpnInterface = interfaces.firstWhere((element) => element.name == "tun0");
      _completer.complete( vpnInterface.addresses.first.address );
    } on StateError {
      // Try wlan connection next
      try {
        NetworkInterface interface = interfaces.firstWhere((element) => element.name == "wlan0");
        _completer.complete( interface.addresses.first.address );
      } catch (ex) {
        // Try any other connection next
        try {
          NetworkInterface interface = interfaces.firstWhere((element) => !(element.name == "tun0" || element.name == "wlan0"));
          _completer.complete( interface.addresses.first.address );
        } catch (ex) {
          _completer.complete( null );
        }
      }
    }
  });
  return _completer.future;
}
