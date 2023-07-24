import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

class BuildPersonalProfilePic extends StatelessWidget {
  const BuildPersonalProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BuildPersonalProfilePic');
    return Consumer<SelfProfileNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 130 * SizeConfig.scaleDiagonal,
        height: 130 * SizeConfig.scaleDiagonal,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Text("${notifier.user.profile?.avatar?.imageKey}"),
                ClipOval(
                  child: CustomProfileImage(
                    cacheKey: notifier.user.profile?.avatar?.imageKey,
                    following: true,
                    width: 100 * SizeConfig.scaleDiagonal,
                    height: 100 * SizeConfig.scaleDiagonal,
                    imageUrl: notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}"),
                    badge: notifier.user.profile?.urluserBadge,
                    onTap: () {},
                    forStory: false,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: CustomTextButton(
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: () async {
                  await CachedNetworkImage.evictFromCache("${notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}")}", scale: 2000);
                  context.read<AccountPreferencesNotifier>().onClickChangeImageProfile(context, "${notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}")}");
                },
                child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}edit-profile-pic.svg", defaultColor: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
