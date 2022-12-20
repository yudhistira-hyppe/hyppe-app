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
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 145 * SizeConfig.scaleDiagonal,
        height: 145 * SizeConfig.scaleDiagonal,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Consumer<SelfProfileNotifier>(
                  builder: (_, notifier, __) => CustomProfileImage(
                    following: true,
                    width: 122 * SizeConfig.scaleDiagonal,
                    height: 122 * SizeConfig.scaleDiagonal,
                    imageUrl: notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}"),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: CustomTextButton(
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: () => context.read<AccountPreferencesNotifier>().onClickChangeImageProfile(context),
                child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}edit-profile-pic.svg", defaultColor: false),
              ),
            ),
          ],
        ),
      );
}
