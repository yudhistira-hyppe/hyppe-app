import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:provider/provider.dart';

import 'package:better_player/better_player.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';

import '../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
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
    final notifier = context.read<PreviewContentNotifier>();
    notifier.betterPlayerController!.dispose();
    notifier.disposeMusic();
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
    if (notifier.betterPlayerController == null) {
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
                  child: !notifier.isLoadVideo
                      ? Center(
                          child: Platform.isAndroid
                              ? AspectRatio(
                                  child: BetterPlayer(controller: notifier.betterPlayerController!),
                                  aspectRatio: notifier.betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 0,
                                )
                              : BetterPlayer(controller: notifier.betterPlayerController!),
                        )
                      : const Center(
                          child: CustomLoading(),
                        ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(left: 40, right: 40),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: const BorderRadius.all(Radius.circular(16))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: const CustomIconWidget(
                              height: 12,
                              width: 12,
                              iconData: "${AssetPath.vectorPath}close_ads.svg",
                            ),
                          ),
                          fourPx,
                          Container(
                            width: 1,
                            height: 13,
                            color: kHyppeGrey,
                          ),
                          sixPx,
                          const Expanded(
                            child: CustomTextWidget(
                              textToDisplay: 'jkldas aldkhaskjd alsdjaskla sdlakhsda hkahds aosdhka alsdjal alskdja',
                              textStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: context.getHeight() * 0.4,
                  child: InkWell(
                    onTap: () {
                      notifier.betterPlayerController?.pause();
                      ShowBottomSheet.onChooseMusic(context);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CustomIconWidget(
                          defaultColor: false,
                          iconData: "${AssetPath.vectorPath}circle_music.svg",
                        ),
                        fourPx,
                        CustomTextWidget(
                            maxLines: 1,
                            textToDisplay: notifier.language.music ?? '',
                            textAlign: TextAlign.left,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 14,
                            ))
                      ],
                    ),
                  ),
                ),
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
