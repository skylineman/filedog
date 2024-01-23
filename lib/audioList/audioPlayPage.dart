import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
//import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as Path;
import 'package:just_audio/just_audio.dart';

import '../hiveDataTable/defImageInfomationClass.dart';
import '../foldersAndFiles.dart';
import '../defClassandGlobal.dart';

class AudioPlayPage extends StatefulWidget {
  AudioPlayPage({Key? key, required this.audioFilePath, required this.fileInfo }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String audioFilePath;
  final ImageFileInfo fileInfo;

  @override
  _AudioPlayPageState createState() => _AudioPlayPageState();
}

class _AudioPlayPageState extends State<AudioPlayPage> {

  AudioPlayer mPlayer = AudioPlayer();
  //late StreamSubscription _playerSubscription;
  //late StreamController _streamController;
  var _playerPos = Duration().obs;
  Duration _playerDuration = Duration();
  var _playerPause = false.obs;
  //late Future isPlayerOK;
  late List<int> audioData;


  @override
  void initState() {

    /*
    isPlayerOK = mPlayer.setFilePath( widget.audioFilePath ).then(( d ) {
      debugPrint('The Music is ' + d!.inSeconds.toString());
      _playerDuration.value = d;
      mPlayer.positionStream.listen(( d ) {
        //debugPrint( 'Duration:' + d!.inSeconds.toString());
        if ( d != null )
          _playerPos.value = d;
      });
      mPlayer.play();
    });
    */

    //mPlayer.setAudioSource( MyCustomSource( audioData )).then((value) => null);

    //ReadCyptoFile(_file)

    super.initState();
  }

  void dispose(){
    super.dispose();
    mPlayer.stop().then((_) => mPlayer.dispose());
  }

  @override
  Widget build(BuildContext context) {

    debugPrint('File Path:' + widget.audioFilePath );

    return Scaffold(
      appBar: AppBar(
        title: Text( widget.fileInfo.realBaseName ),
      ),
      body: FutureBuilder(
        future: ReadCyptoFile( File( widget.audioFilePath ) ),
        builder: ( context, AsyncSnapshot<Uint8List> snapshot ) {
          if ( snapshot.connectionState == ConnectionState.done )
            return Container(
              alignment: Alignment.center,
              child: FutureBuilder(
                future: mPlayer.setAudioSource( MyCustomSource( snapshot.data!.toList() )),
                builder: (BuildContext context, AsyncSnapshot<Duration?> snapshot1 ) {
                  if (snapshot1.connectionState == ConnectionState.done) {

                    _playerDuration = snapshot1.data!;
                    mPlayer.positionStream.listen(( _pos ) {
                      _playerPos.value = _pos;
                      //debugPrint( '!!!!!!----- POS: ' + _pos.toString() );
                    });
                    mPlayer.play();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          padding: EdgeInsets.all(16.0),
                          child: Image.asset( 'images/casestte-1280.png' ),
                          width: ScreenSize(context).width - 32.0,
                        ),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6.0,
                            // 轨道高度
                            trackShape: RectangularSliderTrackShape(),
                            // 轨道形状，可以自定义
                            activeTrackColor: Theme.of(context).primaryColor,
                            // 激活的轨道颜色
                            inactiveTrackColor: Colors.grey[500],
                            // 未激活的轨道颜色
                            thumbShape: RoundSliderThumbShape( //  滑块形状，可以自定义
                              enabledThumbRadius: 6.0, // 滑块大小
                            ),
                            thumbColor: Theme.of(context).primaryColorDark,
                            // 滑块颜色
                            overlayShape: RoundSliderOverlayShape( // 滑块外圈形状，可以自定义
                              overlayRadius: 10.0, // 滑块外圈大小
                            ),
                            overlayColor: Theme.of(context).primaryColorDark,
                            // 滑块外圈颜色
                            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                            // 标签形状，可以自定义
                            activeTickMarkColor: Colors.red, // 激活的刻度颜色
                          ),
                          child: Obx( () => Slider(
                            value: _playerPos.value.inSeconds.toDouble() / _playerDuration.inSeconds.toDouble(),
                            //minHeight: 10.0,
                            onChanged: ( v ) {

                            },
                          ))
                        ),

                        Container(
                          padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                          child: Row(
                            children: [
                              Obx(() => Text( SecondsToString( _playerPos.value.inSeconds ), style: TextStyle( fontSize: 18.0 ),)),
                              Expanded( child: SizedBox() ),
                              Text( SecondsToString( _playerDuration.inSeconds ), style: TextStyle( fontSize: 18.0 ),)
                            ],
                          ),
                        ),

                        SizedBox( height: 32.0,),
                        Container(
                          alignment: Alignment.center,
                          height: 128.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if ( _playerPos.value.inSeconds <= 10 )
                                    _playerPos.value = Duration.zero;
                                  else
                                    _playerPos.value = Duration( seconds: _playerPos.value.inSeconds - 10 );
                                  mPlayer.seek( _playerPos.value );
                                },
                                icon: Icon( Icons.replay_10 ),
                                color: Theme.of(context).primaryColorLight,
                                iconSize: 48.0,
                              ),

                              Obx(() => IconButton(
                                iconSize: 80.0,
                                color: Theme.of(context).primaryColorDark,
                                icon: ( _playerPause.value )
                                  ? Icon( Icons.play_circle_filled )
                                  : Icon( Icons.pause_circle_filled ),
                                onPressed: () {
                                  if (mPlayer.playing) {
                                    mPlayer.pause();
                                    _playerPause.value = true;
                                  }
                                  else {
                                    mPlayer.play();
                                    _playerPause.value = false;
                                  }
                                },
                              )),

                              IconButton(
                                onPressed: () {
                                  _playerPos.value = Duration( seconds: _playerPos.value.inSeconds + 10 );
                                  if ( _playerPos.value.inSeconds > _playerDuration.inSeconds )
                                    _playerPos.value = _playerDuration;
                                  mPlayer.seek(_playerPos.value);
                                },
                                icon: Icon( Icons.forward_10 ),
                                color: Theme.of(context).primaryColorLight,
                                iconSize: 48.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  else
                    return SizedBox( width: 72.0, height: 72.0, child: CircularProgressIndicator( ));
                },
              )
            );
            else
              return Container();
          }
        )
    );

    // TODO: implement build
    throw UnimplementedError();
  }
}

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource( this.bytes );

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value( bytes.sublist(start, end) ),
      contentType: 'audio/mpeg',
    );
  }
}
