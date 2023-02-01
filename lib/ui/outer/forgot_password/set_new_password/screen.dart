import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/widget/forgot_password_title.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_button.dart';
import 'package:provider/provider.dart';

class SetNewPassword extends StatefulWidget {
  const SetNewPassword({super.key});

  @override
  State<SetNewPassword> createState() => _SetNewPasswordState();
}

class _SetNewPasswordState extends State<SetNewPassword> {
  @override
  Widget build(BuildContext context) {
    final translate = context.read<TranslateNotifierV2>().translate;
    return Consumer<ForgotPasswordNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leading: CustomIconButtonWidget(
            color: Theme.of(context).iconTheme.color,
            onPressed: () => Navigator.pop(context),
            iconData: '${AssetPath.vectorPath}back-arrow.svg',
          ),
          title: CustomTextWidget(
            textToDisplay: translate.createNewPassword ?? '',
            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ForgotPasswordTitle(
                        title: translate.forgotPassword ?? '',
                        subtitle: translate.wellEmailYourCodeToResetYourPassword ?? '',
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
                        textInputType: TextInputType.text,
                        onChanged: (v) => notifier.password = v,
                        inputDecoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.only(right: 16, bottom: 16),
                          labelText: notifier.language.password,
                          labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(),
                          //     color: notifier.incorrect
                          //         ? Theme.of(context).colorScheme.error
                          //         : notifier.passwordFocus.hasFocus
                          //             ? Theme.of(context).colorScheme.primaryVariant
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
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                          // focusedBorder:
                          //     UnderlineInputBorder(borderSide: BorderSide(color: notifier.passwordFocus.hasFocus ? Theme.of(context).colorScheme.primaryVariant : Theme.of(context).colorScheme.secondary)),
                        ),
                      ),
                      sixteenPx,
                      CustomTextFormField(
                        // focusNode: notifier.passwordFocus,
                        obscuringCharacter: '*',
                        inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                        inputAreaWidth: SizeConfig.screenWidth!,
                        textEditingController: notifier.passwordConfirmController,
                        style: Theme.of(context).textTheme.bodyText1,
                        obscureText: notifier.hideConfirmPassword,
                        textInputType: TextInputType.text,
                        onChanged: (v) => notifier.confirmPassword = v,
                        inputDecoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.only(right: 16, bottom: 16),
                          labelText: notifier.language.confirm,
                          labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(),
                          //     color: notifier.incorrect
                          //         ? Theme.of(context).colorScheme.error
                          //         : notifier.passwordFocus.hasFocus
                          //             ? Theme.of(context).colorScheme.primaryVariant
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
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                          // focusedBorder:
                          //     UnderlineInputBorder(borderSide: BorderSide(color: notifier.passwordFocus.hasFocus ? Theme.of(context).colorScheme.primaryVariant : Theme.of(context).colorScheme.secondary)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          notifier.checkBoxSuffix(notifier.passwordController.text != ''),
                          CustomTextWidget(
                            textToDisplay: notifier.language.mustNotContainYourNameOrEmail ?? '',
                            textStyle: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          notifier.checkBoxSuffix(System().atLeastEightCharacter(text: notifier.passwordController.text)),
                          CustomTextWidget(
                            textToDisplay: notifier.language.atLeast8Characters ?? '',
                            textStyle: Theme.of(context).textTheme.caption,
                          )
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          notifier.checkBoxSuffix(System().atLeastContainOneCharacterAndOneNumber(text: notifier.passwordController.text)),
                          CustomTextWidget(
                            textToDisplay: notifier.language.atLeastContain1CharacterAnd1Number ?? '',
                            textStyle: Theme.of(context).textTheme.caption,
                          )
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          notifier.checkBoxSuffix(System().specialCharPass(notifier.passwordController.text)),
                          CustomTextWidget(
                            textToDisplay: 'Harus ada spesial karakter',
                            textStyle: Theme.of(context).textTheme.caption,
                          )
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          notifier.checkBoxSuffix(notifier.checkConfirmPassword()),
                          CustomTextWidget(
                            textToDisplay: notifier.language.confirmPasswordCorrect ?? '',
                            textStyle: Theme.of(context).textTheme.caption,
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
                  if (!notifier.loading) {
                    notifier.nextButton(context, mounted);
                  }
                },
                child: notifier.loading
                    ? const CustomLoading()
                    : CustomTextWidget(
                        textToDisplay: 'Submit',
                        textStyle: notifier.nextTextColor(context),
                      ),
              ),
              sixPx,
            ],
          ),
        ),
      ),
    );
  }
}
