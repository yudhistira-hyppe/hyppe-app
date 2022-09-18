import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/widget/otp_field_widget.dart';
import 'package:provider/provider.dart';

class CustomRectangleInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PinAccountNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 240,
        child: Column(
          children: [
            OtpFieldWidget(
              lengthPinCode: 6,
              controller: !notifier.checkPin && !notifier.confirm
                  ? notifier.pin3Controller
                  : !notifier.confirm
                      ? notifier.pin1Controller
                      : notifier.pin2Controller,
              onCompleted: (w) {},
              onChanged: (val) {
                notifier.pinChecking(context, val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
