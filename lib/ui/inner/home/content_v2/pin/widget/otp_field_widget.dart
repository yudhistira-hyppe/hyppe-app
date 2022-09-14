import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpFieldWidget extends StatelessWidget {
  final bool obscureText;
  final int lengthPinCode;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const OtpFieldWidget({
    Key? key,
    this.onCompleted,
    required this.onChanged,
    this.obscureText = false,
    required this.controller,
    required this.lengthPinCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PinAccountNotifier>(
      builder: (_, notifier, __) => PinCodeTextField(
          length: lengthPinCode,
          obscureText: obscureText,
          animationType: AnimationType.scale,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            activeColor: notifier.matchingPin ? theme.colorScheme.primaryVariant : theme.colorScheme.error,
            inactiveColor: notifier.matchingPin ? theme.colorScheme.primaryVariant : theme.colorScheme.error,
            selectedColor: notifier.matchingPin ? theme.colorScheme.primaryVariant : theme.colorScheme.error,
          ),
          textStyle: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          animationDuration: const Duration(milliseconds: 200),
          controller: controller,
          onCompleted: onCompleted,
          onChanged: onChanged,
          autoDisposeControllers: false,
          beforeTextPaste: (text) {
            print("Allowing to paste $text");
            return true;
          },
          appContext: context,
          hintCharacter: '●',
          obscuringWidget: CustomTextWidget(
            textToDisplay: '●',
            textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onBackground),
          ),
          blinkWhenObscuring: true,
          obscuringCharacter: '●'),
    );
  }
}
