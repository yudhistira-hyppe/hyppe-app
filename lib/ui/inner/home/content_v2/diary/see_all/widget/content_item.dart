import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/diary/see_all/diary_see_all_notifier.dart';

class ContentItem extends StatelessWidget {
  const ContentItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DiarySeeAllNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.diary));

    return context.read<ErrorService>().isInitialError(error, notifier.diaryData)
        ? CustomErrorWidget(
            errorType: ErrorType.diary,
            function: () => notifier.initialDiary(context, reload: true),
          )
        : NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  notifier.initialDiary(context);
                });
              }

              return true;
            },
            child: notifier.itemCount == 0
                ? const NoResultFound()
                : GridView.builder(
                    itemCount: notifier.itemCount,
                    scrollDirection: Axis.vertical,
                    controller: notifier.scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.79,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      if (notifier.diaryData == null) {
                        return const CustomLoading();
                      } else if (index == notifier.diaryData?.length && notifier.hasNext) {
                        return const CustomLoading();
                      }

                      final data = notifier.diaryData?[index];
                      return InkWell(
                        onTap: () => notifier.navigateToShortVideoPlayer(context, index),
                        child: Stack(
                          children: [
                            CustomBaseCacheImage(
                              imageUrl: (data?.isApsara ?? false) ? (data?.mediaThumbEndPoint ?? '') : "${data?.fullThumbPath}",
                              imageBuilder: (context, imageProvider) => Container(
                                alignment: Alignment.bottomLeft,
                                child: CustomBalloonWidget(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CustomIconWidget(
                                        defaultColor: false,
                                        color: kHyppeLightButtonText,
                                        iconData: '${AssetPath.vectorPath}like.svg',
                                      ),
                                      fourPx,
                                      CustomTextWidget(
                                        textToDisplay: System().formatterNumber(data?.insight?.likes ?? 0),
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                                      )
                                    ],
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              emptyWidget: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            (data?.saleAmount ?? 0)  > 0
                                ? const Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 3, right: 6.0),
                                      child: CustomIconWidget(
                                        iconData: "${AssetPath.vectorPath}sale.svg",
                                        height: 20,
                                        defaultColor: false,
                                      ),
                                    ))
                                : Container(),
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
