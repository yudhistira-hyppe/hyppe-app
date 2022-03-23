import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_header_feature.dart';

import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_center_item.dart';

class HyppePreviewPic extends StatefulWidget {
  const HyppePreviewPic({Key? key}) : super(key: key);

  @override
  _HyppePreviewPicState createState() => _HyppePreviewPicState();
}

class _HyppePreviewPicState extends State<HyppePreviewPic> {
  @override
  void initState() {
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    notifier.initialPic(context, reload: true);
    notifier.scrollController.addListener(() => notifier.scrollListener(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));

    return Consumer<PreviewPicNotifier>(
      builder: (_, notifier, __) => Container(
        width: SizeConfig.screenWidth,
        height: SizeWidget.barHyppePic,
        margin: const EdgeInsets.only(top: 16.0, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeaderFeature(
              title: notifier.language.latestPicsForYou!,
              onPressed: () => notifier.navigateToSeeAll(context),
            ),
            eightPx,
            Expanded(
              child: context.read<ErrorService>().isInitialError(error, notifier.pic)
                  ? CustomErrorWidget(
                      errorType: ErrorType.pic,
                      function: () => notifier.initialPic(context, reload: true),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo is ScrollStartNotification) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            notifier.initialPic(context);
                          });
                        }

                        return true;
                      },
                      child: ListView.builder(
                        controller: notifier.scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: notifier.itemCount,
                        padding: const EdgeInsets.symmetric(horizontal: 11.5),
                        itemBuilder: (context, index) {
                          if (notifier.pic == null) {
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
                                child: const CustomLoading(),
                                alignment: Alignment.center,
                                width: 80 * SizeConfig.scaleDiagonal,
                                height: 80 * SizeConfig.scaleDiagonal,
                              ),
                            );
                          }

                          return PicCenterItem(
                            data: notifier.pic?[index],
                            onTap: () => context.read<PreviewPicNotifier>().navigateToHyppePicDetail(context, notifier.pic![index]),
                          );

                          // if (notifier.pic != null) {
                          //   if (notifier.pic!.data[index].isLoading == null) {
                          //     return PicCenterItem(
                          //       data: notifier.pic!.data[index],
                          //       onTap: () => context.read<PreviewPicNotifier>().navigateToHyppePicDetail(context, notifier.pic!.data[index]),
                          //     );
                          //   } else {
                          //     return CustomLoading();
                          //   }
                          // }

                          // return CustomShimmer(
                          //   width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                          //   height: 168,
                          //   radius: 8,
                          //   margin: const EdgeInsets.symmetric(horizontal: 4.5),
                          //   padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                          // );
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
