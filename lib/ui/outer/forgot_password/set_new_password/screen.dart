import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/widget/forgot_password_title.dart';
import 'package:provider/provider.dart';

import '../../../constant/widget/icon_button_widget.dart';

class SetNewPassword extends StatefulWidget {
  const SetNewPassword({super.key});

  @override
  State<SetNewPassword> createState() => _SetNewPasswordState();
}

class _SetNewPasswordState extends State<SetNewPassword> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SetNewPassword');
    final notifier = Provider.of<ForgotPasswordNotifier>(context, listen: false);
    notifier.initStateNewPass();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translate = context.read<TranslateNotifierV2>().translate;
    return Consumer<ForgotPasswordNotifier>(
      builder: (_, notifier, __) {
        final isMatch = notifier.passwordConfirmController.text.isNotEmpty ? notifier.passwordController.text == notifier.passwordConfirmController.text : true;
        return Scaffold(
          appBar: AppBar(
            leading: CustomIconButtonWidget(
              color: Theme.of(context).iconTheme.color,
              onPressed: () {
                notifier.passwordConfirmController.clear();
                notifier.passwordController.clear();
                notifier.password = '';
                notifier.confirmPassword = '';
                Navigator.pop(context);
              },
              iconData: '${AssetPath.vectorPath}close.svg',
            ),
            title: CustomTextWidget(
              textToDisplay: translate.createNewPassword ?? '',
              textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          fortyTwoPx,
                          ForgotPasswordTitle(
                            title: translate.createNewPassword ?? '',
                            subtitle: translate.messageNewPassword ?? '',
                          ),
                          thirtySixPx,
                          CustomTextFormField(
                            // focusNode: notifier.passwordFocus,
                            obscuringCharacter: '*',
                            inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                            inputAreaWidth: SizeConfig.screenWidth!,
                            textEditingController: notifier.passwordController,
                            style: Theme.of(context).textTheme.bodyText1,
                            obscureText: notifier.hidePassword,
                            inputFormatter: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9!@#\$%^&*_]'))],
                            textInputType: TextInputType.visiblePassword,
                            onChanged: (v) => notifier.password = v,
                            inputDecoration: InputDecoration(
                              counterText: '',
                              hintText: notifier.language.enterPassword,
                              isDense: true,
                              contentPadding: const EdgeInsets.only(right: 16, bottom: 16),
                              labelText: notifier.language.newPassword,
                              labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(),
                              //     color: notifier.incorrect
                              //         ? Theme.of(context).colorScheme.error
                              //         : notifier.passwordFocus.hasFocus
                              //             ? Theme.of(context).colorScheme.primary
                              //             : null),
                              prefixIconConstraints: BoxConstraints(
                                minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!),
                              ),
                              suffixIconConstraints: BoxConstraints(
                                minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!),
                              ),
                              prefixIcon: Transform.translate(
                                offset: Offset(SizeWidget().calculateSize(-5.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!), 0.0),
                                child: Transform.scale(
                                  scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                                  child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}lock.svg"),
                                ),
                              ),
                              suffixIcon: Transform.scale(
                                scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                                child: CustomTextButton(
                                  style: ButtonStyle(
                                    alignment: const Alignment(0.75, 0.0),
                                    minimumSize: MaterialStateProperty.all(Size.zero),
                                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                                    // overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  ),
                                  child: CustomIconWidget(
                                    iconData: notifier.hidePassword ? '${AssetPath.vectorPath}eye-off.svg' : '${AssetPath.vectorPath}eye.svg',
                                  ),
                                  onPressed: () => notifier.hidePassword = !notifier.hidePassword,
                                ),
                              ),
                              border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                              // focusedBorder:
                              // UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                            ),
                            maxLength: 20,
                          ),
                          sixteenPx,
                          CustomTextFormField(
                            // focusNode: notifier.passwordFocus,
                            isEnabled: notifier.validationRegister(),
                            obscuringCharacter: '*',
                            inputAreaHeight: (isMatch ? 55 : 70) * SizeConfig.scaleDiagonal,
                            inputAreaWidth: SizeConfig.screenWidth!,
                            textEditingController: notifier.passwordConfirmController,
                            style: Theme.of(context).textTheme.bodyText1,
                            obscureText: notifier.hideConfirmPassword,
                            textInputType: TextInputType.visiblePassword,
                            inputFormatter: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9!@#\$%^&*_]'))],
                            onChanged: (v) => notifier.confirmPassword = v,
                            inputDecoration: InputDecoration(
                                hintText: notifier.language.enterPassword,
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.only(right: 16, bottom: !isMatch ? 0 : 16),
                                labelText: notifier.language.rewriteNewPassword,
                                labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(),
                                //     color: notifier.incorrect
                                //         ? Theme.of(context).colorScheme.error
                                //         : notifier.passwordFocus.hasFocus
                                //             ? Theme.of(context).colorScheme.primary
                                //             : null),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                  minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!),
                                ),
                                prefixIcon: Transform.translate(
                                  offset: Offset(SizeWidget().calculateSize(-5.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!), 0.0),
                                  child: Transform.scale(
                                    scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                                    child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}lock.svg"),
                                  ),
                                ),
                                suffixIcon: Transform.scale(
                                  scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                                  child: CustomTextButton(
                                    style: ButtonStyle(
                                        alignment: const Alignment(0.75, 0.0),
                                        minimumSize: MaterialStateProperty.all(Size.zero),
                                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                                        overlayColor: MaterialStateProperty.all(Colors.transparent)),
                                    child: CustomIconWidget(
                                      iconData: notifier.hideConfirmPassword ? '${AssetPath.vectorPath}eye-off.svg' : '${AssetPath.vectorPath}eye.svg',
                                    ),
                                    onPressed: () => notifier.hideConfirmPassword = !notifier.hideConfirmPassword,
                                  ),
                                ),
                                border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                                // focusedBorder:
                                //     UnderlineInputBorder(borderSide: BorderSide(color: notifier.passwordFocus.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface)),
                                errorText: isMatch ? null : notifier.language.passwordDoesntMatch),
                            maxLength: 20,
                          ),
                          sixteenPx,
                          CustomTextWidget(
                            textToDisplay: notifier.language.yourPasswordMustBeAtLeast ?? '',
                            textStyle: TextStyle(color: context.isDarkMode() ? Colors.white : Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          eightPx,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              notifier.checkBoxSuffix(System().atLeastEightUntilTwentyCharacter(text: notifier.passwordController.text)),
                              CustomTextWidget(
                                textToDisplay: notifier.language.atLeast8til20Chars ?? '',
                                textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: context.isDarkMode() ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              notifier.checkBoxSuffix(System().atLeastContainOneCharacterAndOneNumber(text: notifier.passwordController.text)),
                              CustomTextWidget(
                                textToDisplay: notifier.language.atLeastContain1CharacterAnd1Number ?? '',
                                textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: context.isDarkMode() ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              notifier.checkBoxSuffix(System().specialCharPass(notifier.passwordController.text)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    textToDisplay: notifier.language.oneSpecialCharacter ?? '',
                                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: context.isDarkMode() ? Colors.white : Colors.black),
                                  ),
                                  onePx,
                                  CustomTextWidget(
                                    textToDisplay: notifier.language.labelExampleSpecialChar ?? '',
                                    textStyle: Theme.of(context).textTheme.caption,
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomElevatedButton(
                    width: SizeConfig.screenWidth,
                    height: 50,
                    buttonStyle: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(notifier.nextButtonColor(context)),
                        overlayColor: MaterialStateProperty.all<Color>(notifier.nextButtonColor(context)),
                        foregroundColor: MaterialStateProperty.all<Color>(notifier.nextButtonColor(context)),
                        shadowColor: MaterialStateProperty.all<Color>(notifier.nextButtonColor(context))),
                    function: () {
                      notifier.nextButton(context, mounted);
                    },
                    child: notifier.loading
                        ? const CustomLoading()
                        : CustomTextWidget(
                            textToDisplay: notifier.language.resetPassword ?? 'Reset Password',
                            textStyle: notifier.nextTextColor(context),
                          ),
                  ),
                  sixPx,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
