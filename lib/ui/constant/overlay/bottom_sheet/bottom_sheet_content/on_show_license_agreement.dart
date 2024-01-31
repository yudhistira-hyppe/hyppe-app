import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class OnShowLicenseAgreement extends StatelessWidget {
  const OnShowLicenseAgreement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _textTheme = Theme.of(context).textTheme;
    return Consumer<UserInterestNotifier>(
      builder: (context, notifier, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              CustomTextWidget(textToDisplay: notifier.language.termsOfUse ?? "Terms Of Use", textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
              RichText(
                text: TextSpan(
                  style: _textTheme.bodyText2,
                  text: '${notifier.language.byTappingAgreeAndContinueYouAgreeToOur} ',
                  children: [
                    TextSpan(
                      text: '${notifier.language.termsOfService} ',
                      recognizer: TapGestureRecognizer()..onTap = () => notifier.goToEula(),
                      style: _textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: kHyppePrimary),
                      children: [
                        TextSpan(
                          text: '${notifier.language.andAcknowledgeThatYouHaveReadOur} ',
                          style: _textTheme.bodyText2,
                          children: [
                            TextSpan(
                              text: '${notifier.language.privacyPolicy} ',
                              recognizer: TapGestureRecognizer()..onTap = () => context.read<UserInterestNotifier>().goToEula(),
                              style: _textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: kHyppePrimary),
                              children: [
                                TextSpan(
                                  text: notifier.language.toLearnAboutHowWeCollectUseAndShareYourData,
                                  style: _textTheme.bodyText2,
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
                maxLines: null,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              ),
              CustomElevatedButton(
                width: SizeConfig.screenWidth,
                height: 50,
                buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                    overlayColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                    foregroundColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                    shadowColor: MaterialStateProperty.all<Color>(kHyppePrimary)),
                function: () => Navigator.pop(context, true),
                child: Selector<UserInterestNotifier, bool>(
                  selector: (context, notifier) => notifier.isLoading,
                  builder: (_, value, __) {
                    return CustomTextWidget(
                      textToDisplay: notifier.language.agreeAndContinue ?? '',
                      textStyle: _textTheme.bodyText2?.copyWith(color: kHyppeLightButtonText),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
