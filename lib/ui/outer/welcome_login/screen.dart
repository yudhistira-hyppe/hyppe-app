import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_bottom.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_top.dart';
import 'package:move_to_background/move_to_background.dart';

class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'WelcomeLoginScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: GestureDetector(
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                width: SizeConfig.screenWidth,
                child: Column(
                  children: [
                    const PageTop(),
                    PageBottom(),
                  ],
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
