import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../ux/routing.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../general_dialog/show_general_dialog.dart';

class OnStreamingOptions extends StatefulWidget {
  final StreamerNotifier notifier;
  const OnStreamingOptions({super.key, required this.notifier});

  @override
  State<OnStreamingOptions> createState() => _OnStreamingOptionsState();
}

class _OnStreamingOptionsState extends State<OnStreamingOptions> {
  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: context.getColorScheme().background,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sixteenPx,
          Container(
            alignment: Alignment.center,
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
          ),
          CustomGesture(
              onTap: () async {
                widget.notifier.disableComment(context, mounted);
                Routing().moveBack();
              },
              margin: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(
                  textToDisplay: language.disableComments ?? 'Nonaktifkan Komentar',
                  textStyle: const TextStyle(fontSize: 14),
                ),
              )),
          Container(
            height: 2,
            width: double.infinity,
            color: kHyppeBorder,
          ),
          CustomGesture(
            onTap: () async {
              Routing().moveBack();
              if (widget.notifier.totPause < 3) {
                await ShowGeneralDialog.generalDialog(
                  context,
                  titleText: language.pauseLiveTitle ?? "Pause LIVE?",
                  bodyText: language.pauseLiveBody ?? "Your LIVE video will temporarily freeze when paused. You can pause for up to 5 minutes, 3 times.",
                  maxLineTitle: 1,
                  maxLineBody: 4,
                  functionPrimary: () async {
                    widget.notifier.pauseLive();
                    Routing().moveBack();
                  },
                  functionSecondary: () {
                    Routing().moveBack();
                  },
                  titleButtonPrimary: "${language.pause}",
                  titleButtonSecondary: "${language.cancel}",
                  barrierDismissible: true,
                  isHorizontal: false,
                );
              } else {
                await ShowGeneralDialog.generalDialog(
                  context,
                  titleText: language.youveReachedPauseLimit ?? "",
                  bodyText: language.youveReachedPauseLimitDesc ?? "",
                  maxLineTitle: 1,
                  maxLineBody: 4,
                  functionPrimary: () async {
                    Routing().moveBack();
                  },
                  titleButtonPrimary: "${language.gotIt}",
                  barrierDismissible: true,
                  isHorizontal: false,
                  fillColor: false,
                );
              }
            },
            margin: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16, bottom: 16),
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                textToDisplay: language.pauseLive ?? 'Jeda LIVE',
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
