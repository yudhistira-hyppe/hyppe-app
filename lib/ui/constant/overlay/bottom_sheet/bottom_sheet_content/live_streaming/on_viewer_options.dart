import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../ux/routing.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_spacer.dart';

class OnViewerOptions extends StatefulWidget {
  const OnViewerOptions({super.key});

  @override
  State<OnViewerOptions> createState() => _OnViewerOptionsState();
}

class _OnViewerOptionsState extends State<OnViewerOptions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewStreamingNotifier>().buttonSheetReport = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Consumer<ViewStreamingNotifier>(
      builder: (_, notifier, __) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 24),
          decoration: BoxDecoration(
            color: context.getColorScheme().background,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // tenPx,
              Container(
                alignment: Alignment.center,
                child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              ),
              fifteenPx,
              CustomGesture(
                onTap: () async {
                  Routing().moveBack();
                  notifier.reportLive(context);
                },
                margin: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  alignment: Alignment.centerLeft,
                  child: CustomTextWidget(
                    textToDisplay: language.report ?? 'Laporkan',
                    textStyle: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ),
              ),
              Container(
                height: 2,
                width: double.infinity,
                color: kHyppeBorder,
              ),
            ],
          ),
        );
      },
    );
  }
}
