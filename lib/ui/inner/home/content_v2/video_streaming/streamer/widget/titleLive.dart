import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TitleLive extends StatelessWidget {
  const TitleLive({super.key});

  @override
  Widget build(BuildContext context) {
    var profileImage = context.read<HomeNotifier>().profileImage;
    var profileImageKey = context.read<HomeNotifier>().profileImageKey;
    var tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomProfileImage(
                  cacheKey: profileImageKey,
                  following: true,
                  forStory: false,
                  width: 36 * SizeConfig.scaleDiagonal,
                  height: 36 * SizeConfig.scaleDiagonal,
                  imageUrl: System().showUserPicture(profileImage),
                  // badge: notifier.user.profile?.urluserBadge,
                  allwaysUseBadgePadding: false,
                ),
                sixPx,
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      ShowBottomSheet.onStreamWatchersStatus(
                          context, false, notifier);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (notifier.titleLive.isNotEmpty)
                              ? notifier.titleLive
                              : notifier.userName,
                          style: const TextStyle(
                            color: kHyppeTextPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${notifier.totLikes} ${tn.like}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: kHyppeTextPrimary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ShowBottomSheet.onStreamWatchersStatus(
                        context, false, notifier);
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: kHyppeTextPrimary,
                  ),
                )
              ],
            ),
            sixtyFourPx,
            GestureDetector(
              onTap: () async {
                var uri = notifier.dataStream.urlLink??'';
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
                child: Text(notifier.dataStream.textUrl??notifier.dataStream.urlLink??'Klik disini ya!', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
