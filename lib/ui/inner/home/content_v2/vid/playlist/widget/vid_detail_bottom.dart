import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/constants/thumb/profile_image.dart';

import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
// import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_follow_button.dart';

// import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

// import 'package:hyppe/ui/inner/home/content/profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';

class VidDetailBottom extends StatelessWidget {
  final ContentData? data;

  const VidDetailBottom({Key? key, this.data}) : super(key: key);

  static final _system = System();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    return Container(
      width: SizeConfig.screenWidth,
      color: _themes.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          twelvePx,
          _buildDescription(context),
          _buildDivider(context),
          _buildTopRightControl(context),
          fourPx,
          _buildDivider(context),
          _buildBottom(context),
          twelvePx,
        ],
      ),
    );
  }

  Widget _buildDivider(context) => Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color!.withOpacity(0.1));

  Widget _buildDescription(context) {
    return Consumer2<VidDetailNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: SizeConfig.screenWidth,
              child: data != null
                  ? CustomTextWidget(
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      textStyle: Theme.of(context).textTheme.bodyText2,
                      textToDisplay: "${data?.description} ${data?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" ")}",
                    )
                  : const CustomShimmer(height: 16, radius: 4),
            ),
            eightPx,
            data != null
                ? CustomTextWidget(
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    textStyle: Theme.of(context).textTheme.caption!.apply(color: Theme.of(context).colorScheme.secondaryVariant),
                    textToDisplay: '${_system.formatterNumber(data?.insight?.views)} ${notifier2.translate.views!}',
                  )
                : const CustomShimmer(width: 40, height: 6, radius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRightControl(BuildContext context) {
    return Consumer2<VidDetailNotifier, TranslateNotifierV2>(
      builder: (_, value, value2, __) => SizedBox(
        width: SizeConfig.screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Consumer<LikeNotifier>(
              builder: (context, notifier, child) => data != null
                  ? _buildButton(context, '${AssetPath.vectorPath}${(data?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}', "${data?.insight?.likes ?? 0}",
                      () => notifier.likePost(context, data!),
                      colorIcon: (data?.insight?.isPostLiked ?? false) ? kHyppePrimary : Theme.of(context).iconTheme.color)
                  : _buildButton(context, '${AssetPath.vectorPath}none-like.svg', "0", () {}),
            ),
            data != null
                ? (data?.allowComments ?? false)
                    ? _buildButton(
                        context,
                        '${AssetPath.vectorPath}comment.svg',
                        value2.translate.comment!,
                        () {
                          // if (context.read<ProfileNotifier>().myProfile != null) {
                          //   if (context.read<ProfileNotifier>().myProfile!.profileOverviewData!.userOverviewData.isComplete!) {
                          //     ShowBottomSheet.onShowComment(context, comment: data);
                          //   } else {
                          //     ShowBottomSheet().onShowColouredSheet(context, 'Please complete your profile to comment another hyppers',
                          //         maxLines: 2, color: Theme.of(context).colorScheme.error);
                          //   }
                          // } else {
                          //   ShowBottomSheet.onShowSomethingWhenWrong(context);
                          // }
                          ShowBottomSheet.onShowCommentV2(context, postID: data?.postID);
                        },
                      )
                    : const SizedBox.shrink()
                : const SizedBox.shrink(),
            _buildButton(
              context,
              '${AssetPath.vectorPath}share.svg',
              value2.translate.share!,
              data != null ? () => value.createdDynamicLink(context, data: data) : () {},
            ),
            // _buildButton(
            //   context,
            //   '${AssetPath.vectorPath}bookmark.svg',
            //   value2.translate.save!,
            //   data != null
            //       ? () => context.read<PlaylistNotifier>().showMyPlaylistBottomSheet(
            //             context,
            //             data: data,
            //             featureType: FeatureType.pic,
            //             index: context.read<SeeAllNotifier>().contentIndex,
            //           )
            //       : () {},
            // )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(context, String icon, String caption, Function onTap, {Color? colorIcon}) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Column(
        children: [
          CustomIconWidget(
            iconData: icon,
            defaultColor: false,
            color: colorIcon ?? Theme.of(context).appBarTheme.iconTheme!.color,
          ),
          eightPx,
          CustomTextWidget(
            textToDisplay: caption,
            textAlign: TextAlign.left,
            textStyle: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildProfilePicture(context),
          Consumer3<VidDetailNotifier, FollowRequestUnfollowNotifier, TranslateNotifierV2>(
            builder: (context, value, value2, value3, child) {
              if (data?.email == SharedPreference().readStorage(SpKeys.email)) return const SizedBox.shrink();
              return CustomFollowButton(
                caption: value3.translate.follow!,
                onPressed: () async {
                  try {
                    await value.followUser(context);
                  } catch (e) {
                    print(e);
                  }
                },
                isFollowing: value.statusFollowing,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context) => data != null
      ? ProfileComponent(
          show: true,
          following: true,
          onFollow: () {},
          username: data!.username,
          spaceProfileAndId: eightPx,
          haveStory: false,
          isCelebrity: true,
          onTapOnProfileImage: () => _system.navigateToProfile(context, data!.email!),
          featureType: FeatureType.vid,
          imageUrl: '${_system.showUserPicture(data?.avatar?.mediaEndpoint)}',
          createdAt: '${_system.readTimestamp(
            DateTime.parse(data!.createdAt!).millisecondsSinceEpoch,
            context,
            fullCaption: true,
          )}',
          // isCelebrity: data!.isCelebrity,
          // haveStory: data!.isHaveStory ?? false,
          // imageUrl: '${data!.profilePic}$VERYBIG',
          // featureType: context.read<SeeAllNotifier>().featureType!,
        )
      : Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CustomShimmer(width: 36, height: 36, boxShape: BoxShape.circle),
            sixteenPx,
            CustomShimmer(width: 84, height: 16, radius: 4),
          ],
        );
}
