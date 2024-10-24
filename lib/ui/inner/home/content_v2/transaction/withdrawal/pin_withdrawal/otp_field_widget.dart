import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinWithdrawal extends StatelessWidget {
  final bool obscureText;
  final int lengthPinCode;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final String? msgError;

  const PinWithdrawal({
    Key? key,
    this.onCompleted,
    required this.onChanged,
    this.obscureText = false,
    required this.controller,
    required this.lengthPinCode,
    this.msgError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PinWithdrawal');
    final theme = Theme.of(context);

    return SizedBox(
      width: 240,
      child: PinCodeTextField(
          length: lengthPinCode,
          obscureText: obscureText,
          animationType: AnimationType.scale,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            activeColor: msgError == ''
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            inactiveColor: msgError == ''
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            selectedColor: msgError == ''
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          textStyle: theme.textTheme.headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
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
            textStyle: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
          ),
          blinkWhenObscuring: true,
          obscuringCharacter: '●'),
    );
  }
}
