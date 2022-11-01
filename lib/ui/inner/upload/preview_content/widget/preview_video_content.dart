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

  @override
  void initState() {
    final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
    if(notifier.betterPlayerController == null){
      notifier.initVideoPlayer(context);
    }

    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
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
    if(notifier.betterPlayerController == null){
      return const Center(
        child: CustomLoading(),
      );
    }
    print('isVideoInitialized ${notifier.betterPlayerController?.isVideoInitialized()}');
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
