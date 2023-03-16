import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../app.dart';
import '../../../../../../core/arguments/contents/vid_detail_screen_argument.dart';
import '../../../../../../core/config/ali_config.dart';
import '../../../../../../core/constants/enum.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/constants/utils.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../core/services/system.dart';
import '../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../constant/widget/custom_follow_button.dart';
import '../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../constant/widget/custom_text_button.dart';
import '../../pic/playlist/notifier.dart';
import '../player/player_page.dart';
import 'notifier.dart';

class NewVideoDetailScreen extends StatefulWidget {
  final VidDetailScreenArgument arguments;
  const NewVideoDetailScreen({Key? key, required this.arguments,}) : super(key: key);

  @override
  State<NewVideoDetailScreen> createState() => _NewVideoDetailScreenState();
}

class _NewVideoDetailScreenState extends State<NewVideoDetailScreen> with AfterFirstLayoutMixin{

  final _notifier = VidDetailNotifier();


  @override
  void afterFirstLayout(BuildContext context) {
    // context.read<VidDetailNotifier>().getDetail(context, 'c3690a7d-d6a4-47fc-c068-71a1ae4225c4');
    _notifier.initState(context, widget.arguments);
    if (widget.arguments.vidData?.certified ?? false) {
      System().block(context);
    } else {
      System().disposeBlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    var width = MediaQuery.of(context).size.width;
    var height;
    if (orientation == Orientation.portrait) {
      height = width * 9.0 / 16.0;
    } else {
      height = MediaQuery.of(context).size.height;
    }
    return Consumer<VidDetailNotifier>(
      builder: (context, notifier, _) {
        final data = notifier.data;
        var map = {
          DataSourceRelated.vidKey: widget.arguments.vidData?.apsaraId,
          DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
        };
        if(data != null){
          return Scaffold(
            body: notifier.loadDetail ? const CustomLoading() : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Column(
                    children: [
                      if (orientation == Orientation.portrait) _topDetail(context, notifier, data),
                      Container(
                        color: Colors.black,
                        child: PlayerPage(
                          playMode: (widget.arguments.vidData?.isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                          dataSourceMap: map,
                          data: widget.arguments.vidData,
                          height: height,
                          width: width,
                        ),
                      ),
                      twelvePx,
                      // overline
                      Row(
                        children: [
                          CustomTextWidget(textToDisplay: System().formatterNumber(data.insight?.views), textStyle: context.getTextTheme().overline?.copyWith(fontWeight: FontWeight.w700, color: context.getColorScheme().onBackground),),
                          twoPx,
                          CustomTextWidget(textToDisplay: '${notifier.language.views}', textStyle: context.getTextTheme().overline?.copyWith(color: context.getColorScheme().secondary)),
                        ],
                      ),
                      sixteenPx,
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }else{
          return const CustomLoading();
        }

      }
    );
  }

  Widget _topDetail(BuildContext context, VidDetailNotifier notifier, ContentData data){
    return Row(
      children: [
        GestureDetector(
            onTap:(){},
            child: const CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg')),
        sixteenPx,
        CustomProfileImage(
          width: 50,
          height: 50,
          onTap: () {},
          imageUrl: System().showUserPicture(data.avatar?.mediaEndpoint?.split('_')[0]),
          following: true,
          onFollow: () {},
        ),
        twelvePx,
        Expanded(child: Column(
          children: [
            CustomTextWidget(textToDisplay: data.username ?? 'No Username', textStyle: context.getTextTheme().caption?.copyWith(fontWeight: FontWeight.w700),),
            if(data.location != null)
              CustomTextWidget(textToDisplay: data.location ?? '', textStyle: context.getTextTheme().caption,),
            if(data.music != null)
              Row(
                children: [
                  CustomIconWidget(iconData: '${AssetPath.vectorPath}music_stroke_black.svg', color: context.getColorScheme().onBackground, defaultColor: false,),
                  fourPx,
                  CustomTextWidget(textToDisplay: '${data.music?.musicTitle} - ${data.music?.artistName}')
                ],
              ),
            eightPx,
            notifier.checkIsLoading
                ? const Center(child: SizedBox(height: 40, child: CustomLoading()))
                : CustomFollowButton(
              onPressed: () async {
                try {
                  await notifier.followUser(context, isUnFollow: notifier.statusFollowing == StatusFollowing.following);
                } catch (e) {
                  'follow error $e'.logger();
                }
              },
              isFollowing: notifier.statusFollowing,
              checkIsLoading: notifier.checkIsLoading,
            ),
            data.email != SharedPreference().readStorage(SpKeys.email)
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
            data.email == SharedPreference().readStorage(SpKeys.email)
                ? SizedBox(
              width: 50,
              child: CustomTextButton(
                onPressed: () async {
                  if (globalAudioPlayer != null) {
                    globalAudioPlayer!.pause();
                  }
                  await ShowBottomSheet().onShowOptionContent(
                    context,
                    onDetail: true,
                    contentData: data ?? ContentData(),
                    captionTitle: hyppeVid,
                    onUpdate: () => context.read<VidDetailNotifier>().onUpdate(),
                    isShare: data.isShared,
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
        ))
      ],
    );
  }

}
