import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/verification/widget/rectangle_input.dart';
import 'package:provider/provider.dart';

class CustomRectangleVInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PinAccountNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 200,
        child: Column(
          children: [
            RecteangleVInput(
              lengthPinCode: 4,
              controller: notifier.otpController,
              onCompleted: (w) {},
              onChanged: (val) {
                // notifier.pinChecking(context, val);
                // notifier.isOTPCodeFullFilled = notifier.pinController.text.length == 4;
              },
            ),
          ],
        ),
      ),
    );
  }
}
