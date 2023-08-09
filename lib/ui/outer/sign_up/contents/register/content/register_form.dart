import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/outer/sign_up/contents/register/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_button.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_form_field.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_text.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'RegisterForm');
    return Consumer<RegisterNotifier>(
      builder: (_, notifier, __) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: SizeConfig.screenHeight! * 0.15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SignUpText(
                        title: notifier.language.register ?? 'register',
                        paddingDescription: 24 * SizeConfig.scaleDiagonal,
                        description: notifier.language.joinTheCommunityCreateOrWatchAndGetMoney ?? '',
                      ),
                    ),
                    sixtyFourPx,
                    SignUpForm(
                      onChangeValue: notifier.email,
                      focusNode: notifier.emailNode,
                      onChange: (v){
                        notifier.email = v;
                        if(System().validateEmail(v)){
                          notifier.invalidEmail = null;
                        }else{
                          if(v.isNotEmpty){
                            notifier.invalidEmail = notifier.language.messageInvalidEmail;
                          }else{
                            notifier.invalidEmail = null;
                          }
                        }
                      },
                      labelText: notifier.language.email ?? '',
                      suffixIcon: notifier.checkBoxSuffix(System().validateEmail(notifier.email), isEmail: true),
                      suffixIconSize: 1,
                      onTap: () => notifier.passwordToEmail(),
                      textInputType: TextInputType.emailAddress,
                      textEditingController: notifier.emailController,
                      prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
                      errorText: notifier.invalidEmail,
                      inputAreaHeight: (notifier.invalidEmail != null ? 70 : 55) * SizeConfig.scaleDiagonal,
                      contentPadding: EdgeInsets.only(left: 16, bottom: (notifier.invalidEmail != null) ? 0 : 16, right: 16),
                    ),
                    twentyFourPx,
                    SignUpForm(
                      obscure: notifier.hidePassword,
                      onChangeValue: notifier.password,
                      focusNode: notifier.passwordNode,
                      onChange: (v) => notifier.password = v,
                      labelText: notifier.language.password ?? '',
                      onTap: () => notifier.emailToPassword(),
                      suffixIcon: notifier.passwordSuffixIcon(context),
                      textEditingController: notifier.passwordController,
                      prefixIcon: const CustomIconWidget(iconData: '${AssetPath.vectorPath}lock.svg'),
                    ),
                    thirtySixPx,
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
                    )
                  ],
                ),
              ),
              thirtySixPx,
              SignUpButton(
                loading: notifier.loading,
                caption: notifier.language.next,
                textStyle: notifier.nextTextColor(context),
                buttonColor: notifier.nextButtonColor(context),
                onTap: notifier.nextButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
