import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_thumb_image.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class VideoThumbnail extends StatelessWidget {
  final ContentData? videoData;
  final Function fn;
  final bool onDetail;

  const VideoThumbnail({Key? key, this.videoData, required this.fn, required this.onDetail}) : super(key: key);

  static final _system = System();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Stack(
      children: [
        /// Thumbnail
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CustomThumbImage(
              onTap: () {},
              postId: videoData?.postID,
              imageUrl: '${videoData?.fullThumbPath}',
            ),
          ),
        ),

        /// Back Button & More Options
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // CustomBalloonWidget(
                //   child: Visibility(
                //     visible: onDetail,
                //     child: GestureDetector(
                //       onTap: () => Routing().moveBack(),
                //       child: CustomIconWidget(
                //         defaultColor: false,
                //         iconData: '${AssetPath.vectorPath}back-arrow.svg',
                //         color: kHyppeLightButtonText,
                //       ),
                //     ),
                //   ),
                // ),
                Visibility(
                  visible: videoData?.email == SharedPreference().readStorage(SpKeys.email),
                  child: CustomTextButton(
                    onPressed: () => ShowBottomSheet.onShowOptionContent(
                      context,
                      contentData: videoData!,
                      captionTitle: hyppeVid,
                      onDetail: onDetail,
                      onUpdate: () => onDetail ? context.read<VidDetailNotifier>().onUpdate() : context.read<HomeNotifier>().onUpdate(),
                    ),
                    child: const CustomIconWidget(
                      defaultColor: false,
                      iconData: '${AssetPath.vectorPath}more.svg',
                      color: kHyppeLightButtonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// play pause button
        Center(
          child: CustomTextButton(
            onPressed: () => fn(),
            child: const CustomIconWidget(
              defaultColor: false,
              iconData: '${AssetPath.vectorPath}pause.svg',
              color: kHyppeLightButtonText,
            ),
          ),
        ),

        /// Like count & Duration Video
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<LikeNotifier>(
                  builder: (context, value, child) {
                    return CustomBalloonWidget(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomIconWidget(
                            defaultColor: false,
                            iconData: '${AssetPath.vectorPath}like.svg',
                            color: kHyppeLightButtonText,
                          ),
                          fourPx,
                          CustomTextWidget(
                            textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeLightButtonText),
                            textToDisplay: _system.formatterNumber(videoData?.insight?.likes),
                          )
                        ],
                      ),
                    );
                  },
                ),
                CustomBalloonWidget(
                  child: CustomTextWidget(
                    textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeLightButtonText),
                    textToDisplay: System().formatDuration(Duration(seconds: videoData?.metadata?.duration ?? 0).inMilliseconds),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
