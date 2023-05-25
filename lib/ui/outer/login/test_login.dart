import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:provider/provider.dart';

class TestLogin extends StatefulWidget {
  const TestLogin({super.key});

  @override
  _TestLoginState createState() => _TestLoginState();
}

class _TestLoginState extends State<TestLogin> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'TestLogin');
    // var notif = Provider.of<WelcomeLoginNotifier>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeLoginNotifier>(
      builder: (_, notifier, __) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              twentyEightPx,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    focusNode: notifier.emailFocus,
                    inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                    inputAreaWidth: SizeConfig.screenWidth!,
                    textEditingController: notifier.emailController,
                    style: Theme.of(context).textTheme.bodyText1,
                    textInputType: TextInputType.emailAddress,
                    onChanged: (v) {
                      notifier.email = v;
                    },
                    inputDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                      labelText: notifier.incorrect ? notifier.language.notAValidEmailAddress : notifier.language.email,
                      labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: notifier.emailValidator(notifier.emailController.text) != ''
                              ? Theme.of(context).colorScheme.error
                              : notifier.emailFocus.hasFocus
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                      prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)),
                      prefixIcon: Transform.translate(
                        offset: Offset(SizeWidget().calculateSize(-5.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!), 0.0),
                        child: Transform.scale(
                          scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                          child: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
                        ),
                      ),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: notifier.emailFocus.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface)),
                      errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                    ),
                    readOnly: notifier.isLoading
                        ? true
                        : notifier.loadingForObject(LoginNotifier.loadingForgotPasswordKey)
                            ? true
                            : false,
                    // validator: (v) {
                    //   if (notifier.emailValidator(v!) == '') {
                    //     return 'asdasd';
                    //   } else {
                    //     return null;
                    //   }
                    // },
                  ),
                  CustomTextFormField(
                    focusNode: notifier.emailFocus,
                    inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                    inputAreaWidth: SizeConfig.screenWidth!,
                    textEditingController: notifier.emailController,
                    style: Theme.of(context).textTheme.bodyText1,
                    textInputType: TextInputType.emailAddress,
                    onChanged: (v) {
                      notifier.email = v;
                    },
                    inputDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                      labelText: notifier.incorrect ? notifier.language.notAValidEmailAddress : notifier.language.email,
                      labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: notifier.emailValidator(notifier.emailController.text) != ''
                              ? Theme.of(context).colorScheme.error
                              : notifier.emailFocus.hasFocus
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                      prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)),
                      prefixIcon: Transform.translate(
                        offset: Offset(SizeWidget().calculateSize(-5.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!), 0.0),
                        child: Transform.scale(
                          scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                          child: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
                        ),
                      ),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: notifier.emailFocus.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface)),
                      errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                    ),
                    readOnly: notifier.isLoading
                        ? true
                        : notifier.loadingForObject(LoginNotifier.loadingForgotPasswordKey)
                            ? true
                            : false,
                    // validator: (v) {
                    //   if (notifier.emailValidator(v!) == '') {
                    //     return 'asdasd';
                    //   } else {
                    //     return null;
                    //   }
                    // },
                  ),
                  fourPx,
                  CustomTextWidget(
                    textToDisplay: "${notifier.emailValidator(notifier.emailController.text)}",
                    textAlign: TextAlign.start,
                    textStyle: const TextStyle(color: Colors.red),
                  ),
                  twentyFourPx,
                ],
              ),
              twentyPx,
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     CustomTextWidget(
              //       textToDisplay: "${notifier.language.forgotPassword}?",
              //       textStyle: Theme.of(context).primaryTextTheme.button,
              //     ),
              //     notifier.loadingForObject(LoginNotifier.loadingForgotPasswordKey)
              //         ? const CustomLoading(size: 6.3)
              //         : CustomTextButton(
              //             onPressed: () => notifier.onClickForgotPassword(context),
              //             child: CustomTextWidget(
              //               textToDisplay: "${notifier.language.forgotPassword}?",
              //               textStyle: Theme.of(context).primaryTextTheme.button.copyWith(color: kHyppePrimary),
              //             ),
              //           ),
              //   ],
              // ),
              notifier.loadingForObject(LoginNotifier.loadingForgotPasswordKey)
                  ? const CustomLoading(size: 6.3)
                  : Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: CustomTextButton(
                        onPressed: () => notifier.onClickForgotPassword(context),
                        child: CustomTextWidget(
                          textToDisplay: "${notifier.language.forgotPassword}?",
                          textStyle: Theme.of(context).primaryTextTheme.button?.copyWith(color: kHyppePrimary),
                        ),
                      ),
                    ),
              fourPx,
              CustomElevatedButton(
                function: () {
                  if (!notifier.isLoading) {
                    notifier.testLogin(context);
                  }
                },
                buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(notifier.isLoading ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: notifier.isLoading
                    ? const CustomLoading()
                    : CustomTextWidget(
                        textToDisplay: notifier.language.logIn ?? 'Log In',
                        textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                      ),
                width: SizeConfig.screenWidth,
                height: 49 * SizeConfig.scaleDiagonal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
