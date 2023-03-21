import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/widget/otp_field_widget.dart';
import 'package:provider/provider.dart';

class CustomRectangleInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const CustomRectangleInput(this.controller, {Key? key, required this.onChanged}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CustomRectangleInput');
    return Consumer<PinAccountNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 240,
        child: Column(
          children: [
            OtpFieldWidget(
              lengthPinCode: 6,
              controller: controller,
              onCompleted: onChanged,
              onChanged: (e) {},
            ),
          ],
        ),
      ),
    );
  }
}
