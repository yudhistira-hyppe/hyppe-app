import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifier.titleLive,
                      style: TextStyle(
                        color: kHyppeTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${notifier.totLikes} ${tn.like}',
                      style: TextStyle(
                        fontSize: 10,
                        color: kHyppeTextPrimary,
                      ),
                    )
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: kHyppeTextPrimary,
              )
            ],
          )),
    );
  }
}
