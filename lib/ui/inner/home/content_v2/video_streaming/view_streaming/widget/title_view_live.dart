import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class TitleViewLive extends StatelessWidget {
  final LinkStreamModel data;
  final int totLikes;
  final int totViews;

  const TitleViewLive({super.key, required this.data, required this.totLikes, required this.totViews});

  @override
  Widget build(BuildContext context) {
    var tn = context.read<TranslateNotifierV2>().translate;
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: leftTitle(context, tn)),
          sixteenPx,
          Expanded(flex: 2, child: rightTitle(context)),
        ],
      ),
    ));
  }

  Widget leftTitle(BuildContext context, LocalizationModelV2 tn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            ShowBottomSheet.onWatcherStatus(context, data.email ?? '', data.sId ?? '');
          },
          child: CustomProfileImage(
            cacheKey: data.avatar?.imageKey,
            following: true,
            forStory: false,
            width: 36 * SizeConfig.scaleDiagonal,
            height: 36 * SizeConfig.scaleDiagonal,
            imageUrl: System().showUserPicture(data.avatar?.mediaEndpoint ?? ''),
            // badge: notifier.user.profile?.urluserBadge,
            allwaysUseBadgePadding: false,
          ),
        ),
        sixPx,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.username ?? '',
                style: const TextStyle(
                  color: kHyppeTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${totLikes.getCountShort()} ${tn.like}",
                style: const TextStyle(
                  fontSize: 10,
                  color: kHyppeTextPrimary,
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            // ShowBottomSheet.onStreamWatchersStatus(context, notifier);
          },
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: kHyppeTextPrimary,
          ),
        )
      ],
    );
  }

  Widget rightTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(color: kHyppeDanger, borderRadius: BorderRadius.circular(3)),
          child: const Text(
            'LIVE',
            style: TextStyle(color: kHyppeTextPrimary, wordSpacing: 10),
          ),
        ),
        eightPx,
        GestureDetector(
          onTap: () {
            print('testing see views');
            final ref = context.read<StreamerNotifier>();
            ref.dataStream = data;
            print('testing see views ${ref.dataStream}');
            ShowBottomSheet.onStreamWatchersStatus(context, ref);
          },
          child: Container(
            width: 50 * context.getScaleDiagonal(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: kHyppeTransparent, borderRadius: BorderRadius.circular(3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.remove_red_eye_outlined,
                  color: kHyppeTextPrimary,
                  size: 12,
                ),
                sixPx,
                Text(
                  totViews.getCountShort(),
                  style: const TextStyle(color: kHyppeTextPrimary, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        eightPx,
        GestureDetector(
          onTap: () {
            context.read<ViewStreamingNotifier>().exitStreaming(context, data).whenComplete(() async {
              Routing().moveBack();
              await context.read<ViewStreamingNotifier>().destoryPusher();
            });
          },
          child: CustomIconWidget(
            iconData: "${AssetPath.vectorPath}close.svg",
            defaultColor: false,
          ),
        ),
        // CustomIconButtonWidget(
        //   padding: EdgeInsets.all(0),
        //   alignment: Alignment.center,
        //   iconData: "${AssetPath.vectorPath}close.svg",
        //   defaultColor: false,
        //   onPressed: () {
        //     context.read<ViewStreamingNotifier>().exitStreaming(context, data).whenComplete(() async {
        //       Routing().moveBack();
        //       await context.read<ViewStreamingNotifier>().destoryPusher();
        //     });
        //   },
        // )
      ],
    );
  }
}
