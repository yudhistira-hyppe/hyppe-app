import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_any_content_preview.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_top_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../core/constants/size_config.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../constant/widget/custom_loading.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../notifier.dart';
import '../widget/build_bottom_left_widget.dart';

class PreviewContent extends StatefulWidget {
  final GlobalKey? globalKey;
  final PageController pageController;
  final GlobalKey<ScaffoldState> scaffoldState;

  const PreviewContent({
    super.key,
    required this.scaffoldState,
    this.globalKey,
    required this.pageController,
  });

  @override
  State<PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<PreviewContent> with AfterFirstLayoutMixin{
  @override
  void initState() {
    context.read<PreviewContentNotifier>().stickers.clear();
    context.read<PreviewContentNotifier>().onScreenStickers.clear();
    WakelockPlus.enable();
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<PreviewContentNotifier>();
    Future.delayed(Duration.zero, () async{
      notifier.fileContent?[0];
    });
  }

  @override
  void dispose() {

    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);

    return Stack(
      children: [
        // Build content component
        Opacity(
          opacity: 0,
          child: Align(
            alignment: Alignment.center,
            child: notifier.isLoadVideo
                ? Container(
                    width: 80.0 * SizeConfig.scaleDiagonal,
                    height: 80.0 * SizeConfig.scaleDiagonal,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: const Color(0xff822E6E), width: 2.0),
                      color: Theme.of(context).backgroundColor,
                    ),
                    alignment: Alignment.center,
                    child: const CustomLoading(),
                  )
                : BuildBottomLeftWidget(pageController: widget.pageController),
          ),
        ),
        Center(
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: context.getHeight(),
            // height: notifier.featureType == FeatureType.story ||
            //         notifier.featureType == FeatureType.diary
            //     ? MediaQuery.of(context).size.width * (16 / 9)
            //     : null,
            child: BuildAnyContentPreviewer(
              globalKey: widget.globalKey,
              pageController: widget.pageController,
            ),
          ),
        ),
        Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: BuildTopWidget(globalKey: widget.globalKey)),
        if(notifier.showToastLimit)
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: context.getWidth() * 0.7,
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kHyppeTextLightPrimary),
              child: CustomTextWidget(
                textToDisplay: notifier.featureType == FeatureType.vid ? (notifier.language.messageLimitVideo ?? 'Error') : notifier.featureType == FeatureType.diary ? (notifier.language.messageLimitDiary ?? 'Error') : 'Error',
                textStyle: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
            ))
        // Build filters component
        // Align(
        //     alignment: const Alignment(0.95, -0.7),
        //     child: BuildFiltersWidget(
        //       scaffoldState: scaffoldState,
        //       globalKey: globalKey,
        //     )),
        // Build bottom left component
      ],
    );
  }


}
