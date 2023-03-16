import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_center_item.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HyppePreviewPic extends StatefulWidget {
  const HyppePreviewPic({Key? key}) : super(key: key);

  @override
  _HyppePreviewPicState createState() => _HyppePreviewPicState();
}

class _HyppePreviewPicState extends State<HyppePreviewPic> {
  @override
  void initState() {
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    // notifier.initialPic(context, reload: true);
    notifier.scrollController.addListener(() => notifier.scrollListener(context));
    super.initState();
  }

  @override
  void dispose() {
    try {
      final notifier = context.read<PreviewPicNotifier>();
      notifier.scrollController.dispose();
    } catch (e) {
      e.logger();
    }
    super.dispose();
  }

  int _currentItem = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));

    return Consumer2<PreviewPicNotifier, HomeNotifier>(
      builder: (_, notifier, home, __) => Container(
        width: SizeConfig.screenWidth,
        height: SizeWidget.barHyppePic,
        // margin: const EdgeInsets.only(top: 16.0, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: context.read<ErrorService>().isInitialError(error, notifier.pic)
                  ? CustomErrorWidget(
                      errorType: ErrorType.pic,
                      function: () {
                        'initialPic : 4'.logger();
                        notifier.initialPic(context, reload: true);
                      },
                    )
                  : notifier.itemCount == 0
                      ? const NoResultFound()
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo is ScrollStartNotification) {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                'initialPic : 5'.logger();
                                notifier.initialPic(context);
                              });
                            }
                            return true;
                          },
                          child: NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowIndicator();
                              return false;
                            },
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,

                              // controller: notifier.scrollController,
                              // scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: false,
                              itemCount: notifier.itemCount,
                              padding: const EdgeInsets.symmetric(horizontal: 11.5),

                              itemBuilder: (context, index) {
                                if (notifier.pic == null || home.isLoadingPict) {
                                  return CustomShimmer(
                                    width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                                    height: 168,
                                    radius: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 4.5),
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                                  );
                                } else if (index == notifier.pic?.length && notifier.hasNext) {
                                  return UnconstrainedBox(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 80 * SizeConfig.scaleDiagonal,
                                      height: 80 * SizeConfig.scaleDiagonal,
                                      child: const CustomLoading(),
                                    ),
                                  );
                                }

                                return VisibilityDetector(
                                  key: Key(index.toString()),
                                  onVisibilityChanged: (info) {
                                    if (info.visibleFraction == 1)
                                      setState(() {
                                        _currentItem = index;
                                        print(_currentItem);
                                      });
                                  },
                                  child: PicCenterItem(
                                    data: notifier.pic?[index],
                                    // onTap: () => context.read<PreviewPicNotifier>().navigateToHyppePicDetail(context, notifier.pic![index]),
                                    // onTap: () => context.read<PicDetailNotifier>().navigateToDetailPic(notifier.pic![index]),
                                    onTap: () => context.read<PreviewPicNotifier>().navigateToSlidedDetailPic(context, index),
                                    // margin: const EdgeInsets.symmetric(horizontal: 4.5),
                                    lang: notifier.language,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }
}
