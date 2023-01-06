import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:story_view/story_view.dart';

class BuildTopView extends StatefulWidget {
  final String when;
  final bool onDetail;
  final ContentData? data;
  final StoryController storyController;

  const BuildTopView({
    Key? key,
    this.data,
    required this.when,
    this.onDetail = true,
    required this.storyController,
  }) : super(key: key);

  @override
  State<BuildTopView> createState() => _BuildTopViewState();
}

class _BuildTopViewState extends State<BuildTopView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);

    return SafeArea(
      child: Container(
        width: SizeConfig.screenWidth,
        padding: const EdgeInsets.only(left: 16, top: 25.96, bottom: 25.96),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.data?.isReport ?? false
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Selector<SelfProfileNotifier, UserProfileModel?>(
                        selector: (_, select) => select.user.profile,
                        builder: (_, valueNotifier, __) {
                          return ProfileComponent(
                            isDetail: true,
                            show: true,
                            onFollow: () {},
                            following: true,
                            createdAt: widget.when,
                            isCelebrity: false,
                            onTapOnProfileImage: () => System().navigateToProfile(context, widget.data?.email ?? '', storyController: widget.storyController),
                            featureType: FeatureType.pic,
                            username: "${!notifier.isUserLoggedIn(widget.data?.email) ? widget.data?.username : valueNotifier?.username ?? ''}",
                            imageUrl: notifier.onProfilePicShow(
                              "${!notifier.isUserLoggedIn(widget.data?.email) ? widget.data?.avatar?.mediaEndpoint : valueNotifier?.avatar?.mediaEndpoint ?? ''}",
                            ),
                            // onTapOnProfileImage: () => System().navigateToProfileScreen(context, null, storyData: data, userIdStory: userID),
                          );
                        },
                      ),
                    ],
                  ),
            Row(
              children: [
                widget.data?.email == SharedPreference().readStorage(SpKeys.email)
                    ? GestureDetector(
                        onTap: () {
                          widget.storyController.pause();
                          ShowBottomSheet().onShowOptionContent(
                            context,
                            contentData: widget.data!,
                            captionTitle: hyppeStory,
                            onDetail: widget.onDetail,
                            storyController: widget.storyController,
                          );
                        },
                        child: const CustomIconWidget(
                          defaultColor: false,
                          iconData: '${AssetPath.vectorPath}more.svg',
                          color: kHyppeLightButtonText,
                        ),
                      )
                    : const SizedBox(),
                (widget.data?.isReport != true) && widget.data?.email != SharedPreference().readStorage(SpKeys.email)
                    ? GestureDetector(
                        onTap: () {
                          widget.storyController.pause();
                          ShowBottomSheet.onReportContent(
                            context,
                            postData: widget.data,
                            adsData: null,
                            type: hyppeStory,
                            onUpdate: () {
                              widget.storyController.pause();
                              context.read<StoriesPlaylistNotifier>().onUpdate();
                            },
                          );
                        },
                        child: const CustomIconWidget(
                          defaultColor: false,
                          iconData: '${AssetPath.vectorPath}more.svg',
                          color: kHyppeLightButtonText,
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomTextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.only(left: 0.0),
                      ),
                    ),
                    // onPressed: () => notifier.onCloseStory(context, arguments),
                    onPressed: () => notifier.onCloseStory(mounted),
                    child: const CustomIconWidget(
                      defaultColor: false,
                      color: kHyppeLightButtonText,
                      iconData: "${AssetPath.vectorPath}close.svg",
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
