import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
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
import 'package:hyppe/core/services/shared_preference.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  var rememberMe = SharedPreference().readStorage(SpKeys.rememberMe) ?? false;
  var valRememberMe = SharedPreference().readStorage(SpKeys.valRememberMe) ?? ["", ""];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseCrashlytics.instance.setCustomKey('layout', 'SignInForm');
      // var notif = Provider.of<WelcomeLoginNotifier>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("--> login/widget/sign_in_form rememberMe:" + rememberMe.toString());
    print("--> login/widget/sign_in_form valRememberMe:" + valRememberMe.toString());

    // if (rememberMe) {
    //   var preEmail = valRememberMe[0] ?? "";
    //   var prePass = valRememberMe[1] ?? '';
    //   context.read<WelcomeLoginNotifier>().email = preEmail;
    //   context.read<WelcomeLoginNotifier>().password = prePass;
    //   context.read<WelcomeLoginNotifier>().emailController.text = preEmail;
    //   context.read<WelcomeLoginNotifier>().passwordController.text = prePass;
    //   context.read<WelcomeLoginNotifier>().buttonDisable();
    // }

    return Consumer<WelcomeLoginNotifier>(
      builder: (_, notifier, __) => Column(
        children: [
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
              fourPx,
              CustomTextWidget(
                textToDisplay: "${notifier.emailValidator(notifier.emailController.text)}",
                textAlign: TextAlign.start,
                textStyle: const TextStyle(color: Colors.red),
              ),
              twentyFourPx,
              CustomTextFormField(
                focusNode: notifier.passwordFocus,
                obscuringCharacter: '*',
                inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                inputAreaWidth: SizeConfig.screenWidth!,
                textEditingController: notifier.passwordController,
                style: Theme.of(context).textTheme.bodyText1,
                obscureText: notifier.hide,
                textInputType: TextInputType.text,
                onChanged: (v) => notifier.password = v,
                inputDecoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(right: 16, bottom: 16),
                  labelText: notifier.incorrect ? notifier.language.incorrectPassword : notifier.language.password,
                  labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: notifier.incorrect
                          ? Theme.of(context).colorScheme.error
                          : notifier.passwordFocus.hasFocus
                              ? Theme.of(context).colorScheme.primary
                              : null),
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
                        iconData: notifier.hide ? '${AssetPath.vectorPath}eye-off.svg' : '${AssetPath.vectorPath}eye.svg',
                      ),
                      onPressed: () => notifier.hide = !notifier.hide,
                    ),
                  ),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: notifier.passwordFocus.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface)),
                ),
                readOnly: notifier.isLoading
                    ? true
                    : notifier.loadingForObject(LoginNotifier.loadingForgotPasswordKey)
                        ? true
                        : false,
              ),
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
          Container(
            padding: EdgeInsets.all(15),
            width: SizeConfig.screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 8,
                        child: Container(
                          // color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifier.language.simpanInfoLogin ?? 'Simpan info login',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                notifier.language.keteranganSimpanInfoLogin ?? 'Gak perlu masukan lagi email dan kata sandi di perangkat ini',
                                style: TextStyle(color: Colors.black.withOpacity(0.4)),
                              )
                            ],
                          ),
                        )),
                    Expanded(
                        flex: 2,
                        child: Container(
                            alignment: Alignment.center,
                            child: Switch(
                              value: SharedPreference().readStorage(SpKeys.rememberMe) ?? false,
                              activeColor: kHyppePrimary,
                              onChanged: (bool value) {
                                print('--> login/widget/sign_in_form switch:rememberMe:' + value.toString());
                                setState(() {
                                  notifier.rememberMe = value;
                                  SharedPreference().writeStorage(SpKeys.rememberMe, value);
                                });
                              },
                            )))
                  ],
                )
              ],
            ),
          ),
          twentyPx,
          CustomElevatedButton(
            function: () {
              if (!notifier.isLoading) {
                if (notifier.email.isNotEmpty && notifier.password.isNotEmpty && notifier.emailValidator(notifier.emailController.text) == '') {
                  notifier.onClickLogin(context);
                }
              }
            },
            buttonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                notifier.isLoading
                    ? Theme.of(context).colorScheme.surface
                    : notifier.buttonDisable()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: notifier.isLoading
                ? const CustomLoading()
                : CustomTextWidget(
                    textToDisplay: notifier.language.logIn ?? 'Log In',
                    textStyle: notifier.buttonDisable() ? Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) : Theme.of(context).primaryTextTheme.button,
                  ),
            width: SizeConfig.screenWidth,
            height: 49 * SizeConfig.scaleDiagonal,
          ),
        ],
      ),
    );
  }
}
