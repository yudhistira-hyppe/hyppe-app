import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:better_player/better_player.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';

// import 'package:hyppe/core/constants/enum.dart';
// import 'package:video_player/video_player.dart';

class PreviewVideoContent extends StatefulWidget {
  @override
  _PreviewVideoContentState createState() => _PreviewVideoContentState();
}

class _PreviewVideoContentState extends State<PreviewVideoContent> {
  BetterPlayerController? _videoPlayerController;

  void _initVideoPlayer() async {
    final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);

    BetterPlayerConfiguration betterPlayerConfiguration = const BetterPlayerConfiguration(
      autoPlay: false,
      fit: BoxFit.contain,
      showPlaceholderUntilPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        enableFullscreen: false,
        controlBarColor: Colors.black26,
      ),
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      Platform.isIOS ? notifier.url!.replaceAll(" ", "%20") : notifier.url!,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
        maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
        bufferForPlaybackMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
        bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackAfterRebufferMs,
      ),
    );

    _videoPlayerController = BetterPlayerController(betterPlayerConfiguration);
    try {
      await _videoPlayerController?.setupDataSource(dataSource).then((_) {
        setState(() {
          _videoPlayerController?.play();
          _videoPlayerController?.setLooping(true);
          _videoPlayerController?.setOverriddenAspectRatio(_videoPlayerController!.videoPlayerController!.value.aspectRatio);
        });
      });

      // _videoPlayerController?.addEventsListener(
      //   (_) {
      //     notifier.totalDuration = _.parameters!['duration'];

      //     if (_videoPlayerController?.isVideoInitialized() ?? false) if (_videoPlayerController!.videoPlayerController!.value.position >=
      //         _videoPlayerController!.videoPlayerController!.value.duration!) {
      //       notifier.nextVideo = true;
      //     }
      //   },
      // );

      notifier.setVideoPlayerController(_videoPlayerController);
    } catch (e) {
      print('Setup data source error: $e');
    }
  }

  @override
  void initState() {
    _initVideoPlayer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = Provider.of<PreviewContentNotifier>(context);

    Future.delayed(Duration.zero, () {
      if (notifier.isForcePaused) {
        notifier.betterPlayerController?.pause();
      }
    });

    return notifier.betterPlayerController?.isVideoInitialized() ?? false
        ? GestureDetector(
            onTap: () {
              setState(() {
                if (notifier.betterPlayerController?.isPlaying() ?? false) {
                  notifier.betterPlayerController?.pause();
                } else {
                  notifier.betterPlayerController?.play();
                }
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Material(
                  child: Center(
                    child: Platform.isAndroid
                        ? AspectRatio(
                            child: BetterPlayer(controller: notifier.betterPlayerController!),
                            aspectRatio: notifier.betterPlayerController!.videoPlayerController!.value.aspectRatio,
                          )
                        : BetterPlayer(controller: notifier.betterPlayerController!),
                  ),
                ),
                if (!notifier.betterPlayerController!.isPlaying()!)
                  const CustomIconWidget(
                    defaultColor: false,
                    iconData: "${AssetPath.vectorPath}pause.svg",
                  )
              ],
            ),
          )
        : Container(
            child: const Center(
              child: CustomLoading(),
            ),
          );
  }
}
