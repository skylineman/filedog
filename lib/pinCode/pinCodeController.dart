import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cryptography/cryptography.dart';

class PinCodeController extends GetxController {
  late String pinCode;

  @override
  void onInit() {
    super.onInit();
    debugPrint('Init PinCodeController');
  }

  @override
  void onReady() {}

  @override
  void onClose() {}

  Future<Hash> getPinCodeSha1( String v ) => Sha1().hash( utf8.encode( v ) );

}