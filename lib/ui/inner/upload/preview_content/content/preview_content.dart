import 'package:hyppe/ui/inner/upload/preview_content/widget/build_any_content_preview.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_bottom_left_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_top_widget.dart';
import 'package:flutter/material.dart';

class PreviewContent extends StatelessWidget {
  final GlobalKey? globalKey;
  final PageController pageController;
  final GlobalKey<ScaffoldState> scaffoldState;

  const PreviewContent({
    Key? key,
    required this.scaffoldState,
    this.globalKey,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Build content component
        Align(
            alignment: Alignment.center,
            child: BuildAnyContentPreviewer(
              globalKey: globalKey,
              pageController: pageController,
            )),
        // Build top component
        BuildTopWidget(globalKey: globalKey),
        // Build filters component
        // Align(
        //     alignment: const Alignment(0.95, -0.7),
        //     child: BuildFiltersWidget(
        //       scaffoldState: scaffoldState,
        //       globalKey: globalKey,
        //     )),
        // Build bottom left component
        Align(
            alignment: Alignment.bottomLeft,
            child: BuildBottomLeftWidget(
              pageController: pageController,
            )),
      ],
    );
  }
}
