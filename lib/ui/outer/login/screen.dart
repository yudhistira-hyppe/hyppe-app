import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/login/widget/sign_in_form.dart';
import 'package:hyppe/ui/outer/login/widget/sign_in_text.dart';
import 'package:hyppe/ui/outer/login/widget/sign_up_or_google.dart';

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
              child: Stack(
                children: [
                  Align(alignment: const Alignment(0.0, -0.85), child: SignInText()),
                  Transform.translate(
                    offset: Offset(0.0, SizeConfig.screenHeight! / 3.5),
                    child: SignInForm(),
                  ),
                  Transform.translate(
                    offset: Offset(0.0, SizeConfig.screenHeight! / 1.4),
                    child: const SignUpOrGoogle(),
                  ),
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
