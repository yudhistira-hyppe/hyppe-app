import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CustomOTPFieldWidget extends StatelessWidget {
  final bool obscureText;
  final int lengthPinCode;
  final bool isWrong;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const CustomOTPFieldWidget({
    Key? key,
    this.onCompleted,
    required this.onChanged,
    required this.isWrong,
    this.obscureText = false,
    required this.controller,
    required this.lengthPinCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PinCodeTextField(
      length: lengthPinCode,
      obscureText: obscureText,
      animationType: AnimationType.scale,
      pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          fieldHeight: 50,
          fieldWidth: 50,
          activeColor: isWrong ? kHyppeBorderDanger : theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary,
          selectedColor: theme.colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderWidth: 1,
          fieldOuterPadding: const EdgeInsets.only(left: 5, right: 5)),
      textStyle:
          theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      animationDuration: const Duration(milliseconds: 200),
      controller: controller,
      onCompleted: onCompleted,
      onChanged: onChanged,
      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        return true;
      },
      appContext: context,
    );
  }
}
