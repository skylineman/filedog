import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:chewie/chewie.dart';
import 'package:chewie/src/center_play_button.dart';
import 'package:chewie/src/helpers/utils.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:chewie/src/material/material_progress_bar.dart';
import 'package:chewie/src/material/widgets/options_dialog.dart';
import 'package:chewie/src/material/widgets/playback_speed_dialog.dart';

import 'package:video_player/video_player.dart';

///播放视频的页面
class MyPlayVideoPage extends StatefulWidget {
  MyPlayVideoPage( { Key? key, required this.videoPath, required this.videoRealName } ) : super(key: key);
  final String videoPath;
  final String videoRealName;

  @override
  _MyPlayVideoPageState createState() => _MyPlayVideoPageState();

}

// 视频播放部件

class _MyPlayVideoPageState extends State<MyPlayVideoPage> {

  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  //late final BetterPlayerController _betterPlayerController;

  //late final CustomVideoPlayerController _customVideoPlayerController;
  late Future _initializeVideoPlayerFuture;
  RxBool playState = false.obs;   // false: Pause, true: play
  RxBool ctrlPanelVisible = false.obs;
  RxBool isFullScreen = false.obs;  //

  @override
  void initState() {
    super.initState();

    debugPrint( 'Video File:' + widget.videoPath );

    _videoPlayerController = VideoPlayerController.networkUrl(   //file).networkUrl(
        Uri.parse( widget.videoPath ),
    );

    _initializeVideoPlayerFuture =  _videoPlayerController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: true,
        showOptions: false,
        autoInitialize: true,
        //fullScreenByDefault: true,
        //placeholder: Center( child: Container( width: 200.0, height: 200.0, color: Colors.blue, )),
        //overlay: Center( child: Container( width: 200.0, height: 200.0, color: Colors.red, )),
        customControls: CustomPlayerControls( videoRealName: widget.videoRealName,),
      );
    });
  }

  @override
  void dispose(){
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    color: Colors.black87,
    height: double.infinity,
    width: double.infinity,
    child: FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: ( context, AsyncSnapshot<dynamic> snapshot) {
        if ( snapshot.connectionState == ConnectionState.done ) {

          return Chewie( controller: _chewieController );

        }
        else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    ),
  );
}


class CustomPlayerControls extends StatefulWidget {
  const CustomPlayerControls({
    this.showPlayButton = true,
    this.videoRealName = '',
    Key? key,
  }) : super(key: key);

  final bool showPlayButton;
  final String videoRealName;

  @override
  State<StatefulWidget> createState() {
    return _CustomPlayerControlsState();
  }
}

class _CustomPlayerControlsState extends State<CustomPlayerControls>
    with SingleTickerProviderStateMixin {
  late PlayerNotifier notifier;
  late VideoPlayerValue _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  late var _subtitlesPosition = Duration.zero;
  bool _subtitleOn = false;
  Timer? _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = true;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;

  final barHeight = 48.0 * 1.5;
  final marginSize = 5.0;

  late VideoPlayerController controller;
  ChewieController? _chewieController;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;

  @override
  void initState() {
    super.initState();
    notifier = Provider.of<PlayerNotifier>( context, listen: false );
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder?.call(
        context,
        chewieController.videoPlayerController.value.errorDescription!,
      ) ??
          const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 42,
            ),
          );
    }

    return Container(
      //onTap: () => _cancelAndRestartTimer(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionBar(),
          if ( _displayBufferingIndicator )
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              )
            )
          else
            Expanded( child: _buildHitArea()),

          if ( !chewieController.isLive )
            Container(
              height: 24.0,
              padding: EdgeInsets.fromLTRB( 20.0, 16.0, 20.0, 16.0 ),
              child: _buildProgressBar(),
            ),
          _buildBottomBar( context ),
        ]

      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Widget _buildActionBar() {
    return SafeArea(
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayerPageBackButton(),
            Expanded(
              child: Text(
                widget.videoRealName,
                style: const TextStyle( color: Colors.white, fontSize: 16.0 ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            ),
            //Spacer(),
            if (chewieController.showOptions) _buildOptionsButton(),
          ],
        ),
      ),

    );
  }

  Widget _buildOptionsButton() {
    final options = <OptionItem>[
      OptionItem(
        onTap: () async {
          Navigator.pop(context);
          _onSpeedButtonTap();
        },
        iconData: Icons.speed,
        title: chewieController.optionsTranslation?.playbackSpeedButtonText ??
            'Playback speed',
      )
    ];

    if (chewieController.additionalOptions != null &&
        chewieController.additionalOptions!(context).isNotEmpty) {
      options.addAll(chewieController.additionalOptions!(context));
    }

    return AnimatedOpacity(
      opacity: notifier.hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: IconButton(
        onPressed: () async {
          _hideTimer?.cancel();

          if (chewieController.optionsBuilder != null) {
            await chewieController.optionsBuilder!(context, options);
          } else {
            await showModalBottomSheet<OptionItem>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: chewieController.useRootNavigator,
              builder: (context) => OptionsDialog(
                options: options,
                cancelButtonText:
                chewieController.optionsTranslation?.cancelButtonText,
              ),
            );
          }

          if (_latestValue.isPlaying) {
            _startHideTimer();
          }
        },
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubtitles(BuildContext context, Subtitles subtitles) {
    if (!_subtitleOn) {
      return const SizedBox();
    }
    final currentSubtitle = subtitles.getByPosition(_subtitlesPosition);
    if (currentSubtitle.isEmpty) {
      return const SizedBox();
    }

    if (chewieController.subtitleBuilder != null) {
      return chewieController.subtitleBuilder!(
        context,
        currentSubtitle.first!.text,
      );
    }

    return Padding(
      padding: EdgeInsets.all(marginSize),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0x96000000),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          currentSubtitle.first!.text.toString(),
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  AnimatedOpacity _buildBottomBar( BuildContext context )
  {
    final iconColor = Theme.of(context).textTheme.labelLarge!.color;

    return AnimatedOpacity(
      opacity: notifier.hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        //height: barHeight + (chewieController.isFullScreen ? 10.0 : 0),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: !chewieController.isFullScreen ? 20.0 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (chewieController.isLive)
              const Expanded(child: Text('LIVE'))
            else
              _buildPosition( iconColor ),
            if ( chewieController.allowMuting )
              _buildMuteButton( controller ),
            const Spacer(),
            if (chewieController.allowFullScreen) _buildExpandButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMuteButton( VideoPlayerController controller ) {
    return IconButton(
      onPressed: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      color: Colors.white,
      icon: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration( milliseconds: 300 ),
        child: Icon(
          _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
        ),
      ),
    );
  }


    /*
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.only(
              left: 6.0,
            ),
            child: Icon(
              _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

     */

  Widget _buildExpandButton(){
    return IconButton(
      onPressed: _onExpandCollapse,
      iconSize: 24.0,
      color: Colors.white,
      icon: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Icon(
          chewieController.isFullScreen
            ? Icons.fullscreen_exit
            : Icons.fullscreen,
        ),
      )
    );
  }

  /*
  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight + (chewieController.isFullScreen ? 15.0 : 0),
          margin: const EdgeInsets.only(right: 12.0),
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

   */

  Widget _buildHitArea() {
    final bool isFinished = _latestValue.position >= _latestValue.duration;
    final bool showPlayButton = widget.showPlayButton && !_dragging && !notifier.hideStuff;

    return GestureDetector(
      onTap: () {
        //debugPrint( 'TAP!TAP!TAP!TAP!TAP!TAP!TAP!TAP!TAP!TAP!TAP!TAP!TAP!TAP!');


          if ( !notifier.hideStuff ) {
            setState(() {
              notifier.hideStuff = true; // 透明
            });
          } else {
            _cancelAndRestartTimer();
          }



        /*
        if ( _latestValue.isPlaying ) {


          if ( !_displayTapped ) {
            setState(() {
              notifier.hideStuff = true;    // 透明
            });
          } else {
            _cancelAndRestartTimer();
          }
        } else {
          //_playPause();

          setState(() {
            notifier.hideStuff = true;      //  透明
          });
        }

         */
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: notifier.hideStuff ? 0.0 : 1.0,
              duration: const Duration( milliseconds: 300 ),
              child: IconButton(
                onPressed: () => _playerBackward( 10 ),
                iconSize: 48.0,
                icon: Icon( Icons.replay_10, color: Colors.white, )
              )
            ),
            SizedBox( width: 24.0,),
            CenterPlayButton(
              backgroundColor: Colors.black54,
              iconColor: Colors.white,
              isFinished: isFinished,
              isPlaying: controller.value.isPlaying,
              show: showPlayButton,
              onPressed: _playPause,
            ),
            SizedBox( width: 24.0,),
            AnimatedOpacity(
              opacity: notifier.hideStuff ? 0.0 : 1.0,
              duration: const Duration( milliseconds: 300 ),
              child: IconButton(
                onPressed: () => _playerForward( 10 ),
                iconSize: 48.0,
                icon: Icon( Icons.forward_10, color: Colors.white, )
              )
            ),
          ],
        )
      ),
    );
  }

  Future<void> _onSpeedButtonTap() async {
    _hideTimer?.cancel();

    final chosenSpeed = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: chewieController.useRootNavigator,
      builder: (context) => PlaybackSpeedDialog(
        speeds: chewieController.playbackSpeeds,
        selected: _latestValue.playbackSpeed,
      ),
    );

    if (chosenSpeed != null) {
      controller.setPlaybackSpeed(chosenSpeed);
    }

    if (_latestValue.isPlaying) {
      _startHideTimer();
    }
  }

  Widget _buildPosition( Color? iconColor ) {
    final position = _latestValue.position;
    final duration = _latestValue.duration;

    return RichText(
      text: TextSpan(
        text: '${formatDuration(position)} ',
        children: <InlineSpan>[
          TextSpan(
            text: '/ ${formatDuration(duration)}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white.withOpacity(.75),
              fontWeight: FontWeight.normal,
            ),
          )
        ],
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Widget _buildPlayerPageBackButton() {
    return IconButton(
      onPressed: () => chewieController.isFullScreen ? Get.back( closeOverlays: true) : Get.back(),
      icon: Icon( Icons.arrow_back),
      color: Colors.white,
    );
  }

  /*
  Widget _buildSubtitleToggle() {
    //if don't have subtitle hiden button
    if (chewieController.subtitle?.isEmpty ?? true) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: _onSubtitleTap,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          _subtitleOn
              ? Icons.closed_caption
              : Icons.closed_caption_off_outlined,
          color: _subtitleOn ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

   */

  void _onSubtitleTap() {
    setState(() {
      _subtitleOn = !_subtitleOn;
    });
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      notifier.hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<void> _initialize() async {
    _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;
    controller.addListener(_updateState);

    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          notifier.hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      notifier.hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer( const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        notifier.hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
        }
      }
    });
  }

  void _playerForward( int seconds ) {

    if( controller.value.position + Duration(seconds: seconds ) > controller.value.duration ){
      controller.seekTo( controller.value.duration );
      return;
    }
    controller.seekTo( controller.value.position + Duration(seconds: seconds ));
    setState(() {
      _cancelAndRestartTimer();
    });
  }

  void _playerBackward( int seconds ){
    if( controller.value.position - Duration(seconds: seconds ) < Duration.zero ){
      controller.seekTo( Duration.zero );
      return;
    }
    controller.seekTo( controller.value.position - Duration(seconds: seconds ));
    setState(() {
      _cancelAndRestartTimer();
    });
  }

  void _startHideTimer() {
    final hideControlsTimer = chewieController.hideControlsTimer.isNegative
        ? ChewieController.defaultHideControlsTimer
        : chewieController.hideControlsTimer;
    _hideTimer = Timer(hideControlsTimer, () {
      setState(() {
        notifier.hideStuff = true;
      });
    });
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateState() {
    if (!mounted) return;

    // display the progress bar indicator only after the buffering delay if it has been set
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }

  Widget _buildProgressBar() {
    return AnimatedOpacity(
      opacity: notifier.hideStuff ? 0.0 : 1.0,
      duration: const Duration( milliseconds: 300 ),
      child: MaterialVideoProgressBar(
        controller,
        height: 18.0,
        onDragStart: () {
          setState(() {
            _dragging = true;
          });

          _hideTimer?.cancel();
        },
        onDragUpdate: () {
          _hideTimer?.cancel();
        },
        onDragEnd: () {
          setState(() {
            _dragging = false;
          });

          _startHideTimer();
        },
        colors: chewieController.materialProgressColors ??
          ChewieProgressColors(
            playedColor: Theme.of(context).colorScheme.secondary,
            handleColor: Theme.of(context).colorScheme.secondary,
            bufferedColor:
            Theme.of(context).colorScheme.background.withOpacity(0.5),
            backgroundColor: Theme.of(context).disabledColor.withOpacity(.5),
          ),
      )
    );
  }
}
