import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_aggrement_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/notifier.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class UserAgreementTermCondition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<UserAgreementNotifier>(context);
    if (notifier.eula != null && notifier.eula?.data[0].eulaContent != null) {
      return DynamicWidgetBuilder.build(notifier.eula!.data[0].eulaContent!, context, DefaultClickListener())!;
    } else if (notifier.isLoading) {
      return const CustomLoading();
    } else {
      return UnconstrainedBox(
        child: Column(
          children: [
            TextButton(
              child: const Icon(Icons.refresh, size: 50, color: Colors.grey),
              onPressed: () => notifier.initEula(context),
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
