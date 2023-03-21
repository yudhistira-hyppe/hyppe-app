import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_aggrement_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/notifier.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class UserAgreementPrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'UserAgreementPrivacyPolicy');
    final notifier = Provider.of<UserAgreementNotifier>(context);
    if (notifier.eula != null && notifier.eula?.data[1].eulaContent != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 26),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
        color: const Color(0xffEEEEEE),
        child: DynamicWidgetBuilder.build(notifier.eula?.data[1].eulaContent ?? '', context, DefaultClickListener()) ?? Container(),
      );
    } else if (notifier.isLoading) {
      return const CustomLoading();
    } else {
      return UnconstrainedBox(
        child: Column(
          children: [
            TextButton(
              onPressed: () => notifier.initEula(context),
              child: const Icon(Icons.refresh, size: 50, color: Colors.grey),
            ),
            CustomTextWidget(
              textToDisplay: notifier.language.refresh ?? '',
              textStyle: Theme.of(context).textTheme.bodyText1?.apply(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }
}
