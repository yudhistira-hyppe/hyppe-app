import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_thumbnail_report.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/see_all/widget/content_thumbnail.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/tag_label.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/pic/see_all/pic_see_all_notifier.dart';

import '../../../../../../constant/widget/music_status_detail_widget.dart';

class ContentItem extends StatelessWidget {
  const ContentItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final notifier = context.watch<PicSeeAllNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));

    return context.read<ErrorService>().isInitialError(error, notifier.picData)
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
            child: notifier.itemCount == 0
                ? const NoResultFound()
                : ListView.separated(
                    separatorBuilder: (context, index) => Container(
                      height: 1,
                      width: size.width,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    itemCount: notifier.itemCount,
                    scrollDirection: Axis.vertical,
                    controller: notifier.scrollController,
                    itemBuilder: (context, index) {
                      if (notifier.picData == null) {
                        return const CustomLoading();
                      } else if (index == notifier.picData?.length && notifier.hasNext) {
                        return const CustomLoading();
                      }

                      final data = notifier.picData?[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ProfileComponent(
                                  show: true,
                                  onFollow: () {},
                                  following: true,
                                  haveStory: false,
                                  username: data?.username,
                                  featureType: FeatureType.pic,
                                  isCelebrity: data?.privacy?.isCelebrity,
                                  imageUrl: '${System().showUserPicture(data?.avatar?.mediaEndpoint)}',
                                  onTapOnProfileImage: () => System().navigateToProfile(context, data?.email ?? '', isReplaced: false),
                                  createdAt: '${System().readTimestamp(DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? '')).millisecondsSinceEpoch, context, fullCaption: true)}',
                                ),
                                data?.email != SharedPreference().readStorage(SpKeys.email)
                                    ? GestureDetector(
                                        onTap: () => ShowBottomSheet.onReportContent(
                                              context,
                                              postData: data,
                                              type: hyppePic,
                                              adsData: null,
                                              // onUpdate: () => context.read<PicSeeAllNotifier>().onUpdate(),
                                            ),
                                        child: const Icon(Icons.more_vert))
                                    : Container(),
                              ],
                            ),
                            twelvePx,
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: (data?.reportedStatus == "BLURRED")
                                      ? GestureDetector(
                                          onTap: () => notifier.navigateToHyppePicDetail(context, data),
                                          child: PichTumbnailReport(
                                            pictData: data,
                                            seeContent: false,
                                          ),
                                        )
                                      : ContentThumbnail(
                                          picData: data,
                                          fn: () => notifier.navigateToHyppePicDetail(context, data),
                                        ),
                                ),
                                (data?.saleAmount ?? 0) > 0
                                    ? const Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: CustomIconWidget(
                                            iconData: "${AssetPath.vectorPath}sale.svg",
                                            height: 22,
                                            defaultColor: false,
                                          ),
                                        ))
                                    : Container()
                              ],
                            ),
                            (data?.tagPeople?.length ?? 0) != 0 || data?.location != ''
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 10, top: 16),
                                    child: Row(
                                      children: [
                                        (data?.tagPeople?.length ?? 0) != 0
                                            ? TagLabel(
                                                icon: 'tag_people',
                                                label: '${data?.tagPeople?.length} people ',
                                                function: () {
                                                  context.read<PicDetailNotifier>().showUserTag(context, data?.tagPeople, data?.postID);
                                                  // vidNotifier.showUserTag(context, index, data.postID);
                                                },
                                              )
                                            : const SizedBox(),
                                        data?.location == '' || data?.location == null
                                            ? const SizedBox()
                                            : TagLabel(
                                                icon: 'maptag',
                                                label: "${data?.location}",
                                                function: () {},
                                              ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            Padding(
                              padding: const EdgeInsets.only(top: 13.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 240,
                                    child: CustomDescContent(
                                      desc: "${data?.description}",
                                      trimLines: 2,
                                      textAlign: TextAlign.start,
                                      normStyle: Theme.of(context).textTheme.caption,
                                      hrefStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppePrimary),
                                    ),
                                  ),
                                  // Expanded(
                                  //   child: CustomTextWidget(
                                  //     maxLines: 2,
                                  //     textAlign: TextAlign.left,
                                  //     textToDisplay: "${data?.description} ${data?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" ")}",
                                  //     textStyle: Theme.of(context).textTheme.caption,
                                  //   ),
                                  // ),
                                  eightPx,
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Consumer<LikeNotifier>(
                                      builder: (context, notifier, child) => data?.insight?.isloading ?? false
                                          ? const SizedBox(
                                              height: 21,
                                              width: 21,
                                              child: CircularProgressIndicator(
                                                color: kHyppePrimary,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : InkWell(
                                              child: CustomIconWidget(
                                                defaultColor: false,
                                                color: data?.isLiked == true ? kHyppePrimary : Theme.of(context).iconTheme.color,
                                                iconData: '${AssetPath.vectorPath}${data?.isLiked == true ? 'liked.svg' : 'none-like.svg'}',
                                              ),
                                              onTap: () => notifier.likePost(context, data ?? ContentData()),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (data?.music?.musicTitle != null) fourPx,
                            if (data?.music?.musicTitle != null) Container(alignment: Alignment.centerLeft, child: MusicStatusDetail(music: data!.music!))
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
