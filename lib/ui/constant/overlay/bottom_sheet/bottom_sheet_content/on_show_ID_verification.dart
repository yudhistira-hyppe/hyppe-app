import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnShowIDVerificationBottomSheet extends StatelessWidget {
  const OnShowIDVerificationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreUploadContentNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.symmetric(
            vertical: 8 * SizeConfig.scaleDiagonal,
            horizontal: 16 * SizeConfig.scaleDiagonal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}handler.svg"),
            Image.asset("assets/png/verification-idcard.png"),
            CustomTextWidget(
              textToDisplay: notifier.language.needVerifyId!,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
            // CustomTextWidget(
            //   textToDisplay: notifier.language.needVerifyIdDescriptions!,
            //   textStyle: Theme.of(context).textTheme.caption,
            //   textOverflow: TextOverflow.clip,
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    SizedBox(
                      width: 330 * SizeConfig.scaleDiagonal,
                      child: CustomRichTextWidget(
                        textAlign: TextAlign.start,
                        textOverflow: TextOverflow.clip,
                        textSpan: TextSpan(
                            text: notifier.language
                                .needVerifyIdDescriptions!,
                            style: Theme.of(context)
                                .textTheme
                                .caption!.copyWith(height: 1.6)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: 10 * SizeConfig.scaleDiagonal),
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    SizedBox(
                      width: 330 * SizeConfig.scaleDiagonal,
                      child: CustomRichTextWidget(
                        textAlign: TextAlign.start,
                        textOverflow: TextOverflow.clip,
                        textSpan: TextSpan(
                          text: notifier.language
                              .needVerifyIdDescriptions2!,
                          style: Theme.of(context)
                              .textTheme
                              .caption!.copyWith(height: 1.6),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.language.verify!,
                textStyle: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(color: kHyppeLightButtonText),
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () {
                // var notifAccount = Provider.of<AccountPreferencesNotifier>(
                //     context,
                //     listen: false);
                // notifAccount.initialIndex = 0;
                // notifAccount.openValidationIDCamera = true;
                // context.read<PreviewContentNotifier>().clearAdditionalItem();
                // context.read<CameraNotifier>().orientation = null;
                // context.read<PreviewContentNotifier>().isForcePaused = false;
                // Routing().moveAndPop(Routes.accountPreferences);
                notifier.validateIdCard();
              },
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant)),
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.language.noLater!,
                textStyle: Theme.of(context).textTheme.button,
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () => Routing().moveBack(),
              buttonStyle: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
            )
          ],
        ),
      ),
    );
  }
}
