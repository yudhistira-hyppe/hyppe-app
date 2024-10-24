import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:provider/provider.dart';

class SignUpOrGoogle extends StatelessWidget {
  const SignUpOrGoogle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SignUpOrGoogle');
    return Consumer<LoginNotifier>(
      builder: (_, notifier, __) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  textToDisplay: "${notifier.language.dontHaveAnAccount}?   ",
                  textStyle: Theme.of(context).primaryTextTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: () => notifier.onClickSignUpHere(),
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.registerHere ?? '',
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
            CustomRichTextWidget(
              textOverflow: TextOverflow.clip,
              textSpan: TextSpan(
                text: "${notifier.language.byRegisteringYouAgreeToHyppe} ",
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: "${notifier.language.privacyPolicy} ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: kHyppePrimary),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => context.read<UserInterestNotifier>().goToEula(),
                  ),
                  TextSpan(
                    text: "${notifier.language.and} ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: notifier.language.termsOfService,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: kHyppePrimary),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => context.read<UserInterestNotifier>().goToEula(),
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Container(
            //       width: 50,
            //       height: 1,
            //       decoration: BoxDecoration(
            //         border: Border.all(color: Theme.of(context).colorScheme.surface),
            //       ),
            //     ),
            //     twelvePx,
            //     CustomTextWidget(textToDisplay: notifier.language.or, textStyle: Theme.of(context).textTheme.bodyMedium),
            //     twelvePx,
            //     Container(
            //       width: 50,
            //       height: 1,
            //       decoration: BoxDecoration(
            //         border: Border.all(color: Theme.of(context).colorScheme.surface),
            //       ),
            //     ),
            //   ],
            // ),
            // twelvePx,
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     GestureDetector(
            //       onTap: () {
            //         notifier.loginGoogleSign(context);
            //       },
            //       child: Container(
            //         width: 48,
            //         height: 48,
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Theme.of(context).colorScheme.surface),
            //           borderRadius: BorderRadius.circular(24),
            //         ),
            //         child: const Image(image: AssetImage('${AssetPath.pngPath}logo_google.png')),
            //       ),
            //     ),
            //     twelvePx,
            //     GestureDetector(
            //       // onTap: () => notifier.FacebookSignin(),
            //       child: Container(
            //         width: 48,
            //         height: 48,
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Theme.of(context).colorScheme.surface),
            //           borderRadius: BorderRadius.circular(24),
            //         ),
            //         child: const Image(image: AssetImage('${AssetPath.pngPath}logo_facebook.png')),
            //       ),
            //     ),
            //     twelvePx,
            //     GestureDetector(
            //       // onTap: () => notifier.loginTwitter(),
            //       child: Container(
            //         width: 48,
            //         height: 48,
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Theme.of(context).colorScheme.surface),
            //           borderRadius: BorderRadius.circular(24),
            //         ),
            //         child: const Image(image: AssetImage('${AssetPath.pngPath}logo_twitter.png')),
            //       ),
            //     ),
            //     twelvePx,
            //     Container(
            //       width: 48,
            //       height: 48,
            //       decoration: BoxDecoration(
            //         border: Border.all(color: Theme.of(context).colorScheme.surface),
            //         borderRadius: BorderRadius.circular(24),
            //       ),
            //       child: const Image(image: AssetImage('${AssetPath.pngPath}logo_apple.png')),
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
