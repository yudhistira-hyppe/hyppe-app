import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
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
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:story_view/story_view.dart';

class TitlePlaylistDiaries extends StatefulWidget {
  final ContentData? data;
  final StoryController storyController;

  const TitlePlaylistDiaries({
    Key? key,
    this.data,
    required this.storyController,
  }) : super(key: key);

  @override
  State<TitlePlaylistDiaries> createState() => _TitlePlaylistDiariesState();
}

class _TitlePlaylistDiariesState extends State<TitlePlaylistDiaries> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: SizeConfig.screenWidth,
        padding: const EdgeInsets.only(
          left: 16,
          top: 25.96,
          right: 8.0,
          bottom: 25.96,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer2<DiariesPlaylistNotifier, FollowRequestUnfollowNotifier>(
              builder: (context, value, value2, child) {
                return ProfileComponent(
                  isDetail: true,
                  show: true,
                  onFollow: () {},
                  following: true,
                  haveStory: false,
                  onTapOnProfileImage: () => System().navigateToProfile(context, widget.data!.email!, storyController: widget.storyController),
                  username: "${widget.data?.username}",
                  spaceProfileAndId: fourteenPx,
                  featureType: FeatureType.diary,
                  imageUrl: '${System().showUserPicture(widget.data?.avatar?.mediaEndpoint)}',
                  isCelebrity: widget.data?.privacy?.isCelebrity,
                  createdAt: '${System().readTimestamp(
                    DateTime.parse(widget.data!.createdAt!).millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  )}',
                  // haveStory: data!.isHaveStory ?? false,
                  // onFollow: () async => await context
                  //     .read<FollowRequestUnfollowNotifier>()
                  //     .followRequestUnfollowUser(context, fUserId: data!.userID!, statusFollowing: StatusFollowing.rejected, currentValue: data!),
                  // username: "${data!.fullName}",
                  // isCelebrity: data!.isCelebrity,
                  // imageUrl: "${data!.profilePic}$VERYBIG",
                  // following: value.statusFollowing == StatusFollowing.following || value.statusFollowing == StatusFollowing.requested ? true : false,
                  // onTapOnProfileImage: () => context.read<DiariesPlaylistNotifier>().followUser(context),
                );
              },
            ),
            Row(
              children: [
                widget.data!.saleAmount! > 0
                    ? const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}sale.svg",
                          defaultColor: false,
                        ),
                      )
                    : const SizedBox(),
                widget.data?.email == SharedPreference().readStorage(SpKeys.email)
                    ? CustomBalloonWidget(
                        child: GestureDetector(
                          onTap: () {
                            widget.storyController.pause();
                            ShowBottomSheet.onShowOptionContent(
                              context,
                              contentData: widget.data!,
                              captionTitle: hyppeDiary,
                              storyController: widget.storyController,
                              onUpdate: () => context.read<DiariesPlaylistNotifier>().onUpdate(),
                            );
                          },
                          child: const CustomIconWidget(
                            defaultColor: false,
                            iconData: "${AssetPath.vectorPath}more.svg",
                            color: kHyppeLightButtonText,
                          ),
                        ),
                      )
                    : const SizedBox(),
                widget.data?.email != SharedPreference().readStorage(SpKeys.email)
                    ? CustomBalloonWidget(
                        child: GestureDetector(
                          onTap: () {
                            widget.storyController.pause();
                            ShowBottomSheet.onReportContent(context, widget.data, hyppeDiary);
                          },
                          child: const CustomIconWidget(
                            defaultColor: false,
                            iconData: "${AssetPath.vectorPath}more.svg",
                            color: kHyppeLightButtonText,
                          ),
                        ),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomTextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.only(left: 0.0),
                      ),
                    ),
                    onPressed: () => context.read<DiariesPlaylistNotifier>().onWillPop(mounted),
                    child: const DecoratedIconWidget(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
