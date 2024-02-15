import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/icon_ownership.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
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
  final bool inProfile;
  final Function()? callbackReport;
  // final StoryController? storyController;

  const TitlePlaylistDiaries({
    Key? key,
    this.data,
    this.inProfile = false,
    this.callbackReport,
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
    var lang = context.read<TranslateNotifierV2>().translate;
    return Consumer2<DiariesPlaylistNotifier, FollowRequestUnfollowNotifier>(builder: (context, ref, follRef, _) {
      final data = ref.data ?? widget.data;
      double widthUsername = _textSize(data?.username ?? '', const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)).width;
      double widthDate = _textSize(
              '${System().readTimestamp(
                DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? '')).millisecondsSinceEpoch,
                context,
                fullCaption: true,
              )}',
              const TextStyle(fontSize: 12))
          .width;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              // color: Colors.red,
              margin: const EdgeInsets.only(top: kTextTabBarHeight - 45, left: 12.0),
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              width: double.infinity,
              height: kToolbarHeight * 1.6,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
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
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ProfileComponent(
                                isFullscreen: true,
                                show: true,
                                following: true,
                                onFollow: () {},
                                widthText: (data?.username?.length ?? 0) >= 10
                                    ? 100
                                    : widthUsername > widthDate
                                        ? widthUsername
                                        : widthDate,
                                username: data?.username ?? 'No Name',
                                textColor: kHyppeLightBackground,
                                spaceProfileAndId: eightPx,
                                haveStory: false,
                                isCelebrity: false,
                                isUserVerified: data?.privacy?.isIdVerified ?? false,
                                onTapOnProfileImage: () {
                                  // fAliplayer?.setMuted(true);
                                  // fAliplayer?.pause();
                                  System().navigateToProfile(context, data?.email ?? '');
                                  setState(() {
                                    // notifier.isMute = true;
                                  });
                                },
                                featureType: FeatureType.pic,
                                imageUrl: '${System().showUserPicture(data?.avatar?.mediaEndpoint)}',
                                badge: data?.urluserBadge,
                                createdAt: '${System().readTimestamp(
                                  DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? '')).millisecondsSinceEpoch,
                                  context,
                                  fullCaption: true,
                                )}',
                              ),
                            ),
                      if(!widget.inProfile)
                      if (widget.data?.email != SharedPreference().readStorage(SpKeys.email) && (widget.data?.isNewFollowing ?? false))
                        Consumer<PreviewPicNotifier>(
                          builder: (context, picNot, child) => GestureDetector(
                            onTap: () {
                              context.handleActionIsGuest(() async {
                                if (widget.data?.insight?.isloadingFollow != true) {
                                  picNot.followUser(context, widget.data!, isUnFollow: widget.data?.following, isloading: widget.data?.insight!.isloadingFollow ?? false);
                                }
                              });
                            },
                            child: widget.data?.insight?.isloadingFollow ?? false
                                ? const SizedBox(
                                    height: 40,
                                    width: 30,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: CustomLoading(),
                                    ),
                                  )
                                : Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                      decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(8.0)),
                                      // transform: Matrix4.translationValues(-40.0, 0.0, 0.0),
                                      child: Text(
                                        (widget.data?.following ?? false) ? (lang.following ?? '') : (lang.follow ?? ''),
                                        style: const TextStyle(color: kHyppeLightButtonText, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Visibility(
                        visible: (data?.saleAmount == 0 && (data?.certified ?? false)),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: IconOwnership(correct: true),
                        ),
                      ),
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
                                  context.handleActionIsGuest(() async {
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
                                  });
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
                                  context.handleActionIsGuest(() async {
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
                                        if (widget.callbackReport != null) {
                                          widget.callbackReport!.call();
                                        }
                                      },
                                    );
                                    if (globalAliPlayer != null) {
                                      globalAliPlayer?.play();
                                    }
                                    // widget.storyController.pause();
                                  });
                                },
                                child: const CustomIconWidget(
                                  defaultColor: false,
                                  iconData: "${AssetPath.vectorPath}more.svg",
                                  color: kHyppeLightButtonText,
                                ),
                              ),
                            )
                          : const SizedBox(),

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

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
