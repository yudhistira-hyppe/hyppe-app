import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/see_all/widget/content_thumbnail.dart';
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
            child: ListView.separated(
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
                      ProfileComponent(
                        show: true,
                        onFollow: () {},
                        following: true,
                        haveStory: false,
                        username: data?.username,
                        featureType: FeatureType.pic,
                        isCelebrity: data?.privacy?.isCelebrity,
                        imageUrl: '${System().showUserPicture(data?.avatar?.mediaEndpoint)}',
                        onTapOnProfileImage: () => System().navigateToProfile(context, data!.email!),
                        createdAt: '${System().readTimestamp(DateTime.parse(data!.createdAt!).millisecondsSinceEpoch, context, fullCaption: true)}',
                        // onFollow: () async => await context.read<FollowRequestUnfollowNotifier>().followRequestUnfollowUser(
                        //       context,
                        //       currentValue: vidData,
                        //       fUserId: vidData.userID!,
                        //       statusFollowing: StatusFollowing.rejected,
                        //     ),
                      ),
                      twelvePx,
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ContentThumbnail(
                          picData: data,
                          fn: () => notifier.navigateToHyppePicDetail(context, data),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 240,
                              child: CustomTextWidget(
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                textToDisplay: data.description ?? '',
                                textStyle: Theme.of(context).textTheme.caption,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Consumer<LikeNotifier>(
                                builder: (context, notifier, child) => InkWell(
                                  child: CustomIconWidget(
                                    defaultColor: false,
                                    color: (data.insight?.isPostLiked ?? false) ? kHyppePrimary : Theme.of(context).iconTheme.color,
                                    iconData: '${AssetPath.vectorPath}${(data.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                  ),
                                  onTap: () => notifier.likePost(context, data),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
