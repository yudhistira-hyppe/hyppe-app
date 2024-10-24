import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/widget/sign_up_pin_top.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';

import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';

class SignUpPin extends StatefulWidget {
  final VerifyPageArgument arguments;

  const SignUpPin({Key? key, required this.arguments}) : super(key: key);

  @override
  _SignUpPinState createState() => _SignUpPinState();
}

class _SignUpPinState extends State<SignUpPin> with AfterFirstLayoutMixin {
  // late SignUpPinNotifier _notifier;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SignUpPin');
    final notifier = Provider.of<SignUpPinNotifier>(context, listen: false);
    notifier.initState(widget.arguments);
    // notifier.startTimers = true;
    // notifier.startTimer();
    // print(notifier.email);
    super.initState();
  }

  @override
  void dispose() {
    // _notifier.resetTimer();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // _notifier = Provider.of<SignUpPinNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => KeyboardDisposal(
        onTap: () => notifier.unFocusingNode(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () => notifier.onBackVerifiedEmail(),
              child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            ),
            automaticallyImplyLeading: false,
            title: CustomTextWidget(
              textToDisplay: notifier.language.verificationCode ?? '',
              textStyle: Theme.of(context).textTheme.headline6,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: (SizeConfig.screenHeight! + kToolbarHeight),
                  width: SizeConfig.screenWidth,
                  alignment: const Alignment(0.0, -0.4),
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: SignUpPinTop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
