import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/jangakauan_status.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/constant/widget/music_status_detail_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/tag_label.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_follow_button.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import '../../../../../../constant/widget/custom_desc_content_widget.dart';

class VidDetailBottom extends StatelessWidget {
  final ContentData? data;

  const VidDetailBottom({Key? key, this.data}) : super(key: key);

  static final _system = System();

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VidDetailBottom');
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    return Container(
      width: SizeConfig.screenWidth,
      color: _themes.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          data?.email == SharedPreference().readStorage(SpKeys.email) && (data?.reportedStatus == 'OWNED')
              ? ContentViolationWidget(
                  data: data!,
                  text: translate.thisHyppeVidisSubjectToModeration ?? '',
                )
              : Container(),
          twelvePx,
          _buildDescription(context),
          SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                  (data?.reportedStatus != 'OWNED' && data?.reportedStatus != 'BLURRED' && data?.reportedStatus2 != 'BLURRED') &&
                  (data?.boosted.isEmpty ?? [].isEmpty) &&
                  data?.email == SharedPreference().readStorage(SpKeys.email)
              ? ButtonBoost(contentData: data)
              : Container(),
          (data?.boosted.isNotEmpty ?? [].isEmpty) && data?.email == SharedPreference().readStorage(SpKeys.email) ? JangkaunStatus(jangkauan: data?.boostJangkauan ?? 0) : Container(),
          _buildDivider(context),
          _buildTopRightControl(context),
          fourPx,
          _buildDivider(context),
          // _buildBottom(context),
        ],
      ),
    );
  }

  Widget _buildDivider(context) => Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1));

  Widget _buildDescription(context) {
    return Consumer2<VidDetailNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: data != null
                  ?
                  // CustomDescContent(desc: "${data?.description}")
                  SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDescContent(
                            desc: "${data?.description}",
                            trimLines: 3,
                            textAlign: TextAlign.start,
                            seeLess: ' ${notifier2.translate.seeLess}',
                            seeMore: ' ${notifier2.translate.seeMoreContent}',
                            normStyle: Theme.of(context).textTheme.subtitle2,
                            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    )
                  : const CustomShimmer(height: 16, radius: 4),
            ),
            if (data?.music?.musicTitle != null) MusicStatusDetail(music: data!.music!),
            if (data?.music?.musicTitle != null) eightPx,
            data != null
                ? Container(
                    margin: EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () => Provider.of<LikeNotifier>(context, listen: false).viewLikeContent(context, data?.postID ?? '', 'VIEW', 'Viewer', data?.email),
                      child: CustomTextWidget(
                        maxLines: 2,
                        textAlign: TextAlign.left,
                        textStyle: Theme.of(context).textTheme.caption?.apply(color: Theme.of(context).colorScheme.secondary),
                        textToDisplay: '${_system.formatterNumber(data?.insight?.views)} ${notifier2.translate.views}',
                      ),
                    ),
                  )
                : const CustomShimmer(width: 40, height: 6, radius: 4),
            (data?.tagPeople?.isNotEmpty ?? false) || data?.location != ''
                ? Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        data?.tagPeople?.isNotEmpty ?? false
                            ? TagLabel(
                                icon: 'tag_people',
                                label: '${data?.tagPeople?.first.username}',
                                function: () {
                                  notifier.showUserTag(context, data?.tagPeople, data?.postID);
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
                  ? data?.insight?.isloading ?? false
                      ? const SizedBox(
                          height: 21,
                          width: 21,
                          child: CircularProgressIndicator(
                            color: kHyppePrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : _buildButton(context, '${AssetPath.vectorPath}${(data?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}', "${data?.insight?.likes ?? 0}",
                          () => notifier.likePost(context, data ?? ContentData()),
                          colorIcon: (data?.insight?.isPostLiked ?? false) ? kHyppeRed : Theme.of(context).iconTheme.color)
                  : _buildButton(context, '${AssetPath.vectorPath}none-like.svg', "0", () {}),
            ),
            if (data?.allowComments ?? true)
              _buildButton(
                context,
                '${AssetPath.vectorPath}comment.svg',
                value2.translate.comment ?? '',
                () {
                  ShowBottomSheet.onShowCommentV2(context, postID: data?.postID);
                },
              ),
            if ((data?.isShared ?? true) && data?.visibility == 'PUBLIC')
              _buildButton(
                context,
                '${AssetPath.vectorPath}share.svg',
                value2.translate.share ?? '',
                data != null ? () => value.createdDynamicLink(context, data: data) : () {},
              ),
            if (data != null)
              if ((data?.saleAmount ?? 0) > 0 && SharedPreference().readStorage(SpKeys.email) != data?.email)
                _buildButton(
                  context,
                  '${AssetPath.vectorPath}cart.svg',
                  value2.translate.buy ?? '',
                  () async {
                    await context.handleActionIsGuest(() async {
                      globalAliPlayer?.pause();
                      ShowBottomSheet.onBuyContent(context, data: data);
                    });
                  },
                ),
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
            color: colorIcon ?? Theme.of(context).appBarTheme.iconTheme?.color,
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
          data != null
              ? Consumer3<VidDetailNotifier, FollowRequestUnfollowNotifier, TranslateNotifierV2>(
                  builder: (context, value, value2, value3, child) {
                    if (data?.email == SharedPreference().readStorage(SpKeys.email)) return const SizedBox.shrink();
                    return value.checkIsLoading
                        ? const Center(child: SizedBox(height: 40, child: CustomLoading()))
                        : CustomFollowButton(
                            onPressed: () async {
                              try {
                                await value.followUser(context, isUnFollow: value.statusFollowing == StatusFollowing.following);
                              } catch (e) {
                                'follow error $e'.logger();
                              }
                            },
                            isFollowing: value.statusFollowing,
                            checkIsLoading: value.checkIsLoading,
                          );
                  },
                )
              : const Center(child: SizedBox(height: 40, child: CustomLoading())),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context) => data != null
      ? ProfileComponent(
          show: true,
          following: true,
          onFollow: () {},
          username: data?.username,
          spaceProfileAndId: eightPx,
          haveStory: false,

          isCelebrity: false,
          isUserVerified: data?.isIdVerified ?? false,
          onTapOnProfileImage: () => _system.navigateToProfile(context, data?.email ?? ''),

          featureType: FeatureType.vid,
          imageUrl: '${_system.showUserPicture(data?.avatar?.mediaEndpoint)}',
          badge: data?.urluserBadge,
          createdAt: '${_system.readTimestamp(
            DateTime.parse(_system.dateTimeRemoveT(data?.createdAt ?? '')).millisecondsSinceEpoch,
            context,
            fullCaption: true,
          )}',
          // isCelebrity: data.isCelebrity,
          // haveStory: data.isHaveStory ?? false,
          // imageUrl: '${data.profilePic}$VERYBIG',
          // featureType: context.read<SeeAllNotifier>().featureType,
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
