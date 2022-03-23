import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';

class ProofPicture extends StatelessWidget {
  const ProofPicture({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<AccountPreferencesNotifier>(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            textToDisplay: notifier.language.idVerification!,
            textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
          ),
          eightPx,
          CustomTextWidget(
            textStyle: Theme.of(context).textTheme.bodyText2,
            textToDisplay: "${notifier.language.pleaseVerifyYourIdToUseHyppeFeatures}",
          ),
          eightPx,
          Selector<SelfProfileNotifier, UserInfoModel>(
            selector: (context, user) => user.user,
            builder: (context, user, child) {
              if (user.profile?.idProofStatus == null ||
                  user.profile?.idProofStatus == IdProofStatus.initial ||
                  user.profile?.idProofStatus == IdProofStatus.revoke) {
                return InkWell(
                  onTap: () => notifier.takeSelfie(context),
                  child: CustomTextWidget(
                    textToDisplay: "${notifier.language.verifyYourAccount}",
                    textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primaryVariant,
                        ),
                  ),
                );
              } else if (user.profile?.idProofStatus == IdProofStatus.inProgress) {
                return InkWell(
                  onTap: () => notifier.takeSelfie(context),
                  child: CustomTextWidget(
                    textToDisplay: "Veriyfing...",
                    textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primaryVariant,
                        ),
                  ),
                );
              } else {
                return Row(
                  children: [
                    const CustomIconWidget(
                      defaultColor: false,
                      iconData: "${AssetPath.vectorPath}celebrity.svg",
                    ),
                    eightPx,
                    CustomTextWidget(
                      textToDisplay: "${notifier.language.verified}",
                      textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
