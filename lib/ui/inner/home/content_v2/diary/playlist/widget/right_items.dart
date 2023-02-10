import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:provider/provider.dart';

// import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/entities/like/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

// import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

// import 'package:hyppe/ui/inner/home/content/profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';

class RightItems extends StatelessWidget {
  final ContentData data;
  const RightItems({required this.data});

  static final _system = System();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer2<DiariesPlaylistNotifier, TranslateNotifierV2>(
      builder: (_, value, value2, __) => Stack(
        children: [
          Align(
            // alignment: const Alignment(1.0, 0.10),
            alignment: Alignment.bottomRight,

            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: SizedBox(
                height: 400 * SizeConfig.scaleDiagonal,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    // Consumer<PlaylistNotifier>(
                    //   builder: (_, notifier, __) => _customIcon2(
                    //     context,
                    //     "${AssetPath.vectorPath}bookmark.svg",
                    //     value2.translate.save,
                    //     onTap: () {
                    //       context.read<DiariesPlaylistNotifier>().forcePause = true;
                    //       notifier.showMyPlaylistBottomSheet(context, index: value.currentDiary, data: data, featureType: FeatureType.diary);
                    //     },
                    //   ),
                    // ),

                    Consumer<LikeNotifier>(
                      builder: (context, notifier, child) => data.insight?.isloading ?? false
                          ? Container(
                              height: 21,
                              width: 21,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: const CircularProgressIndicator(
                                color: kHyppePrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : _customIcon2(
                              context,
                              '${AssetPath.vectorPath}${data.isLiked == true ? 'liked.svg' : 'none-like.svg'}',
                              (data.insight?.likes ?? 0) > 0 ? _system.formatterNumber((data.insight?.likes ?? 0)) : value2.translate.like ?? '',
                              colorIcon: data.isLiked == true ? kHyppePrimary : kHyppeLightButtonText,
                              onTap: () {
                                context.read<DiariesPlaylistNotifier>().forcePause = false;
                                notifier.likePost(context, data);
                              },
                            ),
                    ),
                    (data.allowComments ?? false)
                        ? _customIcon2(
                            context,
                            "${AssetPath.vectorPath}comment.svg",
                            value2.translate.comment ?? 'comment',
                            onTap: () async {
                              // if (context.read<ProfileNotifier>().myProfile != null) {
                              //   if (context.read<ProfileNotifier>().myProfile.profileOverviewData.userOverviewData.isComplete) {
                              //     context.read<DiariesPlaylistNotifier>().forcePause = true;
                              //     await ShowBottomSheet.onShowComment(context, comment: data);
                              //   } else {
                              //     ShowBottomSheet().onShowColouredSheet(context, 'Please complete your profile to comment another hyppers',
                              //         maxLines: 2, color: Theme.of(context).colorScheme.error);
                              //   }
                              // } else {
                              //   ShowBottomSheet.onShowSomethingWhenWrong(context);
                              // }
                              context.read<DiariesPlaylistNotifier>().forcePause = true;
                              ShowBottomSheet.onShowCommentV2(context, postID: data.postID);
                            },
                          )
                        : const SizedBox.shrink(),
                    if (data.isShared ?? true)
                      _customIcon2(
                        context,
                        "${AssetPath.vectorPath}share.svg",
                        value2.translate.share ?? 'share',
                        colorIcon: kHyppeLightButtonText,
                        onTap: () => value.createdDynamicLink(context, data: data),
                      ),
                    if ((data.saleAmount ?? 0) > 0 && data.email != SharedPreference().readStorage(SpKeys.email))
                      _customIcon2(
                        context,
                        "${AssetPath.vectorPath}cart.svg",
                        value2.translate.buy ?? 'buy',
                        colorIcon: kHyppeLightButtonText,
                        onTap: () async {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                          await ShowBottomSheet.onBuyContent(context, data: data);
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customIcon2(
    BuildContext context,
    String svgIcon,
    String caption, {
    Function? onTap,
    Color? colorIcon,
  }) {
    return CustomTextButton(
      onPressed: onTap,
      child: Column(
        children: <Widget>[
          CustomIconWidget(
            iconData: svgIcon,
            color: colorIcon ?? kHyppeLightButtonText,
            defaultColor: false,
          ),
          fourPx,
          CustomTextWidget(
            textToDisplay: caption,
            textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
          )
        ],
      ),
    );
  }
}
