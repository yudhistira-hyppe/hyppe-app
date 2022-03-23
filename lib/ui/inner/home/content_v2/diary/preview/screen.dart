import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_header_feature.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/center_item_view.dart';

import 'package:hyppe/core/services/error_service.dart';

class HyppePreviewDiary extends StatefulWidget {
  const HyppePreviewDiary({Key? key}) : super(key: key);

  @override
  _HyppePreviewDiaryState createState() => _HyppePreviewDiaryState();
}

class _HyppePreviewDiaryState extends State<HyppePreviewDiary> {
  @override
  void initState() {
    final notifier = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    notifier.initialDiary(context, reload: true);
    notifier.scrollController.addListener(() => notifier.scrollListener(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = context.watch<PreviewDiaryNotifier>();
    final translateNotifier = context.watch<TranslateNotifierV2>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.diary));
    // double _result = context.read<PreviewDiaryNotifier>().scaleDiary(context) - 16 - 8;
    // _result = _result < 100
    //     ? SizeWidget.barShortVideoHomeLarge
    //     : _result;
    // final _barShortVideoHome =
    //     SizeConfig.screenHeight == SizeWidget.baseHeightXD ? SizeWidget.barShortVideoHomeSmall : _result;

    return Container(
      width: SizeConfig.screenWidth,
      margin: const EdgeInsets.only(top: 16.0),
      height: 203,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeaderFeature(
            onPressed: () => notifier.navigateToSeeAll(context),
            title: translateNotifier.translate.latestDiariesForYou!,
          ),
          eightPx,
          Expanded(
            child: context.read<ErrorService>().isInitialError(error, notifier.diaryData)
                ? CustomErrorWidget(errorType: ErrorType.diary, function: () => notifier.initialDiary(context, reload: true))
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo is ScrollStartNotification) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          notifier.initialDiary(context);
                        });
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: notifier.scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: notifier.itemCount,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemBuilder: (context, index) {
                        if (notifier.diaryData == null) {
                          return CustomShimmer(
                            width: (MediaQuery.of(context).size.width - 16.0 - 16.0 - 8) / 3,
                            height: 181,
                            radius: 8,
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          );
                        } else if (index == notifier.diaryData?.length && notifier.hasNext) {
                          return UnconstrainedBox(
                            child: Container(
                              child: const CustomLoading(),
                              alignment: Alignment.center,
                              width: 112 * SizeConfig.scaleDiagonal,
                              height: 40 * SizeConfig.scaleDiagonal,
                            ),
                          );
                        }

                        return CenterItemView(
                          data: notifier.diaryData?[index],
                          onTap: () {
                            // if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
                            context.read<PreviewDiaryNotifier>().navigateToShortVideoPlayer(context, index);
                          },
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
