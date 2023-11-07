import 'dart:convert';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_any_content_preview.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_bottom_left_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_filters_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_sticker_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_top_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/size_config.dart';
import '../notifier.dart';

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

class _PreviewContentState extends State<PreviewContent> {
  @override
  void initState() {
    context.read<PreviewContentNotifier>().stickers.clear();
    context.read<PreviewContentNotifier>().onScreenStickers.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);

    return Stack(
      children: [
        // Build content component
        Align(
          alignment: Alignment.center,
          child: notifier.isLoadVideo
              ? Container(
                  width: 80.0 * SizeConfig.scaleDiagonal,
                  height: 80.0 * SizeConfig.scaleDiagonal,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border:
                        Border.all(color: const Color(0xff822E6E), width: 2.0),
                    color: Theme.of(context).backgroundColor,
                  ),
                  alignment: Alignment.center,
                  child: const CustomLoading(),
                )
              : BuildBottomLeftWidget(pageController: widget.pageController),
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
        BuildTopWidget(globalKey: widget.globalKey),
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
