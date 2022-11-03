import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_agreement_demo_screen.dart';
import 'package:provider/provider.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CustomTextWidget(
          textToDisplay: context.watch<TranslateNotifierV2>().translate.endUserLicenseAgreement ?? '',
          textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: const UserAgreementDemoScreen(),
    );
  }
}
