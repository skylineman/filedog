import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

import 'defClassandGlobal.dart';

// 把视频拆分m3u8
// ffmpeg -i file1.mp4 -c:v mpeg4 file2.mp4
//

Future<dynamic> FfmpegVideo2m3u8( String sfilePath, String tPath, bool isCyptoVideo, StreamController _streamCtlr ) {

  Completer<bool> _completer = Completer();
  late String ffmpegParams;

  if ( isCyptoVideo )
    ffmpegParams = '-i ${sfilePath} -vcodec copy -acodec copy -hls_key_info_file $keyInfoPath -hls_time 10 -hls_playlist_type vod -hls_list_size 0 -hls_segment_filename ${tPath}/file%d.tss ${tPath}/playlist.m3u8';
  else
    ffmpegParams = '-i ${sfilePath} -vcodec copy -acodec copy -hls_time 10 -hls_playlist_type vod -hls_list_size 0 -hls_segment_filename ${tPath}/file%d.tsc ${tPath}/playlist.m3u8';

  Directory( tPath).watch( events: FileSystemEvent.create ).listen( ( event ) {
    _streamCtlr.sink.add( -1 );
  });

  debugPrint( 'FFMPEG: ' + ffmpegParams );
  FFmpegKit.execute( ffmpegParams ).asStream().listen( ( session ) {

    session.getReturnCode().then(( returnCode ) {
      if ( returnCode != null && returnCode.isValueSuccess() ) {
        // SUCCESS
        _streamCtlr.sink.add( -1 );
        _completer.complete( true );
      }
      else if ( returnCode != null && returnCode.isValueCancel() ) {
        // CANCEL
        _streamCtlr.sink.add( -1 );
        _completer.complete( false );
      }
      else {
        // ERROR
        _streamCtlr.sink.add( -1 );
        _completer.complete( false );
      }
    });
  });
  return _completer.future;
}

// 把m3u8合并为视频
//

Future<bool> FfmpegM3u82Video( String sFilePath, String tFilePath ) {

  Completer<bool> _completer = Completer();

  String ffmpegParams = '-allowed_extensions ALL -y -i "${sFilePath}" -vcodec copy -acodec copy ${tFilePath}';
  debugPrint( 'FFMPEG: ' + ffmpegParams );

  /*
  FFmpegKit.executeWithArguments( [ ffmpegParams ]).asStream().listen( ( session ) {

    session.getReturnCode().then(( returnCode ) {
      if ( returnCode != null && returnCode.isValueSuccess() ) {
        // SUCCESS
        _completer.complete( true );
      }
      else if ( returnCode != null && returnCode.isValueCancel() ) {
        // CANCEL
        _completer.complete( false );
      }
      else {
        // ERROR
        _completer.complete( false );
      }
    });
  });

   */

  FFmpegKit.execute( ffmpegParams ).then(( session ) {

    session.getAllLogsAsString().then(( _logs) => debugPrint( 'FFMPEG LOGS: ' + _logs.toString()) );
    session.getReturnCode().then(( returnCode ) {
      if ( returnCode != null && returnCode.isValueSuccess() ) {
        _completer.complete( true );
      }
    });
  });
  return _completer.future;

}