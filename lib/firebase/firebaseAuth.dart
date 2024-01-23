
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
//import 'package:lottie/lottie.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';

// Firebase Sign in with Email
// 国内版本无法使用

/*
Future<bool> CustomSinginWithEmail ( GlobalKey<FormState> _key, String signEmail, String signPassword ){

  final _authFirebase = FirebaseAuth.instance;

  debugPrint('Email:' + signEmail );
  debugPrint('Password:' + signPassword );

  return _authFirebase.signInWithEmailAndPassword( email: signEmail, password: signPassword )
      .then(( _userInfo ) {
    //userInfo = value;
    debugPrint('User ID 5:' + _userInfo.user!.uid);
    EasyLoading.showSuccess( 'Sign In Successfully', duration: Duration(seconds: 3), dismissOnTap: true);
    return true;
    //Get.back( result: true );
  })
      .onError(( FirebaseAuthException error, stackTrace) {
    debugPrint('Onerror: ' + error.code.toString() );
    EasyLoading.showInfo(
        AuthErrorString( error.code ),
        duration: Duration(seconds: 5),
        dismissOnTap: true
    );
    return false;
  });
}

 */

/*
Future<UserCredential> SigninWithGoogle() {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _authFirebase = FirebaseAuth.instance;

  Completer _signinState = Completer();

  _googleSignIn.signIn().then(( googleUser ) {
    if ( googleUser !=null ) {
      debugPrint('Step 1');
      debugPrint(googleUser.displayName! + ' ' + googleUser.email + ' ' + googleUser.photoUrl!);
      googleUser.authentication.then(( googleAuth ) {
        debugPrint('Step 2');
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        _authFirebase.signInWithCredential( credential ).then(( _userInfo ) {
          if ( _userInfo.user != null ) {
            //userInfo = value;
            debugPrint('User ID 4:' + _userInfo.user!.uid);
            _userInfo.user!.getIdToken().then(( value ) {
              debugPrint('User ID Token:' + value!) ;
              EasyLoading.showSuccess( 'Sign In Successfully', duration: Duration(seconds: 3), dismissOnTap: true);
              _signinState.complete( _userInfo );
            });
          }
          else
            _signinState.complete( null );
        })
            .onError((FirebaseAuthException error, stackTrace) {
          debugPrint('Onerror: ' + error.code.toString());
          EasyLoading.showInfo(
              AuthErrorString(error.code),
              duration: Duration(seconds: 5),
              dismissOnTap: true
          );
          _signinState.complete( null );
        });
      })
          .onError((FirebaseAuthException error, stackTrace) {
        debugPrint('Onerror: ' + error.code.toString());
        EasyLoading.showInfo(
            AuthErrorString(error.code),
            duration: Duration(seconds: 5),
            dismissOnTap: true
        );
        _signinState.complete( null );
      });
    }
    else
      _signinState.complete( null );

  });
  return _signinState.future as Future<UserCredential>;
}
 */

/*
String AuthErrorString( String errorString ){
  String _out;
  switch ( errorString ) {
    case 'wrong-password':
      _out = 'Password is wrong';
      break;
    case 'invalid-email':
      _out = 'Email address is invalid';
      break;
    case 'user-not-found':
      _out = 'There is no user corresponding to the given email';
      break;
    case 'too-many-requests':
      _out = 'Too many requests, Please try later';
      break;
    default:
      _out = 'Unknown Error';
      break;
  }
  return _out;
}

Future<bool> confirmEmailLink( String email, String emailLink ) async {
  // Confirm the link is a sign-in with email link.
  if (FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
    try {
// The client SDK will parse the code from the link for you.
      final userCredential = await FirebaseAuth.instance.signInWithEmailLink(email: email, emailLink: emailLink);

// You can access the new user via userCredential.user.
      curAppSetting.userEmail = (( userCredential.user?.email != null ) ? userCredential.user?.email : '')!;

      debugPrint('Get Email: $curAppSetting.userEmail');
      debugPrint('Successfully signed in with email link!');
      return true;

    } catch (error) {
      debugPrint('Error signing in with email link.' + error.toString());
      return false;
    }
  }
  else {
    debugPrint('The Link is not email link.');
    return false;
  }
}

 */

