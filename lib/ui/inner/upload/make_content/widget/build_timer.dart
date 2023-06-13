import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MakeContentNotifier>(
      builder: (context, notifier, child) => AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: notifier.isVideo ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: notifier.isRecordingVideo ? true : false,
          child: SizedBox(
            width: SizeWidget().calculateSize(250, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth()),
            height: 100 * (SizeConfig.screenHeight!) / SizeWidget.baseHeightXD,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 22 * SizeConfig.scaleDiagonal,
                    width: 47 * SizeConfig.scaleDiagonal,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: false,
                    aspectRatio: 7.0,
                    disableCenter: true,
                    viewportFraction: 0.2,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: false,
                    initialPage: notifier.carouselValueIndex(),
                    onPageChanged: (index, reason) {
                      notifier.selectedDuration = notifier.durationOptions?.keys.elementAt(index) ?? 0;
                    },
                  ),
                  items: notifier.durationOptions?.values
                      .map(
                        (element) => CustomTextWidget(
                          textToDisplay: element,
                          textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppeLightButtonText),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
