import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../ux/path.dart';
import '../../../widget/button_sosmed.dart';
import '../../../widget/custom_loading.dart';

class OnLoginApp extends StatefulWidget {
  const OnLoginApp({super.key});

  @override
  State<OnLoginApp> createState() => _OnLoginAppState();
}

class _OnLoginAppState extends State<OnLoginApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeLoginNotifier>(builder: (context, notifier, _) {
      return ListView(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          twentyPx,
          System().showWidgetForGuest(
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomGesture(
                  margin: EdgeInsets.zero,
                  onTap: () {
                    Routing().moveBack();
                  },
                  child: const CustomIconWidget(
                      height: 28,
                      width: 28,
                      iconData: "${AssetPath.vectorPath}close.svg"),
                ),
                sixteenPx
              ],
            ),
            Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              sixteenPx,
              CustomGesture(
                margin: EdgeInsets.zero,
                onTap: () async {
                  Routing().moveBack();
                  Routing().move(Routes.help);
                },
                child: const CustomIconWidget(
                    height: 28,
                    width: 28,
                    iconData: "${AssetPath.vectorPath}help_circle.svg"),
              ),
              const Expanded(child: SizedBox.shrink()),
              CustomGesture(
                margin: EdgeInsets.zero,
                onTap: () {
                  Routing().moveBack();
                },
                child: const CustomIconWidget(
                    height: 28,
                    width: 28,
                    iconData: "${AssetPath.vectorPath}close.svg"),
              ),
              sixteenPx
            ],
          ), ),
          thirtyTwoPx,
          const CustomIconWidget(
            iconData: "${AssetPath.vectorPath}ic_welcome_login.svg",
            defaultColor: false,
          ),
          twentyPx,
          const CustomTextWidget(
            textToDisplay: 'Hyppe Login',
            textAlign: TextAlign.center,
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          tenPx,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: CustomTextWidget(
              textToDisplay: notifier.language.loginMessage ?? '',
              textAlign: TextAlign.center,
              maxLines: 3,
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
          twentyPx,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ButtomSosmed(
              function: () => notifier.loginGoogleSign(context),
              child: notifier.isLoading
                  ? const CustomLoading()
                  : Row(
                      children: [
                        Container(
                          height: 60,
                          padding: const EdgeInsets.only(right: 15.0),
                          // decoration: const BoxDecoration(
                          //   border: Border(
                          //     right: BorderSide(
                          //       color: Color(0xFFEDEDED),
                          //       width: 1.0,
                          //     ),
                          //   ),
                          // ),
                          child: const CustomIconWidget(
                            defaultColor: false,
                            iconData: '${AssetPath.vectorPath}google.svg',
                          ),
                        ),
                        const Spacer(),
                        CustomTextWidget(
                          textToDisplay:
                              notifier.language.signInWithGoogleAccount ?? '',
                          textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w700) ??
                              const TextStyle(),
                        ),
                        const Spacer(),
                      ],
                    ),
            ),
          ),
          Platform.isIOS
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ButtomSosmed(
                    function: () => notifier.loginAppleSign(context),
                    child: notifier.isLoading
                        ? const CustomLoading()
                        : Row(
                            children: [
                              Container(
                                height: 60,
                                padding: const EdgeInsets.only(right: 15.0),
                                // decoration: const BoxDecoration(
                                //   border: Border(
                                //     right: BorderSide(
                                //       color: Color(0xFFEDEDED),
                                //       width: 1.0,
                                //     ),
                                //   ),
                                // ),
                                child: CustomIconWidget(
                                  defaultColor: false,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  width: 20,
                                  iconData: '${AssetPath.vectorPath}apple.svg',
                                ),
                              ),
                              const Spacer(),
                              CustomTextWidget(
                                textToDisplay:
                                    notifier.language.signInWithApple ?? '',
                                textStyle:
                                    Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                            ],
                          ),
                  ),
                )
              : SizedBox(),
          twelvePx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              sixteenPx,
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              ),
              twelvePx,
              CustomTextWidget(
                  textToDisplay: notifier.language.or?.toLowerCase() ?? 'or',
                  textStyle: Theme.of(context).textTheme.bodyText2),
              twelvePx,
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              ),
              sixteenPx
            ],
          ),
          twelvePx,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ButtomSosmed(
              function: () {
                notifier.onClickLoginEmail();
              },
              child: Row(
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.only(right: 15.0),
                    // decoration: const BoxDecoration(
                    //   border: Border(
                    //     right: BorderSide(
                    //       color: Color(0xFFEDEDED),
                    //       width: 1.0,
                    //     ),
                    //   ),
                    // ),
                    child: const CustomIconWidget(
                      defaultColor: false,
                      iconData: '${AssetPath.vectorPath}person_login.svg',
                    ),
                  ),
                  const Spacer(),
                  CustomTextWidget(
                    textToDisplay:
                        notifier.language.useAnotherEmailAddress ?? '',
                    textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w700) ??
                        const TextStyle(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          sixteenPx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextWidget(
                textToDisplay: "${notifier.language.dontHaveAnAccount}?   ",
                textStyle: Theme.of(context).primaryTextTheme.bodyText2,
              ),
              GestureDetector(
                onTap: () => notifier.onClickSignUpHere(),
                child: CustomTextWidget(
                  textToDisplay: notifier.language.registerHere ?? '',
                  textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
          fortyEightPx,
          CustomTextWidget(
            textToDisplay: notifier.language.privateAndService ?? '',
            textAlign: TextAlign.center,
            textStyle: const TextStyle(fontSize: 14),
          ),
          Align(
            alignment: Alignment.center,
            child: RichText(text: TextSpan(
              children: [
                TextSpan(
                  text: "${notifier.language.termsOfService} ",
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: kHyppePrimary),
                  recognizer: TapGestureRecognizer()..onTap = () => notifier.goToEula(),
                ),
                TextSpan(
                  text: "${notifier.language.and} ",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  text: notifier.language.privacyPolicy,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: kHyppePrimary),
                  recognizer: TapGestureRecognizer()..onTap = () => notifier.goToEula(),
                ),
              ]
            )),
          ),
          twentyPx
        ],
      );
    });
  }
}
