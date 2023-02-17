import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_follow_button.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';

class PicDetailTop extends StatelessWidget {
  final ContentData? data;
  final bool onDetail;

  PicDetailTop({
    Key? key,
    this.data,
    this.onDetail = true,
  }) : super(key: key);

  static final _system = System();

  var email = SharedPreference().readStorage(SpKeys.email);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    final translate = context.read<TranslateNotifierV2>().translate;

    return Container(
      width: SizeConfig.screenWidth,
      color: _themes.colorScheme.surface,
      child: Row(
        children: [
          tenPx,
          SizedBox(
            width: 30,
            child: CustomTextButton(
              onPressed: () => context.read<PicDetailNotifier>().onPop(),
              child: const DecoratedIconWidget(
                Icons.arrow_back_ios,
                color: kHyppeTextLightPrimary,
                size: 19,
              ),
            ),
          ),
          twelvePx,
          Expanded(child: _buildProfilePicture(context)),
          data != null
              ? Consumer3<PicDetailNotifier, FollowRequestUnfollowNotifier, TranslateNotifierV2>(
                  builder: (context, value, value2, value3, child) {
                    if (data?.email == email) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        value.checkIsLoading
                            ? const Center(child: SizedBox(height: 40, width: 40, child: CustomLoading()))
                            : CustomFollowButton(
                                checkIsLoading: value.checkIsLoading,
                                onPressed: () async {
                                  try {
                                    await value.followUser(context, isUnFollow: value.statusFollowing == StatusFollowing.following);
                                  } catch (e) {
                                    e.logger();
                                  }
                                },
                                isFollowing: value.statusFollowing,
                              ),
                      ],
                    );
                  },
                )
              : const Center(child: SizedBox(height: 40, child: CustomLoading())),
          data?.email != SharedPreference().readStorage(SpKeys.email)
              ? SizedBox(
                  width: 50,
                  child: CustomTextButton(
                    onPressed: () => ShowBottomSheet.onReportContent(
                      context,
                      postData: data,
                      type: hyppePic,
                      adsData: null,
                      onUpdate: () => context.read<PicDetailNotifier>().onUpdate(),
                    ),
                    child: const CustomIconWidget(
                      defaultColor: false,
                      iconData: '${AssetPath.vectorPath}more.svg',
                      color: kHyppeTextLightPrimary,
                    ),
                  ),
                )
              : const SizedBox(),
          data?.email == SharedPreference().readStorage(SpKeys.email)
              ? SizedBox(
                  width: 50,
                  child: CustomTextButton(
                    onPressed: () async {
                      if (globalAudioPlayer != null) {
                        globalAudioPlayer!.pause();
                      }
                      await ShowBottomSheet().onShowOptionContent(
                        context,
                        onDetail: onDetail,
                        contentData: data ?? ContentData(),
                        captionTitle: hyppePic,
                        onUpdate: () => context.read<PicDetailNotifier>().onUpdate(),
                        isShare: data?.isShared,
                      );
                      if (globalAudioPlayer != null) {
                        globalAudioPlayer!.seek(Duration.zero);
                        globalAudioPlayer!.resume();
                      }
                    },
                    child: const CustomIconWidget(
                      defaultColor: false,
                      iconData: '${AssetPath.vectorPath}more.svg',
                      color: kHyppeTextLightPrimary,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          data != null
              ? Consumer3<PicDetailNotifier, FollowRequestUnfollowNotifier, TranslateNotifierV2>(
                  builder: (context, value, value2, value3, child) {
                    if (data?.email == email) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        value.checkIsLoading
                            ? const Center(child: SizedBox(height: 40, child: CustomLoading()))
                            : CustomFollowButton(
                                checkIsLoading: value.checkIsLoading,
                                onPressed: () async {
                                  try {
                                    await value.followUser(context, isUnFollow: value.statusFollowing == StatusFollowing.following);
                                  } catch (e) {
                                    e.logger();
                                  }
                                },
                                isFollowing: value.statusFollowing,
                              ),
                      ],
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
          onTapOnProfileImage: () => _system.navigateToProfile(context, data?.email ?? ''),
          featureType: FeatureType.pic,
          imageUrl: '${_system.showUserPicture(data?.avatar?.mediaEndpoint)}',
          createdAt: '${_system.readTimestamp(
            DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? '')).millisecondsSinceEpoch,
            context,
            fullCaption: true,
          )}',
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
