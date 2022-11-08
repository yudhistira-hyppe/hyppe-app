import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

import 'package:better_player/better_player.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';

import '../../../../constant/widget/custom_text_widget.dart';

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
    notifier.initVideoPlayer(context);
    _videoPlayerController = notifier.betterPlayerController;

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
    print('isVideoInitialized ${notifier.betterPlayerController?.isVideoInitialized()}');
    if(notifier.betterPlayerController == null){
      return const Center(
        child: CustomLoading(),
      );
    }

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
                  child: !notifier.isLoadVideo ? Center(
                    child: Platform.isAndroid
                        ? AspectRatio(
                            child: BetterPlayer(controller: notifier.betterPlayerController! ),
                            aspectRatio: notifier.betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 0,
                          )
                        : BetterPlayer(controller: notifier.betterPlayerController!),
                  ) : const Center(
                    child: CustomLoading(),
                  ),
                ),
                // Positioned(
                //   right: 16,
                //   bottom: context.getHeight() * 0.4,
                //   child: InkWell(
                //     onTap: (){
                //
                //     },
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: const [
                //         CustomIconWidget(
                //           defaultColor: false,
                //           iconData: "${AssetPath.vectorPath}circle_music.svg",
                //         ),
                //         fourPx,
                //         CustomTextWidget(maxLines: 1, textToDisplay: "Rp.0", textAlign: TextAlign.left, textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14, ))
                //       ],
                //     ),
                //   ),
                // ),
                if (!(notifier.betterPlayerController?.isPlaying() ?? false))
                  const CustomIconWidget(
                    defaultColor: false,
                    iconData: "${AssetPath.vectorPath}pause.svg",
                  )
              ],
            ),
          )
        : const Center(
            child: CustomLoading(),
          );
  }
}
