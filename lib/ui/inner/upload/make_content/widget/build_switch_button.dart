import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildSwitchButton extends StatefulWidget {
  @override
  _BuildSwitchButtonState createState() => _BuildSwitchButtonState();
}

class _BuildSwitchButtonState extends State<BuildSwitchButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MakeContentNotifier>(
      builder: (context, notifier, child) => Container(
        height: 40,
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child:
            // notifier.isRecordingVideo
            //     ? Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 16 * SizeConfig.scaleDiagonal),
            //         child: Row(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Expanded(
            //               flex: 12,
            //               child: IgnorePointer(
            //                 ignoring: true,
            //                 child: Slider(
            //                   max: 1.0,
            //                   value: notifier.progressDev,
            //                   onChanged: (double value) {},
            //                   inactiveColor: kHyppeTextPrimary.withOpacity(0.5),
            //                   activeColor: Theme.of(context).colorScheme.primary,
            //                 ),
            //               ),
            //             ),
            //             fourPx,
            //             Expanded(
            //               flex: 2,
            //               child: CustomTextWidget(
            //                 textToDisplay: System().formatDuration(Duration(seconds: notifier.progressHuman).inMilliseconds),
            //                 textStyle: Theme.of(context).textTheme.bodySmall,
            //               ),
            //             )
            //           ],
            //         ),
            //       )
            //     :
            Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            notifier.featureType == FeatureType.story ||
                    notifier.featureType == FeatureType.pic
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
                        child: GestureDetector(
                          onTap: notifier.featureType == FeatureType.story &&
                                  notifier.isVideo
                              ? () => notifier.onActionChange(context, true)
                              : null,
                          child: CustomTextWidget(
                            textToDisplay: notifier.language.photo ?? '',
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      notifier.isVideo
                          ? const SizedBox.shrink()
                          : const CustomIconWidget(
                              iconData: "${AssetPath.vectorPath}spike.svg")
                    ],
                  )
                : const SizedBox.shrink(),
            (notifier.featureType != FeatureType.pic) &&
                    (notifier.featureType == FeatureType.story ||
                        notifier.featureType == FeatureType.pic)
                ? SizedBox(width: 32 * SizeConfig.scaleDiagonal)
                : const SizedBox.shrink(),
            notifier.featureType != FeatureType.pic
                ? Padding(
                    padding:
                        EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: notifier.featureType == FeatureType.story &&
                                  !notifier.isVideo
                              ? () => notifier.onActionChange(context, false)
                              : null,
                          child: CustomTextWidget(
                              textToDisplay: notifier.language.video ?? '',
                              textStyle:
                                  Theme.of(context).textTheme.bodyMedium),
                        ),
                        notifier.isVideo
                            ? const CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}spike.svg")
                            : const SizedBox.shrink()
                      ],
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
