import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final Future<bool> Function()? onWillPopScope;
  final Function()? onKeyboardDisposal;
  final Function()? onBackPressed;
  final Widget child;
  const SignUpScreen({Key? key, required this.child, this.onBackPressed, this.onWillPopScope, this.onKeyboardDisposal}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SignUpScreen');
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: onWillPopScope,
      child: KeyboardDisposal(
        onTap: onKeyboardDisposal,
        child: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                child,
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 16),
                  child: GestureDetector(
                    onTap: onBackPressed,
                    child: const CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
