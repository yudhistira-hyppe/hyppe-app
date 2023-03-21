import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
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
                      onChange: (v) => notifier.email = v,
                      labelText: notifier.language.email ?? '',
                      suffixIcon: notifier.checkBoxSuffix(System().validateEmail(notifier.email), isEmail: true),
                      suffixIconSize: 1,
                      onTap: () => notifier.passwordToEmail(),
                      textInputType: TextInputType.emailAddress,
                      textEditingController: notifier.emailController,
                      prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
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
                    // SharedPreference().readStorage(SpKeys.referralFrom) == null
                    //     ? Container()
                    //     : Padding(
                    //         padding: const EdgeInsets.all(16.0),
                    //         child: Text('Referral from ${SharedPreference().readStorage(SpKeys.referralFrom)}'),
                    //       ),
                    thirtySixPx,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        notifier.checkBoxSuffix(notifier.password.isNotEmpty),
                        CustomTextWidget(
                          textToDisplay: notifier.language.mustNotContainYourNameOrEmail ?? '',
                          textStyle: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        notifier.checkBoxSuffix(System().atLeastEightCharacter(text: notifier.password)),
                        CustomTextWidget(
                          textToDisplay: notifier.language.atLeast8Characters ?? '',
                          textStyle: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        notifier.checkBoxSuffix(System().atLeastContainOneCharacterAndOneNumber(text: notifier.password)),
                        CustomTextWidget(
                          textToDisplay: notifier.language.atLeastContain1CharacterAnd1Number ?? '',
                          textStyle: Theme.of(context).textTheme.caption,
                        )
                      ],
                    )
                  ],
                ),
              ),
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
