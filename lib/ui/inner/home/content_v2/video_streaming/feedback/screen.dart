import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/summary_live_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/feedback/notifier.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../constant/widget/icon_button_widget.dart';
import '../widget/react_stream_item.dart';

class StreamingFeedbackScreen extends StatefulWidget {
  final SummaryLiveArgument? arguments;
  const StreamingFeedbackScreen({super.key, this.arguments});

  @override
  State<StreamingFeedbackScreen> createState() => _StreamingFeedbackScreenState();
}

class _StreamingFeedbackScreenState extends State<StreamingFeedbackScreen> {
  ReactStream? reactChosen;

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamingFeedbackNotifier>(builder: (context, notifier, _) {
      final language = notifier.language;
      return Scaffold(
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.topRight,
                  child: CustomIconButtonWidget(
                    height: 24,
                    width: 24,
                    onPressed: () => Routing().moveBack(),
                    iconData: '${AssetPath.vectorPath}close_ads.svg',
                  ),
                ),
                twentyPx,
                CustomTextWidget(
                  textToDisplay: language.liveVideoHasEnded ?? 'LIVE telah berakhir',
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                eightPx,
                CustomTextWidget(
                  textToDisplay:
                      '${System().dateFormatter(DateTime.now().toString(), 3)} • ${language.duration} ${widget.arguments?.duration.inMinutes} : ${(widget.arguments?.duration.inSeconds ?? 0) % 60}',
                  textStyle: const TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
                twentyPx,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBorderTab),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textToDisplay: language.engagement ?? 'Keterlibatan',
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      sixteenPx,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemStatus(language.totalViewers ?? 'Jumlah Penonton', widget.arguments?.data.totalViews.toString() ?? '0'),
                              twentyPx,
                              itemStatus(language.totalComments ?? 'Jumlah Komentar', widget.arguments?.data.totalComment.toString() ?? '0'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemStatus(language.totalShares ?? 'Jumlah Membagikan', widget.arguments?.data.totalShare.toString() ?? '0'),
                              twentyPx,
                              itemStatus(language.totalLikes ?? 'Jumlah Suka', widget.arguments?.data.totalLike.toString() ?? '0'),
                            ],
                          ),
                          itemStatus(language.newFollowers ?? 'Pengikut Baru', widget.arguments?.data.totalFollower.toString() ?? '0')
                        ],
                      ),
                    ],
                  ),
                ),
                twelvePx,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBorderTab),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                      onTap: () {
                        ShowBottomSheet.onListOfWatcher(context);
                      },
                    child:  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    CustomTextWidget(
                      textToDisplay: language.viewerList ?? 'List Penonton',
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    
                    CustomTextWidget(
                        textToDisplay: widget.arguments?.data.totalViews.toString() ?? '0',
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.getColorScheme().primary,
                        ),
                      ),
                  ]),
                  ),
                ),
                twelvePx,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBorderTab),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textToDisplay: language.howWasYourLiveExperience ?? 'Bagaimana pengalaman siaran LIVE-mu?',
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      twentyPx,
                      reactChosen != null
                          ? SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                      defaultColor: false,
                                      iconData: reactChosen == ReactStream.bad
                                          ? '${AssetPath.vectorPath}bad_active.svg'
                                          : reactChosen == ReactStream.neutral
                                              ? '${AssetPath.vectorPath}neutral_active.svg'
                                              : '${AssetPath.vectorPath}good_active.svg'),
                                  eightPx,
                                  CustomTextWidget(
                                    textToDisplay: reactChosen == ReactStream.bad
                                        ? (language.poor ?? 'Buruk')
                                        : reactChosen == ReactStream.neutral
                                            ? (language.neutral ?? 'Netral')
                                            : (language.good ?? 'Baik'),
                                    textStyle: const TextStyle(fontSize: 12, color: kHyppeBurem),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ReactStreamItem(
                                    onTap: () async {
                                      reactChosen = await ShowBottomSheet().onReactStreaming(context, ReactStream.bad, 1);
                                      setState(() {});
                                    },
                                    svg: '${AssetPath.vectorPath}bad_outline.svg',
                                    desc: (language.poor ?? 'Buruk')),
                                ReactStreamItem(
                                    onTap: () async {
                                      reactChosen = await ShowBottomSheet().onReactStreaming(context, ReactStream.neutral, 2);
                                      setState(() {});
                                    },
                                    svg: '${AssetPath.vectorPath}neutral_outline.svg',
                                    desc: (language.neutral ?? 'Netral')),
                                ReactStreamItem(
                                    onTap: () async {
                                      reactChosen = await ShowBottomSheet().onReactStreaming(context, ReactStream.good, 3);
                                      setState(() {});
                                    },
                                    svg: '${AssetPath.vectorPath}good_outline.svg',
                                    desc: (language.good ?? 'Baik'))
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget itemStatus(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          textToDisplay: title,
          textStyle: const TextStyle(fontSize: 12, color: kHyppeBurem),
        ),
        twoPx,
        CustomTextWidget(
          textToDisplay: value,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
