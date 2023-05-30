// ignore: unused_import
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:provider/provider.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Register');
    return Consumer<WelcomeLoginNotifier>(
      builder: (_, notifier, __) => Column(
        children: [
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
        ],
      ),
    );
  }
}
