import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_ownership.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';

import '../../../../../../../app.dart';

class TitlePlaylistDiaries extends StatefulWidget {
  final ContentData? data;
  // final StoryController? storyController;

  const TitlePlaylistDiaries({
    Key? key,
    this.data,
    // this.storyController,
  }) : super(key: key);

  @override
  State<TitlePlaylistDiaries> createState() => _TitlePlaylistDiariesState();
}

class _TitlePlaylistDiariesState extends State<TitlePlaylistDiaries> with AfterFirstLayoutMixin {
  @override
  void initState() {
    context.read<DiariesPlaylistNotifier>().setData(null);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'TitlePlaylistDiaries');
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await context.read<DiariesPlaylistNotifier>().initTitleData(context, widget.data?.postID ?? '', widget.data?.visibility ?? 'PUBLIC');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer2<DiariesPlaylistNotifier, FollowRequestUnfollowNotifier>(builder: (context, ref, follRef, _) {
      final data = ref.data ?? widget.data;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: SizeConfig.screenWidth,
              padding: const EdgeInsets.only(
                left: 0,
                top: 25.96,
                right: 8.0,
                bottom: 25.96,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            // fAliplayer?.pause();

                            Routing().moveBack();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            shadows: <Shadow>[Shadow(color: Colors.black54, blurRadius: 8.0)],
                          ),
                        ),
                      ),
                      (data?.isReport ?? false)
                          ? Container()
                          : ProfileComponent(
                              isDetail: true,
                              show: true,
                              onFollow: () {},
                              following: true,
                              haveStory: false,
                              onTapOnProfileImage: () => System().navigateToProfile(context, data?.email ?? ''),
                              username: "${data?.username}",
                              spaceProfileAndId: fourteenPx,
                              featureType: FeatureType.diary,
                              imageUrl: '${System().showUserPicture(data?.avatar?.mediaEndpoint)}',
                              badge: data?.urluserBadge,
                              isCelebrity: data?.privacy?.isCelebrity,
                              isUserVerified: data?.isIdVerified ?? false,
                              createdAt: '${System().readTimestamp(
                                DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? '')).millisecondsSinceEpoch,
                                context,
                                fullCaption: true,
                              )}',
                              // haveStory: data.isHaveStory ?? false,
                              // onFollow: () async => await context
                              //     .read<FollowRequestUnfollowNotifier>()
                              //     .followRequestUnfollowUser(context, fUserId: data.userID, statusFollowing: StatusFollowing.rejected, currentValue: data),
                              // username: "${data.fullName}",
                              // isCelebrity: data.isCelebrity,
                              // imageUrl: "${data.profilePic}$VERYBIG",
                              // following: value.statusFollowing == StatusFollowing.following || value.statusFollowing == StatusFollowing.requested ? true : false,
                              // onTapOnProfileImage: () => context.read<DiariesPlaylistNotifier>().followUser(context),
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      (data?.saleAmount ?? 0) > 0
                          ? const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}sale.svg",
                                defaultColor: false,
                                height: 22,
                              ),
                            )
                          : const SizedBox(),
                      data?.email == SharedPreference().readStorage(SpKeys.email)
                          ? CustomBalloonWidget(
                              child: GestureDetector(
                                onTap: () async {
                                  // widget.storyController.pause();
                                  if (globalAliPlayer != null) {
                                    globalAliPlayer?.pause();
                                  }
                                  SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                  await ShowBottomSheet().onShowOptionContent(
                                    context,
                                    contentData: data!,
                                    captionTitle: hyppeDiary,
                                    isShare: data.isShared,
                                    onUpdate: () => context.read<DiariesPlaylistNotifier>().onUpdate(),
                                  );
                                  SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                                  if (globalAliPlayer != null) {
                                    globalAliPlayer?.play();
                                  }
                                },
                                child: const CustomIconWidget(
                                  defaultColor: false,
                                  iconData: "${AssetPath.vectorPath}more.svg",
                                  color: kHyppeLightButtonText,
                                ),
                              ),
                            )
                          : const SizedBox(),
                      data?.email != SharedPreference().readStorage(SpKeys.email)
                          ? CustomBalloonWidget(
                              child: GestureDetector(
                                onTap: () async {
                                  // widget.storyController.pause();
                                  if (globalAliPlayer != null) {
                                    globalAliPlayer?.pause();
                                  }
                                  await ShowBottomSheet().onReportContent(
                                    context,
                                    postData: data,
                                    type: hyppeDiary,
                                    adsData: null,
                                    onUpdate: () {
                                      context.read<DiariesPlaylistNotifier>().onUpdate();
                                      // widget.storyController.pause();
                                    },
                                  );
                                  if (globalAliPlayer != null) {
                                    globalAliPlayer?.play();
                                  }
                                  // widget.storyController.pause();
                                },
                                child: const CustomIconWidget(
                                  defaultColor: false,
                                  iconData: "${AssetPath.vectorPath}more.svg",
                                  color: kHyppeLightButtonText,
                                ),
                              ),
                            )
                          : const SizedBox(),
                      Visibility(
                        visible: (data?.saleAmount == 0 && (data?.certified ?? false)),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: IconOwnership(correct: true),
                        ),
                      ),
                      // SizedBox(
                      //   width: 40,
                      //   height: 40,
                      //   child: CustomTextButton(
                      //     style: ButtonStyle(
                      //       padding: MaterialStateProperty.all(
                      //         const EdgeInsets.only(left: 0.0),
                      //       ),
                      //     ),
                      //     onPressed: () => context.read<DiariesPlaylistNotifier>().onWillPop(mounted),
                      //     child: const DecoratedIconWidget(
                      //       Icons.close_rounded,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
