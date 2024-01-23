import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'dart:ffi';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:android_id/android_id.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:uuid/uuid.dart';

import '../defClassandGlobal.dart';

// AES Key 前期先自定义一个固定的KEY，待后期再改写，改为随机生成

// 目前，该函数使用Android ID来生成AES KEY，仅完成一些测试工作。

Future initAesKey() {

  Completer _complete = Completer();
  var deviceUuid = AndroidId();
  deviceUuid.getId().then((value) {
    aesNonce = hexStringToIntList(Uuid().v4().replaceAll('-', '').toUpperCase());

    if (value == null || value == '' ||
        value.toUpperCase() == '9774D56D682E549C')
      value = Uuid().v4().replaceAll('-', '').toUpperCase();
    else
      value = value.toUpperCase() + value.toUpperCase(); // e5 24 25 4f f3 b0
    debugPrint('Device ID: $value ');
    //var _sha1 = Sha1();
    Sha1().hash( hexStringToIntList(value) ).then(( value ) {
      aesKey = value.bytes.sublist( 0, 16);
      debugPrint( 'Init!!! aesKey: ' + intListToHexString(aesKey, true) + '   aesNonce: ' + intListToHexString(aesNonce, true));
      _complete.complete( aesKey );
    });

  });
  return _complete.future;
}

// Init key file for ffmpeg
Future<void> initKeyFile4Ffmpeg() {

  Completer _complete = Completer();
  getApplicationSupportDirectory().then(( _dir ) {
    Sha256().hash( aesKey + aesNonce + aesKey + aesNonce ).then(( value ) {
      debugPrint( 'FFmpeg Key Source: ' + intListToHexString( aesKey + aesNonce + aesKey + aesNonce, true ));
      debugPrint ( 'FFmpeg Key: ' + intListToHexString( value.bytes, true ));
      var ffmpegKey = value.bytes.sublist( 0, 16);
      var ffmpegNonce = value.bytes.sublist( 16, 32);
      var _keyFile = File( Path.join( _dir.path, 'enc.key'));

      if ( !( _keyFile.existsSync() ) ) {
        _keyFile.createSync();
        _keyFile.writeAsBytesSync( ffmpegKey, mode: FileMode.writeOnly );
      }

      keyPath = _keyFile.path;

      var _keyInfoFile = File( Path.join( _dir.path, 'enc.keyinfo'));
      if ( !( _keyInfoFile.existsSync() ) ) {
        _keyInfoFile.createSync();
        _keyInfoFile.writeAsStringSync('$keyPath\n' + '$keyPath\n' + intListToHexString( ffmpegNonce, false ));

        //_keyInfoFile.writeAsStringSync('/data/data/com.skylineman.filedog/files/filedog.key\n' + '/data/data/com.skylineman.filedog/files/filedog.key\n' );
      }

      keyInfoPath = _keyInfoFile.path;
      _complete.complete();
    });

  });
  return _complete.future;
}

// Delete key file
Future deleteKeyFile222() {
  return getTemporaryDirectory().then(( _dir ) {
    var _keyFile = File( Path.join( _dir.path, 'enc.key'));
    var _keyInfoFile = File( Path.join( _dir.path, 'enc.keyinfo'));
    //_keyFile.deleteSync();
    //_keyInfoFile.deleteSync();
  });
}

// Read AES key From Key File
Future readAESKeyFromFile() {
  
  return getApplicationSupportDirectory().then(( _dir ) {
    var _keyFile = File( Path.join( _dir.path, 'filedog.key'));
    
    if ( _keyFile.existsSync() ) 
      aesKey = hexStringToIntList( _keyFile.readAsStringSync());
    else
      debugPrint( 'Aes Key file is not found!');


    var _keyInfoFile = File( Path.join( _dir.path, 'filedog.keyinfo'));
    if ( _keyInfoFile.existsSync() ){
      var _lines = _keyInfoFile.readAsLinesSync();
      aesNonce = hexStringToIntList( _lines.last );
    }
    else
      debugPrint( 'Aes KeyInfo file is not found!');

    debugPrint( 'Reading!!! aesKey: ' + intListToHexString(aesKey, true) + '   aesNonce: ' + intListToHexString(aesNonce, true) );
  });
}

// Write AES Key and AES Nonce to Keystore
Future writeAESKeyToKeychain() {
  FlutterSecureStorage keyStorage = FlutterSecureStorage();
  debugPrint( '!Writing!: ' + intListToHexString( aesKey, false ) + intListToHexString( aesNonce, false ));
  return keyStorage.write(key: keyValueAes, value: intListToHexString( aesKey, false ) + intListToHexString( aesNonce, false ));
}

// Read AES Key and AES Nonce from Keystore
Future readAESKeyFromKeyChain() {
  FlutterSecureStorage keyStorage = FlutterSecureStorage();
  return keyStorage.read(key: keyValueAes ).then(( _aes ) {
    //debugPrint( '!Reading!:' + _aes! );
    aesKey = hexStringToIntList( _aes!.substring(0, 32));
    aesNonce = hexStringToIntList( _aes.substring(32, 64));
    debugPrint('Reading!!! aesKey: ' + intListToHexString(aesKey, true) + '   aesNonce: ' + intListToHexString(aesNonce, true));
  });
}

int currentTimeMillis() => new DateTime.now().millisecondsSinceEpoch;

