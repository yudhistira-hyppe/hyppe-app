import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:hyppe/ui/outer/login/widget/sign_in_form.dart';
import 'package:hyppe/ui/outer/login/widget/sign_in_text.dart';
import 'package:hyppe/ui/outer/login/widget/sign_up_or_google.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Consumer<LoginNotifier>(
                        builder: (_, notifier, __) => GestureDetector(
                          onTap: () => notifier.tapBack(),
                          child: const CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                        ),
                      ),
                    ),
                  ),
                  thirtySixPx,
                  Align(alignment: const Alignment(0.0, -0.85), child: SignInText()),
                  sixtyFourPx,
                  SignInForm(),
                  sixtyFourPx,
                  const SignUpOrGoogle(),
                ],
              ),
            ),
          ),
        ),
        // floatingActionButton: Selector<LoginNotifier, bool>(
        //     builder: (_, value, __) {
        //       return Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           Text('Prod Mode'),
        //           Checkbox(
        //             checkColor: Colors.white,
        //             activeColor: Colors.purple,
        //             value: value,
        //             onChanged: (v) => context.read<LoginNotifier>().baseEnv = v!,
        //           ),
        //         ],
        //       );
        //     },
        //     selector: (_, selector) => selector.baseEnv),
      ),
      onTap: () {
        if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
      },
    );
  }
}
