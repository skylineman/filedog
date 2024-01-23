// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get Add {
    return Intl.message(
      'Add',
      name: 'Add',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get Agree {
    return Intl.message(
      'Agree',
      name: 'Agree',
      desc: '',
      args: [],
    );
  }

  /// `Agreement`
  String get Agreement {
    return Intl.message(
      'Agreement',
      name: 'Agreement',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get And {
    return Intl.message(
      'and',
      name: 'And',
      desc: '',
      args: [],
    );
  }

  /// `File Dog`
  String get appName {
    return Intl.message(
      'File Dog',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Audio`
  String get Audio {
    return Intl.message(
      'Audio',
      name: 'Audio',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get Camera {
    return Intl.message(
      'Camera',
      name: 'Camera',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message(
      'Cancel',
      name: 'Cancel',
      desc: '',
      args: [],
    );
  }

  /// `Change Passcode`
  String get ChangePasscode {
    return Intl.message(
      'Change Passcode',
      name: 'ChangePasscode',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get Close {
    return Intl.message(
      'Close',
      name: 'Close',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get Complete {
    return Intl.message(
      'Complete',
      name: 'Complete',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get Completed {
    return Intl.message(
      'Completed',
      name: 'Completed',
      desc: '',
      args: [],
    );
  }

  /// `Confirm `
  String get Confirm {
    return Intl.message(
      'Confirm ',
      name: 'Confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cover`
  String get Cover {
    return Intl.message(
      'Cover',
      name: 'Cover',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get Created {
    return Intl.message(
      'Created',
      name: 'Created',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get Default {
    return Intl.message(
      'Default',
      name: 'Default',
      desc: '',
      args: [],
    );
  }

  /// `Delete `
  String get Delete {
    return Intl.message(
      'Delete ',
      name: 'Delete',
      desc: '',
      args: [],
    );
  }

  /// `All Files in this folder will be deleted. Are you sure?`
  String get DeleteAllFiles {
    return Intl.message(
      'All Files in this folder will be deleted. Are you sure?',
      name: 'DeleteAllFiles',
      desc: '',
      args: [],
    );
  }

  /// `Disagree`
  String get Disagree {
    return Intl.message(
      'Disagree',
      name: 'Disagree',
      desc: '',
      args: [],
    );
  }

  /// `Document`
  String get Document {
    return Intl.message(
      'Document',
      name: 'Document',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get Email {
    return Intl.message(
      'Email',
      name: 'Email',
      desc: '',
      args: [],
    );
  }

  /// `Encrypt Video`
  String get EncryptVideo {
    return Intl.message(
      'Encrypt Video',
      name: 'EncryptVideo',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Passcode`
  String get EnterPasscode {
    return Intl.message(
      'Enter Your Passcode',
      name: 'EnterPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Current Passcode`
  String get EnterCurrentPasscode {
    return Intl.message(
      'Enter Your Current Passcode',
      name: 'EnterCurrentPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your New Passcode`
  String get EnterNewPasscode {
    return Intl.message(
      'Enter Your New Passcode',
      name: 'EnterNewPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get Feedback {
    return Intl.message(
      'Feedback',
      name: 'Feedback',
      desc: '',
      args: [],
    );
  }

  /// `File Dog`
  String get Filedog {
    return Intl.message(
      'File Dog',
      name: 'Filedog',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get Files {
    return Intl.message(
      'Files',
      name: 'Files',
      desc: '',
      args: [],
    );
  }

  /// `Fix`
  String get Fix {
    return Intl.message(
      'Fix',
      name: 'Fix',
      desc: '',
      args: [],
    );
  }

  /// `Folder`
  String get Folder {
    return Intl.message(
      'Folder',
      name: 'Folder',
      desc: '',
      args: [],
    );
  }

  /// `Folder Name`
  String get FolderName {
    return Intl.message(
      'Folder Name',
      name: 'FolderName',
      desc: '',
      args: [],
    );
  }

  /// `Folder Setting`
  String get FolderSetting {
    return Intl.message(
      'Folder Setting',
      name: 'FolderSetting',
      desc: '',
      args: [],
    );
  }

  /// `Follow OS`
  String get FollowOS {
    return Intl.message(
      'Follow OS',
      name: 'FollowOS',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get ForgotPassword {
    return Intl.message(
      'Forgot Password',
      name: 'ForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `hello world`
  String get hello {
    return Intl.message(
      'hello world',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get Import {
    return Intl.message(
      'Import',
      name: 'Import',
      desc: '',
      args: [],
    );
  }

  /// `Import Images or Videos`
  String get ImportImages {
    return Intl.message(
      'Import Images or Videos',
      name: 'ImportImages',
      desc: '',
      args: [],
    );
  }

  /// `is Delete Source File`
  String get isDeleteSourceFile {
    return Intl.message(
      'is Delete Source File',
      name: 'isDeleteSourceFile',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get Item {
    return Intl.message(
      'Item',
      name: 'Item',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get General {
    return Intl.message(
      'General',
      name: 'General',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get Language {
    return Intl.message(
      'Language',
      name: 'Language',
      desc: '',
      args: [],
    );
  }

  /// `Modify `
  String get Modify {
    return Intl.message(
      'Modify ',
      name: 'Modify',
      desc: '',
      args: [],
    );
  }

  /// `Modify Pincode`
  String get ModifyPincode {
    return Intl.message(
      'Modify Pincode',
      name: 'ModifyPincode',
      desc: '',
      args: [],
    );
  }

  /// `Move to Device`
  String get MoveToDevice {
    return Intl.message(
      'Move to Device',
      name: 'MoveToDevice',
      desc: '',
      args: [],
    );
  }

  /// `Moving...`
  String get Moving {
    return Intl.message(
      'Moving...',
      name: 'Moving',
      desc: '',
      args: [],
    );
  }

  /// `Moving to`
  String get Movingto {
    return Intl.message(
      'Moving to',
      name: 'Movingto',
      desc: '',
      args: [],
    );
  }

  /// `Moving Selected File to Trash`
  String get MovingToTrash {
    return Intl.message(
      'Moving Selected File to Trash',
      name: 'MovingToTrash',
      desc: '',
      args: [],
    );
  }

  /// `New Folder`
  String get NewFolder {
    return Intl.message(
      'New Folder',
      name: 'NewFolder',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get Next {
    return Intl.message(
      'Next',
      name: 'Next',
      desc: '',
      args: [],
    );
  }

  /// `No Setting`
  String get NoSetting {
    return Intl.message(
      'No Setting',
      name: 'NoSetting',
      desc: '',
      args: [],
    );
  }

  /// `Password Reset`
  String get PasswordReset {
    return Intl.message(
      'Password Reset',
      name: 'PasswordReset',
      desc: '',
      args: [],
    );
  }

  /// `Pin Code`
  String get Pincode {
    return Intl.message(
      'Pin Code',
      name: 'Pincode',
      desc: '',
      args: [],
    );
  }

  /// `Please Verify Your Fingerprint`
  String get PleaseVerifyYourFingerprint {
    return Intl.message(
      'Please Verify Your Fingerprint',
      name: 'PleaseVerifyYourFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Preparing...`
  String get Preparing {
    return Intl.message(
      'Preparing...',
      name: 'Preparing',
      desc: '',
      args: [],
    );
  }

  /// `Recover`
  String get Recovery {
    return Intl.message(
      'Recover',
      name: 'Recovery',
      desc: '',
      args: [],
    );
  }

  /// `Trash`
  String get Recycled {
    return Intl.message(
      'Trash',
      name: 'Recycled',
      desc: '',
      args: [],
    );
  }

  /// `Refuse`
  String get Refuse {
    return Intl.message(
      'Refuse',
      name: 'Refuse',
      desc: '',
      args: [],
    );
  }

  /// `Scan`
  String get Scan {
    return Intl.message(
      'Scan',
      name: 'Scan',
      desc: '',
      args: [],
    );
  }

  /// `Secrecy`
  String get Secrecy {
    return Intl.message(
      'Secrecy',
      name: 'Secrecy',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get Select {
    return Intl.message(
      'Select',
      name: 'Select',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get Setting {
    return Intl.message(
      'Setting',
      name: 'Setting',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get Signin {
    return Intl.message(
      'Sign In',
      name: 'Signin',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get Signout {
    return Intl.message(
      'Sign Out',
      name: 'Signout',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get Signup {
    return Intl.message(
      'Sign Up',
      name: 'Signup',
      desc: '',
      args: [],
    );
  }

  /// `Sign In with Email`
  String get SigninEmail {
    return Intl.message(
      'Sign In with Email',
      name: 'SigninEmail',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up with Email`
  String get SignupEmail {
    return Intl.message(
      'Sign Up with Email',
      name: 'SignupEmail',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get Skip {
    return Intl.message(
      'Skip',
      name: 'Skip',
      desc: '',
      args: [],
    );
  }

  /// ` `
  String get Space {
    return Intl.message(
      ' ',
      name: 'Space',
      desc: '',
      args: [],
    );
  }

  /// `Sweep`
  String get Sweep {
    return Intl.message(
      'Sweep',
      name: 'Sweep',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get Theme {
    return Intl.message(
      'Theme',
      name: 'Theme',
      desc: '',
      args: [],
    );
  }

  /// `Trash`
  String get Trash {
    return Intl.message(
      'Trash',
      name: 'Trash',
      desc: '',
      args: [],
    );
  }

  /// `Using Fingerprint for Login`
  String get UsingFingerprintforLogin {
    return Intl.message(
      'Using Fingerprint for Login',
      name: 'UsingFingerprintforLogin',
      desc: '',
      args: [],
    );
  }

  /// `Using Pincode for Login`
  String get UsingPincodeforLogin {
    return Intl.message(
      'Using Pincode for Login',
      name: 'UsingPincodeforLogin',
      desc: '',
      args: [],
    );
  }

  /// `Vault`
  String get Vault {
    return Intl.message(
      'Vault',
      name: 'Vault',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get Version {
    return Intl.message(
      'Version',
      name: 'Version',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get Verify {
    return Intl.message(
      'Verify',
      name: 'Verify',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your New Passcode`
  String get VerifyNewPasscode {
    return Intl.message(
      'Verify Your New Passcode',
      name: 'VerifyNewPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Welcome for First Time`
  String get WelcomeFirstUse {
    return Intl.message(
      'Welcome for First Time',
      name: 'WelcomeFirstUse',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'wrong-password' key
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
