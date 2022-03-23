import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInText extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginNotifier>(
      builder: (_, notifier, __) => CustomTextWidget(
        textToDisplay: notifier.language.login!,
        textStyle: Theme.of(context).primaryTextTheme.headline5,
      ),
    );
  }
}
