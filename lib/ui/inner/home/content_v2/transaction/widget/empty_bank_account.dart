import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class EmptyBankAccount extends StatelessWidget {
  final Widget? textWidget;
  const EmptyBankAccount({Key? key, this.textWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'EmptyBankAccount');
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: CustomIconWidget(
              defaultColor: false,
              iconData: '${AssetPath.vectorPath}no-Result-Found.svg',
            ),
          ),
          textWidget ?? Container(),
        ],
      ),
    );
  }
}
