import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
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
        padding: EdgeInsets.symmetric(horizontal: 8 * SizeConfig.scaleDiagonal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            fivePx,
            const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}handler.svg"),
            twentyEightPx,
            const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}verification-need-new.svg",
              defaultColor: false,
            ),
            twentyEightPx,
            CustomTextWidget(
              textToDisplay:
                  notifier.language.verifyId ?? 'Verifikasi Identitas',
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
            fourteenPx,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• "),
                      Expanded(
                        child: CustomRichTextWidget(
                          maxLines: 20,
                          textAlign: TextAlign.start,
                          textOverflow: TextOverflow.clip,
                          textSpan: TextSpan(
                              text:
                                  notifier.language.needVerifyIdDescriptions ??
                                      '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(height: 1.6)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• "),
                      Expanded(
                        child: CustomRichTextWidget(
                          textAlign: TextAlign.start,
                          textOverflow: TextOverflow.clip,
                          textSpan: TextSpan(
                            text: notifier.language.needVerifyIdDescriptions2 ??
                                '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(height: 1.6),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            fourteenPx,
            CustomElevatedButton(
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
                      Theme.of(context).colorScheme.primary),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary)),
              child: CustomTextWidget(
                textToDisplay:
                    notifier.language.verifyNow ?? 'Verifikasi Sekarang',
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: kHyppeLightButtonText),
              ),
            ),
            CustomElevatedButton(
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () => Routing().moveBack(),
              buttonStyle: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
              child: CustomTextWidget(
                textToDisplay: notifier.language.cancel ?? 'cancel',
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
            )
          ],
        ),
      ),
    );
  }
}
