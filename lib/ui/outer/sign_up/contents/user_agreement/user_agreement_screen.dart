import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_agreement_demo_screen.dart';
import 'package:provider/provider.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'UserAgreementScreen');
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: CustomTextWidget(
          textStyle: theme.textTheme.subtitle1,
          textToDisplay: context.watch<TranslateNotifierV2>().translate.endUserLicenseAgreement ?? '',
        ),
      ),
      body: const UserAgreementDemoScreen(),
    );
  }
}
