import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:url_launcher/url_launcher.dart';

class TitleViewLive extends StatelessWidget {
  final FlutterAliplayer? fAliplayer;
  final LinkStreamModel data;
  final int totLikes;
  final int totViews;

  const TitleViewLive({super.key, required this.data, required this.totLikes, required this.totViews, this.fAliplayer});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                ShowBottomSheet.onWatcherStatus(context, data.email ?? '', data.sId ?? '', isViewer: true);
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
            // Flexible(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         (data.title?.isNotEmpty ?? false) ? (data.title ?? '') : (data.username ?? ''),
            //         style: const TextStyle(
            //           color: kHyppeTextPrimary,
            //           fontWeight: FontWeight.w700,
            //         ),
            //         maxLines: 1,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //       Text(
            //         "${totLikes.getCountShort()} ${tn.like}",
            //         style: const TextStyle(
            //           fontSize: 10,
            //           color: kHyppeTextPrimary,
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                // ShowBottomSheet.onStreamWatchersStatus(context, notifier);
                final ref = context.read<StreamerNotifier>();
                ref.dataStream = data;
                ref.titleLive = data.title ?? '';
                ref.userName = data.username ?? '';
                ShowBottomSheet.onStreamWatchersStatus(context, true, ref);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    // width: 86,
                    constraints: BoxConstraints(maxWidth: 86),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (data.title?.isNotEmpty ?? false) ? (data.title ?? '') : (data.username ?? ''),
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
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: kHyppeTextPrimary,
                  )
                ],
              ),
            )
          ],
        ),
        twelvePx,
        GestureDetector(
          onTap: () async {
            var uri = data.urlLink??'';
            if (!uri.withHttp()){
              uri='https://$uri';
            }
            if (await canLaunchUrl(Uri.parse(uri))) {
                await launchUrl(Uri.parse(uri));
              } else {
                throw  Fluttertoast.showToast(msg: 'Could not launch $uri');
              }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.4),
            ),
            child: Text(data.textUrl??data.urlLink??'Klik disini ya!', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
        if (totViews > 0)
          GestureDetector(
            onTap: () {
              print('testing see views');
              final ref = context.read<StreamerNotifier>();
              ref.dataStream = data;
              print('testing see views ${ref.dataStream}');
              ref.titleLive = data.title ?? '';
              ref.userName = data.username ?? '';
              ShowBottomSheet.onStreamWatchersStatus(context, true, ref);
            },
            child: Container(
              width: 50,
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
              await context.read<ViewStreamingNotifier>().destoryPusher();
              Routing().moveBack();
            });
          },
          child: const CustomIconWidget(
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
