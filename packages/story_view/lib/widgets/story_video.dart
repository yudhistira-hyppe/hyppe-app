import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:story_view/services/event_service.dart';
import 'package:story_view/widgets/story_loading.dart';
// import 'package:video_player/video_player.dart';

import '../utils.dart';
import '../controller/story_controller.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoLoader {
  String url;

  File? videoFile;

  Map<String, String>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    // Xulu Developer: check if file is mp4 or not, this is because download problem or something else
    if (url.toLowerCase().endsWith('.m3u8')) {
      state = LoadState.success;
      onComplete();
    } else {
      if (videoFile != null) {
        state = LoadState.success;
        onComplete();
      }

      final fileStream = DefaultCacheManager().getFileStream(url, headers: requestHeaders);

      fileStream.listen((fileResponse) {
        if (fileResponse is FileInfo) {
          if (videoFile == null) {
            state = LoadState.success;
            videoFile = fileResponse.file;
            onComplete();
          }
        }
      });
    }
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;

  /// Xulu Developer Code:
  final Color? backgroundColor;

  StoryVideo(
    this.videoLoader, {
    Key? key,
    this.backgroundColor,
    this.storyController,
  }) : super(key: key ?? UniqueKey());

  static StoryVideo url(
    String url, {
    Key? key,
    Color? backgroundColor,
    StoryController? controller,
    Map<String, String>? requestHeaders,
  }) {
    return StoryVideo(
      VideoLoader(
        url,
        requestHeaders: requestHeaders,
      ),
      key: key,
      storyController: controller,

      /// Xulu Developer Code:
      backgroundColor: backgroundColor,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  StreamSubscription? _streamSubscription;
  BetterPlayerController? playerController;
  final EventService _eventService = EventService();

  double? _width;
  double? _height;
  double? overridenAspectRatio;

  void _setupPlayerController({
    required bool isHlsVideo,
    required Function(BetterPlayerDataSource dataSource) callback,
  }) {
    BetterPlayerConfiguration betterPlayerConfiguration = const BetterPlayerConfiguration(
      fit: BoxFit.fill,
      autoPlay: false,
      showPlaceholderUntilPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        enableFullscreen: false,
        controlBarColor: Colors.black26,
      ),
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      isHlsVideo ? BetterPlayerDataSourceType.network : BetterPlayerDataSourceType.file,
      isHlsVideo ? widget.videoLoader.url : widget.videoLoader.videoFile!.path,
      headers: widget.videoLoader.requestHeaders ?? {},
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
        maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
        bufferForPlaybackMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
        bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackAfterRebufferMs,
      ),
    );

    playerController = BetterPlayerController(betterPlayerConfiguration);

    callback(dataSource);
  }

  @override
  void initState() {
    super.initState();
    widget.storyController!.pause();

    widget.videoLoader.loadVideo(() {
      if (widget.videoLoader.state == LoadState.success) {
        _setupPlayerController(
          callback: (dataSource) {
            playerController?.setupDataSource(dataSource).then((_) {
              overridenAspectRatio =
                  playerController!.videoPlayerController!.value.size!.height / playerController!.videoPlayerController!.value.size!.width;

              _width = playerController?.videoPlayerController?.value.size?.width ?? 0;
              _height = playerController?.videoPlayerController?.value.size?.height ?? 0;

              if (mounted) {
                /// Xulu code
                playerController?.setOverriddenAspectRatio(overridenAspectRatio!);
                setState(() {});
                widget.storyController?.play();
              }
            });

            playerController?.addEventsListener(
              (event) => _eventService.notifyBetterPlayerEvent(event),
            );
          },
          isHlsVideo: widget.videoLoader.url.toLowerCase().endsWith('.m3u8'),
        );

        if (widget.storyController != null && mounted) {
          _streamSubscription = widget.storyController!.playbackNotifier.listen((playbackState) {
            if (playbackState == PlaybackState.pause) {
              playerController!.pause();
            } else {
              playerController!.play();
            }
          });
        }
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Widget getContentView() {
    if (widget.videoLoader.state == LoadState.success && (playerController?.videoPlayerController?.value.initialized ?? false)) {
      // return Center(
      //   child: Platform.isAndroid
      //       ? AspectRatio(
      //           aspectRatio: overridenAspectRatio!,
      //           child: BetterPlayer(controller: playerController!),
      //         )
      //       : SizedBox.expand(
      //           child: FittedBox(
      //             fit: BoxFit.cover,
      //             child: SizedBox(
      //               width: _width,
      //               height: _height,
      //               child: BetterPlayer(controller: playerController!),
      //             ),
      //           ),
      //         ),
      // );

      return Center(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _width,
              height: _height,
              child: BetterPlayer(controller: playerController!),
            ),
          ),
        ),
      );
    }

    return const Center(
      child: StoryLoading(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      child: getContentView(),
      color: widget.backgroundColor ?? Colors.black,
    );
  }
}
