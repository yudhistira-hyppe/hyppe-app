import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/register/content/register_form.dart';
import 'package:hyppe/ui/outer/sign_up/contents/register/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<RegisterNotifier>(
      builder: (_, notifier, __) => SignUpScreen(
        onBackPressed: () => notifier.onBackPressed(context),
        onWillPopScope: () async => notifier.onWillPopScope(context),
        child: const RegisterForm(),
      ),
    );
  }
}
