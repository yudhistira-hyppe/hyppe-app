import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_ownership.dart';
import 'package:hyppe/ui/constant/widget/music_status_detail_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/tag_label.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/vid/see_all/vid_see_all_notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/see_all/widget/content_thumbnail.dart';

class ContentItem extends StatelessWidget {
  const ContentItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ContentItem');
    final size = MediaQuery.of(context).size;
    final notifier = context.watch<VidSeeAllNotifier>();
    // final transnot = context.read<TranslateNotifierV2>().translate;
    final error = context.select((ErrorService value) => value.getError(ErrorType.vid));

    return context.read<ErrorService>().isInitialError(error, notifier.vidData)
        ? CustomErrorWidget(
            errorType: ErrorType.vid,
            function: () => notifier.initialVid(context, reload: true),
          )
        : NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  notifier.initialVid(context);
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
                      if (notifier.vidData == null) {
                        return const CustomLoading();
                      } else if (index == notifier.vidData?.length && notifier.hasNext) {
                        return const CustomLoading();
                      }

                      final data = notifier.vidData?[index];
                      if (kDebugMode) {
                        'woy ${data?.isLiked}'.logger();
                      }
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
                                  featureType: FeatureType.vid,
                                  isCelebrity: data?.privacy?.isCelebrity,
                                  isUserVerified: data?.isIdVerified ?? false,
                                  imageUrl: '${System().showUserPicture(data?.avatar?.mediaEndpoint)}',
                                  badge: data?.urluserBadge,
                                  onTapOnProfileImage: () => System().navigateToProfile(context, data?.email ?? ''),
                                  createdAt: '${System().readTimestamp(DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? '')).millisecondsSinceEpoch, context, fullCaption: true)}',
                                  // onFollow: () async => await context.read<FollowRequestUnfollowNotifier>().followRequestUnfollowUser(
                                  //       context,
                                  //       currentValue: vidData,
                                  //       fUserId: vidData.userID,
                                  //       statusFollowing: StatusFollowing.rejected,
                                  //     ),
                                ),
                                data?.email != SharedPreference().readStorage(SpKeys.email)
                                    ? GestureDetector(
                                        onTap: () => ShowBottomSheet().onReportContent(
                                              context,
                                              postData: data,
                                              type: hyppeVid,
                                              adsData: null,
                                              onUpdate: () => context.read<VidSeeAllNotifier>().onUpdate(),
                                            ),
                                        child: const Icon(Icons.more_vert))
                                    : Container(),
                              ],
                            ),
                            twelvePx,
                            Stack(
                              children: [
                                Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: (data?.reportedStatus == "BLURRED")
                                          ? GestureDetector(
                                              onTap: () => notifier.navigateToHyppeVidDetail(context, data),
                                              child: VideoThumbnailReport(
                                                videoData: data,
                                                seeContent: false,
                                              ),
                                            )
                                          : ContentThumbnail(
                                              vidData: data,
                                              fn: () => notifier.navigateToHyppeVidDetail(context, data),
                                            ),
                                    ),
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
                                    : Container(),
                                Visibility(
                                  visible: (data?.saleAmount == 0 && (data?.certified ?? false)),
                                  child: const Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: IconOwnership(correct: true),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            (data?.tagPeople?.isNotEmpty ?? false) || data?.location != ''
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(top: 10.0),
                                    child: Row(
                                      children: [
                                        data?.tagPeople?.isNotEmpty ?? false
                                            ? TagLabel(
                                                icon: 'tag_people',
                                                label: '${data?.tagPeople?.length} people',
                                                function: () {
                                                  notifier.showUserTag(context, index);
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
                                      builder: (context, notifier, child) => InkWell(
                                        child: data?.insight?.isloading ?? false
                                            ? const SizedBox(
                                                height: 21,
                                                width: 21,
                                                child: CircularProgressIndicator(
                                                  color: kHyppePrimary,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : CustomIconWidget(
                                                defaultColor: false,
                                                color: data?.isLiked == true ? kHyppeRed : Theme.of(context).iconTheme.color,
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
