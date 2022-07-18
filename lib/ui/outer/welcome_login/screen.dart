import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_bottom.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_top.dart';

class WelcomeLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Theme.of(context).colorScheme.secondary,
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: Column(
              children: [
                PageTop(),
                Expanded(child: PageBottom()),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
      },
    );
  }
}
