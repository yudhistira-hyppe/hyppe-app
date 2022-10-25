import 'dart:io';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/button_sosmed.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/register.dart';
import 'package:provider/provider.dart';

class PageBottom extends StatefulWidget {
  @override
  _PageBottomState createState() => _PageBottomState();
}

class _PageBottomState extends State<PageBottom> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeLoginNotifier>(
      builder: (_, notifier, __) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 34, 16, 34),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  CustomTextWidget(
                    textToDisplay: notifier.language.welcomeToHyppe!,
                    textStyle: Theme.of(context).primaryTextTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  eightPx,
                  CustomTextWidget(
                    textToDisplay: notifier.language.signInToFindSomethingInterestingInTheHyppeApp!,
                    maxLines: 2,
                    textStyle: Theme.of(context).primaryTextTheme.subtitle2!,
                  ),
                  fortyTwoPx,
                  ButtomSosmed(
                    function: () => notifier.loginGoogleSign(context),
                    child: notifier.isLoading
                        ? const CustomLoading()
                        : Row(
                            children: [
                              Container(
                                height: 60,
                                padding: EdgeInsets.only(right: 15.0),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Color(0xFFEDEDED),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: CustomIconWidget(
                                  defaultColor: false,
                                  iconData: '${AssetPath.vectorPath}google.svg',
                                ),
                              ),
                              const Spacer(),
                              CustomTextWidget(
                                textToDisplay: notifier.language.signInWithGoogleAccount!,
                                textStyle: Theme.of(context).textTheme.subtitle2!,
                              ),
                              const Spacer(),
                            ],
                          ),
                  ),
                  Platform.isIOS
                      ? ButtomSosmed(
                          function: () => notifier.loginAppleSign(context),
                          child: notifier.isLoading
                              ? const CustomLoading()
                              : Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      padding: EdgeInsets.only(right: 15.0),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFEDEDED),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: CustomIconWidget(
                                        defaultColor: false,
                                        color: Theme.of(context).colorScheme.onBackground,
                                        width: 20,
                                        iconData: '${AssetPath.vectorPath}apple.svg',
                                      ),
                                    ),
                                    const Spacer(),
                                    CustomTextWidget(
                                      textToDisplay: notifier.language.signInWithApple!,
                                      textStyle: Theme.of(context).textTheme.subtitle2!,
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                        )
                      : SizedBox(),
                  twelvePx,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                          ),
                        ),
                      ),
                      twelvePx,
                      CustomTextWidget(textToDisplay: notifier.language.or!, textStyle: Theme.of(context).textTheme.bodyText2),
                      twelvePx,
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  twelvePx,
                  ButtomSosmed(
                    function: () {
                      notifier.onClickLoginEmail();
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          padding: EdgeInsets.only(right: 15.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFFEDEDED),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: CustomIconWidget(
                            defaultColor: false,
                            iconData: '${AssetPath.vectorPath}person.svg',
                          ),
                        ),
                        const Spacer(),
                        CustomTextWidget(
                          textToDisplay: notifier.language.useAnotherEmailAddress!,
                          textStyle: Theme.of(context).textTheme.subtitle2!,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  twelvePx,
                ],
              ),
              Register(),
            ],
          ),
        ),
      ),
    );
  }
}
