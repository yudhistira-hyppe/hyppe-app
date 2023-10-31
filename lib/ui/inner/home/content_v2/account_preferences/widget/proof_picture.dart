import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
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
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ProofPicture');
    final notifier = Provider.of<AccountPreferencesNotifier>(context);
    return Selector<SelfProfileNotifier, UserInfoModel>(
      selector: (context, user) => user.user,
      builder: (context, user, child) {
        bool isIDVerified = SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED;
        return isIDVerified
            ? SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier.language.idVerification ?? 'Verification ID',
                      textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    // eightPx,
                    // CustomTextWidget(
                    //   textStyle: Theme.of(context).textTheme.bodyText2,
                    //   textToDisplay:
                    //       "${notifier.language.pleaseVerifyYourIdToUseHyppeFeatures}",
                    // ),
                    eightPx,
                    Row(
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
                    )
                  ],
                ),
              )
            : Container();
      },
    );
  }

  // verifyMessage(BuildContext context, UserInfoModel user,
  //     AccountPreferencesNotifier notifier) {
  //   if (user.profile?.idProofStatus == IdProofStatus.inProgress) {
  //     return InkWell(
  //       onTap: () => notifier.takeSelfie(context),
  //       child: CustomTextWidget(
  //         textToDisplay: "Veriyfing...",
  //         textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
  //               fontWeight: FontWeight.bold,
  //               color: Theme.of(context).colorScheme.primary,
  //             ),
  //       ),
  //     );
  //   } else if (user.profile?.idProofStatus == IdProofStatus.complete) {
  //     return Row(
  //       children: [
  //         const CustomIconWidget(
  //           defaultColor: false,
  //           iconData: "${AssetPath.vectorPath}celebrity.svg",
  //         ),
  //         eightPx,
  //         CustomTextWidget(
  //           textToDisplay: "${notifier.language.verified}",
  //           textStyle: Theme.of(context)
  //               .textTheme
  //               .bodyText2
  //               ?.copyWith(fontWeight: FontWeight.bold),
  //         ),
  //       ],
  //     );
  //   }
  // }
}
