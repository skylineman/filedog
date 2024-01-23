import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

Future<bool> checkAudioPermission() async {
  Completer<bool> _completer = Completer();

  if ( await Permission.audio.status.isGranted )
    _completer.complete( true );
  else {
    var _status = await Permission.audio.request();
    if ( _status.isGranted )
      _completer.complete( true );
    else
      _completer.complete( false );
  }
  return _completer.future;
}

Future<bool> checkPhotosAndVideoPermission() async {
  if (await Permission.videos.request().isGranted && await Permission.photos.request().isGranted ) {
    return true;
  } else {
    return false;
  }
}

