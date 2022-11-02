import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/widget/rectangle_input.dart';
import 'package:provider/provider.dart';

class CustomRectangleInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 200,
        child: Column(
          children: [
            notifier.inCorrectCode ? CustomTextWidget(
              textToDisplay: notifier.language.incorrectCode,
              textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.error),
            ) : const SizedBox.shrink(),
            sixPx,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RectangleInput(
                    onKeyEvent: (value) => notifier.rawKeyEvent = value,
                    input: notifier.tec1,
                    focusNode: notifier.fn1,
                    onChanged: (v) {
                      notifier.input1 = v;
                      notifier.onTextInputRectangle();
                    }),
                RectangleInput(
                    onKeyEvent: (value) => notifier.rawKeyEvent = value,
                    input: notifier.tec2,
                    focusNode: notifier.fn2,
                    onChanged: (v) {
                      notifier.input2 = v;
                      notifier.onTextInputRectangle();
                    }),
                RectangleInput(
                    onKeyEvent: (value) => notifier.rawKeyEvent = value,
                    input: notifier.tec3,
                    focusNode: notifier.fn3,
                    onChanged: (v) {
                      notifier.input3 = v;
                      notifier.onTextInputRectangle();
                    }),
                RectangleInput(
                    onKeyEvent: (value) => notifier.rawKeyEvent = value,
                    input: notifier.tec4,
                    focusNode: notifier.fn4,
                    onChanged: (v) {
                      notifier.input4 = v;
                      notifier.onTextInputRectangle();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
