import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class RecteangleVInput extends StatelessWidget {
  final bool obscureText;
  final int lengthPinCode;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const RecteangleVInput({
    Key? key,
    this.onCompleted,
    required this.onChanged,
    this.obscureText = false,
    required this.controller,
    required this.lengthPinCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'RecteangleVInput');
    final theme = Theme.of(context);

    return Consumer<PinAccountNotifier>(
      builder: (_, notifier, __) => PinCodeTextField(
        length: lengthPinCode,
        obscureText: obscureText,
        animationType: AnimationType.scale,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: 50,
          fieldWidth: 40,
          activeColor: notifier.matchingPin ? theme.colorScheme.primary : theme.colorScheme.error,
          inactiveColor: notifier.matchingPin ? theme.colorScheme.primary : theme.colorScheme.error,
          selectedColor: notifier.matchingPin ? theme.colorScheme.primary : theme.colorScheme.error,
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
          "Allowing to paste $text".logger();
          return true;
        },
        appContext: context,
      ),
    );
  }
}
